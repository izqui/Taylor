carthage bootstrap
xcodebuild -workspace TaylorPlayground.xcworkspace/ -scheme SwiftSockets -configuration Debug
xcodebuild -workspace TaylorPlayground.xcworkspace/ -scheme Taylor -configuration Debug
open TaylorPlayground.xcworkspace
