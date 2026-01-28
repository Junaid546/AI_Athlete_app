class ProgressMetric {
  final DateTime date;
  final String metricType; // e.g., 'volume', 'strength', 'endurance'
  final double value;

  ProgressMetric({
    required this.date,
    required this.metricType,
    required this.value,
  });

  factory ProgressMetric.fromJson(Map<String, dynamic> json) {
    return ProgressMetric(
      date: DateTime.parse(json['date']),
      metricType: json['metricType'],
      value: json['value'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'metricType': metricType,
      'value': value,
    };
  }
}
