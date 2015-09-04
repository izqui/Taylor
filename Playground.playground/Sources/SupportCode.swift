//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to Playground.playground.
//

import Cocoa
import QuartzCore

public let filters = ["CIPhotoEffectChrome", "CIPhotoEffectNoir", "CIPhotoEffectMono", "CIPhotoEffectProcess"]
@available(OSX 10.10, *)
public func filteredImage(filterName: String) -> NSData? {
    let imageURL = NSBundle.mainBundle().URLForResource("image", withExtension: "jpg")
    let image = CIImage(contentsOfURL: imageURL!)
    let filter = CIFilter(name: filterName)
    filter!.setValue(image, forKey: kCIInputImageKey)
    let imageRep = NSBitmapImageRep(CIImage: filter!.outputImage!)
    return imageRep.representationUsingType(.NSJPEGFileType, properties: [NSImageCompressionFactor:0.3])
}
public func getIPAddress() -> String {
    
    var addresses = NSHost.currentHost().addresses
    if addresses.count > 1 {
        return addresses[1]
    }
    
    return "127.0.0.1"
}