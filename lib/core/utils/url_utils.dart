import 'package:url_launcher/url_launcher.dart';

/// Launches the given [url] in the platform's default browser/handler.
/// Throws a string message if the URL cannot be launched.
Future<void> launchURL(String url) async {
  final uri = Uri.parse(url);
  try {
    await launchUrl(uri);
  } on Exception catch (e) {
    throw 'Could not launch $uri: $e';
  }
}
