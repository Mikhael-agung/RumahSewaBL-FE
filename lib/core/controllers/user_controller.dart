import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  // Observable variables agar UI bisa otomatis terupdate jika data berubah
  var id = 0.obs;
  var username = ''.obs;
  var role = ''.obs;
  var token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // Fungsi untuk memuat data dari SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    id.value = prefs.getInt('user_id') ?? 0;
    username.value = prefs.getString('user_username') ?? '';
    role.value = prefs.getString('user_role') ?? '';
    token.value = prefs.getString('jwt_token') ?? '';
  }

  // Fungsi pembantu untuk mengecek role
  bool hasRole(String targetRole) {
    return role.value.toLowerCase() == targetRole.toLowerCase();
  }

  // Getters untuk mempermudah pengecekan role yang umum
  bool get isAdmin => hasRole('administrator');
  bool get isTenant => hasRole('tenant');
  bool get isManager => hasRole('manager');

  // Fungsi untuk membersihkan data (saat logout)
  void clearUserData() {
    id.value = 0;
    username.value = '';
    role.value = '';
    token.value = '';
  }
}
