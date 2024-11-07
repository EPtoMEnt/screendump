#import <Foundation/Foundation.h>

@interface FrameUpdater : NSObject
@property (nonatomic, retain) NSTimer* myTimer;
@property (nonatomic) BOOL isEnabled;
- (void)startFrameLoop;
- (void)stopFrameLoop;
@end
