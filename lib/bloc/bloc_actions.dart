import 'package:flutter/foundation.dart' show immutable;

import 'person.dart';

// enum PersonUrl {
//   person1,
//   person2,
// }

// extension UrlString on PersonUrl {
//   String get urlString {
//     switch (this) {
//       case PersonUrl.person1:
//         return 'http://localhost/api/persons1.json';
//       case PersonUrl.person2:
//         return 'http://localhost/api/persons2.json';
//     }
//   }
// }

typedef PersonsLoader = Future<Iterable<Person>> Function(String url);

const persons1Url = 'http://192.168.92.126:5500/api/persons1.json';
const persons2Url = 'http://192.168.92.126:5500/api/persons2.json';

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction implements LoadAction {
  final String personUrl;
  final PersonsLoader loader;
  const LoadPersonsAction({
    required this.personUrl,
    required this.loader,
  }) : super();
}
