import 'package:dartz/dartz.dart';
import '../../entities/location.dart';
import '../../repositories/location_repository.dart';
import '../../../core/error/failures.dart';
import '../usecase.dart';

/// Caso de uso para obter localização atual
class GetCurrentLocationUseCase implements UseCase<Location, NoParams> {
  final LocationRepository repository;

  GetCurrentLocationUseCase(this.repository);

  @override
  Future<Either<Failure, Location>> call(NoParams params) async {
    return await repository.getCurrentLocation();
  }
}