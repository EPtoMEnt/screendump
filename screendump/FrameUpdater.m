#import "FrameUpdater.h"

@implementation FrameUpdater {
	
	// Process
	NSOperationQueue *_q;
	BOOL _updatingFrames;
	uint32_t _lastUpdatedSeed;
	NSTimer* _updateFrameTimer;

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
	if (!_updatingFrames) {
		[self stopFrameLoop];
		return;
	}

	// check if screen changed
	uint32_t currentFrameSeed = IOSurfaceGetSeed(_screenSurface);
	
	if (_lastUpdatedSeed != currentFrameSeed && rfbIsActive(_rfbScreenInfo)) {
		_lastUpdatedSeed = currentFrameSeed;
		[_q addOperationWithBlock: ^{
			IOSurfaceAcceleratorTransferSurface(_accelerator, _screenSurface, _staticBuffer, NULL, NULL, NULL, NULL);
			rfbMarkRectAsModified(_rfbScreenInfo, 0, 0, _width, _height);
		}];
	}
}

-(void)stopFrameLoop {
	if (_updateFrameTimer == nil || ![_updateFrameTimer isValid]) return;

	dispatch_async(dispatch_get_main_queue(), ^(void){
		[_updateFrameTimer invalidate];
		_updatingFrames = NO;
	});
}

-(void)startFrameLoop {
	// if (size_image == 0) VNCSetup();
	[self stopFrameLoop];
	_updatingFrames = YES;
	dispatch_async(dispatch_get_main_queue(), ^(void){
		_updateFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1/400 target:self selector:@selector(_updateFrame) userInfo:nil repeats:YES];
	});
}

-(void)dealloc {
    [self stopFrameLoop];
}

@end
