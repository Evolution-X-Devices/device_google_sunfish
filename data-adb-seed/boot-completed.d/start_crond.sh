#!/system/bin/sh
BUSYBOX=/data/adb/ksu/bin/busybox
CRONDIR=/data/adb/cron/crontabs
LOG=/data/adb/cron/crond.log

if ! pidof crond >/dev/null 2>&1; then
    "$BUSYBOX" crond -b -c "$CRONDIR" -L "$LOG"
fi
