class UserModel {
  final String id;
  final String email;
  final String displayName;
  final int totalMeasurements;
  final bool hasSpeakerEmbedding;
  final bool hasFaceEmbedding;
  final String? enrolledAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.totalMeasurements,
    required this.hasSpeakerEmbedding,
    this.hasFaceEmbedding = false,
    this.enrolledAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['display_name'] as String,
        totalMeasurements: json['total_measurements'] as int,
        hasSpeakerEmbedding: json['has_speaker_embedding'] as bool? ?? false,
        hasFaceEmbedding: json['has_face_embedding'] as bool? ?? false,
        enrolledAt: json['enrolled_at'] as String?,
      );
}
