import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/tracker_provider.dart';
import '../core/theme/app_theme.dart';

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
    final daysUntil = provider.getDaysUntilNextPeriod();
    final today = DateTime.now();
    final isFertile = provider.isFertileDay(today);
    final isPeriod = provider.isPeriodDay(today);
    final isActive = provider.isPeriodActive;

    String statusText = 'Normal Day';
    Color statusColor = AppTheme.textDark.withOpacity(0.1);
    Color statusTextColor = AppTheme.textDark;

    if (isPeriod) {
      statusText = 'Period Week';
      statusColor = AppTheme.primaryPink.withOpacity(0.15);
      statusTextColor = AppTheme.primaryPink;
    } else if (isFertile) {
      statusText = 'Fertile Window';
      statusColor = AppTheme.secondaryLavender.withOpacity(0.15);
      statusTextColor = AppTheme.secondaryLavender;
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
                        'Days until next period',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.textDark.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        daysUntil >= 0 ? daysUntil.toString() : '--',
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
