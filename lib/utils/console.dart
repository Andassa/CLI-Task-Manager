import 'dart:io';

class Console {
  static bool get _enabled => stdout.supportsAnsiEscapes;

  static const String _reset = '\x1B[0m';

  static String _wrap(String code, String text) {
    if (!_enabled) {
      return text;
    }
    return '$code$text$_reset';
  }

  /// Efface l'ecran et replace le curseur en haut a gauche.
  /// Sans effet si le terminal ne supporte pas les codes ANSI.
  static void clear() {
    if (_enabled) {
      stdout.write('\x1B[2J\x1B[3J\x1B[H');
    }
  }

  static String bold(String text) => _wrap('\x1B[1m', text);

  static String dim(String text) => _wrap('\x1B[2m', text);

  static String red(String text) => _wrap('\x1B[31m', text);

  static String green(String text) => _wrap('\x1B[32m', text);

  static String yellow(String text) => _wrap('\x1B[33m', text);

  static String blue(String text) => _wrap('\x1B[34m', text);

  static String cyan(String text) => _wrap('\x1B[36m', text);

  static String gray(String text) => _wrap('\x1B[90m', text);
}
