import 'dart:math' as math show Random;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';

const names = [
  'Ankush',
  'Soumili',
  'Sid',
];

extension RandomElement<T> on Iterable<T> {
  T getRandomElements() => elementAt(math.Random().nextInt(length));
}

class NamesCubit extends Cubit<String?> {
  NamesCubit() : super(null);

  void randomName() => emit(names.getRandomElements());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final NamesCubit namesCubit;

  @override
  void initState() {
    super.initState();
    namesCubit = NamesCubit();
  }

  @override
  void dispose() {
    namesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: 'Flutter Bloc'.text.bold.make().centered(),
      ),
      body: StreamBuilder<String?>(
        stream: namesCubit.stream,
        builder: (context, snapshot) {
          final button = TextButton(
            onPressed: () => namesCubit.randomName(),
            child: 'Pick a random name'.text.size(20).make().centered(),
          );
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return button;
            case ConnectionState.waiting:
              return button;
            case ConnectionState.active:
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (snapshot.data ?? ' ').text.size(22).white.make(),
                  20.heightBox,
                  button,
                ],
              );
            case ConnectionState.done:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
