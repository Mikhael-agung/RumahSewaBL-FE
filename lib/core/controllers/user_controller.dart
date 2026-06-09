import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  var id = 0.obs;
  var username = ''.obs;
  var role = ''.obs;
  var token = ''.obs;
  var activeMenu = 'Dashboard'.obs;

  void changeMenu(String menu) {
    activeMenu.value = menu;
  }

  String _normalizeRole(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
  }

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    id.value = prefs.getInt('user_id') ?? 0;
    username.value = prefs.getString('user_username') ?? '';
    role.value = prefs.getString('user_role') ?? '';
    token.value = prefs.getString('jwt_token') ?? '';
  }

  bool hasRole(String targetRole) {
    final normalizedUserRole = _normalizeRole(role.value);
    final normalizedTargetRole = _normalizeRole(targetRole);

    if (normalizedUserRole == normalizedTargetRole) {
      return true;
    }

    const roleAliases = <String, Set<String>>{
      'administrator': {'admin', 'superadmin', 'roleadmin'},
      'manager': {'staff', 'petugas', 'rolemanager'},
      'tenant': {'penyewa', 'user', 'roletenant'},
    };

    return roleAliases[normalizedTargetRole]?.contains(normalizedUserRole) ==
            true ||
        roleAliases[normalizedUserRole]?.contains(normalizedTargetRole) == true;
  }

  bool get isAdmin => hasRole('administrator');
  bool get isTenant => hasRole('tenant');
  bool get isManager => hasRole('manager');

  void clearUserData() {
    id.value = 0;
    username.value = '';
    role.value = '';
    token.value = '';
  }
}
