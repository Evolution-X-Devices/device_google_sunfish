#
# Copyright (C) 2020-2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inside BoardConfig.mk
#TARGET_KERNEL_ADDITIONAL_FLAGS := KCFLAGS="-DCCACHE_FORCE_UPDATE_1"

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
#
#   kernel branch "compiler" (clang-20 port) -- VERIFIED BOOTING 2026-09-06
#       -> Clang 20 (r547379), the line active below. This is byte-for-byte
#          the same toolchain the official EvolutionX 11.5.3 sunfish OTA was
#          built with (banner: "Android (13290119, +pgo, +bolt, +lto, +mlgo,
#          based on r547379) clang version 20.0.0"), so it is known to build
#          this kernel family. lopro ships 4.14.357 built with Clang 21.
#          Built clean first try and booted in 28s with CFI_CLANG=y,
#          LTO_CLANG=y, FTRACE=y; zygote + zygisksu healthy.
TARGET_KERNEL_CLANG_PATH := $(abspath prebuilts/clang/host/$(HOST_PREBUILT_TAG)/clang-r547379)
#TARGET_KERNEL_CLANG_PATH := $(abspath prebuilts/clang/host/$(HOST_PREBUILT_TAG)/clang-r563880c)
#TARGET_KERNEL_CLANG_PATH := $(abspath prebuilts/clang/kernel/$(HOST_PREBUILT_TAG)/clang-r416183b)
TARGET_NEEDS_DTBOIMAGE := true

# Partitions
AB_OTA_PARTITIONS += \
    vendor
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs

# SELinux
BOARD_SEPOLICY_DIRS += device/google/sunfish/sepolicy-lineage/dynamic
BOARD_SEPOLICY_DIRS += device/google/sunfish/sepolicy-lineage/vendor
BOARD_SEPOLICY_DIRS += device/google/sunfish/prebuilts/extra-apps/sepolicy

# Verified Boot
ifneq ($(WITH_AVB),true)
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
endif

include vendor/google/sunfish/BoardConfigVendor.mk

# libksud.so is shipped via PRODUCT_COPY_FILES in device.mk (see comment
# there for why) -- this flag is what actually permits an ELF binary
# through that mechanism; it's board-scoped and silently ignored if set
# from a product .mk like device.mk instead.
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# PRODUCT_COPY_FILES's copy-one-file rule uses plain `cp` (no -p), which
# drops the source file's executable bit regardless of what it was, and the
# app execs this file directly as a subprocess. Force it via a separate
# stamp file (referencing $(PRODUCT_OUT) as a rule prerequisite from
# device.mk hits a "||PRODUCT-PATH-PH||" placeholder-substitution bug --
# PRODUCT_OUT isn't fully resolved yet at product-config-parse time;
# BoardConfigLineage.mk runs later and is fine).
libksud_chmod_stamp := $(OUT_DIR)/libksud_chmod.stamp
$(libksud_chmod_stamp): $(PRODUCT_OUT)/$(TARGET_COPY_OUT_PRODUCT)/app/KernelSUNext/lib/arm64/libksud.so
	chmod 755 $<
	touch $@
droidcore: $(libksud_chmod_stamp)
