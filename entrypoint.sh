#!/usr/bin/env bash
set -euo pipefail

# Vérification argument AppImage
[[ $# -ge 1 ]] || { echo "[ERREUR] chemin AppImage manquant." >&2; exit 1; }
APP="$1"; shift
[[ -x "$APP" ]] || { echo "[ERREUR] $APP introuvable ou non exécutable." >&2; exit 1; }

export NO_CLEANUP=${NO_CLEANUP:-0}

exec "$APP" --no-sandbox "$@"
