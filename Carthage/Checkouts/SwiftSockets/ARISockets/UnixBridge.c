//
//  UnixBridge.c
//  ARISockets
//
//  Created by Helge Heß on 6/26/14.
//

#include <fcntl.h>
#include <sys/ioctl.h>

int ari_fcntlVi(int fildes, int cmd, int val) {
  return fcntl(fildes, cmd, val);
}

int ari_ioctlVip(int fildes, unsigned long request, int *val) {
  return ioctl(fildes, request, val);
}
