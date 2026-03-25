import 'package:formz/formz.dart';

enum PhoneValidationError { empty, invalid }

/// Formz input for phone numbers.
///
/// Accepts optional leading + and 7–15 digits (ITU-T E.164 range).
/// Does not assume country code — server must validate locale-specific formats.
class PhoneInput extends FormzInput<String, PhoneValidationError> {
  const PhoneInput.pure() : super.pure('');
  const PhoneInput.dirty([super.value = '']) : super.dirty();

  // Strips spaces/dashes/parens before matching to allow formatted input.
  static final _phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

  @override
  PhoneValidationError? validator(String value) {
    if (value.isEmpty) return PhoneValidationError.empty;
    final stripped = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_phoneRegex.hasMatch(stripped)) return PhoneValidationError.invalid;
    return null;
  }
}
