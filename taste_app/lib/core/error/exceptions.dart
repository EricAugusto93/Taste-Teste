/// Classe base para todas as exceções
abstract class AppException implements Exception {
  final String message;
  
  const AppException(this.message);
  
  @override
  String toString() => message;
}

/// Exceção de servidor
class ServerException extends AppException {
  const ServerException(String message) : super(message);
}

/// Exceção de rede
class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}

/// Exceção de cache
class CacheException extends AppException {
  const CacheException(String message) : super(message);
}

/// Exceção de validação
class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}

/// Exceção de autenticação
class AuthException extends AppException {
  const AuthException(String message) : super(message);
}

/// Exceção de permissão
class PermissionException extends AppException {
  const PermissionException(String message) : super(message);
}

/// Exceção quando recurso não é encontrado
class NotFoundException extends AppException {
  const NotFoundException(String message) : super(message);
}

/// Exceção de conflito (ex: recurso já existe)
class ConflictException extends AppException {
  const ConflictException(String message) : super(message);
}