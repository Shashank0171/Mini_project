/// Model representing a detected object from YOLOv8.
class DetectionResult {
  final String name;
  final double confidence;

  const DetectionResult({
    required this.name,
    required this.confidence,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      name: json['name'] as String? ?? 'unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'confidence': confidence,
    };
  }

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';
}
