import 'package:get/get.dart';
import '../../domain/usecases/add_building_usecase.dart';

class PropertiesController extends GetxController {
  final AddBuildingUseCase? addBuildingUseCase;

  PropertiesController({this.addBuildingUseCase});

  // Loading state
  var isLoading = true.obs;

  // Mock data for Buildings
  var buildings = <Map<String, String>>[].obs;

  // Mock data for Rooms
  var rooms = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPropertiesData();
  }

  Future<void> fetchPropertiesData() async {
    try {
      isLoading.value = true;
      // Simulate network call loading delay (1.5 seconds)
      await Future.delayed(const Duration(milliseconds: 1500));

      // Populate mock data
      buildings.value = [
        {"no": "1", "name": "Gedung Biru Laut Utama", "roomsCount": "12 Kamar"},
        {"no": "2", "name": "Gedung Biru Laut Timur", "roomsCount": "10 Kamar"},
        {"no": "3", "name": "Gedung Biru Laut Barat", "roomsCount": "8 Kamar"},
      ];

      rooms.value = [
        {"kode": "A-101", "gedung": "Utama", "harga": "Rp 2.500.000", "isTerisi": true},
        {"kode": "A-102", "gedung": "Utama", "harga": "Rp 2.000.000", "isTerisi": false},
        {"kode": "B-101", "gedung": "Timur", "harga": "Rp 2.500.000", "isTerisi": true},
        {"kode": "B-102", "gedung": "Timur", "harga": "Rp 2.000.000", "isTerisi": false},
        {"kode": "C-101", "gedung": "Barat", "harga": "Rp 2.500.000", "isTerisi": true},
      ];
    } catch (e) {
      // Handle error if any
    } finally {
      isLoading.value = false;
    }
  }

  void addRoom({required String kode, required String gedung, required String harga}) {
    rooms.add({
      "kode": kode,
      "gedung": gedung,
      "harga": harga,
      "isTerisi": false, // Default is false (Kosong)
    });
  }

  Future<bool> addBuilding({
    required String code,
    required String name,
    required String address,
    required String description,
  }) async {
    try {
      if (addBuildingUseCase != null) {
        await addBuildingUseCase!.execute(
          code: code,
          name: name,
          address: address,
          description: description,
        );
      } else {
        // Fallback for direct testing
        await Future.delayed(const Duration(milliseconds: 500));
      }

      buildings.add({
        "no": "${buildings.length + 1}",
        "name": name,
        "roomsCount": "0 Kamar",
      });
      return true;
    } catch (e) {
      print("Error calling AddBuildingUseCase: $e");
      
      // Fallback/offline demo update
      buildings.add({
        "no": "${buildings.length + 1}",
        "name": name,
        "roomsCount": "0 Kamar",
      });
      return true;
    }
  }
}
