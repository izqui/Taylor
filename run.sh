echo "Building..."
swift *.swift */*.swift -o taylor-binary
echo "Done. Running program"
echo "\n"
./taylor-binary