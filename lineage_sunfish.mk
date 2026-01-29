#
# Copyright (C) 2020-2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit device configuration
$(call inherit-product, device/google/sunfish/aosp_sunfish.mk)

include device/google/sunfish/device-lineage.mk

# Device identifier. This must come after all inclusions
PRODUCT_BRAND := google
PRODUCT_MODEL := Pixel 4a
PRODUCT_NAME := lineage_sunfish

# Boot animation
TARGET_SCREEN_HEIGHT := 2340
TARGET_SCREEN_WIDTH := 1080

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="sunfish-user 13 TQ3A.230805.001.S1 10786265 release-keys" \
    BuildFingerprint=google/sunfish/sunfish:13/TQ3A.230805.001.S1/10786265:user/release-keys \
    DeviceProduct=sunfish

ifeq ($(WITH_GMS),false)
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/apex/com.google.android.permission.apex
else
# Gapps
TARGET_USES_MINI_GAPPS := true

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/app/GoogleExtShared/GoogleExtShared.apk \
    system/app/GooglePrintRecommendationService/GooglePrintRecommendationService.apk \
    system/apex/com.google.android.permission.apex \
    system/etc/permissions/privapp-permissions-google.xml \
    system/etc/permissions/privapp_allowlist_com.google.android.ext.services.xml \
    system/priv-app/GoogleExtServices/GoogleExtServices.apk \
    system/priv-app/DocumentsUIGoogle/DocumentsUIGoogle.apk \
    system/priv-app/TagGoogle/TagGoogle.apk
endif

$(call inherit-product, vendor/google/sunfish/sunfish-vendor.mk)
