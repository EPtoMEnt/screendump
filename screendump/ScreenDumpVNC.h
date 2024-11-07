#import <Foundation/Foundation.h>
#import <rfb/rfb.h>

#define kVNCServerName "ScreenDumpVNC"

@interface ScreenDumpVNC : NSObject
+(void)load;
+(instancetype)sharedInstance;
-(rfbBool)handleVNCAuthorization:(rfbClientPtr)client data:(const char *)data size:(int)size;
-(size_t)width;
-(size_t)height;
@end