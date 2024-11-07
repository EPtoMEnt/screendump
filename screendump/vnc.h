#import <Foundation/Foundation.h>
#import <rfb/rfb.h>
#import <rfb/keysym.h>
#import "IOHID.h"

extern void handleVNCKeyboard(rfbBool down, rfbKeySym key, rfbClientPtr client);
extern void handleVNCPointer(int buttons, int x, int y, rfbClientPtr client);
extern rfbBool handleVNCAuthorization(rfbClientPtr client, const char *data, int size);