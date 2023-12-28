import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_statemanagement/bloc/bloc_actions.dart';
import 'package:flutter_bloc_statemanagement/bloc/person.dart';
import 'package:flutter_bloc_statemanagement/bloc/persons_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const mockedPerson1 = {
  Person(
    name: 'Foo',
    age: 20,
  ),
  Person(
    name: 'Bar',
    age: 30,
  ),
};

const mockedPerson2 = {
  Person(
    name: 'Foo',
    age: 20,
  ),
  Person(
    name: 'Bar',
    age: 30,
  ),
};

//! Define 2 mocked functions
Future<Iterable<Person>> mockGetPersons1(String _) =>
    Future.value(mockedPerson1);

Future<Iterable<Person>> mockGetPersons2(String _) =>
    Future.value(mockedPerson2);

//! Write the group and the setUp() function
void main() {
  group(
    'Testing bloc',
    () {
      //? Write our test
      late PersonsBloc bloc;

      setUp(() => bloc = PersonsBloc());

      blocTest<PersonsBloc, FetchResult?>(
        'Test initial state',
        build: () => bloc,
        verify: (bloc) => expect(bloc.state, null),
      );

      //? Fetch mock data (persons1) and compare it with FetchResult
      blocTest<PersonsBloc, FetchResult?>(
        'Mock retrieving persons from first iterable',
        build: () => bloc,
        act: (bloc) {
          bloc.add(
            const LoadPersonsAction(
              personUrl: 'dummy_url_1',
              loader: mockGetPersons1,
            ),
          );
          bloc.add(
            const LoadPersonsAction(
              personUrl: 'dummy_url_1',
              loader: mockGetPersons1,
            ),
          );
        },
        expect: () => {
          const FetchResult(
            persons: mockedPerson1,
            isRetrieveFromCache: false,
          ),
          const FetchResult(
            persons: mockedPerson1,
            isRetrieveFromCache: true,
          ),
        },
      );

      //? Fetch mock data (persons2) and compare it with FetchResult
      blocTest<PersonsBloc, FetchResult?>(
        'Mock retrieving persons from second iterable',
        build: () => bloc,
        act: (bloc) {
          bloc.add(
            const LoadPersonsAction(
              personUrl: 'dummy_url_2',
              loader: mockGetPersons2,
            ),
          );
          bloc.add(
            const LoadPersonsAction(
              personUrl: 'dummy_url_2',
              loader: mockGetPersons2,
            ),
          );
        },
        expect: () => {
          const FetchResult(
            persons: mockedPerson2,
            isRetrieveFromCache: false,
          ),
          const FetchResult(
            persons: mockedPerson2,
            isRetrieveFromCache: true,
          ),
        },
      );
    },
  );
}
