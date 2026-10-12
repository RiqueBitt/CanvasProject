#!/usr/bin/env bash
# Abre o CanvasProject de verdade numa tela virtual e captura telas reais.
set -u
APP="$(readlink -f "$1")"
chmod +x "$APP" 2>/dev/null  # o artefato do Actions perde o bit de execução; OUT="$(mkdir -p "$2" && readlink -f "$2")"
export DISPLAY=:99 APPIMAGE_EXTRACT_AND_RUN=1 QT_QPA_PLATFORM=xcb LIBGL_ALWAYS_SOFTWARE=1
Xvfb :99 -screen 0 1600x1000x24 -nolisten tcp >/dev/null 2>&1 &
sleep 2
(command -v openbox >/dev/null && DISPLAY=:99 openbox >/dev/null 2>&1 &)
sleep 2
n=0
shot() { n=$((n+1)); sleep "${2:-3}"; import -window root "$(printf '%s/%02d-%s.png' "$OUT" "$n" "$1")"; echo "captura $n: $1"; }
key() { timeout 10 xdotool key --clearmodifiers "$@"; }
stroke() { xdotool mousemove "$1" "$2" mousedown 1; for i in $(seq 1 30); do
  xdotool mousemove $(( $1 + ($3-$1)*i/30 )) $(( $2 + ($4-$2)*i/30 + (i%7)*4 )); sleep 0.02; done; xdotool mouseup 1; }
"$APP" > "$OUT/app.log" 2>&1 &
APP_PID=$!
sleep 50
W=$(timeout 10 xdotool search --onlyvisible --name "CanvasProject" | tail -1)
[ -n "$W" ] && timeout 10 xdotool windowfocus "$W" windowsize "$W" 1600 1000 windowmove "$W" 0 0
shot tela-de-boas-vindas 4
key ctrl+n; shot novo-documento 4
key Return; shot tela-em-branco 6
stroke 500 400 1000 450; stroke 520 520 1050 600; stroke 600 300 700 700
shot pinceladas 3
key e; stroke 600 480 900 480; key e; shot borracha 3
key F6; shot predefinicoes-de-pincel 3
key F6
key ctrl+shift+n; shot nova-camada 4
key Escape
key 4; shot rotacao-da-tela 3
key 5
key Tab; shot modo-tela-cheia 3
key Tab
key ctrl+m; shot ajuste-de-curvas 4
key Escape
key shift+F6 2>/dev/null; sleep 1
xdotool mousemove 800 20 click 1; shot menu 3
key Escape
kill $APP_PID 2>/dev/null; sleep 1
ls -la "$OUT"
# encerra a tela virtual e o gerenciador de janelas
pkill openbox 2>/dev/null; pkill -f "Xvfb :99" 2>/dev/null; true
