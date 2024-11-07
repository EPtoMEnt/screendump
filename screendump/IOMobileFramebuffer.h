#import <UIKit/UIKit.h>

typedef void *IOMobileFramebufferRef;
typedef void *IOSurfaceAcceleratorRef;
typedef struct __IOMobileFramebuffer *IOMobileFramebufferConnection;

extern CFStringRef kIOSurfaceMemoryRegion;
extern const CFStringRef kIOSurfaceIsGlobal;

extern void IOMobileFramebufferGetDisplaySize(IOMobileFramebufferRef connect, CGSize *size);
extern int IOSurfaceAcceleratorCreate(CFAllocatorRef allocator, int type, IOSurfaceAcceleratorRef *accel);
extern unsigned int IOSurfaceAcceleratorTransferSurface(IOSurfaceAcceleratorRef accelerator, IOSurfaceRef dest, IOSurfaceRef src, void *, void *, void *, void *);

extern kern_return_t IOMobileFramebufferSwapSetLayer(
    IOMobileFramebufferRef fb,
    int layer,
    IOSurfaceRef buffer,
    CGRect bounds,
    CGRect frame,
    int flags
);
typedef mach_port_t io_service_t;
typedef kern_return_t IOReturn;
typedef IOReturn IOMobileFramebufferReturn;
typedef io_service_t IOMobileFramebufferService;
extern void IOSurfaceFlushProcessorCaches(IOSurfaceRef buffer);
extern int IOSurfaceLock(IOSurfaceRef surface, uint32_t options, uint32_t *seed);
extern int IOSurfaceUnlock(IOSurfaceRef surface, uint32_t options, uint32_t *seed);
extern Boolean IOSurfaceIsInUse(IOSurfaceRef buffer);
extern CFMutableDictionaryRef IOServiceMatching(const char *name);
extern const mach_port_t kIOMasterPortDefault;
extern io_service_t IOServiceGetMatchingService(mach_port_t masterPort, CFDictionaryRef matching);
extern IOMobileFramebufferReturn IOMobileFramebufferGetLayerDefaultSurface(IOMobileFramebufferRef pointer, int surface, IOSurfaceRef *buffer);
extern IOMobileFramebufferReturn IOMobileFramebufferCopyLayerDisplayedSurface(IOMobileFramebufferRef pointer, int surface, IOSurfaceRef *buffer);
extern IOMobileFramebufferReturn IOMobileFramebufferOpen(IOMobileFramebufferService service, mach_port_t owningTask, unsigned int type, IOMobileFramebufferRef *pointer);
extern IOMobileFramebufferReturn IOMobileFramebufferGetMainDisplay(IOMobileFramebufferRef *pointer);
extern mach_port_t mach_task_self();