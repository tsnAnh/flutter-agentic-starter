import 'package:formz/formz.dart';

enum PasswordValidationError { empty, tooShort, noUppercase, noDigit, noSpecial }

/// Formz input for passwords.
///
/// Rules: min 8 chars, at least 1 uppercase letter, 1 digit, 1 special char.
class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  static final _uppercaseRegex = RegExp(r'[A-Z]');
  static final _digitRegex = RegExp(r'[0-9]');
  static final _specialRegex = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    if (value.length < 8) return PasswordValidationError.tooShort;
    if (!_uppercaseRegex.hasMatch(value)) return PasswordValidationError.noUppercase;
    if (!_digitRegex.hasMatch(value)) return PasswordValidationError.noDigit;
    if (!_specialRegex.hasMatch(value)) return PasswordValidationError.noSpecial;
    return null;
  }
}
