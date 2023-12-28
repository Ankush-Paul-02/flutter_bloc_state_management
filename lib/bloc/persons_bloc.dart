import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_actions.dart';
import 'person.dart';

//? Define equality on Iterable<T>
extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

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

  @override
  bool operator ==(covariant FetchResult other) =>
      persons.isEqualToIgnoringOrdering(other.persons) &&
      isRetrieveFromCache == other.isRetrieveFromCache;

  @override
  int get hashCode => Object.hash(persons, isRetrieveFromCache);
}

//? Write the bloc header
class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  //? We need a cache for the bloc
  final Map<String, Iterable<Person>> _cache = {};
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
        final loader = event.loader;
        final persons = await loader(url);
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
