import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/failures.dart';
import '../usecase.dart';

/// Parâmetros para registro
class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String name;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

/// Caso de uso para registrar usuário
class RegisterUseCase implements UseCase<void, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}