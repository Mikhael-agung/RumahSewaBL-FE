import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller dihilangkan di sini karena sudah di-inject via AuthBinding
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: ConstantColor.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWeb = constraints.maxWidth > 600;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Main Content Area
                      Expanded(
                        child: _buildMainContent(isWeb, controller, context),
                      ),
                      // Footer
                      _buildFooter(isWeb),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isWeb, LoginController controller, BuildContext context) {
    double w(double value) => isWeb ? value : value.w;
    double h(double value) => isWeb ? value : value.h;
    double sp(double value) => isWeb ? value : value.sp;
    double r(double value) => isWeb ? value : value.r;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w(24), vertical: h(48)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: w(80),
            height: w(80),
            decoration: const BoxDecoration(
              color: ConstantColor.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home,
              color: ConstantColor.textPrimaryColor,
              size: w(40),
            ),
          ),
          SizedBox(height: h(24)),
          // Title
          Text(
            "Rumah Sewa Biru Laut",
            style: TextStyle(
              fontSize: sp(28),
              fontWeight: FontWeight.bold,
              color: ConstantColor.textPrimaryColor,
              fontFamily: 'Serif',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: h(8)),
          // Subtitle
          Text(
            "Private Access for Tenants & Staff",
            style: TextStyle(
              fontSize: sp(14),
              color: ConstantColor.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: h(32)),

          // Card Container
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450), // Max width for web
            child: Container(
              padding: EdgeInsets.all(w(32)),
              decoration: BoxDecoration(
                color: ConstantColor.surfaceColor,
                borderRadius: BorderRadius.circular(r(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username Label & Field
                  Text(
                    "Username",
                    style: TextStyle(
                      fontSize: sp(14),
                      fontWeight: FontWeight.w600,
                      color: ConstantColor.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: h(8)),
                  TextField(
                    controller: controller.usernameController,
                    decoration: InputDecoration(
                      hintText: "Enter your username",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: sp(14)),
                      prefixIcon: Icon(Icons.person, color: Colors.grey.shade400, size: w(20)),
                      filled: true,
                      fillColor: ConstantColor.backgroundColor, 
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(r(12)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: h(16), horizontal: w(16)),
                    ),
                    style: TextStyle(fontSize: sp(14)),
                  ),
                  SizedBox(height: h(20)),
                  
                  // Password Label & Field
                  Text(
                    "Password",
                    style: TextStyle(
                      fontSize: sp(14),
                      fontWeight: FontWeight.w600,
                      color: ConstantColor.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: h(8)),
                  Obx(() => TextField(
                    controller: controller.passwordController,
                    obscureText: controller.obscureText.value,
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: sp(14)),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey.shade400, size: w(20)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureText.value ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey.shade400,
                          size: w(20),
                        ),
                        onPressed: () => controller.toggleObscureText(),
                      ),
                      filled: true,
                      fillColor: ConstantColor.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(r(12)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: h(16), horizontal: w(16)),
                    ),
                    style: TextStyle(fontSize: sp(14)),
                  )),
                  SizedBox(height: h(16)),
                  
                  // Remember Me & Forgot Password
                  Row(
                    children: [
                      SizedBox(
                        width: w(24),
                        height: w(24),
                        child: Obx(() => Checkbox(
                          value: controller.rememberMe.value,
                          activeColor: ConstantColor.buttonColor,
                          shape: const CircleBorder(),
                          side: BorderSide(color: Colors.grey.shade400),
                          onChanged: controller.toggleRememberMe,
                        )),
                      ),
                      SizedBox(width: w(8)),
                      Text(
                        "Remember Me",
                        style: TextStyle(
                          fontSize: sp(12),
                          color: ConstantColor.textSecondaryColor,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Lupa Password?",
                          style: TextStyle(
                            fontSize: sp(12),
                            fontWeight: FontWeight.w600,
                            color: ConstantColor.textPrimaryColor, 
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: h(24)),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: h(48),
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value 
                          ? null 
                          : () async {
                              await controller.login(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ConstantColor.buttonColor,
                        disabledBackgroundColor: ConstantColor.buttonColor.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r(12)),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: w(24),
                              height: w(24),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Masuk",
                                  style: TextStyle(
                                    fontSize: sp(14),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: w(8)),
                                Icon(Icons.login, color: Colors.white, size: w(18)),
                              ],
                            ),
                    )),
                  ),
                  SizedBox(height: h(32)),
                ],
              ),
            ),
          ),
          
          SizedBox(height: h(48)),
          // Bottom Image Placeholder
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              height: h(150),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.vertical(top: Radius.circular(r(24))),
                image: const DecorationImage(
                  image: NetworkImage("https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=600&q=80"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildRoleItem(String label, IconData icon, bool isWeb) {
    double w(double value) => isWeb ? value : value.w;
    double sp(double value) => isWeb ? value : value.sp;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: w(14), color: ConstantColor.textSecondaryColor),
        SizedBox(width: w(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: sp(10),
            fontWeight: FontWeight.bold,
            color: ConstantColor.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isWeb) {
    double w(double value) => isWeb ? value : value.w;
    double h(double value) => isWeb ? value : value.h;
    double sp(double value) => isWeb ? value : value.sp;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: w(48), vertical: h(24)),
      decoration: BoxDecoration(
        color: ConstantColor.backgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: isWeb 
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFooterLeft(sp),
              _buildFooterRight(sp),
            ],
          )
        : Column(
            children: [
              _buildFooterLeft(sp),
              SizedBox(height: h(16)),
              _buildFooterRight(sp),
            ],
          ),
    );
  }

  Widget _buildFooterLeft(double Function(double) sp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rumah Sewa Biru Laut",
          style: TextStyle(
            fontSize: sp(14),
            fontWeight: FontWeight.bold,
            color: ConstantColor.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "© 2024 Rumah Sewa Biru Laut. Rooted in Comfort.",
          style: TextStyle(
            fontSize: sp(12),
            color: ConstantColor.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterRight(double Function(double) sp) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _footerLink("Privacy Policy", sp),
        const SizedBox(width: 16),
        _footerLink("Terms of Service", sp),
        const SizedBox(width: 16),
        _footerLink("Contact Us", sp),
      ],
    );
  }

  Widget _footerLink(String text, double Function(double) sp) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: TextStyle(
          fontSize: sp(12),
          color: ConstantColor.textSecondaryColor,
        ),
      ),
    );
  }
}
