# Planche

[![CI](https://github.com/gwenn-ha-dev/Planche/actions/workflows/ci.yml/badge.svg)](https://github.com/gwenn-ha-dev/Planche/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
![Platform](https://img.shields.io/badge/Platform-macOS%2014%2B-black?logo=apple)
![Swift 6](https://img.shields.io/badge/Swift-6-orange?logo=swift)

*🇬🇧 [English](./README.md) · 🇫🇷 Français*

App macOS native pour visualiser, trier et organiser vos images — une planche-contact pour une arborescence de dossiers.

## Fonctionnalités

- **Parcours récursif** de dossiers d'images.
- **Galerie de miniatures** à taille ajustable, persistée entre les sessions.
- **Vue détaillée plein écran** avec navigation au clavier.
- **Sélection multiple** : ⌘-clic, ⇧-clic, ⌘A.
- **Suppression** vers la corbeille macOS, **glisser-déposer** de dossiers dans la fenêtre, **Afficher dans le Finder** depuis le menu contextuel.
- Formats : JPG, PNG, GIF, BMP, TIFF, HEIC, HEIF, WebP, AVIF, SVG.

## Installation

```sh
git clone https://github.com/gwenn-ha-dev/Planche.git
cd Planche
make build
```

## Comment ça marche

Planche ne modifie jamais vos fichiers. Elle lit une arborescence, l'affiche, et la seule action destructive proposée passe par la corbeille du système.

## Construction

| Commande | Ce qu'elle fait |
|---|---|
| `make build` | Compilation release, tout avertissement est une erreur |
| `make test` | Lance la suite de tests |
| `make run` | Lance l'app |
| `make icon` | Régénère `Resources/AppIcon.icns` |
| `make package` | Produit un bundle distribuable dans `build/` |
| `make lint` | Vérifie la conformité à la charte |
| `make help` | Liste toutes les cibles |

## Dépendances

Aucune — frameworks Apple uniquement.

## Licence

MIT © 2026 gwenn-ha-dev — voir [LICENSE](./LICENSE).
