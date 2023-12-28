import 'dart:convert';
import 'dart:developer' as devtools show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';

import '../bloc/bloc_actions.dart';
import '../bloc/person.dart';
import '../bloc/persons_bloc.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

//? We need to download and parse JSON now
Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((request) => request.close())
    .then((response) => response.transform(utf8.decoder).join())
    .then((ftrStr) => json.decode(ftrStr) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

//? Add a subscript extension to Iterable<T>
extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: 'Flutter Bloc'.text.bold.make().centered(),
      ),
      body: Column(
        children: [
          20.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => context.read<PersonsBloc>().add(
                      const LoadPersonsAction(
                        personUrl: persons1Url,
                        loader: getPersons,
                      ),
                    ),
                child: 'Load json #1'.text.size(20).bold.make(),
              ),
              TextButton(
                onPressed: () => context.read<PersonsBloc>().add(
                      const LoadPersonsAction(
                        personUrl: persons2Url,
                        loader: getPersons,
                      ),
                    ),
                child: 'Load json #2'.text.size(20).bold.make(),
              ),
            ],
          ),
          30.heightBox,
          BlocBuilder<PersonsBloc, FetchResult?>(
            buildWhen: (previousResult, currentResult) =>
                previousResult?.persons != currentResult?.persons,
            builder: (context, fetchResult) {
              fetchResult?.log();
              final persons = fetchResult?.persons;
              if (persons == null) {
                return const SizedBox();
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (context, index) {
                    final person = persons[index]!;
                    return ListTile(
                      title: person.name.text.make(),
                      subtitle: person.age.text.make(),
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
