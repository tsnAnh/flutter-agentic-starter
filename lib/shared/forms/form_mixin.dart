import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

/// Mixin for Cubits that manage a form submission lifecycle.
///
/// Provides:
/// - [submissionStatus] — current [FormzSubmissionStatus]
/// - [setSubmitting] / [setSuccess] / [setFailure] / [resetStatus] helpers
///
/// The mixin requires [S] to be a state type that the host Cubit emits.
/// The host Cubit must call the status setters and re-emit state as needed.
///
/// ```dart
/// class LoginCubit extends Cubit<LoginState> with FormMixin<LoginState> {
///   LoginCubit() : super(const LoginState());
///
///   Future<void> submit() async {
///     setSubmitting();
///     try {
///       await _repo.login(...);
///       setSuccess();
///     } catch (e) {
///       setFailure(e.toString());
///     }
///   }
/// }
/// ```
mixin FormMixin<S> on Cubit<S> {
  FormzSubmissionStatus _submissionStatus = FormzSubmissionStatus.initial;
  String? _failureMessage;

  /// Current submission status.
  FormzSubmissionStatus get submissionStatus => _submissionStatus;

  /// Error message set on [setFailure], null otherwise.
  String? get failureMessage => _failureMessage;

  /// Marks submission as in-progress.
  void setSubmitting() {
    _submissionStatus = FormzSubmissionStatus.inProgress;
    _failureMessage = null;
  }

  /// Marks submission as successful.
  void setSuccess() {
    _submissionStatus = FormzSubmissionStatus.success;
    _failureMessage = null;
  }

  /// Marks submission as failed with an optional [message].
  void setFailure([String? message]) {
    _submissionStatus = FormzSubmissionStatus.failure;
    _failureMessage = message;
  }

  /// Resets submission status to [FormzSubmissionStatus.initial].
  void resetStatus() {
    _submissionStatus = FormzSubmissionStatus.initial;
    _failureMessage = null;
  }

  /// Returns true when submission is in progress.
  bool get isSubmitting =>
      _submissionStatus == FormzSubmissionStatus.inProgress;

  /// Returns true when submission succeeded.
  bool get isSuccess => _submissionStatus == FormzSubmissionStatus.success;

  /// Returns true when submission failed.
  bool get isFailure => _submissionStatus == FormzSubmissionStatus.failure;
}
