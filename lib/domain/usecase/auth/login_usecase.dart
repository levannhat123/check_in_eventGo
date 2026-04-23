import '../../../data/repositories/auth/auth_repository.dart';
import '../../entities/auth_result.dart';
import '../../utils/auth_error_handler.dart';

class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<AuthResult> call(String email, String password) async {
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email,
        password,
      );
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure(AuthErrorHandler.getErrorMessage(e));
    }
  }
}
