import 'dart:convert';
import 'dart:io';

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
/// Handler
///
class Handler {
  /// Simple path
  String? path;

  /// Regex path
  Pattern? rPath;

  /// Callback
  Object Function() callback;

  /// Constructor
  Handler({
    this.path,
    this.rPath,
    required this.callback,
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
    // assert(handler.path != null && handler.rPath == null);
    // assert(handler.rPath != null && handler.path == null);

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
          orElse: () => Handler(callback: () => ''),
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

          final Object result = await hFind.callback.call();

          request.response.write(jsonEncode(
            <String, dynamic>{
              'success': true,
              'result': result,
            },
          ));
        }
      }

      if (path != '') {
        final Object result = await _routes[method]![path]!.callback.call();

        isError = false;

        request.response.write(jsonEncode(
          <String, dynamic>{
            'success': true,
            'result': result,
          },
        ));
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
