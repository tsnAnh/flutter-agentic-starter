import 'package:formz/formz.dart';

enum RequiredValidationError { empty }

/// Formz input that validates any non-empty string value.
class RequiredInput extends FormzInput<String, RequiredValidationError> {
  const RequiredInput.pure() : super.pure('');
  const RequiredInput.dirty([super.value = '']) : super.dirty();

  @override
  RequiredValidationError? validator(String value) {
    return value.trim().isEmpty ? RequiredValidationError.empty : null;
  }
}
