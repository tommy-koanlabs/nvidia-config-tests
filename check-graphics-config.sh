#!/bin/bash
# Simple script to capture current graphics configuration

OUTPUT_FILE="graphics-config-$(date +%Y%m%d-%H%M%S).txt"

echo "=== Graphics Configuration Report ===" > "$OUTPUT_FILE"
echo "Generated: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "=== Linux Kernel Version ===" >> "$OUTPUT_FILE"
uname -r >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "=== Graphics Information ===" >> "$OUTPUT_FILE"
inxi -G >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

#echo "=== Installed NVIDIA Package ===" >> "$OUTPUT_FILE"
#dpkg -l | grep -E "nvidia-driver|nvidia.*-open" | grep "^ii" >> "$OUTPUT_FILE"
#echo "" >> "$OUTPUT_FILE"

echo "=== GRUB Configuration ===" >> "$OUTPUT_FILE"
cat /etc/default/grub >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "=== Current Boot Parameters ===" >> "$OUTPUT_FILE"
cat /proc/cmdline >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "=== Modprobe Configuration ===" >> "$OUTPUT_FILE"
if [ -f /etc/modprobe.d/nvidia.conf ]; then
    cat /etc/modprobe.d/nvidia.conf >> "$OUTPUT_FILE"
else
    echo "No /etc/modprobe.d/nvidia.conf found" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

echo "=== NVIDIA Systemd Services ===" >> "$OUTPUT_FILE"
for service in nvidia-suspend nvidia-hibernate nvidia-resume nvidia-powerd nvidia-persistenced; do
    if systemctl list-unit-files | grep -q "^${service}.service"; then
        status=$(systemctl is-enabled ${service}.service 2>&1)
        echo "${service}.service: $status" >> "$OUTPUT_FILE"
    fi
done
echo "" >> "$OUTPUT_FILE"

echo "Configuration saved to: $OUTPUT_FILE"
