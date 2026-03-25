import 'package:formz/formz.dart';

enum NumericValidationError { empty, invalid, belowMin, aboveMax }

/// Formz input for numeric string values with optional min/max range.
///
/// The value is stored as a [String] (as entered by user) and parsed
/// to [num] during validation. Pass [min] / [max] to enforce range.
class NumericInput extends FormzInput<String, NumericValidationError> {
  const NumericInput.pure({this.min, this.max}) : super.pure('');
  const NumericInput.dirty(
    super.value, {
    this.min,
    this.max,
  }) : super.dirty();

  /// Optional lower bound (inclusive).
  final num? min;

  /// Optional upper bound (inclusive).
  final num? max;

  @override
  NumericValidationError? validator(String value) {
    if (value.isEmpty) return NumericValidationError.empty;
    final parsed = num.tryParse(value);
    if (parsed == null) return NumericValidationError.invalid;
    if (min != null && parsed < min!) return NumericValidationError.belowMin;
    if (max != null && parsed > max!) return NumericValidationError.aboveMax;
    return null;
  }
}
