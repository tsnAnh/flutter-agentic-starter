import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Mixin for view models that fire Dio requests and need clean cancellation.
///
/// Cancels all in-flight requests when the view model is disposed, preventing
/// state emissions after disposal.
///
/// Usage:
/// ```dart
/// class UserViewModel with RequestCancellationMixin {
///   UserViewModel(this._userApi);
///
///   Future<void> loadUser(String id) async {
///     final result = await _userApi.getUser(id, cancelToken: cancelToken);
///     // ...
///   }
/// }
/// ```
mixin RequestCancellationMixin {
  CancelToken? _cancelToken;

  /// A [CancelToken] scoped to this view model's lifetime.
  /// Pass this to every Dio request to enable automatic cancellation on close.
  CancelToken get cancelToken {
    if (_cancelToken == null || _cancelToken!.isCancelled) {
      _cancelToken = CancelToken();
    }
    return _cancelToken!;
  }

  /// Cancels all in-flight requests associated with this instance.
  void cancelRequests([String? reason]) {
    _cancelToken?.cancel(reason ?? 'View model disposed');
    _cancelToken = null;
  }

  @mustCallSuper
  void dispose() => cancelRequests();
}
