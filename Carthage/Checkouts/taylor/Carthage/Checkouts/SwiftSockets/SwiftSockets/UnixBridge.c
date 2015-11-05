//
//  UnixBridge.c
//  SwiftSockets
//
//  Created by Helge Heß on 6/26/14.
//  Copyright (c) 2014-2015 Always Right Institute. All rights reserved.
//

#include <fcntl.h>
#include <sys/ioctl.h>

int ari_fcntlVi(int fildes, int cmd, int val) {
  return fcntl(fildes, cmd, val);
}

int ari_ioctlVip(int fildes, unsigned long request, int *val) {
  return ioctl(fildes, request, val);
}
