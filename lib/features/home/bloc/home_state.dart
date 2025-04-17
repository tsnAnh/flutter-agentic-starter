import 'package:equatable/equatable.dart';

import '../../../core/error.dart';
import '../../../shared/data/models/dtos/city.dart';

abstract class HomeState extends Equatable {}

final class HomeInitial extends HomeState {
  @override
  List<Object?> get props => [];
}

final class CitiesLoading extends HomeState {
  @override
  List<Object?> get props => [];
}

final class LoadCitiesSuccess extends HomeState {
  LoadCitiesSuccess(this.cities);

  final List<City> cities;

  @override
  List<Object?> get props => [cities];
}

final class LoadCitiesError extends HomeState {
  LoadCitiesError(this.error);

  final DataSourceError error;

  @override
  List<Object?> get props => [error];
}
