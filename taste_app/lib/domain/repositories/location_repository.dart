import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/location.dart';

/// Interface do repositório de localização
abstract class LocationRepository {
  /// Obter localização atual do usuário
  Future<Either<Failure, Location>> getCurrentLocation();

  /// Verificar se as permissões de localização estão concedidas
  Future<Either<Failure, bool>> hasLocationPermission();

  /// Solicitar permissões de localização
  Future<Either<Failure, bool>> requestLocationPermission();

  /// Verificar se o serviço de localização está habilitado
  Future<Either<Failure, bool>> isLocationServiceEnabled();

  /// Obter endereço a partir de coordenadas (geocoding reverso)
  Future<Either<Failure, String>> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  });

  /// Obter coordenadas a partir de endereço (geocoding)
  Future<Either<Failure, Location>> getCoordinatesFromAddress(String address);
}