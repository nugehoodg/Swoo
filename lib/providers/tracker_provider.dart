import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/period_log.dart';

class TrackerProvider with ChangeNotifier {
  List<PeriodLog> _loggedPeriods = [];
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
      // Clear out the old format if migrating
      prefs.remove('logged_periods');
    }
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_loggedPeriods.map((e) => e.toJson()).toList());
    await prefs.setString('period_history', encoded);
  }

  Future<void> logPeriodStart(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (isPeriodActive) return; // Already active

    _loggedPeriods.add(PeriodLog(startDate: normalizedDate));
    _loggedPeriods.sort((a, b) => a.startDate.compareTo(b.startDate));
    await _saveData();
    notifyListeners();
  }

  Future<void> logPeriodEnd(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (!isPeriodActive) return; // None active

    // Ensure end date is not before start date
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

  bool isPeriodDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    if (_loggedPeriods.isEmpty) return false;

    for (var log in _loggedPeriods) {
      DateTime start = log.startDate;
      DateTime end = log.endDate ?? DateTime.now();
      
      if ((normalizedDay.isAfter(start.subtract(const Duration(days: 1))) &&
           normalizedDay.isBefore(end.add(const Duration(days: 1))))) {
        return true;
      }
    }
    
    if (isPeriodActive) return false;

    DateTime predictedStart = lastPeriod!.startDate;
    DateTime predictedEnd = lastPeriod!.endDate ?? predictedStart.add(const Duration(days: 4));
    int standardLength = predictedEnd.difference(predictedStart).inDays;
    if (standardLength < 1) standardLength = 4;

    while (predictedStart.isBefore(normalizedDay.add(Duration(days: averageCycleLength)))) {
      if ((normalizedDay.isAfter(predictedStart.subtract(const Duration(days: 1))) &&
           normalizedDay.isBefore(predictedStart.add(Duration(days: standardLength + 1))))) {
        return true;
      }
      predictedStart = predictedStart.add(Duration(days: averageCycleLength));
    }
    
    return false;
  }

  bool isFertileDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    if (_loggedPeriods.isEmpty) return false;

    DateTime cycleStart = lastPeriod!.startDate;
    for (int i = 0; i < 6; i++) {
       final fertileStart = cycleStart.add(const Duration(days: 11));
       final fertileEnd = cycleStart.add(const Duration(days: 16));
       
       if (normalizedDay.isAfter(fertileStart.subtract(const Duration(days: 1))) && 
           normalizedDay.isBefore(fertileEnd.add(const Duration(days: 1)))) {
         return true;
       }
       cycleStart = cycleStart.add(Duration(days: averageCycleLength));
    }
    return false;
  }

  Future<void> clearData() async {
    _loggedPeriods.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('period_history');
    notifyListeners();
  }
}
