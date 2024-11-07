export THEOS_PACKAGE_SCHEME = rootless
export ARCHS = arm64 arm64e
export TARGET = iphone:16.5:14.0
export GO_EASY_ON_ME = 1
export COPYFILE_DISABLE=1

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += Capturer Server

include $(THEOS_MAKE_PATH)/aggregate.mk

after-screendumpd-stage::
	$(ECHO_NOTHING)$(FAKEROOT) chown root:wheel $(THEOS_STAGING_DIR)/Library/LaunchDaemons/ru.mostmodest.screendumpd.plist$(ECHO_END)