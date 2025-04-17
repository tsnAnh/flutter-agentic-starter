import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../shared/blocs/authentication_cubit.dart';
import '../../core/di/get_it.dart';
import '../../shared/i18n/i18n.dart';
import '../../shared/data/models/dtos/city.dart';
import '../../core/router/router.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';

final class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _textController = TextEditingController();
  final _textController2 = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _textController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.helloWorld),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocProvider<HomeBloc>(
                create: (context) => getIt<HomeBloc>(),
                child: Center(
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) => _buildHome(context, state),
                  ),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                context.read<AuthenticationCubit>().setUnauthenticated();
                context.go(AppRoutes.login);
              },
              child: const Text('Logout'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context, HomeState state) {
    if (state is LoadCitiesSuccess) {
      return _buildCityList(state.cities);
    } else if (state is LoadCitiesError) {
      return const Text('Error');
    } else if (state is HomeInitial) {
      return ElevatedButton(
        onPressed: () => context.read<HomeBloc>().add(HomeEvent.loadCities),
        child: Text(context.l10n.displaySomeText),
      );
    } else {
      // Loading
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget _buildCityList(List<City> cities) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) => ListTile(
        key: ValueKey(cities[index].id),
        title: Text(cities[index].name),
      ),
      itemCount: cities.length,
    );
  }
}
