import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
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
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login berhasil'), backgroundColor: Colors.green),
          );
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
}
