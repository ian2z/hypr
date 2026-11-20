#!/bin/bash
# =============================================================================
# Hyprsunset Safe Controller
# Evita conflitos de protocolo Wayland zwlr_gamma_control_v1 e travamento de tela
# =============================================================================

ACTION="${1:-toggle}"
TEMP="${2:-4000}"

kill_sunset_cleanly() {
    # 1. Envia SIGTERM para encerramento gracioso
    killall -TERM hyprsunset 2>/dev/null
    
    # 2. Aguarda até 300ms para liberação completa do socket Wayland
    for i in {1..6}; do
        if ! pgrep -x hyprsunset >/dev/null 2>&1; then
            break
        fi
        sleep 0.05
    done

    # 3. Se ainda estiver vivo, força SIGKILL
    if pgrep -x hyprsunset >/dev/null 2>&1; then
        killall -9 hyprsunset 2>/dev/null
        sleep 0.05
    fi
}

reset_identity() {
    # Aplica matriz identidade para garantir que as cores voltem 100% ao normal
    hyprsunset -i &
    PID=$!
    sleep 0.1
    kill -TERM $PID 2>/dev/null || true
}

case "$ACTION" in
    off)
        kill_sunset_cleanly
        reset_identity
        ;;
    set)
        kill_sunset_cleanly
        hyprsunset -t "$TEMP" &
        disown
        ;;
    toggle)
        if pgrep -x hyprsunset >/dev/null 2>&1; then
            kill_sunset_cleanly
            reset_identity
        else
            kill_sunset_cleanly
            hyprsunset -t "$TEMP" &
            disown
        fi
        ;;
    status)
        if pgrep -x hyprsunset >/dev/null 2>&1; then
            echo "1"
        else
            echo "0"
        fi
        ;;
    *)
        echo "Uso: $0 {on|off|toggle|set <temp>|status}"
        exit 1
        ;;
esac
