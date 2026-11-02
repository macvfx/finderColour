import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var model: FinderColoursViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isDropTargeted = false
    @State private var heroColour: FinderColour = .blue
    @State private var showSuccess = false
    @State private var hasRunIntro = false

    var body: some View {
        VStack(spacing: 18) {
            header
            dropZone

            if !model.items.isEmpty {
                itemList
                colourControls
            }

            statusBar
        }
        .padding(24)
        .background(Color(nsColor: .windowBackgroundColor))
        .task {
            await runIntroAnimation()
        }
        .onChange(of: model.successfulApplyCount) { _ in
            guard let colour = model.lastAppliedColour else { return }
            animateSuccessfulApply(colour)
        }
    }

    private var header: some View {
        VStack(spacing: 5) {
            HStack(spacing: 8) {
                Text("Finder")
                    .foregroundStyle(.primary)
                Text("Colours")
                    .foregroundStyle(titleGradient)
            }
            .font(.largeTitle.bold())
            Text("Read or change the Finder colour on dropped files and folders.")
                .foregroundStyle(.secondary)
        }
    }

    private var dropZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isDropTargeted ? Color.accentColor.opacity(0.14) : Color.secondary.opacity(0.07))
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isDropTargeted ? Color.accentColor : Color.secondary.opacity(0.35),
                    style: StrokeStyle(lineWidth: 2, dash: [7])
                )

            VStack(spacing: 10) {
                AnimatedFolderHero(
                    colour: heroColour,
                    isTargeted: isDropTargeted,
                    showSuccess: showSuccess,
                    reduceMotion: reduceMotion
                )
                Text("Drop files or folders here")
                    .font(.headline)
                Text("You can drop several items at once. Folders are not processed recursively.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 145)
        .onDrop(
            of: [UTType.fileURL.identifier],
            isTargeted: $isDropTargeted,
            perform: receiveDrop(providers:)
        )
    }

    private var itemList: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Dropped Items")
                    .font(.headline)
                Text("\(model.items.count)")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Refresh") { model.refresh() }
                    .disabled(model.isWorking)
                Button("Clear List") { model.clearList() }
                    .disabled(model.isWorking)
            }

            List(model.items) { item in
                ItemRow(item: item) {
                    model.remove(item)
                }
            }
            .listStyle(.inset)
            .frame(minHeight: 145)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.18))
            }
        }
    }

    private var colourControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Apply to All Dropped Items")
                .font(.headline)

            HStack(spacing: 9) {
                ForEach(FinderColour.allCases) { colour in
                    ColourButton(colour: colour) {
                        model.apply(colour)
                    }
                    .disabled(model.isWorking)
                }
            }
        }
    }

    private var titleGradient: LinearGradient {
        LinearGradient(
            colors: [.orange, .red, .yellow, .blue, .purple, .green],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    @MainActor
    private func runIntroAnimation() async {
        guard !hasRunIntro else { return }
        hasRunIntro = true
        guard !reduceMotion else { return }

        let sweep: [FinderColour] = [.orange, .red, .yellow, .purple, .green, .blue]
        for colour in sweep {
            try? await Task.sleep(nanoseconds: 95_000_000)
            withAnimation(.easeInOut(duration: 0.15)) {
                heroColour = colour
            }
        }
    }

    private func animateSuccessfulApply(_ colour: FinderColour) {
        let displayedColour = colour == .none ? FinderColour.blue : colour
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            heroColour = displayedColour
            showSuccess = true
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 900_000_000)
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
                showSuccess = false
            }
        }
    }

    private var statusBar: some View {
        VStack(alignment: .leading, spacing: 7) {
            Divider()
            HStack(spacing: 8) {
                if model.isWorking {
                    ProgressView()
                        .controlSize(.small)
                }
                Text(model.statusMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            if let errorMessage = model.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }
        }
    }

    private func receiveDrop(providers: [NSItemProvider]) -> Bool {
        let matchingProviders = providers.filter {
            $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
        }
        guard !matchingProviders.isEmpty else { return false }

        let group = DispatchGroup()
        let lock = NSLock()
        var droppedURLs: [URL] = []

        for provider in matchingProviders {
            group.enter()
            provider.loadItem(
                forTypeIdentifier: UTType.fileURL.identifier,
                options: nil
            ) { item, _ in
                defer { group.leave() }

                let url: URL?
                if let data = item as? Data {
                    url = URL(dataRepresentation: data, relativeTo: nil)
                } else if let droppedURL = item as? URL {
                    url = droppedURL
                } else if let droppedURL = item as? NSURL {
                    url = droppedURL as URL
                } else {
                    url = nil
                }

                guard let url else { return }
                lock.lock()
                droppedURLs.append(url)
                lock.unlock()
            }
        }

        group.notify(queue: .main) {
            model.add(droppedURLs)
        }
        return true
    }
}

private struct AnimatedFolderHero: View {
    let colour: FinderColour
    let isTargeted: Bool
    let showSuccess: Bool
    let reduceMotion: Bool

    private let dotColours: [Color] = [
        .orange, .red, .yellow, .blue, .purple, .green,
        Color(nsColor: .systemGray)
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Image(systemName: "folder.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(colour.colour)
                    .shadow(color: colour.colour.opacity(0.28), radius: 8, y: 4)

                HStack(spacing: 3) {
                    ForEach(Array(dotColours.enumerated()), id: \.offset) { _, dotColour in
                        Circle()
                            .fill(dotColour)
                            .frame(width: 6, height: 6)
                            .overlay(Circle().stroke(.white.opacity(0.45), lineWidth: 0.5))
                    }
                }
                .offset(y: 10)
            }
            .frame(width: 92, height: 72)
            .scaleEffect(isTargeted && !reduceMotion ? 1.08 : 1)

            if showSuccess {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .green)
                    .background(Circle().fill(Color(nsColor: .windowBackgroundColor)))
                    .transition(.scale.combined(with: .opacity))
                    .offset(x: 4, y: 2)
            }
        }
        .frame(width: 104, height: 78)
        .animation(
            reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.68),
            value: isTargeted
        )
        .accessibilityHidden(true)
    }
}

private struct ItemRow: View {
    let item: DroppedItem
    let remove: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: item.path))
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .lineLimit(1)
                Text(item.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            if let colour = item.finderColour {
                FinderColourBadge(colour: colour)
            } else {
                Text("Reading…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button(action: revealInFinder) {
                Label("Reveal", systemImage: "magnifyingglass")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.borderless)
            .help("Reveal \(item.name) in Finder")

            Button(action: remove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Remove from list")
        }
        .padding(.vertical, 3)
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: revealInFinder)
        .help("Double-click to reveal in Finder")
    }

    private func revealInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([item.url])
    }
}

private struct FinderColourBadge: View {
    let colour: FinderColour

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(colour.colour)
                .overlay {
                    if colour == .none {
                        Circle()
                            .stroke(Color.secondary, lineWidth: 1)
                    }
                }
                .frame(width: 11, height: 11)
            Text(colour.name)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.09), in: Capsule())
    }
}

private struct ColourButton: View {
    let colour: FinderColour
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(colour == .none ? Color.clear : colour.colour)
                        .frame(width: 27, height: 27)
                    Circle()
                        .stroke(Color.secondary.opacity(0.55), lineWidth: colour == .none ? 1.5 : 0)
                    if colour == .none {
                        Image(systemName: "slash")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                Text(colour.name)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 7)
        .background(Color.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.16))
        }
        .help("Apply \(colour.name) to all dropped items")
    }
}
