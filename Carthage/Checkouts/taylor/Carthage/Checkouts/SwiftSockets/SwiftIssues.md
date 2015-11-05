Issues with Swift
=================

Below a collection of issues I've found in the current implementation of Swift.
Presumably they fix most of them pretty quickly.

FIXME: Collect and list all issues :-)

###Bugs

- No access to ioctl() (presumably due to varargs)
- No access to fcntl() (presumably due to varargs)
- sizeof() only works on types, not on variables/constants (No ```var buf: CInt; sizeof(buf)``` - lame! ;-)
- Cannot put methods into extensions which are going to be overridden 
  ('declarations in extensions cannot be overridden yet')
- no ```let constant = 42``` in extensions, gives 
  "'var' declarations without getter/setter not allowed here" (this ain't
  no var)
- Would be nice if Swift would allow chaining of Void methods (.onRead {} .onWrite {}) - right now all the methods have to return self manually.

###How To?

####Error Handling

I'm not sure how we are supposed to handle errors in Swift. Maybe using some
enum for the error codes and a fallback value (e.g. the file descriptor) for
the success case. Kinda like an Optional, with more fail values than nil.

####Casting C Structures

How should we cast between typed pointers? Eg bind() takes a &sockaddr, but the
actual structure is variable (eg a sockaddr_in).

I hacked around it like this (beta3, now a bit different, but same issue):
```swift
var addr = address // where address is sockaddr_in
    
// CAST: Hope this works, essentially cast to void and then take the rawptr
let bvptr: CConstVoidPointer = &addr
let bptr = CConstPointer<sockaddr>(nil, bvptr.value)
```
Which doesn't feel right.

####Flexible Length C Structures

I guess this can be done with UnsafePointer. Structures like sockaddr_un,
which embed the path within the structure and thereby have a different size.

#### Overloading functions with Optionals

This seems to behave a bit weird (forgot the details ;-):
```swift
func getSocketOption(option: CInt) -> CInt {
  return 0
}
func getSocketOption(option: CInt?) -> CInt {
  return 0
}
```
