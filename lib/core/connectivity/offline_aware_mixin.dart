import 'connectivity_cubit.dart';

/// Mixin for Cubits/BLoCs that need to react to connectivity changes.
///
/// The implementing class must provide a [connectivityCubit] instance.
///
/// Usage:
/// ```dart
/// class MyFeatureCubit extends Cubit<MyState> with OfflineAwareMixin {
///   MyFeatureCubit(this.connectivityCubit) : super(MyInitial());
///
///   @override
///   final ConnectivityCubit connectivityCubit;
/// }
/// ```
mixin OfflineAwareMixin {
  /// Provide the app-wide [ConnectivityCubit] from the implementing class.
  ConnectivityCubit get connectivityCubit;

  /// Returns true when the device has a network interface available.
  bool get isOnline => connectivityCubit.state.isOnline;

  /// Returns true when the device is offline.
  bool get isOffline => !isOnline;
}
