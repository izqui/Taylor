//
//  SocketAddress.swift
//  ARISockets
//
//  Created by Helge Heß on 6/12/14.
//  Copyright (c) 2014 Always Right Institute. All rights reserved.
//

import Darwin
// import Darwin.POSIX.netinet.`in` - this doesn't seem to work
// import struct Darwin.POSIX.netinet.`in`.sockaddr_in - neither

let INADDR_ANY = in_addr(s_addr: 0)

/**
 * in_addr represents an IPv4 address in Unix. We extend that a little bit
 * to increase it's usability :-)
 */
public extension in_addr {

  public init() {
    s_addr = INADDR_ANY.s_addr
  }
  
  public init(string: String?) {
    if let s = string {
      if s.isEmpty {
        s_addr = INADDR_ANY.s_addr
      }
      else {
        var buf = INADDR_ANY // Swift wants some initialization
        
        s.withCString { cs in inet_pton(AF_INET, cs, &buf) }
        s_addr = buf.s_addr
      }
    }
    else {
      s_addr = INADDR_ANY.s_addr
    }
  }
  
  public var asString: String {
    if self == INADDR_ANY {
      return "*.*.*.*"
    }
    
    let len   = Int(INET_ADDRSTRLEN) + 2
    var buf   = [CChar](count: len, repeatedValue: 0)
    
    var selfCopy = self // &self doesn't work, because it can be const?
    let cs = inet_ntop(AF_INET, &selfCopy, &buf, socklen_t(len))
    
    return String.fromCString(cs)!
  }
  
}

public func ==(lhs: in_addr, rhs: in_addr) -> Bool {
  return __uint32_t(lhs.s_addr) == __uint32_t(rhs.s_addr)
}

extension in_addr : Equatable, Hashable {
  
  public var hashValue: Int {
    // Knuth?
    return Int(UInt32(s_addr) * 2654435761 % (2^32))
  }
  
}

extension in_addr: StringLiteralConvertible {
  // this allows you to do: let addr : in_addr = "192.168.0.1"

  public init(stringLiteral value: StringLiteralType) {
    self.init(string: value)
  }
  
  public init(extendedGraphemeClusterLiteral v: ExtendedGraphemeClusterType) {
    self.init(string: v)
  }
  
  public init(unicodeScalarLiteral value: String) {
    // FIXME: doesn't work with UnicodeScalarLiteralType?
    self.init(string: value)
  }
}

extension in_addr: CustomStringConvertible {
  
  public var description: String {
    return asString
  }
    
}

public protocol SocketAddress {
  
  static var domain: Int32 { get }
  
  init() // create empty address, to be filled by eg getsockname()
  
  var len: __uint8_t { get }
}

extension sockaddr_in: SocketAddress {
  
  public static var domain = AF_INET // if you make this a let, swiftc segfaults
  public static var size   = __uint8_t(sizeof(sockaddr_in))
    // how to refer to self?
  
  public init() {
    sin_len    = sockaddr_in.size
    sin_family = sa_family_t(sockaddr_in.domain)
    sin_port   = 0
    sin_addr   = INADDR_ANY
    sin_zero   = (0,0,0,0,0,0,0,0)
  }
  
  public init(address: in_addr = INADDR_ANY, port: Int?) {
    self.init()
    
    sin_port = port != nil ? in_port_t(htons(CUnsignedShort(port!))) : 0
    sin_addr = address
  }
  
  public init(address: String?, port: Int?) {
    let isWildcard = address != nil
      ? (address! == "*" || address! == "*.*.*.*")
      : true;
    let ipv4       = isWildcard ? INADDR_ANY : in_addr(string: address)
    self.init(address: ipv4, port: port)
  }
  
  public init(string: String?) {
    if let s = string {
      if s.isEmpty {
        self.init(address: INADDR_ANY, port: nil)
      }
      else {
        // split string at colon
        let components = s.characters.split(":", maxSplit: 1).map { String($0) }
        if components.count == 2 {
          self.init(address: components[0], port: Int(components[1]))
        }
        else {
          assert(components.count == 1)
          let c1         = components[0]
          let isWildcard = (c1 == "*" || c1 == "*.*.*.*")
          if isWildcard {
            self.init(address: nil, port: nil)
          }
          else if let port = Int(c1) { // it's a number
            self.init(address: nil, port: port)
          }
          else { // it's a host
            self.init(address: c1, port: nil)
          }
        }
      }
    }
    else {
      self.init(address: INADDR_ANY, port: nil)
    }
  }
  
