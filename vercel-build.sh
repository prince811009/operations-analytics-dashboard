#!/bin/bash

set -e

FLUTTER_VERSION="3.44.2"

git clone https://github.com/flutter/flutter.git \
  --depth 1 \
  --branch "$FLUTTER_VERSION" \
  "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

flutter config --enable-web
flutter pub get
flutter build web --release