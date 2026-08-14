#
# Copyright (C) 2020-2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Kernel
BOARD_KERNEL_IMAGE_NAME := Image.lz4
TARGET_COMPILE_WITH_MSM_KERNEL := true
TARGET_KERNEL_CONFIG := sunfish_defconfig
TARGET_KERNEL_SOURCE := kernel/google/msm-4.14
# Kernel toolchain -- MUST match the kernel source in kernel/google/msm-4.14:
#
#   abu-adm 16-ksu (KernelSU-Next + susfs, branch sunfish-abu-16ksu)
#       -> platform Clang 21 (r563880c), the line active below.
#          This tree uses modern constructs (e.g. scoped_guard() in
#          kernel/locking/rtmutex.c) that Clang 12 rejects with
#          -Werror,-Wunused-variable. Upstream builds it with Clang 21 too.
#
#   Evolution X's own kernel (branches sunfish-build-fixes / sunfish-ksu-susfs /
#   sunfish-ksunext-susfs)
#       -> Clang 12 (r416183b); the platform Clang 21's stricter diagnostics
#          reject that older source. Swap the two lines below when building those.
TARGET_KERNEL_CLANG_PATH := $(abspath prebuilts/clang/host/$(HOST_PREBUILT_TAG)/clang-r563880c)
#TARGET_KERNEL_CLANG_PATH := $(abspath prebuilts/clang/kernel/$(HOST_PREBUILT_TAG)/clang-r416183b)
TARGET_NEEDS_DTBOIMAGE := true

# Partitions
AB_OTA_PARTITIONS += \
    vendor
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4

# SELinux
BOARD_SEPOLICY_DIRS += device/google/sunfish/sepolicy-lineage/dynamic
BOARD_SEPOLICY_DIRS += device/google/sunfish/sepolicy-lineage/vendor

# Verified Boot
ifneq ($(WITH_AVB),true)
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
endif

include vendor/google/sunfish/BoardConfigVendor.mk