  public var port: Int { // should we make that optional and use wildcard as nil
    get {
      return Int(ntohs(sin_port))
    }
    set {
      sin_port = in_port_t(htons(CUnsignedShort(newValue)))
    }
  }
  
  public var address: in_addr {
    return sin_addr
  }
  
  public var isWildcardPort:    Bool { return sin_port == 0 }
  public var isWildcardAddress: Bool { return sin_addr == INADDR_ANY }
  
  public var len: __uint8_t { return sockaddr_in.size }

  public var asString: String {
    let addr = address.asString
    return isWildcardPort ? addr : "\(addr):\(port)"
  }
}

public func == (lhs: sockaddr_in, rhs: sockaddr_in) -> Bool {
  return (lhs.sin_addr.s_addr == rhs.sin_addr.s_addr)
      && (lhs.sin_port        == rhs.sin_port)
}

extension sockaddr_in: Equatable, Hashable {
  
  public var hashValue: Int {
    return sin_addr.hashValue + sin_port.hashValue
  }
  
}

/**
 * This allows you to do: let addr : sockaddr_in = "192.168.0.1:80"
 *
 * Adding an IntLiteralConvertible seems a bit too weird and ambigiuous to me.
 *
 * Note: this does NOT work:
 *   let s : sockaddr_in = "*:\(port)"
 * it requires:
 *   StringInterpolationConvertible
 */
extension sockaddr_in: StringLiteralConvertible {
  
  public init(stringLiteral value: String) {
    self.init(string: value)
  }
  
  public init(extendedGraphemeClusterLiteral v: ExtendedGraphemeClusterType) {
    self.init(string: v)
  }

  public init(unicodeScalarLiteral v: String) {
    // FIXME: doesn't work with UnicodeScalarLiteralType?
    self.init(string: v)
  }
}

extension sockaddr_in: CustomStringConvertible {
  
  public var description: String {
    return asString
  }
  
}

extension sockaddr_in6: SocketAddress {
  
  public static var domain = AF_INET6
  public static var size   = __uint8_t(sizeof(sockaddr_in6))
  
  public init() {
    sin6_len      = sockaddr_in6.size
    sin6_family   = sa_family_t(sockaddr_in.domain)
    sin6_port     = 0
    sin6_flowinfo = 0
    sin6_addr     = in6addr_any
    sin6_scope_id = 0
  }
  
  public var port: Int {
    get {
      return Int(ntohs(sin6_port))
    }
    set {
      sin6_port = in_port_t(htons(CUnsignedShort(newValue)))
    }
  }
  
  public var isWildcardPort: Bool { return sin6_port == 0 }
  
  public var len: __uint8_t { return sockaddr_in6.size }
}

extension sockaddr_un: SocketAddress {
  // TBD: sockaddr_un would be interesting as the size of the structure is
  //      technically dynamic (embedded string)
  
  public static var domain = AF_UNIX
  public static var size   = __uint8_t(sizeof(sockaddr_un)) // CAREFUL
  
  public init() {
    sun_len    = sockaddr_un.size // CAREFUL - kinda wrong
    sun_family = sa_family_t(sockaddr_un.domain)
    
    // Autsch!
    sun_path   = (
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0
    );
  }
  
  public var len: __uint8_t {
    // FIXME?: this is wrong. It needs to be the base size + string length in
    //         the buffer
    return sockaddr_un.size
  }
}


/* DNS */

extension addrinfo {
  
  public init() {
    ai_flags     = 0 // AI_CANONNAME, AI_PASSIVE, AI_NUMERICHOST
    ai_family    = AF_UNSPEC // AF_INET or AF_INET6 or AF_UNSPEC
    ai_socktype  = SOCK_STREAM
    ai_protocol  = 0   // or IPPROTO_xxx for IPv4
    ai_addrlen   = 0   // length of ai_addr below
    ai_canonname = nil // UnsafePointer<Int8>
    ai_addr      = nil // UnsafePointer<sockaddr>
    ai_next      = nil // UnsafePointer<addrinfo>
  }
  
