class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String rePassword;
  /// Backend RoleEnum bekliyor → "ROLE_USER", "ROLE_MUSICIAN", "ROLE_VENUE", "ROLE_LISTENER",
  /// "ROLE_STUDIO", "ROLE_ORGANIZER", "ROLE_PRODUCER" gibi **string** göndereceğiz.
  final String role;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.rePassword,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'password': password,
    'rePassword': rePassword,
    'role': role,
  };
}
