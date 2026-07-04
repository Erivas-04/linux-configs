#!/bin/bash
set -e

TARGET_DIR="${1:?Uso: $0 <directorio>}"

# Validar que existe
[ -d "$TARGET_DIR" ] || {
  echo "Error: '$TARGET_DIR' no es un directorio"
  exit 1
}

# Validar que estamos dentro de tmux
[ -n "$TMUX" ] || {
  echo "Error: debe ejecutarse dentro de tmux"
  exit 1
}

# 1. Mover el pane actual al directorio destino, limpiar concola y abrir nvim
tmux send-keys "cd $TARGET_DIR" Enter
tmux send-keys "cls" Enter
tmux send-keys "n" Enter

# 2. Crear un nuevo pane (split horizontal) en el directorio destino
tmux split-window -h -c "$TARGET_DIR"
tmux send-keys "c" Enter

# 3. Crear tab "git" con lazygit
tmux new-window -n "git" -c "$TARGET_DIR" "lazygit"

# 4. Crear tab "docker" con lazydocker
tmux new-window -n "docker" -c "$TARGET_DIR" "lazydocker"

# Opcional: volver al tab original
tmux select-window -t "{start}"
