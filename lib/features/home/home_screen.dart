import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeInitial() => const _HomeEmptyState(),
            CitiesLoading() => const Center(child: CircularProgressIndicator()),
            LoadCitiesSuccess(:final cities) => ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                return ListTile(
                  title: Text(city.name),
                  subtitle: Text(city.id),
                );
              },
            ),
            LoadCitiesError(:final error) => Center(
              child: Text(error.exception.toString()),
            ),
          };
        },
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: () => context.read<HomeBloc>().add(HomeEvent.loadCities),
        child: const Text('Load cities'),
      ),
    );
  }
}
