#!/vendor/bin/sh
#
# Boot debugging: capture a full logcat to /metadata/log.txt.
#
# Gated on /metadata/start.txt so it can be toggled from recovery without
# rebuilding. From recovery (or an adb root shell):
#
#   enable:   adb shell 'mount /metadata; touch /metadata/start.txt'
#   disable:  adb shell 'mount /metadata; rm /metadata/start.txt'
#   read:     adb shell 'mount /metadata'; adb pull /metadata/log.txt
#
# Doing nothing is the default -- with no start.txt this exits immediately.

[ -f /metadata/start.txt ] || exit 0

rm -f /metadata/log.txt /metadata/log.txt.1 /metadata/log.txt.2

# /metadata is only 10MB and update_engine needs room in /metadata/ota for OTA
# snapshot state -- an unbounded log fills it and makes sideload fail with
# kInstallDeviceOpenError. -r/-n cap total output at ~3MB across 3 files.
exec /system/bin/logcat -b all -v threadtime -f /metadata/log.txt -r 1024 -n 2
