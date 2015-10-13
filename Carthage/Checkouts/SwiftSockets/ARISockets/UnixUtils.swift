//
//  UnixUtils.swift
//  ARISockets
//
//  Created by Helge Hess on 6/10/14.
//  Copyright (c) 2014 Always Right Institute. All rights reserved.
//

import Darwin


/* network utility functions */

func ntohs(value: CUnsignedShort) -> CUnsignedShort {
  // hm, htons is not a func in OSX and the macro is not mapped
  return (value << 8) + (value >> 8);
}
let htons = ntohs // same thing, swap bytes :-)



/* ioctl / ioccom stuff */

let IOC_OUT  : CUnsignedLong = 0x40000000

// hh: not sure this is producing the right value
let FIONREAD : CUnsignedLong =
  ( IOC_OUT
  | ((CUnsignedLong(sizeof(Int32)) & CUnsignedLong(IOCPARM_MASK)) << 16)
  | (102 /* 'f' */ << 8) | 127)


/* dispatch convenience */

import Dispatch

extension dispatch_source_t {
  
  func onEvent(cb: (dispatch_source_t, CUnsignedLong) -> Void) {
    dispatch_source_set_event_handler(self) {
      let data = dispatch_source_get_data(self)
      cb(self, data)
    }
  }
}
