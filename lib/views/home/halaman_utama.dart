import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir_api/api/checkin.dart';
import 'package:tugas_akhir_api/api/register_user.dart';
import 'package:tugas_akhir_api/check.dart';
import 'package:tugas_akhir_api/extension/navigator.dart';
import 'package:tugas_akhir_api/model/absen_today_model.dart';
import 'package:tugas_akhir_api/model/checkout.dart';
import 'package:tugas_akhir_api/model/get_user_model.dart';
import 'package:tugas_akhir_api/views/home/profil_detail.dart';

class HalamanPage extends StatefulWidget {
  static const id = "/Halaman";

  const HalamanPage({super.key});

  @override
  State<HalamanPage> createState() => _HalamanPageState();
}

class _HalamanPageState extends State<HalamanPage> {
  GetUserModel? userData;
  AbsenTodayModel? absenToday;

  bool isLoading = true;
  String? errorMessage;

  // === real-time clock ===
  late String _currentTime;
  late String _currentDate;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadAbsenToday();

    // set awal
    _updateTime();

    // update setiap 1 detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat("HH:mm:ss").format(now);
      _currentDate = DateFormat("EEE, dd MMM yyyy", "id_ID").format(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
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

  Future<void> _loadAbsenToday() async {
    try {
      final data = await AbsenAPI.getAbsenToday();
      setState(() {
        absenToday = data;
      });
    } catch (e) {
      print("Error load absen today: $e");
    }
  }

  Future<void> _absenCheckOut() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = "Alamat tidak ditemukan";
      String locationName = "Lokasi Tidak Diketahui";
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        locationName = place.locality ?? "Lokasi Tidak Diketahui";
      }

      CheckOutModel? result = await AbsenAPI.checkOut(
        checkOutLat: position.latitude,
        checkOutLng: position.longitude,
        checkOutLocation: locationName,
        checkOutAddress: address,
      );

      if (!mounted) return;

      if (result != null) {
        await _loadAbsenToday();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Check-out berhasil: ${result.message}")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Check-out gagal")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
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
                    // ======================= HEADER ==========================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
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
                          CircleAvatar(
                            radius: 28,
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
                                    size: 32,
                                    color: Colors.blue,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                context.push(ProfilDetail());
                              },
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
                                    "${user?.batchKe ?? "-"} • ${user?.trainingTitle ?? "-"}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ======================= LIVE ATTENDANCE ==========================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
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
                          children: [
                            const Text(
                              "Absensi Langsung",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentTime, // jam real-time
                              style: const TextStyle(
                                fontSize: 36,
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentDate, // tanggal real-time
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            const Text(
                              "Jam Pelatihan",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "08:00 - 15:00",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.push(AbsensiApp());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3B82F6),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Masuk",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _absenCheckOut,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3B82F6),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Pulang",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ======================= ATTENDANCE HISTORY ==========================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: Colors.black87,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Riwayat Absensi Hari Ini",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (absenToday?.data != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      "EEE, dd MMM yyyy",
                                      "id_ID",
                                    ).format(absenToday!.data!.attendanceDate!),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${absenToday!.data!.checkInTime ?? '-'} - ${absenToday!.data!.checkOutTime ?? '-'}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color:
                                              absenToday!.data!.status ==
                                                  "Terlambat"
                                              ? Colors.red
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          else
                            const Text(
                              "Belum ada absensi hari ini",
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }
}
