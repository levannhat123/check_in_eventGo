class AppStorageKey {
  // Local storage keys
  static const String isLoggedIn = 'isLoggedIn';
  static const String isFirstLaunch = 'isFirstLaunch';

  // HTTP/auth headers and tokens
  static const String accessToken = 'access_token';
  static const String headerAuthToken = 'X-Csrf-Token';
  static const String headerAuthCookie = 'cookie';
  static const String headerSetCookie = 'set-cookie';
  static const String keyAuthCookie = 'auth_cookie';

  // Firestore/Supabase collections or buckets
  static const String profilesTable = 'profiles';
  static const String ticketsCollection = 'tickets';
  static const String ordersCollection = 'orders';
  static const String avatarsProfileBucket = 'avatars_profile';

  // Common fields
  static const String id = 'id';
  static const String role = 'role';
  static const String email = 'email';
  static const String fullName = 'full_name';
  static const String avatarUrl = 'avatar_url';
  static const String phone = 'phone';
  static const String eventId = 'eventId';
  static const String paymentStatus = 'paymentStatus';
  static const String startTime = 'startTime';
  static const String endTime = 'endTime';
  static const String tickets = 'tickets';
  static const String quantity = 'quantity';
  static const String checkedIn = 'checkedIn';
  static const String checkInStatus = 'checkinStatus';
  static const String checkInTimestamp = 'checkinTimestamp';
  static const String userEmail = 'userEmail';
  static const String createdAt = 'createdAt';

  // Common values
  static const String statusCompleted = 'completed';
  static const String statusPartial = 'partial';
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';
}
