carthage bootstrap
xcodebuild -workspace TaylorPlayground.xcworkspace/ -scheme "Mac Framework" -configuration Debug
xcodebuild -workspace TaylorPlayground.xcworkspace/ -scheme Taylor -configuration Debug
open TaylorPlayground.xcworkspace
