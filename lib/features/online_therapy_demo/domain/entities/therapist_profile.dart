class TherapistProfile {
  const TherapistProfile({
    required this.id,
    required this.userId,
    required this.title,
    required this.specialties,
    required this.languages,
    required this.bio,
    required this.rating,
    required this.isVerified,
  });

  final String id;
  final String userId;
  final String title;
  final List<String> specialties;
  final List<String> languages;
  final String bio;
  final double rating;
  final bool isVerified;
}
