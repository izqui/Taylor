carthage checkout
xcodebuild -workspace TaylorPlayground.xcworkspace/ -scheme "Universal Framework" -configuration Debug
xcodebuild -workspace TaylorPlayground.xcworkspace/ -scheme Taylor -configuration Debug
open TaylorPlayground.xcworkspace
