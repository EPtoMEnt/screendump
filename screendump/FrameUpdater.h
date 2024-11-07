#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <rfb/rfb.h>
#import "IOMobileFramebuffer.h"

@interface FrameUpdater : NSObject
-(instancetype)initWithSurfaceInfo:(IOSurfaceRef)screenSurface rfbScreenInfo:(rfbScreenInfoPtr)rfbScreenInfo accelerator:(IOSurfaceAcceleratorRef)accelerator staticBuffer:(IOSurfaceRef)staticBuffer width:(size_t)width height:(size_t)height;
- (void)startFrameLoop;
- (void)stopFrameLoop;
@end
