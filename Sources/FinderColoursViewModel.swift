import AppKit
import Foundation

@MainActor
final class FinderColoursViewModel: ObservableObject {
    @Published private(set) var items: [DroppedItem] = []
    @Published private(set) var isWorking = false
    @Published private(set) var statusMessage = "Drop files or folders to begin."
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastAppliedColour: FinderColour?
    @Published private(set) var successfulApplyCount = 0

    func add(_ urls: [URL]) {
        var knownPaths = Set(items.map(\.path))
        var addedCount = 0

        for url in urls {
            let normalisedURL = url.standardizedFileURL
            guard FileManager.default.fileExists(atPath: normalisedURL.path) else {
                continue
            }
            guard knownPaths.insert(normalisedURL.path).inserted else {
                continue
            }
            items.append(DroppedItem(url: normalisedURL, finderColour: nil))
            addedCount += 1
        }

        if addedCount > 0 {
            refresh()
        } else if !urls.isEmpty {
            statusMessage = "Those items are already in the list or no longer exist."
        }
    }

    func remove(_ item: DroppedItem) {
        items.removeAll { $0.id == item.id }
        statusMessage = items.isEmpty
            ? "Drop files or folders to begin."
            : "\(items.count) item\(items.count == 1 ? "" : "s") ready."
    }

    func clearList() {
        items.removeAll()
        errorMessage = nil
        statusMessage = "Drop files or folders to begin."
    }

    func refresh() {
        guard !items.isEmpty, !isWorking else { return }

        let paths = items.map(\.path)
        isWorking = true
        errorMessage = nil
        statusMessage = "Reading Finder colours…"

        Task {
            do {
                let colours = try await Task.detached(priority: .userInitiated) {
                    try FinderMetadata.readColours(at: paths)
                }.value

                for index in items.indices where index < colours.count {
                    items[index].finderColour = colours[index]
                }
                statusMessage = "Read \(items.count) item\(items.count == 1 ? "" : "s")."
            } catch {
                show(error)
            }
            isWorking = false
        }
    }

    func apply(_ colour: FinderColour) {
        guard !items.isEmpty, !isWorking else { return }

        let paths = items.map(\.path)
        isWorking = true
        errorMessage = nil
        statusMessage = "Applying \(colour.name)…"

        Task {
            do {
                try await Task.detached(priority: .userInitiated) {
                    try FinderMetadata.setColour(colour, at: paths)
                }.value

                for index in items.indices {
                    items[index].finderColour = colour
                }
                lastAppliedColour = colour
                successfulApplyCount += 1
                statusMessage = colour == .none
                    ? "Cleared the colour from \(items.count) item\(items.count == 1 ? "" : "s")."
                    : "Applied \(colour.name) to \(items.count) item\(items.count == 1 ? "" : "s")."
            } catch {
                show(error)
            }
            isWorking = false
        }
    }

    private func show(_ error: Error) {
        errorMessage = error.localizedDescription
        statusMessage = "The Finder operation did not complete."
    }
}
