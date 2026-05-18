import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:rumah_sewa_biru_laut_fe/core/controllers/user_controller.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginController extends GetxController {
  final LoginUseCase loginUseCase;

  LoginController({required this.loginUseCase});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  var isLoading = false.obs;
  var obscureText = true.obs;
  var rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedCredentials();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('saved_username');
    
    if (savedUsername != null && savedUsername.isNotEmpty) {
      usernameController.text = savedUsername;
      rememberMe.value = true;
    }
  }

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<bool> login(BuildContext context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password tidak boleh kosong')),
      );
      return false;
    }

    isLoading.value = true;

    try {
      final user = await loginUseCase.execute(username, password);
      
      if (user.token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', user.token);
        await prefs.setInt('user_id', user.id);
        await prefs.setString('user_username', user.username);
        await prefs.setString('user_role', user.role);

        if (rememberMe.value) {
          await prefs.setString('saved_username', user.username);
        } else {
          await prefs.remove('saved_username');
        }
        
        final userController = Get.find<UserController>();
        await userController.loadUserData();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login berhasil'), backgroundColor: Colors.green),
          );
          
          usernameController.clear();
          passwordController.clear();
          
          await validateUser(user, context);
        }
        return true; 
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login gagal. Token tidak ditemukan.'), backgroundColor: Colors.red),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> validateUser(User user, BuildContext context) async {
    bool isValid = true;
    String? targetRoute;

    switch (user.role.toLowerCase()) {
      case 'administrator':
        targetRoute = RouteName.adminDashPage;
        break;
      case 'manager':
        targetRoute = RouteName.managerDashPage;
        break;
      case 'tenant':
        targetRoute = RouteName.tenantDashPage;
        break;
      default:
        isValid = false;
    }

    if (isValid && targetRoute != null && context.mounted) {
        context.go(targetRoute);
    } else if (!isValid && context.mounted) {
       context.go(RouteName.loginScreen);
    }
  }
}
