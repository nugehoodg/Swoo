import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/tracker_provider.dart';
import '../core/theme/app_theme.dart';
import '../models/cycle_phase.dart';
import '../widgets/symptoms_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrackerProvider>();
    final today = DateTime.now();
    final phase = provider.getPhaseForDay(today);
    final isActive = provider.isPeriodActive;
    final displayValue = isActive
        ? provider.getDaysUntilPeriodEnd()
        : provider.getDaysUntilNextPeriod();

    String statusText = 'Normal Day';
    Color statusColor = AppTheme.textDark.withOpacity(0.1);
    Color statusTextColor = AppTheme.textDark;

    switch (phase) {
      case CyclePhase.period:
        statusText = 'Period Phase';
        statusColor = AppTheme.primaryPink.withOpacity(0.15);
        statusTextColor = AppTheme.primaryPink;
        break;
      case CyclePhase.follicular:
        statusText = 'Follicular Phase';
        statusColor = AppTheme.follicularBlue.withOpacity(0.3);
        statusTextColor = const Color(0xFF0277BD);
        break;
      case CyclePhase.fertile:
        statusText = 'Fertile Window';
        statusColor = AppTheme.secondaryLavender.withOpacity(0.15);
        statusTextColor = AppTheme.secondaryLavender;
        break;
      case CyclePhase.ovulation:
        statusText = 'Ovulation Day';
        statusColor = AppTheme.ovulationGold.withOpacity(0.3);
        statusTextColor = const Color(0xFFE65100);
        break;
      case CyclePhase.luteal:
        statusText = 'Luteal Phase';
        statusColor = AppTheme.lutealYellow.withOpacity(0.5);
        statusTextColor = const Color(0xFFF57F17);
        break;
      default:
        break;
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 48,
                    horizontal: 24,
                  ),
                  child: Column(
                    children: [
                      Text(
                        isActive
                            ? 'Days left before period stopped'
                            : 'Days until next period',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.textDark.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayValue >= 0 ? displayValue.toString() : '--',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 100,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryPink,
                              height: 1.0,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusTextColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SymptomsBottomSheet.availableSymptoms.map((
                        symptom,
                      ) {
                        final isSelected = provider
                            .getSymptoms(today)
                            .contains(symptom);
                        return FilterChip(
                          label: Text(symptom),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textDark,
                            fontSize: 12,
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
                            provider.toggleSymptom(today, symptom);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  if (isActive) {
                    provider.logPeriodEnd(DateTime.now());
                    _confettiController.play();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Period stopped. Great job tracking!',
                        ),
                        backgroundColor: AppTheme.secondaryLavender,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  } else {
                    provider.logPeriodStart(DateTime.now());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Period start logged for today!'),
                        backgroundColor: AppTheme.primaryPink,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(
                  isActive
                      ? Icons.stop_circle_outlined
                      : Icons.add_circle_outline,
                ),
                label: Text(isActive ? 'Log Period Off' : 'Log Period Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive
                      ? AppTheme.textDark
                      : AppTheme.primaryPink,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppTheme.primaryPink,
              AppTheme.secondaryLavender,
              Colors.white,
              AppTheme.backgroundPeach,
            ],
          ),
        ),
      ],
    );
  }
}
