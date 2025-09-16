import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_akhir_api/extension/navigator.dart';
import 'package:tugas_akhir_api/preference/preference.dart';
import 'package:tugas_akhir_api/utils/splash_screen.dart';
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
      body: Column(
        children: [
          Expanded(
            child: Container(
              // width: double.infinity,
              height: double.infinity,
              color: Colors.white, // warna background splash
              alignment: Alignment.center,
              child: Lottie.asset(
                AppImage.splashlogo,
                fit: BoxFit.contain, // biar skalanya pas & gak kepotong
              ),
            ),
          ),
        ],
      ),
    );
  }
}
