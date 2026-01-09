enum AuthRole { agent, user }

class AuthUser {
  final String uid;
  final AuthRole role;
  final bool isProfileCreated;
  final String? email;
  final String? fullName;
  final String? phone;

  const AuthUser({
    required this.uid,
    required this.role,
    this.isProfileCreated = false,
    this.email,
    this.fullName,
    this.phone,
  });
}
