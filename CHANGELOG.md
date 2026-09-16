# Changelog

All notable changes to Planche are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning: [SemVer](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- The app now ships the generated `Resources/AppIcon.icns`. An `AppIcon.appiconset`
  left in the asset catalog silently won over it, so the bundle carried placeholder
  clipart, and only at four of the ten sizes.

### Removed
- `Planche/Assets.xcassets` and the root `clean.png` it was drawn from.

## [0.1.0] — 2026-09-16

### Added
- Initial release.

[Unreleased]: https://github.com/gwenn-ha-dev/Planche/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/gwenn-ha-dev/Planche/releases/tag/v0.1.0
