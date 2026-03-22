import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String formatDisplayDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
  
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMM yyyy').format(date).toUpperCase();
  }
}
