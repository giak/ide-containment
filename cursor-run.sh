#!/usr/bin/env bash
###############################################################################
# Lance Cursor IDE conteneurisé
###############################################################################
set -euo pipefail

IMAGE="cursor-base:latest"
CTNAME="cursor_session"

EPHEMERE=true
WORKDIR_HOST="$PWD"
APPIMAGE=""

# ── Analyse des options ───────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --persist|-p) EPHEMERE=false; shift ;;
    --ephemere|-e) EPHEMERE=true;  shift ;;
    --workdir|-w) WORKDIR_HOST="$2"; shift 2 ;;
    *) APPIMAGE="$1"; shift ;;
  esac
done

[[ -n "$APPIMAGE" ]] || { echo "Usage: $0 [--persist] [--workdir <dir>] <Cursor.AppImage>"; exit 1; }
APP_HOST="$HOME/Applications/$APPIMAGE"
[[ -x "$APP_HOST" ]] || { echo "[ERREUR] $APP_HOST introuvable."; exit 1; }

# ── Autorisation X11 (cookie) ─────────────────────────────────────
xauth list "$DISPLAY" | awk '{print $9}' | xargs -I{} xauth add "$(hostname)/unix:${DISPLAY##*:}" . {} || true

# ── Bus DBus session de l’hôte ───────────────────────────────────
BUS_SOCK="/run/user/$(id -u)/bus"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$BUS_SOCK"

# ── Options Docker ───────────────────────────────────────────────
OPTS="-it \
  -e DISPLAY=$DISPLAY \
  -e DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
  -e APPIMAGE_EXTRACT_AND_RUN=1 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $HOME/.Xauthority:/home/cursor/.Xauthority:ro \
  -v $HOME/Applications:/home/cursor/Applications:ro \
  -v $HOME/.cursor-docker-config:/home/cursor/.config/Cursor \
  -v $WORKDIR_HOST:/home/cursor/workspace \
  -v /run/dbus/system_bus_socket:/run/dbus/system_bus_socket:ro \
  -v $BUS_SOCK:$BUS_SOCK:ro \
  --security-opt apparmor=unconfined \
  --name $CTNAME"

$EPHEMERE && OPTS="--rm $OPTS" || OPTS="-e NO_CLEANUP=1 $OPTS"
[[ -e /dev/dri ]] && OPTS="$OPTS --device /dev/dri"

docker rm -f $CTNAME 2>/dev/null || true
exec docker run $OPTS "$IMAGE" /home/cursor/Applications/"$APPIMAGE"
