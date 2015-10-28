//
//  SwiftSockets.h
//  SwiftSockets
//
//  Created by Helge Heß on 6/13/14.
//  Copyright (c) 2014-2015 Always Right Institute. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for SwiftSockets.
FOUNDATION_EXPORT double SwiftSocketsVersionNumber;

//! Project version string for SwiftSockets.
FOUNDATION_EXPORT const unsigned char SwiftSocketsVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SwiftSockets/PublicHeader.h>


// Frameworks have no bridging headers anymore. The only way to expose functions
// is to put them in the public header.

// I think the originals are not mapped because they are using varargs
FOUNDATION_EXPORT int ari_fcntlVi (int fildes, int cmd, int val);
FOUNDATION_EXPORT int ari_ioctlVip(int fildes, unsigned long request, int *val);
