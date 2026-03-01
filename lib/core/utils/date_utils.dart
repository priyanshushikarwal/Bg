import 'package:intl/intl.dart';

class DateFormatterUtils {
  static final DateFormat displayFormat = DateFormat('dd-MM-yy');

  static DateTime? parseFlexible(String text) {
    if (text.isEmpty) return null;

    final cleanText = text.replaceAll(RegExp(r'[^0-9/\-\.]'), '');
    if (cleanText.isEmpty) return null;

    final onlyDigits = cleanText.replaceAll(RegExp(r'[^0-9]'), '');

    int? day, month, year;

    if (onlyDigits.length == 6) {
      day = int.tryParse(onlyDigits.substring(0, 2));
      month = int.tryParse(onlyDigits.substring(2, 4));
      year = int.tryParse(onlyDigits.substring(4, 6));
    } else if (onlyDigits.length == 8) {
      day = int.tryParse(onlyDigits.substring(0, 2));
      month = int.tryParse(onlyDigits.substring(2, 4));
      year = int.tryParse(onlyDigits.substring(4, 8));
    } else {
      final parts = cleanText.split(RegExp(r'[/\-\.]'));
      if (parts.length == 3) {
        day = int.tryParse(parts[0]);
        month = int.tryParse(parts[1]);
        year = int.tryParse(parts[2]);
      } else if (parts.length == 1 &&
          onlyDigits.length >= 1 &&
          onlyDigits.length <= 4) {
      }
    }

    if (day == null || month == null || year == null) return null;

    if (year < 100) {
      if (year < 50) {
        year += 2000;
      } else {
        year += 1900;
      }
    }

    try {
      final date = DateTime(year, month, day);
      if (date.year == year && date.month == month && date.day == day) {
        return date;
      }
    } catch (_) {}

    return null;
  }

  static String formatToShort(DateTime date) {
    return displayFormat.format(date);
  }

  static String? normalizeDateString(String text) {
    final date = parseFlexible(text);
    if (date != null) {
      return formatToShort(date);
    }
    return null;
  }
}
