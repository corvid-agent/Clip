import Foundation
@testable import Clip

// MARK: - Model Tests

func runModelTests() {
    // ClipContent equality
    print("Testing ClipContent equality...")
    let textA = ClipContent.text("hello")
    let textB = ClipContent.text("hello")
    let textC = ClipContent.text("world")
    assertTrue(textA == textB, "Same text should be equal")
    assertTrue(textA != textC, "Different text should not be equal")

    let urlA = ClipContent.url(URL(string: "https://example.com")!)
    let urlB = ClipContent.url(URL(string: "https://example.com")!)
    let urlC = ClipContent.url(URL(string: "https://other.com")!)
    assertTrue(urlA == urlB, "Same URL should be equal")
    assertTrue(urlA != urlC, "Different URLs should not be equal")

    let imgA = ClipContent.image(Data([0x01, 0x02]))
    let imgB = ClipContent.image(Data([0x01, 0x02]))
    let imgC = ClipContent.image(Data([0x03]))
    assertTrue(imgA == imgB, "Same image data should be equal")
    assertTrue(imgA != imgC, "Different image data should not be equal")

    assertTrue(textA != urlA, "Different content types should not be equal")

    // ClipItem creation
    print("Testing ClipItem creation...")
    let item = ClipItem(content: .text("test content"))
    assertFalse(item.isPinned, "Should default to not pinned")
    assertEqual(item.typeLabel, "text")
    assertEqual(item.iconName, "doc.text")

    let urlItem = ClipItem(content: .url(URL(string: "https://example.com")!))
    assertEqual(urlItem.typeLabel, "url")
    assertEqual(urlItem.iconName, "link")

    let imageItem = ClipItem(content: .image(Data(repeating: 0, count: 2048)))
    assertEqual(imageItem.typeLabel, "image")
    assertEqual(imageItem.iconName, "photo")

    // Preview text
    print("Testing preview text...")
    let shortText = ClipItem(content: .text("short"))
    assertEqual(shortText.preview, "short")

    let longText = ClipItem(content: .text(String(repeating: "a", count: 200)))
    assertTrue(longText.preview.count <= 83, "Preview should be truncated") // 80 + "..."
    assertTrue(longText.preview.hasSuffix("..."), "Truncated preview should end with ...")

    let urlPreview = ClipItem(content: .url(URL(string: "https://example.com/path")!))
    assertEqual(urlPreview.preview, "https://example.com/path")

    let imagePreview = ClipItem(content: .image(Data(repeating: 0, count: 5120)))
    assertEqual(imagePreview.preview, "Image (5 KB)")

    // Search matching
    print("Testing search matching...")
    let searchItem = ClipItem(content: .text("Hello World"))
    assertTrue(searchItem.matches("hello"), "Should match case-insensitive")
    assertTrue(searchItem.matches("WORLD"), "Should match case-insensitive")
    assertFalse(searchItem.matches("xyz"), "Should not match unrelated query")

    let searchURL = ClipItem(content: .url(URL(string: "https://github.com")!))
    assertTrue(searchURL.matches("github"), "URL should match domain")
    assertFalse(searchURL.matches("gitlab"), "URL should not match wrong domain")

    let searchImage = ClipItem(content: .image(Data()))
    assertTrue(searchImage.matches("image"), "Image should match 'image'")
    assertFalse(searchImage.matches("text"), "Image should not match 'text'")

    // ClipItem equality
    print("Testing ClipItem equality...")
    let id = UUID()
    let date = Date()
    let itemA = ClipItem(id: id, content: .text("same"), timestamp: date, isPinned: false)
    let itemB = ClipItem(id: id, content: .text("same"), timestamp: date, isPinned: false)
    assertTrue(itemA == itemB, "Items with same properties should be equal")

    let itemC = ClipItem(content: .text("same"), isPinned: false)
    assertTrue(itemA != itemC, "Items with different IDs should not be equal")

    // Relative time
    print("Testing relativeTime...")
    let recentItem = ClipItem(content: .text("recent"), timestamp: Date())
    assertEqual(recentItem.relativeTime, "now")

    let oldItem = ClipItem(content: .text("old"), timestamp: Date().addingTimeInterval(-3600))
    assertEqual(oldItem.relativeTime, "1h ago")

    let dayOldItem = ClipItem(content: .text("day"), timestamp: Date().addingTimeInterval(-86400))
    assertEqual(dayOldItem.relativeTime, "1d ago")

    let minuteItem = ClipItem(content: .text("minute"), timestamp: Date().addingTimeInterval(-120))
    assertEqual(minuteItem.relativeTime, "2m ago")

    print("Model tests complete.")
}
