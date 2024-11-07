export THEOS_PACKAGE_SCHEME = rootless
export ARCHS = arm64
export TARGET = iphone:16.5:14.0
export GO_EASY_ON_ME = 1
export COPYFILE_DISABLE=1

include $(THEOS)/makefiles/common.mk

TOOL_NAME = screendumpd
$(TOOL_NAME)_FILES = main.mm
$(TOOL_NAME)_FRAMEWORKS := IOSurface IOKit
$(TOOL_NAME)_PRIVATE_FRAMEWORKS := IOMobileFramebuffer IOSurface
$(TOOL_NAME)_OBJCFLAGS += -I./vncbuild/include -Iinclude
$(TOOL_NAME)_LDFLAGS += -Wl,-segalign,4000 -L./vncbuild/lib  -lvncserver -lpng -llzo2 -ljpeg -lssl -lcrypto -lz
$(TOOL_NAME)_CFLAGS = -w
$(TOOL_NAME)_CODESIGN_FLAGS = "-Sen.plist"
$(TOOL_NAME)_INSTALL_PATH = /usr/libexec

before-stage::
	$(ECHO_NOTHING)find . -name '.DS_Store' -type f -delete$(ECHO_END)
	$(ECHO_NOTHING)chmod 0775 layout/DEBIAN/*$(ECHO_END)

include $(THEOS_MAKE_PATH)/tool.mk
