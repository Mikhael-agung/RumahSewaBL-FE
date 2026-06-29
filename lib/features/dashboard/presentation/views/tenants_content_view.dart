import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/bindings/tenants_binding.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/tenants_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/entities/tenant.dart';

class TenantsContentView extends StatefulWidget {
  const TenantsContentView({super.key});

  @override
  State<TenantsContentView> createState() => _TenantsContentViewState();
}

class _TenantsContentViewState extends State<TenantsContentView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _tenantCodeController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late TenantsController _controller;

  @override
  void initState() {
    super.initState();
    TenantsBinding().dependencies();
    _controller = Get.find<TenantsController>();
    _searchController.addListener(() {
      _controller.filterTenants(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tenantCodeController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _tenantCodeController.clear();
    _fullNameController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
  }

  void _showAddTenantDialog() {
    _clearForm();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;
        return Dialog(
          backgroundColor: ConstantColor.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Tambah Penyewa",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: ConstantColor.textPrimaryColor,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Kode Penyewa (e.g. TNT-001)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ConstantColor.textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _tenantCodeController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: "TNT-...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: ConstantColor.backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Nama Lengkap",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ConstantColor.textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _fullNameController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: "Masukkan nama lengkap...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: ConstantColor.backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "No. Telepon",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ConstantColor.textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneNumberController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: "0812...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: ConstantColor.backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ConstantColor.textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: "email@example.com",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: ConstantColor.backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                foregroundColor: ConstantColor.textDarkColor,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text(
                                "Batal",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final code = _tenantCodeController.text
                                          .trim();
                                      final name = _fullNameController.text
                                          .trim();
                                      final phone = _phoneNumberController.text
                                          .trim();
                                      final email = _emailController.text
                                          .trim();

                                      if (code.isNotEmpty &&
                                          name.isNotEmpty &&
                                          phone.isNotEmpty &&
                                          email.isNotEmpty) {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        final result = await _controller
                                            .addTenant(
                                              tenantCode: code,
                                              fullName: name,
                                              phoneNumber: phone,
                                              email: email,
                                            );

                                        if (!mounted) return;

                                        Navigator.of(context).pop();
                                        if (result.account != null) {
                                          await _showTenantCredentialDialog(
                                            result.account!,
                                          );
                                        }

                                        if (!mounted) return;

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Penyewa berhasil ditambahkan!",
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              "Semua field harus diisi",
                                            ),
                                            backgroundColor:
                                                Colors.red.shade800,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ConstantColor.buttonColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Simpan",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showTenantCredentialDialog(Account account) async {
    bool copiedUsername = false;
    bool copiedPassword = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final canClose = copiedUsername && copiedPassword;

            Future<void> copyValue(String value, bool isUsername) async {
              await Clipboard.setData(ClipboardData(text: value));
              if (!context.mounted) return;
              setState(() {
                if (isUsername) {
                  copiedUsername = true;
                } else {
                  copiedPassword = true;
                }
              });

              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text(
                    isUsername
                        ? "Username berhasil di-copy"
                        : "Password berhasil di-copy",
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }

            return WillPopScope(
              onWillPop: () async => canClose,
              child: Dialog(
                backgroundColor: ConstantColor.surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kredensial Akun Penyewa",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: ConstantColor.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          account.note,
                          style: const TextStyle(
                            color: ConstantColor.textSecondaryColor,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _CredentialCopyTile(
                          label: "Username",
                          value: account.username,
                          copied: copiedUsername,
                          onCopy: () => copyValue(account.username, true),
                        ),
                        const SizedBox(height: 12),
                        _CredentialCopyTile(
                          label: "Password",
                          value: account.password,
                          copied: copiedPassword,
                          onCopy: () => copyValue(account.password, false),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: canClose
                                ? () => Navigator.of(dialogContext).pop()
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ConstantColor.buttonColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              disabledForegroundColor: Colors.grey.shade600,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              "Saya Sudah Menyimpan Kredensial",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTenantDialog(Tenant tenant) {
    _tenantCodeController.text = tenant.tenantCode;
    _fullNameController.text = tenant.fullName;
    _phoneNumberController.text = tenant.phoneNumber;
    _emailController.text = tenant.email;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;
        return Dialog(
          backgroundColor: ConstantColor.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Edit Penyewa",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: ConstantColor.textPrimaryColor,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Kode Penyewa (e.g. TNT-001)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ConstantColor.textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _tenantCodeController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: "TNT-...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: ConstantColor.backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Nama Lengkap",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ConstantColor.textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _fullNameController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: "Masukkan nama lengkap...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: ConstantColor.backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "No. Telepon",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ConstantColor.textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneNumberController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: "0812...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: ConstantColor.backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ConstantColor.textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: "email@example.com",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: ConstantColor.backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                foregroundColor: ConstantColor.textDarkColor,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text(
                                "Batal",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final code = _tenantCodeController.text
                                          .trim();
                                      final name = _fullNameController.text
                                          .trim();
                                      final phone = _phoneNumberController.text
                                          .trim();
                                      final email = _emailController.text
                                          .trim();

                                      if (code.isNotEmpty &&
                                          name.isNotEmpty &&
                                          phone.isNotEmpty &&
                                          email.isNotEmpty) {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        final success = await _controller
                                            .updateTenant(
                                              id: tenant.id,
                                              tenantCode: code,
                                              fullName: name,
                                              phoneNumber: phone,
                                              email: email,
                                            );

                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                success
                                                    ? "Penyewa berhasil diperbarui!"
                                                    : "Penyewa gagal diperbarui!",
                                              ),
                                              backgroundColor: success
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              "Semua field harus diisi",
                                            ),
                                            backgroundColor:
                                                Colors.red.shade800,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ConstantColor.buttonColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Simpan",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteTenantConfirmation(Tenant tenant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: ConstantColor.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Konfirmasi Hapus",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              content: !isLoading
                  ? const SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ConstantColor.primaryColor,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      "Apakah Anda yakin ingin menghapus penyewa \"${tenant.fullName}\"? Tindakan ini tidak dapat dibatalkan.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ConstantColor.textSecondaryColor,
                      ),
                    ),
              actions: !isLoading
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          final success = await _controller.deleteTenant(
                            tenant.id,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? "Penyewa berhasil dihapus!"
                                      : "Penyewa gagal dihapus!",
                                ),
                                backgroundColor: success
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Hapus",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tenants",
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: ConstantColor.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Kelola data penyewa",
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: ConstantColor.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isMobile ? 24 : 32),

        Container(
          padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search & Add Button Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool shrinkRow = constraints.maxWidth < 600;

                  Widget searchField = Container(
                    width: shrinkRow ? double.infinity : 320,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Cari nama penyewa...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade400,
                          size: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 11,
                        ),
                      ),
                    ),
                  );

                  Widget addButton = ElevatedButton.icon(
                    onPressed: _showAddTenantDialog,
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text(
                      "Tambah Penyewa",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ConstantColor.buttonColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                  );

                  if (shrinkRow) {
                    return Column(
                      children: [
                        searchField,
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: addButton),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [searchField, addButton],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Responsive Table Wrapper with GetX Observer
              Obx(() {
                if (_controller.isLoading.value) {
                  return _buildShimmerTable();
                }

                if (_controller.filteredTenants.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada data penyewa",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tambahkan penyewa untuk memulai",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return isMobile
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 800),
                          child: _buildTenantsTable(
                            context,
                            _controller.filteredTenants,
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: _buildTenantsTable(
                          context,
                          _controller.filteredTenants,
                        ),
                      );
              }),
              const SizedBox(height: 24),

              // Pagination Footer
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool wrapPagination = constraints.maxWidth < 600;

                  Widget showingText = Obx(() {
                    final total = _controller.tenants.length;
                    final filtered = _controller.filteredTenants.length;
                    return Text(
                      "Menampilkan $filtered dari $total penyewa",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    );
                  });

                  Widget paginationControls = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPaginationButton("<", isSelected: false),
                      const SizedBox(width: 8),
                      _buildPaginationButton("1", isSelected: true),
                      const SizedBox(width: 8),
                      _buildPaginationButton(">", isSelected: false),
                    ],
                  );

                  if (wrapPagination) {
                    return Column(
                      children: [
                        showingText,
                        const SizedBox(height: 16),
                        paginationControls,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [showingText, paginationControls],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerTable() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF1F5F9),
      highlightColor: const Color(0xFFE2E8F0),
      period: const Duration(milliseconds: 1000),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.5),
          1: FlexColumnWidth(2.0),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(3.0),
          4: FlexColumnWidth(1.5),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            children: [
              _buildHeaderCell("NAMA"),
              _buildHeaderCell("KODE"),
              _buildHeaderCell("NO. TELEPON"),
              _buildHeaderCell("EMAIL"),
              _buildHeaderCell("AKSI"),
            ],
          ),
          ...List.generate(3, (_) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTenantsTable(BuildContext context, List<Tenant> tenantList) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.5), // Nama
        1: FlexColumnWidth(2.0), // Kode
        2: FlexColumnWidth(2.5), // No Telepon
        3: FlexColumnWidth(3.0), // Email
        4: FlexColumnWidth(1.5), // Aksi
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Table Header
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(
              bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
            ),
          ),
          children: [
            _buildHeaderCell("NAMA"),
            _buildHeaderCell("KODE"),
            _buildHeaderCell("NO. TELEPON"),
            _buildHeaderCell("EMAIL"),
            _buildHeaderCell("AKSI"),
          ],
        ),

        // Rows
        ...tenantList.map((tenant) {
          return TableRow(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 12.0,
                ),
                child: Text(
                  tenant.fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 12.0,
                ),
                child: Text(
                  tenant.tenantCode,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 12.0,
                ),
                child: Text(
                  tenant.phoneNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 12.0,
                ),
                child: Text(
                  tenant.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 12.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: ConstantColor.secondaryColor,
                      ),
                      onPressed: () => _showEditTenantDialog(tenant),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () => _showDeleteTenantConfirmation(tenant),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildPaginationButton(String text, {required bool isSelected}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? ConstantColor.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _CredentialCopyTile extends StatelessWidget {
  final String label;
  final String value;
  final bool copied;
  final VoidCallback onCopy;

  const _CredentialCopyTile({
    required this.label,
    required this.value,
    required this.copied,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ConstantColor.backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ConstantColor.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ConstantColor.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: onCopy,
            style: ElevatedButton.styleFrom(
              backgroundColor: copied
                  ? Colors.green
                  : ConstantColor.buttonColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(
              copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 18,
            ),
            label: Text(copied ? "Tersalin" : "Copy"),
          ),
        ],
      ),
    );
  }
}
