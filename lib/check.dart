import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir_api/utils/splash_screen.dart';

void main() {
  runApp(const AbsensiApp());
}

class AbsensiApp extends StatefulWidget {
  const AbsensiApp({super.key});

  @override
  State<AbsensiApp> createState() => _AbsensiAppState();
}

class _AbsensiAppState extends State<AbsensiApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const AbsensiPage(),
    );
  }
}

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  String currentTime = DateFormat('HH:mm').format(DateTime.now());
  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        currentTime = DateFormat('HH:mm').format(DateTime.now());
      });
      _updateTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background gambar (dummy map / logo)
          SizedBox.expand(child: Image.asset(AppImage.logo, fit: BoxFit.cover)),

          /// Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.center,
              ),
            ),
          ),

          /// Jam di atas
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  currentTime,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Icon(Icons.access_time, color: Colors.white70, size: 18),
              ],
            ),
          ),

          /// Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.2,
            maxChildSize: 0.55,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Judul
                    const Text(
                      "Absensi Masuk",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    /// Lokasi Card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Lokasi Anda",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Jl. Gatot Subroto No.1, RT.1/RW.3,\nSenayan, Tanah Abang, Jakarta Pusat",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Catatan
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "Catatan (opsional)",
                        prefixIcon: const Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Tombol Absen
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Absen masuk berhasil pada $currentTime",
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue,
                        elevation: 5,
                      ),
                      child: const Text(
                        "Absen Masuk",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
