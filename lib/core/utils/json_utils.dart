import 'package:json_path/json_path.dart';

/// Reads a field from [response] using a [jsonPath] expression.
/// Set [isForList] to true to wrap a single value in a list.
dynamic getJsonField(
  dynamic response,
  String jsonPath, [
  bool isForList = false,
]) {
  final field = JsonPath(jsonPath).read(response);
  if (field.isEmpty) {
    return null;
  }
  if (field.length > 1) {
    return field.map((f) => f.value).toList();
  }
  final value = field.first.value;
  return isForList && value is! Iterable ? [value] : value;
}
