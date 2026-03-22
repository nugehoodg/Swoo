import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/tracker_provider.dart';
import '../core/theme/app_theme.dart';
import '../models/cycle_phase.dart';
import '../widgets/symptoms_bottom_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  final Set<CyclePhase> _visiblePhases = {
    CyclePhase.period,
    CyclePhase.follicular,
    CyclePhase.fertile,
    CyclePhase.ovulation,
    CyclePhase.luteal,
  };

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SymptomsBottomSheet(date: selectedDay);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrackerProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                onDaySelected: _onDaySelected,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppTheme.primaryPink,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.primaryPink,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: Theme.of(context).textTheme.bodyMedium!
                      .copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark.withOpacity(0.6),
                      ),
                  weekendStyle: Theme.of(context).textTheme.bodyMedium!
                      .copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark.withOpacity(0.6),
                      ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildCalendarCell(day, provider);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.primaryPink,
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: _buildCalendarCell(day, provider, isToday: true),
                    );
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    return const SizedBox.shrink();
                  },
                ),
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Filter by phase',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                'Period',
                AppTheme.primaryPink,
                AppTheme.surfaceWhite,
                CyclePhase.period,
              ),
              _buildFilterChip(
                'Follicular',
                AppTheme.follicularBlue,
                const Color(0xFF0277BD),
                CyclePhase.follicular,
              ),
              _buildFilterChip(
                'Fertile',
                AppTheme.secondaryLavender,
                AppTheme.surfaceWhite,
                CyclePhase.fertile,
              ),
              _buildFilterChip(
                'Ovulation',
                AppTheme.ovulationGold,
                AppTheme.surfaceWhite,
                CyclePhase.ovulation,
              ),
              _buildFilterChip(
                'Luteal',
                AppTheme.lutealYellow,
                const Color(0xFFF57F17),
                CyclePhase.luteal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    Color bgColor,
    Color textColor,
    CyclePhase phase,
  ) {
    final isSelected = _visiblePhases.contains(phase);
    return ElevatedFilterChip(
      label: label,
      activeBgColor: bgColor,
      activeTextColor: textColor,
      isSelected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _visiblePhases.add(phase);
          } else {
            _visiblePhases.remove(phase);
          }
        });
      },
    );
  }

  Widget _buildCalendarCell(
    DateTime day,
    TrackerProvider provider, {
    bool isToday = false,
  }) {
    final phase = provider.getPhaseForDay(day);
    final symptoms = provider.getSymptoms(day);
    final hasSymptoms = symptoms.isNotEmpty;

    Color bgColor = Colors.transparent;
    Color textColor = AppTheme.textDark;
    Color dotColor = AppTheme.primaryPink;

    if (_visiblePhases.contains(phase)) {
      switch (phase) {
        case CyclePhase.period:
          bgColor = AppTheme.primaryPink;
          textColor = AppTheme.surfaceWhite;
          dotColor = AppTheme.surfaceWhite;
          break;
        case CyclePhase.follicular:
          bgColor = AppTheme.follicularBlue;
          textColor = const Color(0xFF0277BD);
          dotColor = const Color(0xFF0277BD);
          break;
        case CyclePhase.fertile:
          bgColor = AppTheme.secondaryLavender;
          textColor = AppTheme.surfaceWhite;
          dotColor = AppTheme.surfaceWhite;
          break;
        case CyclePhase.ovulation:
          bgColor = AppTheme.ovulationGold;
          textColor = AppTheme.surfaceWhite;
          dotColor = AppTheme.surfaceWhite;
          break;
        case CyclePhase.luteal:
          bgColor = AppTheme.lutealYellow;
          textColor = const Color(0xFFF57F17);
          dotColor = const Color(0xFFF57F17);
          break;
        default:
          break;
      }
    }

    return Container(
      margin: isToday ? EdgeInsets.zero : const EdgeInsets.all(6),
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if (hasSymptoms)
            Positioned(
              bottom: 6,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ElevatedFilterChip extends StatelessWidget {
  final String label;
  final Color activeBgColor;
  final Color activeTextColor;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const ElevatedFilterChip({
    super.key,
    required this.label,
    required this.activeBgColor,
    required this.activeTextColor,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: isSelected ? activeTextColor : AppTheme.textDark,
      ),
      backgroundColor: Colors.transparent,
      selectedColor: activeBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : activeBgColor,
          width: 2,
        ),
      ),
      showCheckmark: false,
      selected: isSelected,
      onSelected: onSelected,
    );
  }
}
