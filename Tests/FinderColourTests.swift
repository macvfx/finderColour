import XCTest
@testable import FinderColours

final class FinderColourTests: XCTestCase {
    func testFinderColourIndexesMatchFinder() {
        XCTAssertEqual(FinderColour.none.rawValue, 0)
        XCTAssertEqual(FinderColour.grey.rawValue, 1)
        XCTAssertEqual(FinderColour.green.rawValue, 2)
        XCTAssertEqual(FinderColour.purple.rawValue, 3)
        XCTAssertEqual(FinderColour.blue.rawValue, 4)
        XCTAssertEqual(FinderColour.yellow.rawValue, 5)
        XCTAssertEqual(FinderColour.red.rawValue, 6)
        XCTAssertEqual(FinderColour.orange.rawValue, 7)
    }

    func testVisibleNamesUseCanadianSpelling() {
        XCTAssertEqual(FinderColour.grey.name, "Grey")
        XCTAssertEqual(FinderColour.grey.finderTagName, "Gray")
        XCTAssertEqual(FinderColour.green.finderTagValue, "Green\n2")
        XCTAssertEqual(FinderColour.allCases.count, 8)
    }

    func testModernFinderTagRoundTrip() throws {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: folder,
            withIntermediateDirectories: false
        )
        defer { try? FileManager.default.removeItem(at: folder) }

        try FinderMetadata.setColour(.green, at: [folder.path])
        XCTAssertEqual(try FinderMetadata.readColours(at: [folder.path]), [.green])
        XCTAssertEqual(
            try folder.resourceValues(forKeys: [.tagNamesKey]).tagNames,
            ["Green"]
        )

        try FinderMetadata.setColour(.none, at: [folder.path])
        XCTAssertEqual(try FinderMetadata.readColours(at: [folder.path]), [.none])
    }

    func testPublicSupportLinks() {
        XCTAssertEqual(FinderColoursSupportLinks.website.host, "code.matx.ca")
        XCTAssertEqual(
            FinderColoursSupportLinks.userGuide.absoluteString,
            "https://github.com/macvfx/finderColour/blob/main/USER-GUIDE.md"
        )
    }
}
