class PeriodLog {
  DateTime startDate;
  DateTime? endDate;

  PeriodLog({required this.startDate, this.endDate});

  Map<String, dynamic> toJson() => {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      };

  factory PeriodLog.fromJson(Map<String, dynamic> json) {
    return PeriodLog(
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}
