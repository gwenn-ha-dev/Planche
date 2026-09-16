# Planche — agent context

## What this is

A native macOS app to view, sort and organise your images — a contact sheet for a folder tree.

Platform: macOS 14+. Build system: Xcode project. Bundle ID `dev.gwennha.Planche`.

## Build and test

```sh
make build   # release, warnings are errors
make test
make lint    # charter compliance — run before declaring anything done
```

Never invoke `swift build`, `xcodebuild` or a build script directly; go through
the `Makefile`. It is the same interface in every project here.

## Invariants — do not break these

- **No hard-coded user-visible strings.** Everything goes through
  `Resources/Localizable.xcstrings`, present in both `en` and `fr`. Adding a
  string means adding both translations in the same change.
- **No build artefacts committed.** No `.app`, no `build/`, no `.build/`.
- **Dependencies: none.** Adding one requires documenting it in the README's
  *Dependencies* section.
- **`README.md` and `README.fr.md` stay in sync.** Editing one means editing the other.
- **The icon is generated**, never hand-placed: `outils/icone.swift` is the
  source, `make icon` rebuilds `Resources/AppIcon.icns`.
- Identifiers, commit messages and both READMEs are in **English**; comments may
  be in English or French (charter §2).

## Layout

```
.github/
.gitignore
CHANGELOG.md
CONTRIBUTING.md
LICENSE
Localizable.xcstrings
Makefile
Planche.xcodeproj/
Planche/
README.md
Resources/
clean.png
outils/
```

## The charter

The full norm this project follows lives at `../../Charte/CHARTE.md`.
