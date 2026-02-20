import Foundation
@testable import Clip

// MARK: - Test Helpers

enum TestError: Error {
    case failed(String)
}

func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "", file: String = #file, line: Int = #line) {
    if a != b {
        print("FAIL [\(file):\(line)] assertEqual: \(a) != \(b) \(message)")
    }
}

func assertTrue(_ condition: Bool, _ message: String = "", file: String = #file, line: Int = #line) {
    if !condition {
        print("FAIL [\(file):\(line)] assertTrue: \(message)")
    }
}

func assertFalse(_ condition: Bool, _ message: String = "", file: String = #file, line: Int = #line) {
    if condition {
        print("FAIL [\(file):\(line)] assertFalse: \(message)")
    }
}

// MARK: - ClipboardService Tests

func runClipboardServiceTests() async {
    let service = ClipboardService()

    // Adding items
    print("Testing addItem...")
    let item1 = ClipItem(content: .text("Hello, world"))
    let item2 = ClipItem(content: .text("Second item"))
    let item3 = ClipItem(content: .url(URL(string: "https://example.com")!))

    await service.addItem(item1)
    await service.addItem(item2)
    await service.addItem(item3)

    var items = await service.items
    assertEqual(items.count, 3, "Should have 3 items")

    // Items are inserted at the position after pinned items, so newest unpinned is at index 0.
    assertEqual(items[0].content, .url(URL(string: "https://example.com")!), "Newest item first")

    // Filtering
    print("Testing filteredItems...")
    let textResults = await service.filteredItems(query: "hello")
    assertEqual(textResults.count, 1, "Should match 1 text item")

    let urlResults = await service.filteredItems(query: "example")
    assertEqual(urlResults.count, 1, "Should match 1 URL item")

    let noResults = await service.filteredItems(query: "nonexistent")
    assertEqual(noResults.count, 0, "Should match no items")

    let allResults = await service.filteredItems(query: "")
    assertEqual(allResults.count, 3, "Empty query returns all items")

    // Pinning
    print("Testing togglePin...")
    await service.togglePin(item1.id)
    items = await service.items
    let pinned = items.first { $0.id == item1.id }
    assertTrue(pinned?.isPinned == true, "Item should be pinned")

    // Pinned items sort to front.
    assertTrue(items[0].isPinned, "First item should be pinned")

    // Toggle back.
    await service.togglePin(item1.id)
    items = await service.items
    let unpinned = items.first { $0.id == item1.id }
    assertTrue(unpinned?.isPinned == false, "Item should be unpinned")

    // Remove item
    print("Testing removeItem...")
    await service.removeItem(item2.id)
    items = await service.items
    assertEqual(items.count, 2, "Should have 2 items after removal")
    assertFalse(items.contains { $0.id == item2.id }, "Removed item should not exist")

    // Clear unpinned
    print("Testing clearUnpinned...")
    await service.togglePin(item1.id)
    await service.clearUnpinned()
    items = await service.items
    assertEqual(items.count, 1, "Only pinned item should remain")
    assertTrue(items[0].isPinned, "Remaining item should be pinned")

    // Clear all
    print("Testing clearAll...")
    await service.clearAll()
    items = await service.items
    assertEqual(items.count, 0, "All items should be cleared")

    // Max items limit
    print("Testing max items limit...")
    let freshService = ClipboardService()
    for i in 0..<60 {
        let item = ClipItem(content: .text("Item \(i)"))
        await freshService.addItem(item)
    }
    items = await freshService.items
    assertEqual(items.count, ClipboardService.maxItems, "Should not exceed max items")

    // Image items
    print("Testing image items...")
    let imageService = ClipboardService()
    let imageData = Data(repeating: 0xFF, count: 1024)
    let imageItem = ClipItem(content: .image(imageData))
    await imageService.addItem(imageItem)
    items = await imageService.items
    assertEqual(items.count, 1, "Should have 1 image item")

    if case .image(let data) = items[0].content {
        assertEqual(data.count, 1024, "Image data should be preserved")
    } else {
        print("FAIL: Expected image content")
    }

    print("ClipboardService tests complete.")
}
