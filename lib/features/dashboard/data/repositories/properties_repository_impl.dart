import '../../domain/entities/building.dart';
import '../../domain/repositories/properties_repository.dart';
import '../datasources/properties_remote_data_source.dart';

class PropertiesRepositoryImpl implements PropertiesRepository {
  final PropertiesRemoteDataSource remoteDataSource;

  PropertiesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Building> addBuilding({
    required String code,
    required String name,
    required String address,
    required String description,
  }) async {
    return await remoteDataSource.addBuilding(
      code: code,
      name: name,
      address: address,
      description: description,
    );
  }
}
