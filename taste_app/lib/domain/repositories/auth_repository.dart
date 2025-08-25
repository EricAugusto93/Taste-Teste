import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user_profile.dart';

/// Interface do repositório de autenticação
abstract class AuthRepository {
  /// Fazer login com email e senha
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  });

  /// Registrar novo usuário
  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Fazer logout
  Future<Either<Failure, void>> logout();

  /// Verificar se usuário está autenticado
  Future<Either<Failure, bool>> isAuthenticated();

  /// Obter usuário atual
  Future<Either<Failure, UserProfile?>> getCurrentUser();

  /// Recuperar senha
  Future<Either<Failure, void>> resetPassword(String email);

  /// Atualizar perfil do usuário
  Future<Either<Failure, void>> updateProfile(UserProfile profile);
}