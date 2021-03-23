# Dart Side

![](https://badgen.net/github/release/DizoftTeam/dart_side)
![](https://badgen.net/github/stars/DizoftTeam/dart_side)
![](https://badgen.net/github/forks/DizoftTeam/dart_side)
![](https://badgen.net/github/issues/DizoftTeam/dart_side)
![](https://badgen.net/github/open-issues/DizoftTeam/dart_side)
![](https://badgen.net/github/license/DizoftTeam/dart_side)
![](https://badgen.net/github/tag/DizoftTeam/dart_side)
![](https://badgen.net/pub/v/dart_side)
![](https://badgen.net/pub/likes/dart_side)
![](https://badgen.net/pub/points/dart_side)
![](https://badgen.net/pub/popularity/dart_side)
![](https://badgen.net/pub/sdk-version/dart_side)

Simple and Pure Dart Http server

## Usage

A simple usage example:

```dart
import 'dart:io';

import 'package:dart_side/dart_side.dart';

Future<void> main() async {
  final HttpServer server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    4040,
  );

  print('Listening on localhost:${server.port}');

  final DServer handler = new DServer();

  handler.handle(
    method: Method.GET,
    handler: Handler(
      path: '/v1/schedules',
      callback: () {
        // Somthing like Paginate list
        return <String, dynamic>{
          'items': <String>[
            'schedule 1',
            'schedule 2',
            'schedule 3',
            'schedule 4',
            'schedule 5',
          ],
        };
      },
    ),
  );

  handler.handle(
    method: Method.GET,
    handler: Handler(
      rPath: r'/v1/schedules/\d+',
      callback: () {
        return <String, dynamic>{
          'read': 'schedule',
          'id': -1,
        };
      },
    ),
  );

  await for (HttpRequest request in server) {
    await handler.serve(request);
  }
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/DizoftTeam/dart_side/issues).
