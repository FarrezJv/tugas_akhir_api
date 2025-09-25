import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir_api/model/history_absen.dart';

class DetailAbsensiScreen extends StatelessWidget {
  final History absen;

  const DetailAbsensiScreen({super.key, required this.absen});

  @override
  Widget build(BuildContext context) {
    final date = absen.attendanceDate != null
        ? DateFormat(
            "EEEE, dd MMMM yyyy",
            "id_ID",
          ).format(absen.attendanceDate!)
        : "-";

    final LatLng position = LatLng(
      absen.checkInLat ?? -6.200000, // default Jakarta
      absen.checkInLng ?? 106.816666,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    "Detail Absensi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 40), // biar center teks
                ],
              ),
            ),

            // ================= MAP =================
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: position,
                    zoom: 16,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("checkin"),
                      position: position,
                      infoWindow: const InfoWindow(title: "Lokasi Absen"),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  scrollGesturesEnabled: false,
                  trafficEnabled: true,
                ),
              ),
            ),

            // ================= DETAIL =================
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 28),

                      _buildInfoRow(
                        Icons.location_on,
                        "Lokasi",
                        absen.checkInAddress ?? "-",
                        color: const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        Icons.login,
                        "Jam Masuk",
                        absen.checkInTime ?? "--:--",
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        Icons.logout,
                        "Jam Keluar",
                        absen.checkOutTime ?? "--:--",
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        Icons.info_outline,
                        "Status",
                        absen.status ?? "-",
                        color: Colors.blueGrey,
                      ),

                      if (absen.alasanIzin != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.note,
                          "Alasan",
                          absen.alasanIzin!,
                          color: Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color ?? Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
