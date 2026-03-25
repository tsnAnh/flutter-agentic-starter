import 'package:flutter_bloc/flutter_bloc.dart';

import 'data_state.dart';

/// Abstract cubit that manages a single async [DataState<T>].
/// Subclasses implement [fetch] to provide the data-loading logic.
abstract class BaseCubit<T> extends Cubit<DataState<T>> {
  BaseCubit() : super(const DataStateInitial());

  /// Override to implement the actual data fetching.
  Future<T> fetch();

  /// Triggers a fresh load; emits Loading → Loaded or Error.
  Future<void> load() async {
    if (isClosed) return;
    emit(const DataStateLoading());
    try {
      final data = await fetch();
      if (!isClosed) emit(DataStateLoaded(data));
    } on Object catch (e, st) {
      if (!isClosed) emit(DataStateError(e.toString(), st));
    }
  }

  /// Alias for [load] — resets state and re-fetches.
  Future<void> refresh() => load();
}
