#import <errno.h>
#import <substrate.h>
#import <notify.h>
#import <UIKit/UIKit.h>
#import <rootless.h>

#define kSettingsPath @"/var/mobile/Library/Preferences/com.cosmosgenius.screendump.plist"

extern "C" UIImage* _UICreateScreenUIImage();

static BOOL isEnabled;
static BOOL isBlackScreen;

@interface CapturerScreen : NSObject
- (void)start;
@end

@implementation CapturerScreen

-(id)init
{
	NSLog(@"screendump bb: CapturerScreen init");
	self = [super init];
	// [self start];
	return self;
}

+(void)load
{
	CapturerScreen* instance = [self sharedInstance];
	[instance start];
}

+(instancetype)sharedInstance
{
	static dispatch_once_t onceToken = 0;
	__strong static CapturerScreen* sharedInstance = nil;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

-(unsigned char *)pixelBRGABytesFromImageRef:(CGImageRef)imageRef
{
    
    NSUInteger iWidth = CGImageGetWidth(imageRef);
    NSUInteger iHeight = CGImageGetHeight(imageRef);
    NSUInteger iBytesPerPixel = 4;
    NSUInteger iBytesPerRow = iBytesPerPixel * iWidth;
    NSUInteger iBitsPerComponent = 8;
    unsigned char *imageBytes = (unsigned char *)malloc(iWidth * iHeight * iBytesPerPixel);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(imageBytes,
                                                 iWidth,
                                                 iHeight,
                                                 iBitsPerComponent,
                                                 iBytesPerRow,
                                                 colorspace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGRect rect = CGRectMake(0 , 0 , iWidth, iHeight);
    CGContextDrawImage(context , rect ,imageRef);
    CGColorSpaceRelease(colorspace);
    CGContextRelease(context);
    CGImageRelease(imageRef);
    
    return imageBytes;
}
-(unsigned char *)pixelBRGABytesFromImage:(UIImage *)image
{
    return [self pixelBRGABytesFromImageRef:image.CGImage];
}
-(void)start
{
	dispatch_async(dispatch_get_main_queue(), ^(void){
		NSLog(@"screendumpbb: setting capture timer every 0.4f");
		[NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(capture) userInfo:nil repeats:YES];
	});
}
-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0f);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
	[image release];
    return newImage;
}
-(void)capture
{
	NSLog(@"screendumpbb: capture");
	@autoreleasepool {
		
		NSLog(@"screendumpbb: capture - isBlackScreen: %d", isBlackScreen);
		NSLog(@"screendumpbb: capture - isEnabled: %d", isEnabled);
		if(isBlackScreen || !isEnabled) {
			return;
		}
		
		UIImage* image = _UICreateScreenUIImage();
		NSLog(@"screendumpbb: capture - got frame, now resizing...");
		
		CGSize newS = CGSizeMake(image.size.width, image.size.height);
		
		image = [[self imageWithImage:image scaledToSize:newS] copy];
		
		CGImageRef imageRef = image.CGImage;
		
		NSUInteger iWidth = CGImageGetWidth(imageRef);
		NSUInteger iHeight = CGImageGetHeight(imageRef);
		NSUInteger iBytesPerPixel = 4;
		
		size_t size = iWidth * iHeight * iBytesPerPixel;
		
		unsigned char * bytes = [self pixelBRGABytesFromImageRef:imageRef];
		NSLog(@"screendumpbb: capture - resize complete, got bytes");
		
		dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			@autoreleasepool {
				NSLog(@"screendumpbb: capture - writing buffer...");
				NSData *imageData = [NSData dataWithBytesNoCopy:bytes length:size freeWhenDone:YES];
				[imageData writeToFile:@"//tmp/screendump_Buff.tmp" atomically:YES];
				[@{@"width":@(iWidth), @"height":@(iHeight), @"size":@(size),} writeToFile:@"//tmp/screendump_Info.tmp" atomically:YES];
				NSLog(@"screendumpbb: capture - notifying daemon");
				notify_post("com.julioverne.screendump/frameChanged");
			}
		});
	}
}

@end

/*
%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
	%orig;
	CapturerScreen* cap = [[CapturerScreen alloc] init];
	[cap start];
}
%end
*/

static void screenDisplayStatus(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo)
{
    uint64_t state;
    int token;
    notify_register_check("com.apple.iokit.hid.displayStatus", &token);
    notify_get_state(token, &state);
    notify_cancel(token);
    if(!state) {
		isBlackScreen = YES;
    } else {
		isBlackScreen = NO;
	}
	NSLog(@"screendumpbb: screenDisplayStatus - isBlackScreen: %d", isBlackScreen);
}

static void loadPrefs(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo)
{
	NSLog(@"screendumpbb: loadPrefs");
	@autoreleasepool {
		NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.cosmosgenius.screendump"];
		isEnabled = [[defaults objectForKey:@"CCSisEnabled"]?:@NO boolValue];
		NSLog(@"screendumpbb: loadPrefs - isEnabled: %d", isEnabled);
	}
}

%ctor
{
	NSLog(@"screendumpbb: ctor");
	isEnabled = NO;
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, screenDisplayStatus, CFSTR("com.apple.iokit.hid.displayStatus"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	NSLog(@"screendumpbb: ctor 1");
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, loadPrefs, CFSTR("com.cosmosgenius.screendump/preferences.changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	NSLog(@"screendumpbb: ctor 2");
	
	loadPrefs(NULL, NULL, NULL, NULL, NULL);
	NSLog(@"screendumpbb: ctor 3");
}