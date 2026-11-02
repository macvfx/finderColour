import Foundation

struct DroppedItem: Identifiable, Equatable {
    let url: URL
    var finderColour: FinderColour?

    var id: String { url.path }
    var name: String { url.lastPathComponent }
    var path: String { url.path }
}
