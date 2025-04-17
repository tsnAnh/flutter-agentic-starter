import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/data/repositories/city_repository.dart';
import '../../../shared/data/models/dtos/city.dart';

@injectable
final class HomeCubit extends Cubit<List<City>> {
  HomeCubit(this.repository) : super(/* initial state ==> */ []);

  final CityRepository repository;

  /// Functions contain async logics should return [Future] type
  Future<void> _fetchTexts() async {
    final citiesOption = await repository.getCities();
    emit(citiesOption.getOrElse(() => []));
  }

  /// Cubit or Bloc should expose normal functions (functions not return a [Future])
  /// to UI layer
  /// Consider use [unawaited] function for calling functions that return [Future]
  /// Not all futures need to be awaited
  void displaySomeText() => unawaited(_fetchTexts());
}
