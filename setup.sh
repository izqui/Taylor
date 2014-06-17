echo "Adding SDKROOT to your .bash_profile file"
echo "\nexport SDKROOT=$(xcrun --show-sdk-path --sdk macosx)" >> ~/.bash_profile
echo "Creating swift command by linking it"
sudo ln -s /Applications/Xcode6-Beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift /usr/bin/swift