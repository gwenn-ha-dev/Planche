# Changelog

All notable changes to Planche are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning: [SemVer](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] — 2026-10-09

First release as Planche: a signed and notarized `.dmg`.

### Added
- The app is distributed as `Planche-1.1.0.dmg`, signed with a Developer ID,
  notarized and stapled.
- README captures of the gallery, a selection, the detail view and the keyboard
  shortcuts, in English and French, taken by `outils/captures.sh` on pictures
  drawn by `outils/echantillons.swift`.
- `make sign`, `make dmg`, `make shots`, `make release-check`.
- Launch arguments that set the view (`-folder`, `-select`, `-show`,
  `-shortcuts`), read from the command line only, for the captures.
- A project site (`site/`) for GitHub Pages.

### Fixed
- A system in neither English nor French got the French interface: the
  development region is now English, and the bundle declares `en` and `fr`.
- The French interface no longer falls back to English for plain strings: the
  catalog carries an explicit French entry for every key.
- The keyboard shortcuts sheet clipped its last line.
- A focus ring was drawn around the whole window content.
- The app now ships the generated `Resources/AppIcon.icns`. An `AppIcon.appiconset`
  left in the asset catalog silently won over it, so the bundle carried placeholder
  clipart, and only at four of the ten sizes.

### Removed
- `Planche/Assets.xcassets` and the root `clean.png` it was drawn from.

## [1.0] — 2026-05-03

### Added
- First release, published under the name TrierImages.

[Unreleased]: https://github.com/gwenn-ha-dev/Planche/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/gwenn-ha-dev/Planche/releases/tag/v1.1.0
[1.0]: https://github.com/gwenn-ha-dev/Planche/tree/v1.0
