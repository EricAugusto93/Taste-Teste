import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/failures.dart';
import '../usecase.dart';

/// Parâmetros para login
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Caso de uso para fazer login
class LoginUseCase implements UseCase<void, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}