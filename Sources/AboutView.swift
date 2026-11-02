import AppKit
import SwiftUI

struct AboutView: View {
    @Environment(\.openWindow) private var openWindow

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }

    var body: some View {
        VStack(spacing: 15) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 92, height: 92)
                .accessibilityLabel("Finder Colours app icon")

            Text("Finder Colours")
                .font(.title2.weight(.semibold))

            Text("Version \(version) (\(build))")
                .foregroundStyle(.secondary)

            Text("A local macOS utility for reading and changing Finder colour tags on dropped files and folders.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Label(
                "Works locally. It does not upload file names, paths, tags, or file contents.",
                systemImage: "hand.raised.fill"
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 9))

            HStack(spacing: 12) {
                Button {
                    openWindow(id: "help")
                } label: {
                    Label("Help", systemImage: "questionmark.circle")
                }
                .buttonStyle(.bordered)

                Link(
                    "User Guide",
                    destination: FinderColoursSupportLinks.userGuide
                )
                .buttonStyle(.bordered)
            }

            Link("code.matx.ca", destination: FinderColoursSupportLinks.website)
                .font(.caption)
        }
        .padding(26)
    }
}
