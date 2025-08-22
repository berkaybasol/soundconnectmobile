// lib/core/network/api_paths.dart

/// Bu sınıf, backend’de tanımlı tüm REST API endpoint’lerinin Flutter tarafında
/// merkezi bir şekilde tutulması için kullanılır.
/// Böylece “hardcoded string” yerine her yerde sabitleri çağırabilir,
/// backend ile Flutter arasında uyumu kolayca sağlayabilirsin.
///
/// ÖNEMLİ: Backend’deki `EndPoints.java` ile birebir eşleşmeli, yoksa
/// Flutter yanlış path’ten request atar ve hata alırsın.
class ApiPaths {
  // ===== Base pieces =====
  // API versiyonlama için temel sabitler.
  static const String _api = '/api';           // Ortak prefix
  static const String _v1  = '$_api/v1';       // v1 versiyonu

  // ===== Auth =====
  // Kullanıcı kimlik doğrulama endpoint’leri
  static const String _authBase        = '$_v1/auth';
  static const String register         = '$_authBase/register';              // POST register
  static const String login            = '$_authBase/login';                 // POST login
  static const String verifyCode       = '$_authBase/verify-code';           // POST OTP doğrulama
  static const String resendCode       = '$_authBase/resend-code';           // POST OTP tekrar gönderme
  static const String googleSignIn     = '$_authBase/google-sign-in';        // POST Google login
  static const String completeGoogleProfile = '$_authBase/complete-google-profile'; // Google login sonrası profil tamamlama

  // ===== Location (City / District / Neighborhood) =====
  // Şehir, ilçe, mahalle işlemleri
  static const String citiesAll        = '$_v1/cities/get-all-cities';       // Tüm şehirler
  static String cityById(String id)    => '$_v1/cities/get-city/$id';        // Şehir id’ye göre
  static const String cityPretty       = '$_v1/cities/pretty';               // Formatlı şehir listesi

  static const String districtsAll     = '$_v1/districts/get-all-districts'; // Tüm ilçeler
  static String districtsByCity(String cityId) =>
      '$_v1/districts/get-by-city/$cityId';                                 // İlçeleri şehre göre getir
  static String districtById(String id) => '$_v1/districts/get-by-id/$id';   // İlçe id’ye göre getir

  static const String neighborhoodsAll = '$_v1/neighborhoods/get-all';       // Tüm mahalleler
  static String neighborhoodsByDistrict(String districtId) =>
      '$_v1/neighborhoods/get-by-district/$districtId';                      // Mahalleleri ilçeye göre
  static String neighborhoodById(String id) =>
      '$_v1/neighborhoods/get-by-id/$id';                                    // Mahalle id’ye göre

  // ===== Instruments =====
  // Kullanıcı enstrüman işlemleri
  static const String instrumentsAll = '$_v1/user/instruments';              // Kullanıcıya ait tüm enstrümanlar
  static String instrumentById(String id) => '$_v1/user/instruments/$id';    // Tek enstrüman
  // Admin işlemleri
  static const String instrumentsAdminCreate = '$_v1/admin/instruments';     // Yeni enstrüman oluştur
  static String instrumentsAdminDelete(String id) =>
      '$_v1/admin/instruments/$id';                                          // Enstrüman sil

  // ===== Musician Profile =====
  // Kullanıcı tarafı
  static const String _musicianUserBase = '$_v1/user/musician-profiles';
  static const String musicianMe        = '$_musicianUserBase/me';           // Benim müzisyen profilim
  static const String musicianCreate    = '$_musicianUserBase/create';       // Müzisyen profili oluştur
  static const String musicianUpdate    = '$_musicianUserBase/update';       // Güncelle
  // Admin tarafı
  static const String _musicianAdminBase = '$_v1/admin/musician-profiles';
  static String musicianByUserIdAdmin(String userId) =>
      '$_musicianAdminBase/by-user/$userId';                                // Belirli userId’ye göre
  static String musicianAdminUpdateByUser(String userId) =>
      '$_musicianAdminBase/by-user/$userId/update';                         // Admin tarafından güncelle

  // !!! Public musician endpoint backend’de yok, o yüzden kaldırıldı.

  // ===== Venue Applications =====
  // Kullanıcı tarafı
  static const String _venueAppsUserBase = '$_v1/user/venue-applications';
  static const String venueAppCreate     = '$_venueAppsUserBase/create';      // Mekan başvurusu yap
  static const String venueAppMy         = '$_venueAppsUserBase/my';          // Benim başvurularım
  static const String venueAppMyPending  = '$_venueAppsUserBase/my/pending';  // Bekleyen başvurularım
  // Admin tarafı
  static const String _venueAppsAdminBase = '$_v1/admin/venue-applications';
  static const String venueAppsByStatusAdmin = '$_venueAppsAdminBase/by-status';
  static String venueAppByIdAdmin(String id) =>
      '$_venueAppsAdminBase/$id';                                            // Başvuru id’ye göre getir
  static String venueAppApproveAdmin(String applicationId) =>
      '$_venueAppsAdminBase/approve/$applicationId';                         // Admin onayla
  static String venueAppRejectAdmin(String applicationId) =>
      '$_venueAppsAdminBase/reject/$applicationId';                          // Admin reddet

