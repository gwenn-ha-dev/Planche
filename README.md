# TrierImages

Application macOS native pour visualiser, trier et organiser vos images.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Fonctionnalités

- **Parcours récursif** de dossiers d'images
- **Galerie de miniatures** avec taille ajustable (persistée entre les sessions)
- **Vue détaillée** plein écran avec navigation au clavier
- **Sélection multiple** : Cmd+clic, Shift+clic, Cmd+A
- **Suppression** vers la corbeille macOS
- **Glisser-déposer** de dossiers directement dans la fenêtre
- **Afficher dans le Finder** depuis le menu contextuel

### Formats supportés

JPG, PNG, GIF, BMP, TIFF, HEIC, HEIF, WebP, AVIF, SVG

## Raccourcis clavier

| Raccourci | Action |
|-----------|--------|
| ⌘O | Ouvrir un dossier |
| ⌘A | Tout sélectionner |
| Espace | Ouvrir / fermer la vue détaillée |
| ← → | Image précédente / suivante |
| ⌫ | Mettre à la corbeille |
| Échap | Fermer la vue détaillée |

## Installation

### Depuis les releases

Télécharger le `.dmg` depuis la page [Releases](../../releases) et glisser l'application dans `/Applications`.

### Compilation depuis les sources

```bash
git clone https://github.com/tlebris/TrierImages.git
cd TrierImages
open TrierImages.xcodeproj
```

Compiler et lancer depuis Xcode avec **⌘R**.

**Pré-requis :** macOS 14.0 (Sonoma) ou ultérieur, Xcode 15+.

## Licence

[MIT](LICENSE)
