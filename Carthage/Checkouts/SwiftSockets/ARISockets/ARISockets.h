//
//  ARISockets.h
//  ARISockets
//
//  Created by Helge Heß on 6/13/14.
//
//

#import <Foundation/Foundation.h>

//! Project version number for ARISockets.
FOUNDATION_EXPORT double ARISocketsVersionNumber;

//! Project version string for ARISockets.
FOUNDATION_EXPORT const unsigned char ARISocketsVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ARISockets/PublicHeader.h>


// Frameworks have no bridging headers anymore. The only way to expose functions
// is to put them in the public header.

// I think the originals are not mapped because they are using varargs
FOUNDATION_EXPORT int ari_fcntlVi (int fildes, int cmd, int val);
FOUNDATION_EXPORT int ari_ioctlVip(int fildes, unsigned long request, int *val);
