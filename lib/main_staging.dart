import 'package:flutter/material.dart';

import 'app.dart';
import 'core/flavor_configurations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ConfigurationProfile.current = ConfigurationProfile.staging;
  initializeFlutterApp();
}
