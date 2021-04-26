///
/// Исключение приложения
///
class SideException implements Exception {
  ///
  /// Дополнительные данные исключения
  ///
  late final Map<String, dynamic>? data;

  ///
  /// Текст исключения
  ///
  late final String? message;

  /// Исключение приложения
  SideException({String? message, Map<String, dynamic>? info}) {
    this.data = Map<String, dynamic>.from(info ?? <String, dynamic>{});
    this.message = message;
  }

  @override
  String toString() => '$message';
}
