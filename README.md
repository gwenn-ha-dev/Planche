# Planche

[![CI](https://github.com/gwenn-ha-dev/Planche/actions/workflows/ci.yml/badge.svg)](https://github.com/gwenn-ha-dev/Planche/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
![Platform](https://img.shields.io/badge/Platform-macOS%2014%2B-black?logo=apple)
![Swift 6](https://img.shields.io/badge/Swift-6-orange?logo=swift)

*🇬🇧 English · 🇫🇷 [Français](./README.fr.md)*

A native macOS app to view, sort and organise your images — a contact sheet for a folder tree.

## Features

- **Recursive browsing** of image folders.
- **Thumbnail gallery** with adjustable size, persisted between sessions.
- **Full-screen detail view** with keyboard navigation.
- **Multiple selection**: ⌘-click, ⇧-click, ⌘A.
- **Delete** to the macOS trash, **drag and drop** folders straight into the window, **Reveal in Finder** from the context menu.
- Formats: JPG, PNG, GIF, BMP, TIFF, HEIC, HEIF, WebP, AVIF, SVG.

## Install

```sh
git clone https://github.com/gwenn-ha-dev/Planche.git
cd Planche
make build
```

## How it works

Planche never modifies your files. It reads a folder tree, shows it, and the only destructive action it offers goes through the system trash.

## Build

| Command | What it does |
|---|---|
| `make build` | Release build, warnings are errors |
| `make test` | Run the test suite |
| `make run` | Launch the app |
| `make icon` | Regenerate `Resources/AppIcon.icns` |
| `make package` | Produce a distributable bundle in `build/` |
| `make lint` | Check compliance with the project charter |
| `make help` | List every target |

## Dependencies

None — Apple frameworks only.

## License

MIT © 2026 gwenn-ha-dev — see [LICENSE](./LICENSE).
