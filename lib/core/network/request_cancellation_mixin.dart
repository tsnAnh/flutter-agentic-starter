import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mixin for BLoCs/Cubits that fire Dio requests and need clean cancellation.
///
/// Cancels all in-flight requests when the BLoC/Cubit is closed, preventing
/// state emissions after disposal.
///
/// Usage:
/// ```dart
/// class UserCubit extends Cubit<UserState> with RequestCancellationMixin {
///   UserCubit(this._userApi) : super(UserInitial());
///
///   Future<void> loadUser(String id) async {
///     final result = await _userApi.getUser(id, cancelToken: cancelToken);
///     // ...
///   }
/// }
/// ```
mixin RequestCancellationMixin<S> on BlocBase<S> {
  CancelToken? _cancelToken;

  /// A [CancelToken] scoped to this BLoC/Cubit's lifetime.
  /// Pass this to every Dio request to enable automatic cancellation on close.
  CancelToken get cancelToken {
    if (_cancelToken == null || _cancelToken!.isCancelled) {
      _cancelToken = CancelToken();
    }
    return _cancelToken!;
  }

  /// Cancels all in-flight requests associated with this instance.
  void cancelRequests([String? reason]) {
    _cancelToken?.cancel(reason ?? 'BLoC closed');
    _cancelToken = null;
  }

  @override
  Future<void> close() {
    cancelRequests();
    return super.close();
  }
}
