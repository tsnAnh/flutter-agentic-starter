#!/usr/bin/env bash
# Compatibility wrapper for the Dart setup wizard.

set -euo pipefail

flutter pub get
dart run project_setup "$@"
