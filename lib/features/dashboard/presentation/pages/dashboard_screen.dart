import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Clear all shared preferences
              
              if (context.mounted) {
                context.go(RouteName.loginScreen);
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("Selamat Datang di Dashboard!"),
      ),
    );
  }
}
