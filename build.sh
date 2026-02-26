#!/bin/bash
echo "Cloning Flutter repository..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

echo "Flutter version:"
flutter --version

echo "Building Flutter Web App..."
flutter build web --release
