class CycleData {
  final DateTime startDate;
  final int lengthInDays;

  CycleData({required this.startDate, this.lengthInDays = 28});

  DateTime get nextPredictedDate => startDate.add(Duration(days: lengthInDays));
}
