import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/tracker_provider.dart';
import '../core/theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrackerProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800),
                  leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppTheme.primaryPink),
                  rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryPink),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textDark.withOpacity(0.6)),
                  weekendStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textDark.withOpacity(0.6)),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildCalendarCell(day, provider);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryPink, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: _buildCalendarCell(day, provider, isToday: true),
                    );
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    return const SizedBox.shrink(); // Hide outside days
                  },
                ),
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Period', AppTheme.primaryPink),
              const SizedBox(width: 32),
              _buildLegend('Fertile', AppTheme.secondaryLavender),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCalendarCell(DateTime day, TrackerProvider provider, {bool isToday = false}) {
    bool isPeriod = provider.isPeriodDay(day);
    bool isFertile = provider.isFertileDay(day);

    Color bgColor = Colors.transparent;
    Color textColor = AppTheme.textDark;

    if (isPeriod) {
      bgColor = AppTheme.primaryPink;
      textColor = AppTheme.surfaceWhite;
    } else if (isFertile) {
      bgColor = AppTheme.secondaryLavender;
      textColor = AppTheme.surfaceWhite;
    }

    return Container(
      margin: isToday ? EdgeInsets.zero : const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16, 
          height: 16, 
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}
