import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  @override
  User? get currentUser => _supabase.auth.currentUser;

  @override
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  @override
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  @override
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response.user;
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);
  }

  @override
  Future<User?> updatePassword(String newPassword) async {
    final response = await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    return response.user;
  }

  @override
  Future<void> sendEmailVerification(String email, String otpCode) async {
    await _supabase.auth.verifyOTP(
      type: OtpType.email,
      email: email,
      token: otpCode,
    );
  }
}
