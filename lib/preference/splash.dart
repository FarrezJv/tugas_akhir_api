import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:tugas_akhir_api/extension/navigator.dart';
import 'package:tugas_akhir_api/preference/preference.dart';
import 'package:tugas_akhir_api/views/auth/login.dart';
import 'package:tugas_akhir_api/views/home/botnav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const id = "/splash_screen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLogin();
    });
  }

  void checkLogin() async {
    final isLogin = await PreferenceHandler.getLogin();

    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (!mounted) return;

      if (isLogin == true) {
        context.pushReplacementNamed(BotnavPage.id);
      } else {
        context.pushNamed(LoginPage.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient dibuat netral di area tengah biar logo keliatan jelas
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3B82F6), // biru utama (atas)
              Color(
                0xFFF9FBFF,
              ), // putih kebiruan (tengah - buat logo stand out)
              Color(0xFF1E40AF), // biru tua (bawah)
            ],
            stops: [0.0, 0.55, 1.0], // posisi transisi warna
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo dengan animasi
            Expanded(
              child: Center(
                child: ZoomIn(
                  duration: const Duration(milliseconds: 1200),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 1200),
                    child: Image.asset(
                      "assets/images/full_logo-removebg-preview.png",
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // Credit (tagline dihapus)
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: FadeInUp(
                duration: const Duration(milliseconds: 1500),
                child: Column(
                  children: const [
                    Text(
                      "Developed by Farrez Juan Verterry",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "© 2025 | All Rights Reserved",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
