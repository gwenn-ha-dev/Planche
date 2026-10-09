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
  `Localizable.xcstrings` (at the root), present in both `en` and `fr`. Adding a
  string means adding both translations in the same change.
- **No build artefacts committed.** No `.app`, no `build/`, no `.build/`.
- **Dependencies: none.** Adding one requires documenting it in the README's
  *Dependencies* section.
- **`README.md` and `README.fr.md` stay in sync.** Editing one means editing the other.
- **The icon is generated**, never hand-placed: `outils/icone.swift` is the
  source, `make icon` rebuilds `Resources/AppIcon.icns`, and the app ships that
  file — it is a Copy Resources entry, named by `CFBundleIconFile` in
  `Planche/Info.plist`. There is deliberately no `Assets.xcassets`: an
  `AppIcon.appiconset` silently wins over the generated `.icns`, and for five
  months this one shipped placeholder clipart that `make lint` could not see.
- Identifiers, commit messages and both READMEs are in **English**; comments may
  be in English or French (charter §2).

## Public identity and releases (charter §12)

- Commit as `gwenn-ha-dev <13298867+gwenn-ha-dev@users.noreply.github.com>` (set
  in this repo's git config) and in UTC: `TZ=UTC git commit …`. No personal name,
  email or `/Users/…` path in tracked files. `../../Charte/outils/identite.sh .` checks.
- A release: `make package && make sign && make dmg && make shots && make release-check`,
  then tag `v<version>` and attach `build/Planche-<version>.dmg` — see
  `../../Charte/DISTRIBUTION-AGENT.md`, phase 3. The version is `MARKETING_VERSION`
  in `Planche.xcodeproj`, three numbers.
- `make package` archives with Xcode and copies the app out of the archive to
  `build/Planche.app`, signed "Apple Development". `make sign` re-signs it with
  the Developer ID, keeping its entitlements — the sandbox and
  `files.user-selected.read-write`, which come from build settings
  (`ENABLE_APP_SANDBOX`, `ENABLE_USER_SELECTED_FILES`), not from the empty
  `Planche.entitlements` — minus `get-task-allow`.
- **The development region is English** (`developmentRegion = en`), while the
  string catalog's source language is French — the keys are French sentences.
  So every key needs an explicit `fr` entry, even when it equals the key:
  without it `fr.lproj` ships no `Localizable.strings` and a French system falls
  back to English. The captures (`make shots`) show it at once.
- Captures: `outils/captures.sh` draws 24 pictures (`outils/echantillons.swift`)
  into the app's sandbox container — the only place the sandboxed app reads
  without an Open panel — and sets each view with launch arguments (`-folder`,
  `-select`, `-show`, `-shortcuts`, documented in `ContentView.swift`). Never
  capture a real photo folder.

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
PlancheTests/
README.fr.md
README.md
Resources/
docs/
outils/
site/
```

## The charter

The full norm this project follows lives at `../../Charte/CHARTE.md`.
