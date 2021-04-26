import 'package:dart_side/src/validators/base_validator.dart';

///
/// Валидатор на проверку что данные есть
///
class RequiredValidator extends BaseValidator {
  @override
  String validate(dynamic value) {
    if (value == null) {
      return 'Value must not be null';
    }

    if (value is String && value.isEmpty) {
      return 'Value is required';
    }

    // TODO: корректно ли?
    if (value is num && value == 0) {
      return 'Value is zero';
    }

    return '';
  }
}
