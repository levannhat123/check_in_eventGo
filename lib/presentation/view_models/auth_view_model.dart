import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/base/base_view_model.dart';
import '../../core/constants/app_storage_key.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/auth/auth_repository.dart';
import '../../domain/usecase/auth/login_usecase.dart';
import '../../domain/usecase/auth/logout_usecase.dart';

class AuthViewModel extends BaseViewModel {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _authRepository;
  ProfileModel? _userProfile;
  ProfileModel? get userProfile => _userProfile;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository authRepository,
  }) : _loginUseCase = loginUseCase,

       _logoutUseCase = logoutUseCase,

       _authRepository = authRepository {
    _authRepository.authStateChanges.listen((authState) {
      _currentUser = authState.session?.user;
      Future.microtask(() => notifyListeners());
    });
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _authRepository.isLoggedIn;
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  int _countdown = 60;
  bool _canResend = false;
  Timer? _otpTimer;

  int get countdown => _countdown;
  bool get canResend => _canResend;
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void resetNewPasswordScreenState() {
    _obscurePassword = true;
    _obscureConfirmPassword = true;
  }

  void startOtpCountdown() {
    _otpTimer?.cancel();
    _countdown = 60;
    _canResend = false;
    notifyListeners();

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _countdown--;
      } else {
        _canResend = true;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  void stopOtpCountdown() {
    _otpTimer?.cancel();
  }

  Future<void> checkAuthState() async {
    try {
      _setLoading(true);
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final now = DateTime.now().millisecondsSinceEpoch / 1000;
        if (session.expiresAt != null && session.expiresAt! > now) {
          try {
            final profile = await Supabase.instance.client
                .from(AppStorageKey.profilesTable)
                .select(AppStorageKey.role)
                .eq(AppStorageKey.id, session.user.id)
                .maybeSingle();

            debugPrint('User profile: $profile');
            if (profile != null &&
                profile[AppStorageKey.role] != AppStorageKey.roleAdmin) {
              _currentUser = session.user;
              await _saveLoginState(true);
            } else {
              await logout();
            }
          } catch (e) {
            await _createUserProfile(session.user);
            _currentUser = session.user;
            await _saveLoginState(true);
          }
        } else {
          await logout();
        }
      } else {
        _currentUser = null;
        await _saveLoginState(false);
      }

      _isInitialized = true;
      _setLoading(false);
    } catch (e) {
      _isInitialized = true;
      _setLoading(false);
      debugPrint('Error checking auth state: $e');
    }
  }

  Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStorageKey.isLoggedIn, isLoggedIn);
  }

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool(AppStorageKey.isFirstLaunch) ?? true;
    if (isFirst) {
      await prefs.setBool(AppStorageKey.isFirstLaunch, false);
    }
    return isFirst;
  }

  Future<void> _createUserProfile(User user) async {
    await Supabase.instance.client.from(AppStorageKey.profilesTable).insert({
      AppStorageKey.id: user.id,
      AppStorageKey.role: AppStorageKey.roleUser,
      AppStorageKey.email: user.email,
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _loginUseCase(email, password);

      if (result.isSuccess && result.user != null) {
        final profile = await Supabase.instance.client
            .from(AppStorageKey.profilesTable)
            .select(AppStorageKey.role)
            .eq(AppStorageKey.id, result.user!.id)
            .maybeSingle();

        if (profile == null) {
          await _createUserProfile(result.user!);
        }

        if (profile == null ||
            profile[AppStorageKey.role] != AppStorageKey.roleAdmin &&
                profile[AppStorageKey.role] != AppStorageKey.roleUser) {
          _currentUser = result.user;
          await _saveLoginState(true);
          _setLoading(false);
          return true;
        } else {
          await logout();
          _setLoading(false);
          _setError(
            "Chỉ nhân viên (Staff) mới được phép truy cập chức năng này.",
          );
          return false;
        }
      } else {
        _setLoading(false);
        _setError(result.errorMessage ?? AppStrings.loginFailed);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError(AppStrings.unknownError);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final result = await _logoutUseCase();
      if (result.isSuccess) {
        _currentUser = null;
        notifyListeners();
      } else {
        _setError(result.errorMessage ?? AppStrings.logoutFailed);
      }
    } catch (e) {
      _setError(AppStrings.logoutError);
    }
  }

  String get userEmail {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.email ?? 'Không tìm thấy email';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void clearError() {
    _clearError();
  }

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  File? _imageFile;
  File? get imageFile => _imageFile;

  String? _networkAvatarUrl;
  String? get networkAvatarUrl => _networkAvatarUrl;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _networkAvatarUrl = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

  Future<void> updateUserProfile(ProfileModel user) async {
    try {
      String? finalAvatarUrl = _userProfile?.avatarUrl;
      _setLoading(true);

      if (_imageFile != null) {
        debugPrint('Đang upload ảnh mới...');
        final file = _imageFile!;
        final fileName = 'public/${user.id}.jpg';
        await Supabase.instance.client.storage
            .from(AppStorageKey.avatarsProfileBucket)
            .upload(
              fileName,
              file, // File local
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );
        final tempUrl = Supabase.instance.client.storage
            .from(AppStorageKey.avatarsProfileBucket)
            .getPublicUrl(fileName);

        finalAvatarUrl = '$tempUrl?t=${DateTime.now().millisecondsSinceEpoch}';

        debugPrint('Upload thành công: $finalAvatarUrl');
      }

      final profileToSave = user.copyWith(avatarUrl: finalAvatarUrl);
      await Supabase.instance.client.from(AppStorageKey.profilesTable).upsert({
        AppStorageKey.id: profileToSave.id,
        AppStorageKey.email: profileToSave.email,
        AppStorageKey.fullName: profileToSave.fullName,
        AppStorageKey.avatarUrl: profileToSave.avatarUrl,
        AppStorageKey.phone: profileToSave.phone,
      });

      _userProfile = profileToSave;
      _networkAvatarUrl = profileToSave.avatarUrl;
      debugPrint('Upserted profile for user: ${user.email}');
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      debugPrint('Error upserting profile: $e');
    }
  }

  Future<void> refreshUserProfile() async {
    await _fetchUserProfile();
    if (_userProfile != null) {
      nameController.text = _userProfile?.fullName ?? '';
      phoneController.text = _userProfile?.phone ?? '';
      emailController.text = _userProfile?.email ?? '';
      _networkAvatarUrl = _userProfile?.avatarUrl;
      _imageFile = null;
    }
    notifyListeners();
  }

  Future<void> initialize() async {
    await _fetchUserProfile();
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    if (_userProfile != null) {
      nameController.text = _userProfile?.fullName ?? '';
      phoneController.text = _userProfile?.phone ?? '';
      emailController.text = _userProfile?.email ?? user.email ?? '';
      _networkAvatarUrl = _userProfile?.avatarUrl;
      _imageFile = null;
    } else {
      nameController.text = '';
      phoneController.text = '';
      emailController.text = user.email ?? '';
      _imageFile = null;
      _networkAvatarUrl = null;
    }
    notifyListeners();
  }

  Future<void> _fetchUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _userProfile = null;
      return;
    }

    try {
      final profileData = await Supabase.instance.client
          .from(AppStorageKey.profilesTable)
          .select()
          .eq(AppStorageKey.id, user.id)
          .single();
      _userProfile = ProfileModel.fromJson(profileData);
      debugPrint('Profile refreshed: ${_userProfile?.fullName}');
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      _userProfile = null;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
