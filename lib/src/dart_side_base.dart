import 'dart:convert';
import 'dart:io';

import 'package:dart_side/src/exceptions/side_exception.dart';

/// HTTP methods
enum Method {
  /// GET
  GET,

  /// POST
  POST,

  /// PUT
  PUT,

  /// DELETE
  DELETE,
}

///
/// Посредник
///
abstract class Pipeline<T> {
  /// Посредник
  const Pipeline();

  ///
  /// Запускаемое действие
  ///
  Future<T> run(T value);
}

///
/// Handler
///
class Handler {
  /// Simple path
  String? path;

  /// Regex path
  Pattern? rPath;

  /// Набор посредников на запрос
  List<Pipeline<HttpRequest>> middleware;

  /// Набор посредников на ответ TODO: ждет реализации
  List<Pipeline<dynamic>> postMiddleware;

  /// Callback
  Object Function(HttpRequest request) callback;

  /// Constructor
  Handler({
    this.path,
    this.rPath,
    required this.callback,
    this.middleware = const <Pipeline<HttpRequest>>[],
    this.postMiddleware = const <Pipeline>[],
  });
}

///
/// Main class of Server
///
class DServer {
  ///
  /// Набор роутов
  ///
  static final Map<Method, Map<String, Handler>> _routes =
      <Method, Map<String, Handler>>{};

  ///
  /// Регистрация обработчика
  ///
  void handle({
    required Method method,
    required Handler handler,
  }) {
    if (_routes[method] == null) {
      _routes[method] = <String, Handler>{};
    }

    _routes[method]!.update(
      '${method.toString().split('.')[1]} ${handler.path ?? handler.rPath}',
      (Handler value) => handler,
      ifAbsent: () => handler,
    );
  }

  ///
  /// Стартовая точка
  ///
  Future<dynamic> serve(HttpRequest request) async {
    request.response.headers.add(
      'Content-Type',
      'application/json;charset=utf-8',
    );

    request.response.headers.add('X-Powered-By', '_dserver');

    late Method method;

    switch (request.method.trim().toUpperCase()) {
      case 'GET':
        method = Method.GET;
        break;
      case 'POST':
        method = Method.POST;
        break;
      case 'PUT':
        method = Method.PUT;
        break;
      case 'DELETE':
        method = Method.DELETE;
        break;
    }

    print('Handle ${request.method} ${request.requestedUri}');

    bool isError = true;

    if (_routes.containsKey(method)) {
      final String empty = '_empty_';
      final String rPath = request.requestedUri.path;

      String path = _routes[method]!.keys.firstWhere(
            (String path) => path.split(' ')[1].trim() == rPath,
            orElse: () => empty,
          );

      Handler? handler = null;

      // Try find by RegExp
      if (path == empty) {
        final Map<String, Handler> handlers = _routes[method]!;

        final List<Handler> rHandlers = <Handler>[];

        handlers.forEach((String key, Handler value) {
          if (value.rPath != null) {
            rHandlers.add(value);
          }
        });

        final Handler hFind = rHandlers.firstWhere(
          (Handler handler) {
            final RegExp regExp = RegExp(handler.rPath!.toString());

            if (regExp.hasMatch(rPath)) {
              return true;
            }

            return false;
          },
          orElse: () => Handler(callback: (_) => ''),
        );

        // Still not found - Route not found!
        if (hFind.path == null && hFind.rPath == null) {
          path = '';
          isError = false;

          request.response.statusCode = HttpStatus.notFound;
          request.response.write(jsonEncode(
            <String, dynamic>{
              'success': false,
              'system': true,
              'error': 'Route not found',
            },
          ));
        } else {
          path = '';
          isError = false;

          handler = hFind;
        }
      } else {
        handler = _routes[method]![path]!;
      }

      // Handler найден!
      if (handler != null) {
        Object? result = null;
        bool hasException = false;
        bool middlewareException = false;

        // Побежали по middleware
        if (handler.middleware.isNotEmpty) {
          try {
            for (Pipeline<HttpRequest> middleware in handler.middleware) {
              await middleware.run(request);
            }
          } catch (e) {
            middlewareException = true;

            request.response.statusCode = HttpStatus.internalServerError;

            print(e);

            request.response.write(jsonEncode(
              <String, dynamic>{
                'success': false,
                'system': false,
                'middleware': true,
                'error': e is Exception ? '$e' : 'Middleware Error',
              },
            ));

            isError = false;
          }
        }

        if (!middlewareException) {
          try {
            result = await handler.callback.call(request);
          } catch (e) {
            hasException = true;
            isError = false;

            request.response.statusCode = HttpStatus.internalServerError;

            final Map<String, dynamic> data = <String, dynamic>{
              'success': false,
              'system': false,
              'error': e is Exception ? '$e' : 'Internal Server Error',
            };

            if (e is SideException) {
              data['info'] = e.data;
            }

            request.response.write(jsonEncode(data));
          }

          if (!hasException) {
            isError = false;

            request.response.write(jsonEncode(
              <String, dynamic>{
                'success': true,
                'result': result,
              },
            ));
          }
        }
      }
    }

    if (isError) {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write(jsonEncode(
        <String, dynamic>{
          'success': false,
          'system': false,
          'error': 'Some error was occured',
        },
      ));
    }

    await request.response.close();
  }
}
