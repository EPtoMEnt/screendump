#import "./include/IOKit/hid/IOHIDEventTypes.h"
#import "./include/IOKit/hidsystem/IOHIDUsageTables.h"

typedef uint32_t IOHIDDigitizerTransducerType;

#ifdef __LP64__
typedef double IOHIDFloat;
#else
typedef float IOHIDFloat;
#endif

typedef UInt32	IOOptionBits;
typedef uint32_t IOHIDEventField;

typedef uint32_t IOHIDEventOptionBits;
typedef struct __IOHIDEvent *IOHIDEventRef;
typedef struct CF_BRIDGED_TYPE(id) __IOHIDEventSystemClient * IOHIDEventSystemClientRef;
IOHIDEventRef IOHIDEventCreateKeyboardEvent(
    CFAllocatorRef allocator,
    uint64_t time, uint16_t page, uint16_t usage,
    Boolean down, IOHIDEventOptionBits flags
);
IOHIDEventRef IOHIDEventCreateDigitizerEvent(CFAllocatorRef allocator, uint64_t timeStamp, IOHIDDigitizerTransducerType type, uint32_t index, uint32_t identity, uint32_t eventMask, uint32_t buttonMask, IOHIDFloat x, IOHIDFloat y, IOHIDFloat z, IOHIDFloat tipPressure, IOHIDFloat barrelPressure, Boolean range, Boolean touch, IOOptionBits options);
IOHIDEventRef IOHIDEventCreateDigitizerFingerEvent(CFAllocatorRef allocator, uint64_t timeStamp, uint32_t index, uint32_t identity, uint32_t eventMask, IOHIDFloat x, IOHIDFloat y, IOHIDFloat z, IOHIDFloat tipPressure, IOHIDFloat twist, Boolean range, Boolean touch, IOOptionBits options);
IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);
void IOHIDEventAppendEvent(IOHIDEventRef parent, IOHIDEventRef child);
void IOHIDEventSetIntegerValue(IOHIDEventRef event, IOHIDEventField field, int value);
void IOHIDEventSetSenderID(IOHIDEventRef event, uint64_t sender);
void IOHIDEventSystemClientDispatchEvent(IOHIDEventSystemClientRef client, IOHIDEventRef event);
// void IOHIDEventSystemConnectionDispatchEvent(IOHIDEventSystemConnectionRef connection, IOHIDEventRef event);
