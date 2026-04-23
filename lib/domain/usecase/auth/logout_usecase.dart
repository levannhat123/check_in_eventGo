import '../../../core/constants/app_strings.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../entities/auth_result.dart';

class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<AuthResult> call() async {
    try {
      await _authRepository.signOut();
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure(
        AppStrings.logoutErrorWithDetails + e.toString(),
      );
    }
  }
}
