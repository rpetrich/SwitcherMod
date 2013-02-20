TWEAK_NAME = SwitcherMod
SwitcherMod_FILES = SwitcherMod.x
SwitcherMod_FRAMEWORKS = Foundation UIKit

ADDITIONAL_CFLAGS = -std=c99

SDKVERSION := 5.1
INCLUDE_SDKVERSION := 6.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 4.0

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
