import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../shared/i18n/i18n.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading_widget.dart';
import '../domain/models/city.dart';
import 'home_view_model.dart';

final class HomeScreen extends SignalWidget {
  const HomeScreen({required this.viewModel, super.key});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final state = viewModel.cities.value;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.homeTitle)),
      body: SafeArea(
        child: switch (state) {
          null => _HomeEmptyState(onLoad: viewModel.loadCities),
          AsyncData<List<City>>(:final value) => _CityList(cities: value),
          AsyncError<List<City>>() => AppErrorWidget(
            message: context.l10n.homeLoadError,
            onRetry: viewModel.loadCities,
          ),
          AsyncLoading<List<City>>() => const AppLoadingWidget(),
        },
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState({required this.onLoad});

  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: onLoad,
        child: Text(context.l10n.homeLoadCities),
      ),
    );
  }
}

class _CityList extends StatelessWidget {
  const _CityList({required this.cities});

  final List<City> cities;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        return ListTile(title: Text(city.name), subtitle: Text(city.id));
      },
    );
  }
}