  // ===== Venue Profile =====
  // Kullanıcı tarafı
  static const String _venueProfileUserBase = '$_v1/user/venue-profiles';
  static const String venueProfileMe        = '$_venueProfileUserBase/me';    // Benim mekan profilim
  static String venueProfileUpdate(String venueId) =>
      '$_venueProfileUserBase/update/$venueId';                              // Mekan profilini güncelle
  // Admin tarafı
  static const String _venueProfileAdminBase = '$_v1/admin/venue-profiles';
  static String venueProfileByUserIdAdmin(String userId) =>
      '$_venueProfileAdminBase/by-user/$userId';                             // User’a göre getir
  static String venueProfileAdminUpdate(String userId, String venueId) =>
      '$_venueProfileAdminBase/by-user/$userId/$venueId/update';             // Admin update
  static String venueProfileAdminCreate(String venueId) =>
      '$_venueProfileAdminBase/create/$venueId';                             // Admin create

  // ===== Listener Profile =====
  static const String _listenerUserBase = '$_v1/user/listener-profiles';
  static const String listenerMe        = '$_listenerUserBase/me';            // Benim dinleyici profilim
  static const String listenerCreate    = '$_listenerUserBase/create';        // Dinleyici profili oluştur
  static const String listenerUpdate    = '$_listenerUserBase/update';        // Güncelle
  // Admin
  static const String _listenerAdminBase = '$_v1/admin/listener-profiles';
  static String listenerByUserIdAdmin(String userId) =>
      '$_listenerAdminBase/by-user/$userId';                                 // User id’ye göre getir
  static String listenerAdminUpdate(String userId) =>
      '$_listenerAdminBase/update/$userId';                                  // Güncelle

  // ===== Organizer Profile =====
  static const String _organizerUserBase = '$_v1/user/organizer-profiles';
  static const String organizerMe        = '$_organizerUserBase/me';          // Benim organizatör profilim
  static const String organizerUpdate    = '$_organizerUserBase/update';      // Güncelle
  // Admin
  static const String _organizerAdminBase = '$_v1/admin/organizer-profiles';
  static String organizerByUserIdAdmin(String userId) =>
      '$_organizerAdminBase/by-user/$userId';                                // User id’ye göre getir
  static String organizerAdminUpdate(String userId) =>
      '$_organizerAdminBase/by-user/$userId/update';                         // Admin güncelle

  // ===== Producer Profile =====
  static const String _producerUserBase = '$_v1/user/producer-profiles';
  static const String producerMe        = '$_producerUserBase/me';            // Benim prodüktör profilim
  static const String producerUpdate    = '$_producerUserBase/update';        // Güncelle
  // Admin
  static const String _producerAdminBase = '$_v1/admin/producer-profiles';
  static String producerByUserIdAdmin(String userId) =>
      '$_producerAdminBase/by-user/$userId';                                 // User id’ye göre getir
  static String producerAdminUpdate(String userId) =>
      '$_producerAdminBase/by-user/$userId/update';                          // Admin güncelle

  // ===== DM (Direct Message) =====
  // Kullanıcı tarafı
  static const String _dmUserBase = '$_v1/user/dm';
  static const String dmConversationList   = '$_dmUserBase/conversations/my'; // Benim konuşmalarım
  static const String dmConversationBetween= '$_dmUserBase/conversations/between'; // ?otherUserId={uuid}
  static String dmMessagesByConversation(String conversationId) =>
      '$_dmUserBase/messages/conversation/$conversationId';                   // Konuşmaya göre mesajlar
  static const String dmMessageSend        = '$_dmUserBase/messages';         // Mesaj gönder
  static String dmMessageMarkRead(String messageId) =>
      '$_dmUserBase/messages/$messageId/read';                               // Mesajı okundu işaretle
  // Admin
  static const String _dmAdminBase = '$_v1/admin/dm';
  static const String dmAdminConversations = '$_dmAdminBase/conversations';   // Tüm konuşmalar
  static String dmAdminConversationById(String conversationId) =>
      '$_dmAdminBase/$conversationId';                                       // Tek konuşma
  static const String dmAdminMessages = '$_dmAdminBase/messages';             // Mesaj listesi
  static String dmAdminDeleteMessage(String conversationId, String messageId) =>
      '$_dmAdminBase/$conversationId/messages/$messageId';                   // Admin mesaj sil

  // ===== Follow =====
  static const String _followBase  = '$_v1/follow';
  static const String follow       = '$_followBase/';                         // POST takip et
  static const String unfollow     = '$_followBase/unfollow';                 // POST takipten çık
  static String getFollowing(String userId) =>
      '$_followBase/following/$userId';                                      // Kullanıcının takip ettikleri
  static String getFollowers(String userId) =>
      '$_followBase/followers/$userId';                                      // Kullanıcının takipçileri
  static const String isFollowing  = '$_followBase/is-following';             // GET ?followerId=&followingId=

  // ===== Users (genel admin/user yönetimi – gerekirse) =====
  static const String _usersBase = '$_v1/users';
  static const String usersAll   = '$_usersBase/get-all-users';               // Tüm kullanıcılar
  static String userById(String id) => '$_usersBase/$id';                     // Tek kullanıcı
  static const String userSave   = '$_usersBase/save';                        // Yeni kullanıcı
  static String userUpdate(String id) => '$_usersBase/update/$id';            // Güncelle
  static String userDelete(String id) => '$_usersBase/delete/$id';            // Sil

  // ===== Venues (genel CRUD) =====
  static const String _venuesBase = '$_v1/venues';
  static const String venuesAll   = '$_venuesBase/get-all';                   // Tüm mekanlar
  static String venueById(String id) => '$_venuesBase/get-by-id/$id';         // Tek mekan
  static const String venueSave   = '$_venuesBase/save';                      // Kaydet
  static String venueUpdate(String id) => '$_venuesBase/update/$id';          // Güncelle
  static String venueDelete(String id) => '$_venuesBase/delete/$id';          // Sil
}
