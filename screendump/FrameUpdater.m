#import "FrameUpdater.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

@implementation FrameUpdater {
	
	// Process
	NSOperationQueue *_q;
	BOOL _updatingFrames;
	uint32_t _lastUpdatedSeed;
	NSTimer* _updateFrameTimer;
	CADisplayLink *_displayLink;

	// Shared from ScreenDumpVNC
	IOSurfaceRef _screenSurface;
	rfbScreenInfoPtr _rfbScreenInfo;
	IOSurfaceAcceleratorRef _accelerator;
	IOSurfaceRef _staticBuffer;
	size_t _width;
	size_t _height;
}

-(instancetype)initWithSurfaceInfo:(IOSurfaceRef)screenSurface rfbScreenInfo:(rfbScreenInfoPtr)rfbScreenInfo accelerator:(IOSurfaceAcceleratorRef)accelerator staticBuffer:(IOSurfaceRef)staticBuffer width:(size_t)width height:(size_t)height {
	if ((self = [super init])) {
		_q = [[NSOperationQueue alloc] init];
		_updatingFrames = NO;
		_lastUpdatedSeed = 0;
		_updateFrameTimer = nil;

		_screenSurface = screenSurface;
		_rfbScreenInfo = rfbScreenInfo;
		_accelerator = accelerator;
		_staticBuffer = staticBuffer;
		_width = width;
		_height = height;
	}
	return self;
}


-(void)_updateFrame {
	[_q addOperationWithBlock: ^{
		if (!_updatingFrames) {
			[self stopFrameLoop];
			return;
		}
		// Check if screen changed
		uint32_t currentFrameSeed = IOSurfaceGetSeed(_screenSurface);
		
		// Only proceed if the screen has changed and the VNC is active
		if (_lastUpdatedSeed != currentFrameSeed && rfbIsActive(_rfbScreenInfo)) {
			_lastUpdatedSeed = currentFrameSeed;
			
			// Optimize the transfer by checking if the accelerator is available
			if (_accelerator) {
				IOSurfaceAcceleratorTransferSurface(_accelerator, _screenSurface, _staticBuffer, NULL, NULL, NULL, NULL);
			}
			
			// Mark the entire screen as modified only if necessary
			if (_width > 0 && _height > 0) {
				rfbMarkRectAsModified(_rfbScreenInfo, 0, 0, _width, _height);
			}
		}
	}];
}

-(void)startFrameLoop {
    [self stopFrameLoop];
    _updatingFrames = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_updateFrame)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    });
}

-(void)stopFrameLoop {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    _updatingFrames = NO;
}

-(void)dealloc {
    [self stopFrameLoop];
}

@end
