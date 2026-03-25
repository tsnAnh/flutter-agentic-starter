import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/data/repositories/city_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

@injectable
final class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this.repository) : super(HomeInitial()) {
    on<HomeEvent>(
      (event, emit) async {
        await _handleHomeEvent(event, emit);
      },
    );
  }

  final CityRepository repository;

  Future<void> _handleHomeEvent(
    HomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    switch (event) {
      case HomeEvent.loadCities:
        await _handleLoadCitiesEvent(emit);
        break;
    }
  }

  Future<void> _handleLoadCitiesEvent(Emitter<HomeState> emit) async {
    emit(CitiesLoading());
    final option = await repository.getCities();
    emit(LoadCitiesSuccess(option.getOrElse(() => [])));
  }
}
