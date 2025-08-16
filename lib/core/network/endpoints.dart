class ApiPaths {
  // Auth BASE'i muhtemelen /api/v1/auth gibi
  static const authBase = '/api/v1/auth';

  static const login = '$authBase/login';
  static const register = '$authBase/register';
  static const verifyEmail = '$authBase/verify-email';
  static const googleSignIn = '$authBase/google-sign-in';
  static const completeGoogleProfile = '$authBase/complete-google-profile';
}
