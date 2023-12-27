// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer' as devtools show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction implements LoadAction {
  final PersonUrl personUrl;
  const LoadPersonsAction({required this.personUrl}) : super();
}

enum PersonUrl {
  person1,
  person2,
}

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.person1:
        return 'http://192.168.92.126:5500/api/persons1.json';
      case PersonUrl.person2:
        return 'http://192.168.92.126:5500/api/persons2.json';
    }
  }
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({
    required this.name,
    required this.age,
  });

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;
}

//? We need to download and parse JSON now
Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((request) => request.close())
    .then((response) => response.transform(utf8.decoder).join())
    .then((ftrStr) => json.decode(ftrStr) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

//? Define the result of the bloc
@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrieveFromCache;

  const FetchResult({
    required this.persons,
    required this.isRetrieveFromCache,
  });

  @override
  String toString() =>
      'FetchResult(persons: $persons, isRetrieveFromCache: $isRetrieveFromCache)';
}

//? Write the bloc header
class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  //? We need a cache for the bloc
  final Map<PersonUrl, Iterable<Person>> _cache = {};
  //? Handle the LoadPersonsAction in the constructor
  PersonsBloc() : super(null) {
    on<LoadPersonsAction>((event, emit) async {
      final url = event.personUrl;
      if (_cache.containsKey(url)) {
        //! We have the value in the cache
        final cachedPersons = _cache[url]!;
        final result = FetchResult(
          persons: cachedPersons,
          isRetrieveFromCache: true,
        );
        emit(result);
      } else {
        final persons = await getPersons(url.urlString);
        _cache[url] = persons;
        final result = FetchResult(
          persons: persons,
          isRetrieveFromCache: false,
        );
        emit(result);
      }
    });
  }
}

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
                onPressed: () => context
                    .read<PersonsBloc>()
                    .add(const LoadPersonsAction(personUrl: PersonUrl.person1)),
                child: 'Load json #1'.text.size(20).bold.make(),
              ),
              TextButton(
                onPressed: () => context
                    .read<PersonsBloc>()
                    .add(const LoadPersonsAction(personUrl: PersonUrl.person2)),
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
