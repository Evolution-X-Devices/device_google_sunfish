#!/system/bin/sh

# input_suspend semantics: 1 = stop charging, 0 = allow charging
CHARGING_SWITCH="/sys/class/power_supply/smb5/input_suspend"

while true; do
    # Get current battery level and plugged-in status
    LEVEL=$(dumpsys battery | awk '$1=="level:"{print $2}')
    PLUGGED=$(dumpsys battery | grep -E "AC powered:|USB powered:|Wireless powered:" | grep -c "true")

    # 1. EMERGENCY SHUTDOWN BLOCK (Unplugged & under 20%)
    if [ "$LEVEL" -lt 20 ] && [ "$PLUGGED" -eq 0 ]; then
        svc power shutdown
        exit 0
    fi

    # 2. CHARGE LIMITER BLOCK (When charger is plugged in)
    if [ "$PLUGGED" -gt 0 ]; then
        # If battery reaches 80% or more, stop charging
        if [ "$LEVEL" -ge 80 ]; then
            echo 1 > "$CHARGING_SWITCH"

        # If battery drops back down to 70% or lower, resume charging
        elif [ "$LEVEL" -le 70 ]; then
            echo 0 > "$CHARGING_SWITCH"
        fi
    else
        # Force-enable charging when unplugged so it charges normally next time you plug it in
        echo 0 > "$CHARGING_SWITCH"
    fi

    # Check state every 30 seconds
    sleep 30
done
