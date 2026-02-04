import 'package:intl/intl.dart';

class DateFormatterUtils {
  static final DateFormat displayFormat = DateFormat('dd-MM-yy');

  /// Parses a date string from various common formats.
  /// Supported: DDMMYY, DDMMYYYY, DD/MM/YY, DD/MM/YYYY, DD-MM-YY, DD-MM-YYYY, DD.MM.YY, DD.MM.YYYY
  static DateTime? parseFlexible(String text) {
    if (text.isEmpty) return null;

    // Clean text: keep only digits and separators
    final cleanText = text.replaceAll(RegExp(r'[^0-9/\-\.]'), '');
    if (cleanText.isEmpty) return null;

    // Try parsing if it's purely digits
    final onlyDigits = cleanText.replaceAll(RegExp(r'[^0-9]'), '');

    int? day, month, year;

    if (onlyDigits.length == 6) {
      // DDMMYY
      day = int.tryParse(onlyDigits.substring(0, 2));
      month = int.tryParse(onlyDigits.substring(2, 4));
      year = int.tryParse(onlyDigits.substring(4, 6));
    } else if (onlyDigits.length == 8) {
      // DDMMYYYY
      day = int.tryParse(onlyDigits.substring(0, 2));
      month = int.tryParse(onlyDigits.substring(2, 4));
      year = int.tryParse(onlyDigits.substring(4, 8));
    } else {
      // Try splitting by separators
      final parts = cleanText.split(RegExp(r'[/\-\.]'));
      if (parts.length == 3) {
        day = int.tryParse(parts[0]);
        month = int.tryParse(parts[1]);
        year = int.tryParse(parts[2]);
      } else if (parts.length == 1 &&
          onlyDigits.length >= 1 &&
          onlyDigits.length <= 4) {
        // Maybe just DD or DDMM? Too ambiguous, skip
      }
    }

    if (day == null || month == null || year == null) return null;

    // Normalize year
    if (year < 100) {
      // If year is say 25, it's 2025. If 99, 1999?
      // Usually in these systems we assume 2000+ for anything current
      if (year < 50) {
        year += 2000;
      } else {
        year += 1900;
      }
    }

    try {
      final date = DateTime(year, month, day);
      // Strict validation: check if the date actually exists (e.g. 31/02/2024 is invalid)
      if (date.year == year && date.month == month && date.day == day) {
        return date;
      }
    } catch (_) {}

    return null;
  }

  /// Formats a DateTime to 'dd-MM-yy'
  static String formatToShort(DateTime date) {
    return displayFormat.format(date);
  }

  /// Takes a string in any format and returns it in 'dd-MM-yy' if valid
  static String? normalizeDateString(String text) {
    final date = parseFlexible(text);
    if (date != null) {
      return formatToShort(date);
    }
    return null;
  }
}
