#!/bin/bash

# Replace sepolicy required
rm -rf device/evolution/sepolicy
git clone https://github.com/Evolution-X/device_evolution_sepolicy -b udc-p device/evolution/sepolicy
