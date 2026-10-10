# Planche

[![CI](https://github.com/gwenn-ha-dev/Planche/actions/workflows/ci.yml/badge.svg)](https://github.com/gwenn-ha-dev/Planche/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
![Platform](https://img.shields.io/badge/Platform-macOS%2014%2B-black?logo=apple)
![Swift 5](https://img.shields.io/badge/Swift-5-orange?logo=swift)

*🇬🇧 English · 🇫🇷 [Français](./README.fr.md)*

A native macOS app to view, sort and organise your images — a contact sheet for a folder tree.

![Planche showing a folder named Horizons: 24 pictures of shores, ridges and dunes as thumbnails in a grid, each with its file name, the thumbnail size slider at the bottom right and "24 images" in the status bar](docs/img/gallery.png)

## Features

- **Recursive browsing**: every image in a folder and its subfolders, in natural order (`shore-2` before `shore-10`).
- **Thumbnail gallery** with a size slider, remembered between sessions.
- **Detail view** with keyboard navigation: ← → to move, Space or Esc to go back.
- **Multiple selection**: ⌘-click, ⇧-click, ⌘A.
- **Delete** to the macOS Trash, **drag and drop** a folder straight into the window, **Show in Finder**, **Copy Image** and **Copy Path** from the context menu.
- Formats: JPG, PNG, GIF, BMP, TIFF, HEIC, HEIF, WebP, AVIF, SVG.
- English and French, following the system language.

| Selection | Detail view |
|---|---|
| ![Three pictures selected among larger thumbnails, outlined in blue; the status bar reads "24 images · 3 selected" and a trash button has appeared in the toolbar](docs/img/selection.png) | ![The detail view: one seascape fills the window, with its file name, its position "15 / 24", arrows to the previous and next picture, and buttons to trash it, show it in Finder or copy it](docs/img/detail.png) |

The keyboard shortcuts are one keystroke away, ⌘/:

![The Keyboard Shortcuts sheet over the gallery: ⌘O Open Folder, ⌘A Select All, ⌫ Delete selection; in the detail view Space, ← →, Esc and ⌫ Move to Trash](docs/img/shortcuts.png)

## Install

Download **`Planche-<version>.dmg`** from the [latest release](https://github.com/gwenn-ha-dev/Planche/releases/latest), open it and drag Planche onto Applications. The app is signed with a Developer ID and notarized by Apple: it opens with a double click.

To build from source instead:

```sh
git clone https://github.com/gwenn-ha-dev/Planche.git
cd Planche
make package      # build/Planche.app
```

## Usage

Open a folder with ⌘O, or drop one onto the window. Click a thumbnail to select it, double-click it (or press Space) to see it large. ⌫ moves the selection to the Trash, after a confirmation.

## How it works

Planche never modifies your files. It reads a folder tree, shows it, and the only destructive action it offers goes through the system Trash. The app is sandboxed: it reads only the folders you open or drop on it.

## Build

| Command | What it does |
|---|---|
| `make build` | Release build, warnings are errors |
| `make test` | Run the test suite |
| `make run` | Launch the app |
| `make icon` | Regenerate `Resources/AppIcon.icns` |
| `make package` | Build `build/Planche.app` |
| `make sign` | Sign it with a Developer ID, notarize and staple it |
| `make dmg` | Pack the notarized app into a notarized `.dmg` |
| `make shots` | Retake the captures in `docs/img/` |
| `make release-check` | Check that `build/` is publishable |
| `make lint` | Check compliance with the project charter |
| `make help` | List every target |

The pictures in the captures are drawn by `outils/echantillons.swift`, not taken from anyone's photo library.

## Dependencies

None — Apple frameworks only.

## License

MIT © 2026 gwenn-ha-dev — see [LICENSE](./LICENSE).
