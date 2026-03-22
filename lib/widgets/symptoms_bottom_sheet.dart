import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/tracker_provider.dart';
import '../core/theme/app_theme.dart';

class SymptomsBottomSheet extends StatelessWidget {
  final DateTime date;

  const SymptomsBottomSheet({super.key, required this.date});

  static const List<String> availableSymptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Fatigue',
    'Mood Swings',
    'Acne',
    'Cravings',
    'Backache',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrackerProvider>();
    final selectedSymptoms = provider.getSymptoms(date);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            DateFormat('MMMM d, yyyy').format(date),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryPink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log your symptoms for this day.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textDark.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: availableSymptoms.map((symptom) {
              final isSelected = selectedSymptoms.contains(symptom);
              return FilterChip(
                label: Text(symptom),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.textDark,
                ),
                backgroundColor: AppTheme.backgroundPeach,
                selectedColor: AppTheme.primaryPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : AppTheme.primaryPink.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                showCheckmark: false,
                selected: isSelected,
                onSelected: (_) {
                  provider.toggleSymptom(date, symptom);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textDark,
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text(
              'Save & Close',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
