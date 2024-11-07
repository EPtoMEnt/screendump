#import "ScreenDumpVNC.h"
#import "FrameUpdater.h"
#import "utils.h"
#import "vnc.h"
#import <UIKit/UIKit.h>
#import <rfb/rfb.h>
#import "IOMobileFramebuffer.h"

@implementation ScreenDumpVNC {
	int _prefsHeight;
	int _prefsWidth;
	bool _enabled;
	NSString *_password;
	rfbScreenInfoPtr _rfbScreenInfo;
	bool _vncIsRunning;

	// sent to FrameUpdater
	IOSurfaceRef _screenSurface;
	size_t _sizeImage;
	IOSurfaceAcceleratorRef _accelerator;
	IOSurfaceRef _staticBuffer;
	size_t _width;
	size_t _height;

	FrameUpdater *_frameUpdater;
}

+(void)load {
	ScreenDumpVNC* sharedInstance = [self sharedInstance];
	if (![sharedInstance enabled]) return;
	[sharedInstance setupScreenInfo];
	[sharedInstance startVNCServer];
}

+(instancetype)sharedInstance {
	static dispatch_once_t onceToken = 0;
	__strong static ScreenDumpVNC* sharedInstance = nil;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

-(instancetype)init {
	if ((self = [super init])) {
        // TODO: init procedures
		[self loadPrefs];
	}
	return self;
}

-(void)loadPrefs {
    NSDictionary* defaults = getPrefsForAppId(@"ru.mostmodest.screendump");
	NSNumber *height = [defaults objectForKey:@"height"];
	_prefsHeight = height ? [height intValue] : 0;

	NSNumber *width = [defaults objectForKey:@"width"];
	_prefsWidth = width ? [width intValue] : 0;

	NSNumber *enabled = [defaults objectForKey:@"enabled"];
	_enabled = enabled ? [enabled boolValue] : NO;
	_password = [defaults objectForKey:@"password"];
}

-(void)setupVNCAuthentication {
	if (_rfbScreenInfo == nil) return;

	_rfbScreenInfo->authPasswdData = nil;
	if (_password && _password.length) {
        _rfbScreenInfo->authPasswdData = (void *)_password;
    }
}

-(void)startVNCServer {
	if (_rfbScreenInfo == nil || _vncIsRunning == YES) return;

	[self setupVNCAuthentication];
    rfbInitServer(_rfbScreenInfo);
    rfbRunEventLoop(_rfbScreenInfo, -1, YES);
	[_frameUpdater startFrameLoop];
}

-(void)shutdownVNCServer {
	// unused
	if (_rfbScreenInfo == nil || _vncIsRunning == NO) return;

	[_frameUpdater stopFrameLoop];
    rfbShutdownServer(_rfbScreenInfo, YES);
}

-(void)setupScreenInfo {
	size_t bytesPerPixel;
	size_t bitsPerSample;

	if (!_screenSurface) {
		IOMobileFramebufferRef framebufferConnection;

		IOSurfaceAcceleratorCreate(kCFAllocatorDefault, 0, &_accelerator);
		IOMobileFramebufferGetMainDisplay(&framebufferConnection);
		IOMobileFramebufferGetLayerDefaultSurface(framebufferConnection, 0, &_screenSurface);

        if (_screenSurface == NULL) IOMobileFramebufferCopyLayerDisplayedSurface(framebufferConnection, 0, &_screenSurface);

		_width = _prefsWidth == 0 ? IOSurfaceGetWidth(_screenSurface) : _prefsWidth;
		_height = _prefsHeight == 0 ? IOSurfaceGetHeight(_screenSurface) : _prefsHeight;

		_sizeImage = IOSurfaceGetAllocSize(_screenSurface);
		// TODO: do these change at all? this might have been done for perf reasons
		// bytesPerRow = IOSurfaceGetBytesPerRow(_screenSurface);
		// pixelF = IOSurfaceGetPixelFormat(_screenSurface);

		bytesPerPixel = 4; // IOSurfaceGetBytesPerElement(_screenSurface);
		bitsPerSample = 8;

		_staticBuffer = IOSurfaceCreate((CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
            @"PurpleEDRAM", kIOSurfaceMemoryRegion,
            // [NSNumber numberWithBool:YES], kIOSurfaceIsGlobal,
            [NSNumber numberWithInt:bytesPerPixel*_width], kIOSurfaceBytesPerRow,
			[NSNumber numberWithInt:bytesPerPixel], kIOSurfaceBytesPerElement,
            [NSNumber numberWithInt:_width], kIOSurfaceWidth,
            [NSNumber numberWithInt:_height], kIOSurfaceHeight,
            [NSNumber numberWithInt:'BGRA'], kIOSurfacePixelFormat,
            [NSNumber numberWithInt:(_width*_height*bytesPerPixel)], kIOSurfaceAllocSize,
        nil]);
	}
	
    int argc = 1;
    char *arg0 = strdup(kVNCServerName);
    char *argv[] = {arg0, NULL};
	int samplesPerPixel = 3;

    _rfbScreenInfo = rfbGetScreen(&argc, argv, _width, _height, bitsPerSample, samplesPerPixel, bytesPerPixel);
	
    _rfbScreenInfo->frameBuffer = (char *)IOSurfaceGetBaseAddress((IOSurfaceRef)CFRetain(_staticBuffer));
    _rfbScreenInfo->serverFormat.redShift = bitsPerSample * 2;
    _rfbScreenInfo->serverFormat.greenShift = bitsPerSample * 1;
    _rfbScreenInfo->serverFormat.blueShift = bitsPerSample * 0;

    _rfbScreenInfo->kbdAddEvent = &handleVNCKeyboard;
    _rfbScreenInfo->ptrAddEvent = &handleVNCPointer;
    _rfbScreenInfo->passwordCheck = &handleVNCAuthorization;

    free(arg0);

	_frameUpdater = [[FrameUpdater alloc] initWithSurfaceInfo:_screenSurface rfbScreenInfo:_rfbScreenInfo accelerator:_accelerator staticBuffer:_staticBuffer width:_width height:_height];
}

-(rfbBool)handleVNCAuthorization:(rfbClientPtr)client data:(const char *)data size:(int)size {
    NSString *password = (__bridge NSString *)(_rfbScreenInfo->authPasswdData);
    if (!password) {
        return TRUE;
    }
    if ([password length] == 0) {
        return TRUE;
    }
    rfbEncryptBytes(client->authChallenge, (char *)[password UTF8String]);
    bool good = (memcmp(client->authChallenge, data, size) == 0);
    return good;
}

-(size_t)width {
	return _width;
}

-(size_t)height {
	return _height;
}

-(bool)enabled {
	return _enabled;
}

@end
