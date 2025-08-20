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

  // ---- Location (şehir/ilçe/mahalle) ----
  static const String citiesAll = '/api/v1/cities/get-all-cities';

  static String districtsByCity(String cityId) =>
      '/api/v1/districts/get-by-city/$cityId';
  static const String districtsAll = '/api/v1/districts/get-all-districts';

  static String neighborhoodsByDistrict(String districtId) =>
      '/api/v1/neighborhoods/get-by-district/$districtId';
  static const String neighborhoodsAll = '/api/v1/neighborhoods/get-all';


  // ---- Venue Applications ----
  static const String userVenueApplicationsCreate = '/api/v1/user/venue-applications/create';
}


