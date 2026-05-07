#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/bipolar_monitor"

echo "==> Installing Flutter dependencies..."
flutter pub get

echo "==> Running build_runner (Drift code generation)..."
dart run build_runner build --delete-conflicting-outputs

echo "==> Done. You can now run: flutter run"
