// lib/core/network/api_paths.dart

/// Backend endpoint sabitleri
class ApiPaths {
  static const String authBase = '/api/v1/auth';

  // Auth
  static const String register   = '$authBase/register';
  static const String login      = '$authBase/login';
  static const String verifyCode = '$authBase/verify-code';
  static const String resendCode = '$authBase/resend-code';

  // (Opsiyonel) Google
  static const String googleSignIn = '$authBase/google-sign-in';
  static const String completeGoogleProfile = '$authBase/complete-google-profile';
}
