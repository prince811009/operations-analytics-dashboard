#!/bin/bash

set -e

FLUTTER_VERSION="3.44.2"
FLUTTER_PATH="$HOME/flutter"

if [ ! -d "$FLUTTER_PATH" ]; then
  git clone https://github.com/flutter/flutter.git \
    --depth 1 \
    --branch "$FLUTTER_VERSION" \
    "$FLUTTER_PATH"
fi

export PATH="$FLUTTER_PATH/bin:$PATH"

flutter config --enable-web
flutter pub get
flutter build web --release