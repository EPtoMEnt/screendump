#import <Foundation/Foundation.h>
#import <stdio.h>
#import "ScreenDumpVNC.h"
#import "utils.h"

#define kPreferencesNotify "ru.mostmodest.screendump/restart"

int main(int argc, char *argv[], char *envp[]) {
	@autoreleasepool {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)exitProcess, CFSTR(kPreferencesNotify), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

        [ScreenDumpVNC load];
        [[NSRunLoop currentRunLoop] run];
		CFRunLoopRun();
		return 0;
	}
}