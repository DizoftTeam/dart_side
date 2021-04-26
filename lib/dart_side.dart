///
/// A Simple and Pure Dart Http Server for Small Projects
///
library dart_side;

export 'src/dart_side_base.dart';

// Exceptions
export 'src/exceptions/side_exception.dart';

// Extensions
export 'src/extensions/request_extension.dart';

// Services
export 'src/services/base_service.dart';

// Validators
export 'src/validators/required_validator.dart';

///
/// Функция валидатора
///
typedef Validator = String Function(dynamic value);
