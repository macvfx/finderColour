import AppKit
import SwiftUI

@main
struct FinderColoursApp: App {
    @StateObject private var model = FinderColoursViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 680, minHeight: 560)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .appInfo) {
                FinderColoursOpenWindowButton(
                    label: "About Finder Colours",
                    windowID: "about"
                )
            }

            CommandGroup(after: .pasteboard) {
                Button("Refresh Colours") {
                    model.refresh()
                }
                .keyboardShortcut("r", modifiers: .command)
                .disabled(model.items.isEmpty || model.isWorking)

                Button("Clear List") {
                    model.clearList()
                }
                .keyboardShortcut(.delete, modifiers: [.command])
                .disabled(model.items.isEmpty || model.isWorking)
            }

            CommandGroup(replacing: .help) {
                FinderColoursOpenWindowButton(
                    label: "Finder Colours Help",
                    windowID: "help"
                )
                .keyboardShortcut("?", modifiers: [.command])

                Link(
                    "Full User Guide",
                    destination: FinderColoursSupportLinks.userGuide
                )

                Divider()

                Link(
                    "Visit code.matx.ca",
                    destination: FinderColoursSupportLinks.website
                )
            }
        }

        Window("About Finder Colours", id: "about") {
            AboutView()
                .frame(width: 420, height: 430)
        }
        .windowResizability(.contentSize)

        Window("Finder Colours Help", id: "help") {
            HelpView()
                .frame(minWidth: 560, minHeight: 540)
        }
        .windowResizability(.contentSize)
    }
}

private struct FinderColoursOpenWindowButton: View {
    let label: String
    let windowID: String
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button(label) {
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: windowID)
        }
    }
}
