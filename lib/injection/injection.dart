import 'package:check_in_qr/presentation/view_models/home_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/auth/auth_repository_impl.dart';
import '../domain/usecase/auth/login_usecase.dart';
import '../domain/usecase/auth/logout_usecase.dart';
import '../presentation/view_models/auth_change_notifier.dart';
import '../presentation/view_models/auth_view_model.dart';

final getIt = GetIt.instance;

void setupDependencies(GoRouter router) {
  getIt.registerSingleton<AuthChangeNotifier>(AuthChangeNotifier());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  // UseCases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(
    () => AuthViewModel(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory(() => HomeViewModel());
}
