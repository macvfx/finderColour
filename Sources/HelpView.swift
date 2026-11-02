import SwiftUI

struct HelpView: View {
    private enum Topic: String, CaseIterable, Identifiable {
        case quickStart = "Quick Start"
        case colours = "Colours & Tags"
        case troubleshooting = "Privacy & Help"

        var id: String { rawValue }
    }

    @Environment(\.dismiss) private var dismiss
    @State private var topic: Topic = .quickStart

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Finder Colours Help")
                        .font(.title2.weight(.semibold))
                    Text("Drop items, read their Finder colours, and change them without navigating through Finder menus.")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(20)

            Picker("Help Topic", selection: $topic) {
                ForEach(Topic.allCases) { topic in
                    Text(topic.rawValue).tag(topic)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    switch topic {
                    case .quickStart:
                        quickStart
                    case .colours:
                        coloursAndTags
                    case .troubleshooting:
                        privacyAndHelp
                    }

                    Divider()

                    HStack(spacing: 8) {
                        Image(systemName: "book")
                        Link(
                            "Full User Guide",
                            destination: FinderColoursSupportLinks.userGuide
                        )
                        Spacer()
                        Link(
                            "code.matx.ca",
                            destination: FinderColoursSupportLinks.website
                        )
                    }
                    .font(.caption)
                }
                .padding(20)
            }
        }
    }

    private var quickStart: some View {
        VStack(alignment: .leading, spacing: 16) {
            HelpSection(title: "1. Drop items", icon: "square.and.arrow.down") {
                Text("Drag one or more files or folders into the dashed drop area. The app reads each item's current Finder colour automatically.")
                Text("Dropped folders are treated as individual items. Their contents are not processed recursively.")
            }

            HelpSection(title: "2. Choose a colour", icon: "paintpalette.fill") {
                Text("Choose **None**, **Orange**, **Red**, **Yellow**, **Blue**, **Purple**, **Green**, or **Grey**. The choice applies to every item currently in the list.")
                Text("Wait for the confirmation checkmark before closing the app or moving an item.")
            }

            HelpSection(title: "3. Check the result", icon: "magnifyingglass") {
                Text("Click **Reveal** beside an item, or double-click its row, to select it in Finder.")
                Text("Use **Refresh** (⌘R) if a tag was changed outside the app. **Clear List** removes items from this window without changing their tags.")
            }
        }
    }

    private var coloursAndTags: some View {
        VStack(alignment: .leading, spacing: 16) {
            HelpSection(title: "Modern Finder tags", icon: "tag.fill") {
                Text("Finder Colours uses the same named colour-tag metadata that Finder uses. This produces the coloured tag indicator and, on supported macOS versions, the coloured folder appearance.")
                Text("The app presents the Canadian spelling **Grey** while using Finder's standard internal tag name.")
            }

            HelpSection(title: "One standard colour at a time", icon: "exclamationmark.triangle") {
                Text("Applying a colour replaces the item's existing Finder tag list with that one standard colour tag. Choosing **None** removes all Finder tags from the item.")
                Text("If you use several custom or keyword tags on the same item, manage those tags in Finder instead.")
            }

            HelpSection(title: "Filesystems", icon: "externaldrive") {
                Text("Tag support depends on the destination filesystem and server. Some network shares, removable formats, or permission settings may refuse or fail to retain Finder metadata.")
            }
        }
    }

    private var privacyAndHelp: some View {
        VStack(alignment: .leading, spacing: 16) {
            HelpSection(title: "Privacy", icon: "hand.raised.fill") {
                Text("All tag reads and changes happen locally through macOS Foundation file metadata APIs.")
                Text("Finder Colours does not upload file names, paths, tag names, file contents, usage information, or diagnostics. It has no account, analytics, updater, or background service.")
            }

            HelpSection(title: "If a colour will not change", icon: "wrench.and.screwdriver") {
                Text("Confirm the item still exists and that your account can modify it. Try the same tag in Finder to check whether the filesystem supports Finder tags.")
                Text("Use **Refresh** after changing tags in Finder. If the problem is isolated to a server or drive, test a disposable local folder for comparison.")
            }

            HelpSection(title: "Reduced animation", icon: "figure.walk.motion") {
                Text("The short opening and confirmation animations respect **System Settings → Accessibility → Display → Reduce motion**.")
            }
        }
    }
}

private struct HelpSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
            content
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
