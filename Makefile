TWEAK_NAME = SwitcherMod
SwitcherMod_FILES = SwitcherMod.x
SwitcherMod_FRAMEWORKS = Foundation UIKit

ADDITIONAL_CFLAGS = -std=c99

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
