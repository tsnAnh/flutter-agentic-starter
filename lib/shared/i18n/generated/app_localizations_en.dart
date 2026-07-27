// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get displaySomeText => 'Display some text!';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeLoadCities => 'Load cities';

  @override
  String get homeLoadError => 'We couldn\'t load the cities. Please try again.';

  @override
  String get retry => 'Retry';
}
