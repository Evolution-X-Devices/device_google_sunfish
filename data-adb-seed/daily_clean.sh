#!/system/bin/sh
# 1. Force the system to trim dead application caches
pm trim-caches 4G

# 2. Loop through all running user apps and force compress their memory heaps
for pid in $(top -n 1 | grep "u0_a" | awk '{print $1}'); do
    am compact full "$pid" >/dev/null 2>&1
done

# 3. Aggressively push installed apps into the restricted battery bucket
for pkg in $(pm list packages -3 | cut -d: -f2); do
    if [ "$pkg" != "com.aistra.hail" ]; then
        am set-standby-bucket "$pkg" restricted >/dev/null 2>&1

        # Automatically restrict background data for these same apps
        uid=$(dumpsys package "$pkg" | grep "userId=" | awk -F= '{print $2}' | tr -d ' ')
        if [ ! -z "$uid" ]; then
            cmd netpolicy set uid-policy "$uid" 1 >/dev/null 2>&1
        fi
    fi
done

# 4. Aggressive Doze: Force the device into deep sleep state immediately when idle
dumpsys deviceidle force-idle deep >/dev/null 2>&1

# 5. Purge inactive kernel memory page caches to free up hardware I/O lines
echo 3 > /proc/sys/vm/drop_caches

# Log the successful maintenance event with a timestamp
echo "RAM, Battery & Network Optimization successfully executed at $(date)" >> /sdcard/Download/clean_log.txt
