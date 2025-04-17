import 'package:hydrated_bloc/hydrated_bloc.dart';

final class AuthenticationCubit extends HydratedCubit<bool> {
  AuthenticationCubit() : super(false);

  static const authenticationStateKey = 'auth_state';

  void setAuthenticated() => emit(true);

  void setUnauthenticated() => emit(false);

  @override
  bool? fromJson(Map<String, dynamic> json) =>
      json[authenticationStateKey] as bool;

  @override
  Map<String, dynamic>? toJson(bool state) => {authenticationStateKey: state};
}
