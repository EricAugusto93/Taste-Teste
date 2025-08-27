/// Classe base para todas as exceções
abstract class AppException implements Exception {
  final String message;
  
  const AppException(this.message);
  
  @override
  String toString() => message;
}

/// Exceção de servidor
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Exceção de rede
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Exceção de cache
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Exceção de validação
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Exceção de autenticação
class AuthException extends AppException {
  const AuthException(super.message);
}

/// Exceção de permissão
class PermissionException extends AppException {
  const PermissionException(super.message);
}

/// Exceção quando recurso não é encontrado
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Exceção de conflito (ex: recurso já existe)
class ConflictException extends AppException {
  const ConflictException(super.message);
}