import 'dart:io';

import 'package:dart_side/dart_side.dart';
import 'package:dart_side/src/extensions/request_extension.dart';

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
      callback: (HttpRequest request) {
        // Something like Paginate list
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
      callback: (HttpRequest request) async {
        /// Get JSON Data
        /// If is not JSON = [Null] will be provided
        final dynamic jsonData = await request.json();

        return <String, dynamic>{
          'read': 'schedule',
          'id': -1,
          'json': jsonData,
        };
      },
    ),
  );

  await for (HttpRequest request in server) {
    await handler.serve(request);
  }
}
