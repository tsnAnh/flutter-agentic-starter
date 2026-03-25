import 'package:formz/formz.dart';

enum UrlValidationError { empty, invalid }

/// Formz input for URLs (http/https).
class UrlInput extends FormzInput<String, UrlValidationError> {
  const UrlInput.pure() : super.pure('');
  const UrlInput.dirty([super.value = '']) : super.dirty();

  @override
  UrlValidationError? validator(String value) {
    if (value.isEmpty) return UrlValidationError.empty;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return UrlValidationError.invalid;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return UrlValidationError.invalid;
    }
    return null;
  }
}
