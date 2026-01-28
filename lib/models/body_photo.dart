class BodyPhoto {
  final String imageUrl;
  final DateTime date;
  final double? weight;

  BodyPhoto({
    required this.imageUrl,
    required this.date,
    this.weight,
  });

  factory BodyPhoto.fromJson(Map<String, dynamic> json) {
    return BodyPhoto(
      imageUrl: json['imageUrl'],
      date: DateTime.parse(json['date']),
      weight: json['weight']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'date': date.toIso8601String(),
      'weight': weight,
    };
  }
}
