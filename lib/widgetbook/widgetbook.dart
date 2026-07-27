import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../core/theme/theme.dart';
import '../shared/i18n/generated/app_localizations.dart';
import 'widgetbook.directories.g.dart';

void main() => runApp(const WidgetbookApp());

@widgetbook.App()
final class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppTheme.light),
            WidgetbookTheme(name: 'Dark', data: AppTheme.dark),
          ],
        ),
        ViewportAddon(Viewports.all),
        LocalizationAddon(
          locales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
        TextScaleAddon(),
        BuilderAddon(
          name: 'Screen sizing',
          builder: (context, child) {
            ScreenUtil.configure(
              data: MediaQuery.of(context),
              designSize: const Size(430, 932),
              minTextAdapt: true,
              splitScreenMode: false,
            );
            return child;
          },
        ),
      ],
    );
  }
}
