import 'dart:io';

import 'package:flutter/foundation.dart';

/// True when running on a physical/emulated Android device (not web).
bool get isAndroid => !kIsWeb && Platform.isAndroid;

/// True when running on a physical/emulated iOS device (not web).
bool get isiOS => !kIsWeb && Platform.isIOS;

/// True when running in a browser via Flutter Web.
bool get isWeb => kIsWeb;
