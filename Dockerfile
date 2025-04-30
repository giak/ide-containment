####################################################################
# Cursor IDE (AppImage) – image d’exécution générique et complète
####################################################################
FROM debian:12-slim

# ── Dépendances indispensables ────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # X11 / GTK / Electron
    libx11-6 libxcb1 libxext6 libxtst6 libgtk-3-0 libnss3 libglib2.0-0 \
    # OpenGL / GPU
    libgbm1 libdrm2 libgl1-mesa-dri libglx-mesa0 libgl1-mesa-glx mesa-utils \
    # Audio & clavier
    libasound2 libxkbfile1 \
    # DBus + outils desktop
    libdbus-1-3 dbus-x11 xdg-utils \
    git                       \
    firefox-esr               \
    # Divers
    ca-certificates libssl3 \
 && rm -rf /var/lib/apt/lists/*

# ── Script d’entrée ───────────────────────────────────────────────
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ── Utilisateur non-root (UID paramétrable) ───────────────────────
ARG UID=1000
RUN useradd -m -u ${UID} cursor
USER cursor
WORKDIR /home/cursor

# ── Variables d’environnement ─────────────────────────────────────
ENV APPIMAGE_EXTRACT_AND_RUN=1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
