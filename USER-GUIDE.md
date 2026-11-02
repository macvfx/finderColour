# Finder Colours — User Guide

Finder Colours reads and changes the modern Finder colour tags attached to
files and folders. It is designed for quick visual organization when opening
Finder's tag menus item by item would be inconvenient.

## Requirements

- macOS 13 or later
- Normal read and metadata-write access to the items being changed
- A filesystem that preserves Finder tags

No Finder Automation permission, account, login item, or background service is
required.

## Quick start

1. Open **Finder Colours**.
2. Drag one or more files or folders into the dashed drop area.
3. Review the detected colour beside each item.
4. Choose **None**, **Orange**, **Red**, **Yellow**, **Blue**, **Purple**,
   **Green**, or **Grey** under *Apply to All Dropped Items*.
5. Wait for the confirmation checkmark.
6. Click **Reveal** beside an item, or double-click its row, to select it in
   Finder and inspect the result.

Dropped folders are handled as individual items. Finder Colours does not walk
through a folder or change anything inside it.

## Understanding the list

Each row shows:

- the item's normal macOS icon;
- its name and absolute path;
- the Finder colour currently reported by macOS;
- **Reveal**, which selects the item in Finder;
- a remove button, which removes the row without changing the item.

Dragging the same path again does not create a duplicate row. Paths that no
longer exist are ignored.

### Refresh

Choose **Refresh** or press Command-R to read every listed item again. Refresh
is useful after changing a tag directly in Finder.

### Clear List

Choose **Clear List** to empty the app window. This does not remove or change
Finder tags. The remove button at the end of an individual row behaves the same
way for that one row.

## Applying colours

Colour changes apply to every item currently in the list. Finder Colours uses
the modern Finder tag metadata exposed by Foundation:

| Finder number | Displayed colour |
|---:|---|
| 0 | None |
| 1 | Grey |
| 2 | Green |
| 3 | Purple |
| 4 | Blue |
| 5 | Yellow |
| 6 | Red |
| 7 | Orange |

These numbers differ from the older AppleScript `label index` ordering. Finder
Colours and its current shell script use the modern mapping throughout.

### Existing tags are replaced

Finder allows an item to carry several named tags. Finder Colours deliberately
offers a simpler, single-colour workflow:

- Applying a colour replaces the item's current Finder tag list with that one
  standard colour tag.
- Applying **None** removes all Finder tags from the item.

If an item must retain custom tags such as `Approved`, `Client Review`, or
`Archive`, edit it in Finder instead.

## Filesystems and permissions

Finder tags are filesystem metadata. Support depends on the storage location:

- APFS and normal local macOS storage generally preserve tags.
- Some SMB servers, removable-drive formats, synchronized folders, or
  permission configurations may reject or discard them.
- A read-only item or directory cannot be changed.
- Moving an item to a filesystem without compatible metadata support may lose
  its tag.

When a colour will not persist, try the same operation on a disposable local
folder. If local storage works but a server or drive does not, the limitation
belongs to that storage path rather than the app.

## Privacy

Finder Colours operates locally. It does not:

- upload file names, paths, tags, or file contents;
- scan inside dropped folders;
- collect analytics or usage information;
- create an account or contact a service during normal operation;
- install a helper, login item, background process, or updater;
- send diagnostics automatically.

The app contains links to [code.matx.ca](https://code.matx.ca) and the
[public User Guide](https://github.com/macvfx/finderColour/blob/main/USER-GUIDE.md).
Those websites are contacted only after a user opens a link.

## Accessibility and animation

The drop target performs a short colour sweep when the app opens. A successful
change briefly recolours the folder graphic and shows a checkmark. These
effects respect **System Settings → Accessibility → Display → Reduce motion**.

All operations are also available through labelled controls and normal macOS
menus.

## Troubleshooting

### The app reports an error

Confirm that:

1. the item still exists at the displayed path;
2. your account can modify it;
3. the containing filesystem accepts Finder tags;
4. the item is not on read-only media.

Try changing the same tag in Finder. If Finder cannot retain it either, the
problem is the filesystem or permissions rather than Finder Colours.

### Finder and the app show different colours

Press Command-R to refresh the list. Older scripts that read Finder's legacy
AppleScript `label index` may report a different number because that interface
uses a different ordering. Use the current `finder-labels.sh` included here.

### A custom tag disappeared

Applying a colour replaces all existing Finder tags by design. Use Finder when
several keyword or custom tags need to remain attached to the same item.

### A folder's contents did not change

That is expected. Dropping a folder changes only the folder itself. Finder
Colours never applies tags recursively.

## In-app help and About

- Choose **Help → Finder Colours Help** or press Command-Question Mark for the
  concise in-app guide.
- Choose **Finder Colours → About Finder Colours** for the installed version,
  privacy summary, User Guide, and [code.matx.ca](https://code.matx.ca) link.

## Command-line use

The included `finder-labels.sh` provides the same modern colour mapping:

```sh
./finder-labels.sh list "/Users/example/Example_Project"
./finder-labels.sh set green "/Users/example/Example_Project/Example_Folder"
./finder-labels.sh get "/Users/example/Example_Project/Example_Folder"
./finder-labels.sh clear "/Users/example/Example_Project/Example_Folder"
```

Run `./finder-labels.sh --help` for all commands. Recursive listing reports
nested items but does not make `set` or `clear` recursive.

## More information

- [code.matx.ca](https://code.matx.ca)
- [Finder Colours source](https://github.com/macvfx/finderColour)
