import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // WAJIB biar bisa pakai locale
import 'package:intl/intl.dart';
import 'package:tugas_akhir_api/api/checkin.dart';
import 'package:tugas_akhir_api/model/absen_stats.dart';
import 'package:tugas_akhir_api/model/history_absen.dart';

class AbsenStatsPage extends StatefulWidget {
  const AbsenStatsPage({super.key});
  static const id = "/AbsenStats";

  @override
  State<AbsenStatsPage> createState() => _AbsenStatsPageState();
}

class _AbsenStatsPageState extends State<AbsenStatsPage> {
  AbsenStatsModel? statsData;
  HistoryAbsenModel? historyData;

  bool isLoading = true;
  String? errorMessage;

  DateTimeRange? selectedRange;
  bool showAllHistory = false;

  @override
  void initState() {
    super.initState();
    _initLocale(); // inisialisasi locale dulu
    _loadData();
  }

  Future<void> _initLocale() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      Intl.defaultLocale = 'id_ID';
    });
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final stats = await AbsenAPI.getAbsenStats();
      final history = await AbsenAPI.getHistoryAbsen();
      setState(() {
        statsData = stats;
        historyData = history;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<History> get filteredHistory {
    if (historyData?.data == null) return [];
    if (selectedRange == null) return historyData!.data!;
    return historyData!.data!.where((h) {
      if (h.attendanceDate == null) return false;
      return h.attendanceDate!.isAfter(
            selectedRange!.start.subtract(const Duration(days: 1)),
          ) &&
          h.attendanceDate!.isBefore(
            selectedRange!.end.add(const Duration(days: 1)),
          );
    }).toList();
  }

  Future<void> pickDateRange() async {
    final now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange:
          selectedRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      locale: const Locale(
        'id',
        'ID',
      ), // supaya date picker pakai bhs Indonesia
    );

    if (picked != null) {
      setState(() {
        selectedRange = picked;
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
    final historyToShow = showAllHistory
        ? filteredHistory
        : filteredHistory.take(2).toList();

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
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Rekap Absensi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.date_range,
                                  color: Colors.white,
                                ),
                                onPressed: pickDateRange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            selectedRange == null
                                ? "Filter: Semua Tanggal"
                                : "Filter: ${DateFormat('dd MMM yyyy', 'id_ID').format(selectedRange!.start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(selectedRange!.end)}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= CARD STATS =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            const Divider(height: 28),
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
                            const Divider(height: 28),
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

                    const SizedBox(height: 24),

                    // ================= HISTORY LIST =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Riwayat Absensi Berdasarkan Tanggal",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (filteredHistory.isEmpty)
                            const Text("Tidak ada data untuk rentang ini."),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: historyToShow.length,
                            itemBuilder: (context, index) {
                              final h = historyToShow[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF3B82F6),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'EEEE, dd MMM yyyy',
                                        'id_ID',
                                      ).format(h.attendanceDate!),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.login,
                                          size: 18,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 6),
                                        Text("Masuk: ${h.checkInTime ?? '-'}"),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.logout,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Keluar: ${h.checkOutTime ?? '-'}",
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          size: 18,
                                          color: Colors.blueGrey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text("Status: ${h.status ?? '-'}"),
                                      ],
                                    ),
                                    if (h.alasanIzin != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.note,
                                            size: 18,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              "Alasan: ${h.alasanIzin}",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),

                          if (filteredHistory.length > 2)
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    showAllHistory = !showAllHistory;
                                  });
                                },
                                child: Text(
                                  showAllHistory
                                      ? "Sembunyikan"
                                      : "Lihat Semua",
                                  style: const TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
