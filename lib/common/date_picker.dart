import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:weekly_date_picker/weekly_date_picker.dart';

class DatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) changeDay;
  const DatePicker(
      {super.key, required this.selectedDate, required this.changeDay});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(DateFormat(DateFormat.YEAR_MONTH_DAY).format(selectedDate)),
        WeeklyDatePicker(
          selectedDay: selectedDate,
          changeDay: changeDay,
          enableWeeknumberText: false,
          backgroundColor: Colors.transparent,
          weekdayTextColor: const Color(0xFF8A8A8A),
          digitsColor: Colors.white,
          selectedDigitBackgroundColor: const Color.fromARGB(255, 42, 100, 72),
          selectedDigitBorderColor: const Color.fromARGB(255, 24, 56, 41),
        )
      ],
    );
  }
}
