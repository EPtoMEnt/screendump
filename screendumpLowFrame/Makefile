TARGET = iphone:16.5:14.0

include $(THEOS)/makefiles/common.mk

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
	PACKAGE_BUILDNAME := rootless
else
	PACKAGE_BUILDNAME := rootful
endif

TOOL_NAME = screendumpd
$(TOOL_NAME)_FILES = main.mm
export ARCHS = arm64
$(TOOL_NAME)_ARCHS = arm64
ARCHS = arm64
$(TOOL_NAME)_VALID_ARCHS = arm64
$(TOOL_NAME)_FRAMEWORKS := IOSurface IOKit
$(TOOL_NAME)_PRIVATE_FRAMEWORKS := IOMobileFramebuffer IOSurface

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
    # Rootless
    $(TOOL_NAME)_OBJCFLAGS += -IscreendumpLowFrame/vncbuild/include -Iinclude
    $(TOOL_NAME)_LDFLAGS += -Wl,-segalign,4000 -LscreendumpLowFrame/vncbuild/lib -lvncserver -lpng -llzo2 -ljpeg -lssl -lcrypto -lz
    $(TOOL_NAME)_INSTALL_PATH = /usr/libexec
else
    # Rootful settings
    $(TOOL_NAME)_OBJCFLAGS += -Ivncbuild/include -Iinclude
    $(TOOL_NAME)_LDFLAGS += -Wl,-segalign,4000 -Lvncbuild/lib -lvncserver -lpng -llzo2 -ljpeg -lssl -lcrypto -lz
    $(TOOL_NAME)_INSTALL_PATH = /usr/libexec
endif

$(TOOL_NAME)_CFLAGS = -w
$(TOOL_NAME)_CODESIGN_FLAGS = "-Sen.plist"

include $(THEOS_MAKE_PATH)/tool.mk

SUBPROJECTS += hooks

include $(THEOS_MAKE_PATH)/aggregate.mk

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
after-screendumpd-stage::
	$(ECHO_NOTHING) rm $(THEOS_STAGING_DIR)/Library/LaunchDaemons/com.julioverne.screendumpd.plist$(ECHO_END)
	$(ECHO_NOTHING) mv $(THEOS_STAGING_DIR)/Library/LaunchDaemons/com.julioverne.screendumpd.rootless.plist $(THEOS_STAGING_DIR)/Library/LaunchDaemons/com.julioverne.screendumpd.plist$(ECHO_END)
	$(ECHO_NOTHING)$(FAKEROOT) chown root:wheel $(THEOS_STAGING_DIR)/Library/LaunchDaemons/com.julioverne.screendumpd.plist$(ECHO_END)
else
after-screendumpd-stage::
	$(ECHO_NOTHING) rm $(THEOS_STAGING_DIR)/Library/LaunchDaemons/com.julioverne.screendumpd.rootless.plist$(ECHO_END)
	$(ECHO_NOTHING)$(FAKEROOT) chown root:wheel $(THEOS_STAGING_DIR)/Library/LaunchDaemons/com.julioverne.screendumpd.plist$(ECHO_END)
endif