  public init(flags: Int32, family: Int32) {
    self.init()
    ai_flags  = flags
    ai_family = family
  }
  
  public var hasNext : Bool {
    return ai_next != nil
  }
  public var next : addrinfo? {
    return hasNext ? ai_next.memory : nil
  }
  
  public var canonicalName : String? {
    guard ai_canonname != nil && ai_canonname[0] != 0 else { return nil }
    
    return String.fromCString(ai_canonname)
  }
  
  public var hasAddress : Bool {
    return ai_addr != nil
  }
  
  public var isIPv4 : Bool {
    return hasAddress &&
           (ai_addr.memory.sa_family == sa_family_t(sockaddr_in.domain))
  }
  
  public var addressIPv4 : sockaddr_in?  { return address() }
  /* Not working anymore in b4
  public var addressIPv6 : sockaddr_in6? { return address() }
   */
  
  public func address<T: SocketAddress>() -> T? {
    guard ai_addr != nil else { return nil }
    guard ai_addr.memory.sa_family == sa_family_t(T.domain) else { return nil }
    
    let aiptr = UnsafePointer<T>(ai_addr) // cast
    return aiptr.memory // copies the address to the return value
  }
  
  public var dynamicAddress : SocketAddress? {
    guard hasAddress else { return nil }
    
    if ai_addr.memory.sa_family == sa_family_t(sockaddr_in.domain) {
      let aiptr = UnsafePointer<sockaddr_in>(ai_addr) // cast
      return aiptr.memory // copies the address to the return value
    }
    
    if ai_addr.memory.sa_family == sa_family_t(sockaddr_in6.domain) {
      let aiptr = UnsafePointer<sockaddr_in6>(ai_addr) // cast
      return aiptr.memory // copies the address to the return value
    }
    
    return nil
  }
}

extension addrinfo : CustomStringConvertible {
  
  public var description : String {
    var s = "<addrinfo"
    
    if ai_flags != 0 {
      var fs = [String]()
      var f  = ai_flags
      if f & AI_CANONNAME != 0 {
        fs.append("canonname")
        f = f & ~AI_CANONNAME
      }
      if f & AI_PASSIVE != 0 {
        fs.append("passive")
        f = f & ~AI_PASSIVE
      }
      if f & AI_NUMERICHOST != 0 {
        fs.append("numerichost")
        f = f & ~AI_NUMERICHOST
      }
      if f != 0 {
        fs.append("flags[\(f)]")
      }
      let fss = fs.joinWithSeparator(",")
      s += " flags=" + fss
    }
    
    if ai_family != AF_UNSPEC { s += sa_family_t(ai_family).description }
    switch ai_socktype {
      case 0:           break
      case SOCK_STREAM: s += " stream"
      case SOCK_DGRAM:  s += " datagram"
      default:          s += " type[\(ai_socktype)]"
    }
    
    if let cn = canonicalName {
      s += " " + cn
    }
    
    if hasAddress {
      if let a = addressIPv4 {
        s += " \(a)"
      }
      /* Not working anymore in b4
      else if let a = addressIPv6 {
        s += " \(a)"
      }
      */
      else {
        s += " address[len=\(ai_addrlen)]"
      }
    }
    
    s += (ai_next != nil ? " +" : "")
    
    s += ">"
    return s
  }
}

extension addrinfo : SequenceType {
  
  public func generate() -> AnyGenerator<addrinfo> {
    var cursor : addrinfo? = self
    
    return anyGenerator {
      guard let info = cursor else { return .None }
      cursor = info.next
      return info
    }
  }
}

extension sa_family_t { // Swift 2 : CustomStringConvertible, already imp?!
  
  // TBD: does Swift 2 still pick this up?
  public var description : String {
    switch Int32(self) {
      case AF_UNSPEC: return ""
      case AF_INET:   return "IPv4"
      case AF_INET6:  return "IPv6"
      case AF_LOCAL:  return "local"
      default:        return "family[\(self)]"
    }
  }
  
}
