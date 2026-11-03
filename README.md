# Finder Colours

Finder Colours is a small native macOS utility for reading and changing Finder
colour tags. Drop files or folders into its window, review their current
colours, apply one standard colour to the list, and reveal an item in Finder to
inspect the result.

The interface uses Canadian spelling while accepting both `grey` and `gray` in
the companion shell script.

## Features

- Accepts one or many files and folders in a single drop.
- Reads modern Finder colour-tag metadata.
- Applies None, Orange, Red, Yellow, Blue, Purple, Green, or Grey.
- Reveals any listed item in Finder from a button or double-click.
- Treats a dropped folder as one item; it never changes its contents
  recursively.
- Includes a Reduce Motion-aware opening and success animation.
- Includes the `finder-labels.sh` command-line companion.
- Runs locally without an account, analytics, updater, or background service.

## Important tag behaviour

Finder items can carry several named tags. Finder Colours intentionally models
one standard colour at a time:

- Applying a colour replaces the item's existing Finder tag list with that one
  standard colour tag.
- Applying **None** removes all Finder tags from the item.
- **Clear List** only clears the app window; it does not alter Finder tags.

Use Finder itself when an item must retain several custom or keyword tags.

## Modern tags and legacy labels

Finder's modern tag numbers and its older AppleScript `label index` use
different colour orders. Legacy label actions can produce a coloured dot while
leaving a folder's blue icon unchanged; Finder's modern named-tag action can
also tint the folder icon on supported macOS versions. Removing and reapplying
a colour in Finder rewrites it through that modern path.

Finder Colours and the included shell script use the modern tag system. See
[Modern tags versus legacy labels](USER-GUIDE.md#modern-tags-versus-legacy-labels)
for the complete side-by-side number table and behaviour explanation.

## Privacy

Tag reads and changes happen locally through macOS Foundation file metadata
APIs. Finder Colours does not upload file names, paths, tags, contents, usage
information, or diagnostics. The `code.matx.ca` and User Guide links open only
when selected.

See the [User Guide](USER-GUIDE.md) for complete operation, privacy details,
filesystem limitations, and troubleshooting.

## Requirements

- macOS 13 or later
- Xcode and [XcodeGen](https://github.com/yonaskolb/XcodeGen) to regenerate the
  checked-in project

## Build from source

```sh
xcodegen generate
xcodebuild \
  -project FinderColours.xcodeproj \
  -scheme FinderColours \
  -configuration Debug \
  -derivedDataPath Build \
  build
```

Open `FinderColours.xcodeproj` in Xcode for normal development. Signing teams,
certificates, provisioning profiles, notarization credentials, local build
outputs, and packaged apps are intentionally not stored in this repository.

## Tests

```sh
xcodebuild \
  -project FinderColours.xcodeproj \
  -scheme FinderColours \
  -configuration Debug \
  -derivedDataPath Build \
  CODE_SIGNING_ALLOWED=NO \
  test
```

Tests cover the Finder colour-number mapping, Canadian display spelling,
modern tag write/read/clear round trips, and public support links.

## Command-line companion

```sh
./finder-labels.sh colours
./finder-labels.sh get "/Users/example/Example_Project"
./finder-labels.sh set green "/Users/example/Example_Project"
./finder-labels.sh clear "/Users/example/Example_Project"
```

Run `./finder-labels.sh --help` for folder listing and recursive reporting
options. The `set` and `clear` operations affect only the explicitly supplied
paths.

## Links

- [User Guide](USER-GUIDE.md)
- [code.matx.ca](https://code.matx.ca)
- [Source repository](https://github.com/macvfx/finderColour)

## License

Finder Colours is available under the [MIT License](LICENSE).
