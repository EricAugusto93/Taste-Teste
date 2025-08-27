import 'package:equatable/equatable.dart';

/// Classe base para todas as falhas
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Falha de servidor
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Falha de rede
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Falha de cache
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Falha de validação
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Falha de autenticação
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Falha de permissão
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Falha quando recurso não é encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Falha de conflito (ex: recurso já existe)
class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}