import 'package:flutter/material.dart';
import 'package:tugas_akhir_api/api/checkin.dart';
import 'package:tugas_akhir_api/model/absen_stats.dart';

class AbsenStatsPage extends StatefulWidget {
  const AbsenStatsPage({super.key});
  static const id = "/AbsenStats";

  @override
  State<AbsenStatsPage> createState() => _AbsenStatsPageState();
}

class _AbsenStatsPageState extends State<AbsenStatsPage> {
  AbsenStatsModel? statsData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await AbsenAPI.getAbsenStats();
      setState(() {
        statsData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(
    String title,
    String value, {
    IconData? icon,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: color ?? Colors.blue, size: 22),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = statsData?.data;

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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Container(
                          //   padding: const EdgeInsets.all(6),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(12),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.black.withOpacity(0.1),
                          //         blurRadius: 4,
                          //         offset: const Offset(0, 2),
                          //       ),
                          //     ],
                          //   ),
                          //   child: Image.asset(
                          //     AppImage.logoPng,
                          //     height: 32,
                          //     width: 32,
                          //   ),
                          // ),
                          const SizedBox(width: 12),
                          const Text(
                            textAlign: TextAlign.center,
                            "Statistik Absensi",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= CARD STATS =================
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
                              "Ringkasan Absensi",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 30),

                            _buildInfoRow(
                              "Total Hadir",
                              "${stats?.totalMasuk ?? 0}",
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                            _buildInfoRow(
                              "Total Izin",
                              "${stats?.totalIzin ?? 0}",
                              icon: Icons.mail_outline,
                              color: Colors.blue,
                            ),
                            _buildInfoRow(
                              "Total Absen",
                              "${stats?.totalAbsen ?? 0}",
                              icon: Icons.fact_check_outlined,
                              color: Colors.purple,
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              "Sudah Absen Hari Ini",
                              (stats?.sudahAbsenHariIni == true
                                  ? "Ya"
                                  : "Belum"),
                              icon: Icons.today,
                              color: Colors.orange,
                            ),
                          ],
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
