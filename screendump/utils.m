#import "utils.h"

NSDictionary* getPrefsForAppId(NSString *appID) {
    NSDictionary* defaults = nil;
	CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)appID, CFSTR("mobile"), kCFPreferencesAnyHost);
	if (keyList) {
		defaults = (NSDictionary *)CFPreferencesCopyMultiple(keyList, (CFStringRef)appID, CFSTR("mobile"), kCFPreferencesAnyHost) ? : @{};
		CFRelease(keyList);
	}
    return defaults;
}

void exitProcess() {
	exit(0);
}