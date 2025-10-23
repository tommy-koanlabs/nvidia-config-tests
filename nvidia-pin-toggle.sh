#!/bin/bash

# NVIDIA Driver Pin Toggle Script
# Enables/disables APT preferences to prevent 580 driver installation

PREFS_FILE="/etc/apt/preferences.d/nvidia-pin"
BACKUP_FILE="/etc/apt/preferences.d/nvidia-pin.bak"

NVIDIA_PIN_CONTENT="Package: linux-modules-nvidia-580*
Pin: version *
Pin-Priority: -1

Package: nvidia-driver-580*
Pin: version *
Pin-Priority: -1
"

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root (use sudo)"
        exit 1
    fi
}

enable_pin() {
    if [[ -f "$PREFS_FILE" ]]; then
        echo "✓ NVIDIA pin is already enabled"
        return 0
    fi

    echo "Creating $PREFS_FILE..."
    echo "$NVIDIA_PIN_CONTENT" > "$PREFS_FILE"
    echo "✓ NVIDIA 580 driver is now pinned (blocked)"
    echo ""
    echo "You can now safely install 550 driver:"
    echo "  sudo apt install linux-modules-nvidia-550-\$(uname -r) nvidia-driver-550"
}

disable_pin() {
    if [[ ! -f "$PREFS_FILE" ]]; then
        echo "✓ NVIDIA pin is already disabled"
        return 0
    fi

    # Backup before removal
    cp "$PREFS_FILE" "$BACKUP_FILE"
    rm "$PREFS_FILE"
    echo "✓ NVIDIA pin has been disabled"
    echo "  (Backup saved to $BACKUP_FILE)"
}

status() {
    if [[ -f "$PREFS_FILE" ]]; then
        echo "Status: ENABLED (580 driver is blocked)"
        echo ""
        echo "Content of $PREFS_FILE:"
        cat "$PREFS_FILE"
    else
        echo "Status: DISABLED (580 driver can be installed)"
    fi
}

usage() {
    echo "Usage: $0 {enable|disable|status|toggle}"
    echo ""
    echo "Commands:"
    echo "  enable   - Block NVIDIA 580 driver installation"
    echo "  disable  - Allow NVIDIA 580 driver installation"
    echo "  status   - Show current pin status"
    echo "  toggle   - Enable if disabled, disable if enabled"
    exit 1
}

main() {
    case "${1:-status}" in
        enable)
            check_root
            enable_pin
            ;;
        disable)
            check_root
            disable_pin
            ;;
        status)
            status
            ;;
        toggle)
            check_root
            if [[ -f "$PREFS_FILE" ]]; then
                disable_pin
            else
                enable_pin
            fi
            ;;
        *)
            usage
            ;;
    esac
}

main "$@"
