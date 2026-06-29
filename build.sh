#!/bin/bash
# Enable error output
set -e

# Disable interactive promps
export CI=true

if [ ! -d "flutter_sdk" ]; then
  echo "Cloning Flutter repository (shallow)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter_sdk
else
  echo "Flutter SDK directory already exists, skipping clone."
fi

export PATH="$PATH:`pwd`/flutter_sdk/bin"

echo "Flutter version:"
flutter --version

echo "Disabling analytics and enabling web..."
flutter config --no-analytics

echo "Running pub get..."
flutter pub get

echo "Building Flutter Web App..."
flutter build web --release --tree-shake-icons --pwa-strategy=none

echo "Build successful!"
