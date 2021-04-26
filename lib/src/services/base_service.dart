import 'package:dart_side/src/exceptions/side_exception.dart';
import 'package:dart_side/src/validators/base_validator.dart';

///
/// Базовый сервис
///
abstract class BaseSideService {
  // Набор ошибок
  final Map<String, List<String>> _validateErrors = <String, List<String>>{};

  ///
  /// Метод валидации даных
  ///
  bool validate({
    required Map<String, dynamic> data,
    required Map<String, Map<String, dynamic>> rules,
    bool needThrow = false,
  }) {
    bool result = true;

    // _validateErrors.clear();

    rules.forEach((String key, Map<String, dynamic> value) {
      value.forEach((String name, dynamic validator) {
        final String error = validator is BaseValidator
            ? validator.validate(data[key])
            : validator(data[key]);

        if (error.isNotEmpty) {
          result = false;

          if (!_validateErrors.containsKey(key)) {
            _validateErrors[key] = <String>[];
          }

          _validateErrors[key]!.add(error);
        }
      });
    });

    if (!result && needThrow) {
      throw SideException(
        message: 'Ошибка валидации',
        info: _validateErrors,
      );
    }

    return result;
  }
}
