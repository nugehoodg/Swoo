import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/period_log.dart';
import '../models/cycle_phase.dart';

class TrackerProvider with ChangeNotifier {
  List<PeriodLog> _loggedPeriods = [];
  Map<String, List<String>> _dailySymptoms = {};
  final int averageCycleLength = 28;

  List<PeriodLog> get loggedPeriods => _loggedPeriods;

  bool get isPeriodActive {
    if (_loggedPeriods.isEmpty) return false;
    return _loggedPeriods.last.endDate == null;
  }

  PeriodLog? get lastPeriod {
    if (_loggedPeriods.isEmpty) return null;
    return _loggedPeriods.last;
  }

  String _formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  List<String> getSymptoms(DateTime date) {
    final key = _formatDateKey(date);
    return _dailySymptoms[key] ?? [];
  }

  Future<void> toggleSymptom(DateTime date, String symptom) async {
    final key = _formatDateKey(date);
    final currentSymptoms = List<String>.from(_dailySymptoms[key] ?? []);
    
    if (currentSymptoms.contains(symptom)) {
      currentSymptoms.remove(symptom);
    } else {
      currentSymptoms.add(symptom);
    }

    if (currentSymptoms.isEmpty) {
      _dailySymptoms.remove(key);
    } else {
      _dailySymptoms[key] = currentSymptoms;
    }

    await _saveData();
    notifyListeners();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('period_history');
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        _loggedPeriods = decoded.map((e) => PeriodLog.fromJson(e)).toList();
        _loggedPeriods.sort((a, b) => a.startDate.compareTo(b.startDate));
      } catch (e) {
        _loggedPeriods = [];
      }
    } else {
      prefs.remove('logged_periods');
    }

    final String? symptomsData = prefs.getString('symptoms_data');
    if (symptomsData != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(symptomsData);
        _dailySymptoms = decoded.map((key, value) {
           return MapEntry(key, List<String>.from(value));
        });
      } catch (e) {
        _dailySymptoms = {};
      }
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_loggedPeriods.map((e) => e.toJson()).toList());
    await prefs.setString('period_history', encoded);

    final String encodedSymptoms = jsonEncode(_dailySymptoms);
    await prefs.setString('symptoms_data', encodedSymptoms);
  }

  Future<void> logPeriodStart(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (isPeriodActive) return;

    _loggedPeriods.add(PeriodLog(startDate: normalizedDate));
    _loggedPeriods.sort((a, b) => a.startDate.compareTo(b.startDate));
    await _saveData();
    notifyListeners();
  }

  Future<void> logPeriodEnd(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (!isPeriodActive) return;

    if (normalizedDate.isBefore(_loggedPeriods.last.startDate)) {
      _loggedPeriods.last.endDate = _loggedPeriods.last.startDate;
    } else {
      _loggedPeriods.last.endDate = normalizedDate;
    }
    
    await _saveData();
    notifyListeners();
  }

  int getDaysUntilNextPeriod() {
    if (_loggedPeriods.isEmpty) return -1;
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    
    DateTime nextPeriod = lastPeriod!.startDate.add(Duration(days: averageCycleLength));
    while (nextPeriod.isBefore(normalizedToday)) {
      nextPeriod = nextPeriod.add(Duration(days: averageCycleLength));
    }
    return nextPeriod.difference(normalizedToday).inDays;
  }

  int getDaysUntilPeriodEnd() {
    if (!isPeriodActive || lastPeriod == null) return 0;
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    
    DateTime predictedEnd = lastPeriod!.startDate.add(const Duration(days: 4));
    int daysLeft = predictedEnd.difference(normalizedToday).inDays;
    return daysLeft >= 0 ? daysLeft : 0;
  }

  CyclePhase getPhaseForDay(DateTime day) {
    if (_loggedPeriods.isEmpty) return CyclePhase.none;
    final normalizedDay = DateTime(day.year, day.month, day.day);

    for (var log in _loggedPeriods) {
      DateTime start = log.startDate;
      DateTime end = log.endDate ?? DateTime.now();
      
      if (!normalizedDay.isBefore(start) && !normalizedDay.isAfter(end)) {
        return CyclePhase.period;
      }
    }
    
    if (isPeriodActive) return CyclePhase.none;

    DateTime cycleStart = _loggedPeriods.first.startDate;
    
    while (cycleStart.add(Duration(days: averageCycleLength)).isBefore(normalizedDay)) {
        cycleStart = cycleStart.add(Duration(days: averageCycleLength));
    }

    for (int i = 0; i < 3; i++) {
        DateTime currentCycleStart = cycleStart.add(Duration(days: averageCycleLength * i));
        DateTime nextCycleStart = currentCycleStart.add(Duration(days: averageCycleLength));
        
        if (normalizedDay.isBefore(currentCycleStart) || !normalizedDay.isBefore(nextCycleStart)) {
             continue; // Not in this cycle window
        }
        
        DateTime periodEnd = currentCycleStart.add(const Duration(days: 4)); // predicted
        DateTime ovulation = nextCycleStart.subtract(const Duration(days: 14));
        DateTime fertileStart = ovulation.subtract(const Duration(days: 4));
        
        if (!normalizedDay.isAfter(periodEnd)) {
            return CyclePhase.period;
        } else if (normalizedDay.isBefore(fertileStart)) {
            return CyclePhase.follicular;
        } else if (normalizedDay.isBefore(ovulation)) {
            return CyclePhase.fertile;
        } else if (normalizedDay.isAtSameMomentAs(ovulation)) {
            return CyclePhase.ovulation;
        } else {
            return CyclePhase.luteal;
        }
    }
    
    return CyclePhase.none;
  }

  Future<void> clearData() async {
    _loggedPeriods.clear();
    _dailySymptoms.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('period_history');
    await prefs.remove('symptoms_data');
    notifyListeners();
  }
}
