import 'package:flutter/material.dart';
import 'package:tugas_akhir_api/api/register_user.dart';
import 'package:tugas_akhir_api/extension/navigator.dart';
import 'package:tugas_akhir_api/model/get_user_model.dart';
import 'package:tugas_akhir_api/preference/preference.dart';
import 'package:tugas_akhir_api/views/auth/login.dart';

class ProfilDetail extends StatefulWidget {
  const ProfilDetail({super.key});
  static const id = "/ProfilDetail";

  @override
  State<ProfilDetail> createState() => _ProfilDetailState();
}

class _ProfilDetailState extends State<ProfilDetail> {
  GetUserModel? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await AuthenticationAPI.getProfile();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(String title, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : "-",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    PreferenceHandler.removeUserId();
    PreferenceHandler.removeToken();
    PreferenceHandler.removeLogin();
    context.pushReplacement(LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    final user = userData?.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text("Error: $errorMessage"))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // ================= HEADER =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Tombol Back
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                (user?.profilePhotoUrl != null &&
                                    user!.profilePhotoUrl!.isNotEmpty)
                                ? NetworkImage(user.profilePhotoUrl!)
                                : null,
                            child:
                                (user?.profilePhotoUrl == null ||
                                    user!.profilePhotoUrl!.isEmpty)
                                ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.blue,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? "-",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user?.email ?? "-",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Logout tombol kecil (opsional)
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= CARD DETAIL =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Detail Profil",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 30),

                            _buildInfoRow(
                              "Nama Lengkap",
                              user?.name ?? "",
                              icon: Icons.person,
                            ),
                            _buildInfoRow(
                              "Email",
                              user?.email ?? "",
                              icon: Icons.email,
                            ),
                            _buildInfoRow(
                              "Jenis Kelamin",
                              user?.jenisKelamin ?? "",
                              icon: Icons.wc,
                            ),
                            _buildInfoRow(
                              "Batch Ke",
                              user?.batchKe ?? "",
                              icon: Icons.group,
                            ),
                            _buildInfoRow(
                              "Pelatihan",
                              user?.trainingTitle ?? "",
                              icon: Icons.school,
                            ),
                            _buildInfoRow(
                              "Periode",
                              (user?.batch?.startDate != null &&
                                      user?.batch?.endDate != null)
                                  ? "${user!.batch!.startDate!.toLocal().toString().split(' ')[0]} - ${user.batch!.endDate!.toLocal().toString().split(' ')[0]}"
                                  : "-",
                              icon: Icons.date_range,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tombol Logout di bawah card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shadowColor: Colors.red.withOpacity(
                              0.3,
                            ), // efek terang
                            elevation: 6,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ), // outline tipis
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}
