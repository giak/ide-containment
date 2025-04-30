# 🧠 Cursor IDE — Exécution conteneurisée sous Linux Mint 22

Ce projet permet de lancer l’éditeur **Cursor (AppImage)** dans un conteneur Docker sécurisé, isolé, performant et personnalisable.  
Il offre un environnement de développement IA robuste, avec intégration GPU, configuration persistante, et choix dynamique de version Cursor.

---

## ✨ Fonctionnalités

- 💻 Lancement de **n’importe quelle version AppImage de Cursor**.
- 🔐 Exécution **isolée** (X11 + volumes maîtrisés + AppArmor désactivé).
- ⟳ Mode **éphémère** ou **persistant** selon les besoins.
- ⚡ Accélération **GPU** automatique via `/dev/dri`.
- 📂 Volume projet : montage dynamique de n’importe quel dossier.
- 🔒 Support **DBus système + session** : notifications, authentification IA.
- 🧠 Authentification via navigateur **intégré au conteneur** (Firefox).
- 🛠️ Configuration Cursor **persistante** dans `~/.cursor-docker-config`.

---

## 📁 Structure du projet

```
~/docker-cursor/
├── Dockerfile              # Image de base Debian avec toutes les dépendances Cursor
├── entrypoint.sh           # Script d'entrée générique (lance l'AppImage)
├── cursor-run.sh           # Script de lancement intelligent (montages, options)
├── Applications/           # 📅 Contient les AppImages Cursor téléchargées
└── .cursor-docker-config/  # ⚙️  Configuration Cursor persistante (stockage local)
```

---

## 🚀 Installation

1. **Installer Docker** (si besoin)

```bash
sudo apt update && sudo apt install -y docker.io
sudo systemctl enable --now docker
```

2. **Cloner ce projet et construire l’image Docker**

```bash
cd ~/docker-cursor
docker build -t cursor-base:latest .
```

3. **Télécharger une AppImage Cursor**

Place-la dans `~/Applications`, par exemple :

```bash
mv ~/Téléchargements/Cursor-0.49.6.AppImage ~/Applications/
chmod +x ~/Applications/Cursor-0.49.6.AppImage
```

---

## 🧪 Utilisation

### ➔ Mode éphémère (recommandé)

```bash
./cursor-run.sh Cursor-0.49.6.AppImage
```

- Supprime le conteneur à la fermeture.
- Ne conserve que la configuration utilisateur (`~/.cursor-docker-config`).

### ➔ Mode persistant (lancement plus rapide)

```bash
./cursor-run.sh --persist Cursor-0.49.6.AppImage
```

- Garde les caches internes de Cursor.
- Conteneur relançable : `docker start -a cursor_session`.

### ➔ Changer le dossier de travail

```bash
./cursor-run.sh --workdir ~/Dev/MonProjet Cursor-0.49.6.AppImage
```

Ce dossier sera monté dans `/home/cursor/workspace` à l’intérieur du conteneur.

---

## 🔧 Dépendances clés installées dans l’image

- `libx11`, `libgtk-3`, `libnss3`, `libgbm1`, `libdrm2` (GPU & X11)
- `libasound2`, `libxkbfile1`, `xdg-utils` (audio, clavier, ouverture navigateur)
- `dbus`, `dbus-x11` (bus système + session)
- `git`, `firefox-esr` (authentification OAuth, intégration extensions)

---

## 🛡️ Fonctionnement technique

- Cursor est lancé en **non-root** dans `/home/cursor/`.
- L’AppImage est **extraite automatiquement** sans FUSE grâce à `APPIMAGE_EXTRACT_AND_RUN=1`.
- Le **bus DBus session de l’hôte** est monté dans le conteneur pour permettre l’authentification IA et les notifications.
- Le **navigateur Firefox** du conteneur est utilisé pour le login GitHub/Google (OAuth).
- Le rendu **OpenGL** est activé grâce au montage `/dev/dri`.

---

## 🔒 Sécurité

- Aucun accès root dans le conteneur (`useradd -u 1000 cursor`).
- L’image est compacte et ne contient que le strict nécessaire.
- `--security-opt apparmor=unconfined` désactive temporairement AppArmor pour permettre l’accès au bus DBus.
- Les volumes sont contrôlés : aucun accès par défaut à `.ssh` ou autres répertoires sensibles.

---

## 🔁 Mise à jour de Cursor

1. Télécharger une nouvelle AppImage dans `~/Applications/`
2. Lancer avec :

```bash
./cursor-run.sh Cursor-0.50.0.AppImage
```

Aucun rebuild Docker n’est requis.

---

## 🧠 Prochaines optimisations possibles

- Migration vers **Podman rootless + systemd --user**.
- Script CLI interactif avec sélection visuelle des AppImages.
- Intégration d’un `.desktop` file pour lancement depuis menu Mint.
- Version Flatpak ou Firejail alternative (non Docker).

---

## 🙌 Auteur

Développé dans le cadre d’un environnement de développement IA générative sécurisé, optimisé et portable.

---

## 📩 Licence

Libre usage à des fins de développement, distribution restreinte si image modifiée.


