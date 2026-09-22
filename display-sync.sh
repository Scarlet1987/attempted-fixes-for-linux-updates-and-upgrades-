#!/usr/bin/env bash
# ==============================================================================
# TAG:      RX580_WAKE_FIX
# LOCATION: /usr/local/bin/display-sync.sh
# SYSTEMD:  /etc/systemd/system/display-state-sync.service
# UDEV:     /etc/udev/rules.d/99-display-hotplug.rules
# ==============================================================================

STATE_DIR="/run/display_topology"
SCRIPT_PATH="$(readlink -f "$0")"

get_connected_ports() {
    for card in /sys/class/drm/card*-*; do
        if [ -f "$card/status" ] && [ "$(cat "$card/status")" = "connected" ]; then
            basename "$card" | cut -d'-' -f2-
        fi
    done
}

install_system_hooks() {
    echo "[+] Installing RX580_WAKE_FIX system hooks..."
    mkdir -p "$STATE_DIR"

    SYSTEMD_PATH=$(grep "^# SYSTEMD:" "$SCRIPT_PATH" | awk '{print $3}')
    UDEV_PATH=$(grep "^# UDEV:" "$SCRIPT_PATH" | awk '{print $3}')

    cat <<EOF | sudo tee "$SYSTEMD_PATH" > /dev/null
# TAG: RX580_WAKE_FIX
[Unit]
Description=RX580_WAKE_FIX DRM Hardware Wake Poller
Before=sleep.target
StopWhenUnneeded=yes

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=$SCRIPT_PATH pre-sleep
ExecStop=$SCRIPT_PATH post-wake

[Install]
WantedBy=sleep.target
EOF

    cat <<EOF | sudo tee "$UDEV_PATH" > /dev/null
# TAG: RX580_WAKE_FIX
ACTION=="change", SUBSYSTEM=="drm", HOTPLUG=="1", RUN+="$SCRIPT_PATH poll-awake"
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable display-state-sync.service
    sudo udevadm control --reload-rules
    echo "[✓] RX580_WAKE_FIX hooks successfully installed."
}

destroy_system_hooks() {
    echo "[-] Executing Search & Destroy for RX580_WAKE_FIX..."

    SYSTEMD_PATH=$(grep "^# SYSTEMD:" "$SCRIPT_PATH" | awk '{print $3}')
    UDEV_PATH=$(grep "^# UDEV:" "$SCRIPT_PATH" | awk '{print $3}')

    if [ -f "$SYSTEMD_PATH" ]; then
        sudo systemctl disable display-state-sync.service >/dev/null 2>&1
        sudo rm -f "$SYSTEMD_PATH"
        echo "  - Removed: $SYSTEMD_PATH"
    fi

    if [ -f "$UDEV_PATH" ]; then
        sudo rm -f "$UDEV_PATH"
        echo "  - Removed: $UDEV_PATH"
    fi

    sudo systemctl daemon-reload
    sudo udevadm control --reload-rules

    echo "[✓] All hooks destroyed and system reset to default state."
    echo "    Note: You can now safely delete $SCRIPT_PATH when ready."
}

check_status() {
    echo "=== RX580_WAKE_FIX Status Check ==="
    SYSTEMD_PATH=$(grep "^# SYSTEMD:" "$SCRIPT_PATH" | awk '{print $3}')
    UDEV_PATH=$(grep "^# UDEV:" "$SCRIPT_PATH" | awk '{print $3}')

    [ -f "$SYSTEMD_PATH" ] && echo "[INSTALLED] Systemd Hook: $SYSTEMD_PATH" || echo "[MISSING] Systemd Hook"
    [ -f "$UDEV_PATH" ] && echo "[INSTALLED] Udev Hook: $UDEV_PATH" || echo "[MISSING] Udev Hook"
    
    echo -n "Connected DRM Ports: "
    get_connected_ports | tr '\n' ' '
    echo ""
}

case "$1" in
    --install)
        install_system_hooks
        ;;

    --destroy)
        destroy_system_hooks
        ;;

    --status)
        check_status
        ;;

    pre-sleep)
        mkdir -p "$STATE_DIR"
        get_connected_ports > "$STATE_DIR/pre_sleep_ports.txt"
        ;;

    post-wake)
        if [ -f /sys/module/drm_kms_helper/parameters/poll ]; then
            echo 1 | sudo tee /sys/module/drm_kms_helper/parameters/poll > /dev/null
        fi

        for i in {1..6}; do
            [ -n "$(get_connected_ports)" ] && break
            sleep 0.5
        done

        if pgrep -x "gnome-shell" > /dev/null || pgrep -x "cosmic-comp" > /dev/null; then
            echo change | sudo tee /sys/class/drm/card0/uevent > /dev/null 2>&1
        fi
        ;;

    poll-awake)
        echo change | sudo tee /sys/class/drm/card0/uevent > /dev/null 2>&1
        ;;

    *)
        echo "Usage: $0 {--install|--destroy|--status}"
        exit 1
        ;;
esac
