import '../features/profile/models/user_profile.dart';

export '../features/profile/models/user_profile.dart' show UserProfile;

class User extends UserProfile {
  const User({
    required super.name,
    required super.email,
    super.photoUrl,
    super.createdAt,
    super.id = '',
  });
}
