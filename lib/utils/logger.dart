import 'package:logger/logger.dart';

/// Глобальный logger для приложения
/// Использует разные уровни в зависимости от режима (debug/release)
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // Не показывать стек вызовов
    errorMethodCount: 5, // Показывать стек только для ошибок
    lineLength: 80, // Ширина строки
    colors: true, // Цветной вывод в консоль
    printEmojis: true, // Эмодзи для уровней
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: Level.debug, // В релизе будет Level.warning
);

/// Краткий logger без форматирования для простых сообщений
final simpleLogger = Logger(
  printer: SimplePrinter(colors: true),
  level: Level.debug,
);
