import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ tambahin ini
import 'package:tugas_akhir_api/preference/splash.dart';
import 'package:tugas_akhir_api/views/auth/login.dart';
import 'package:tugas_akhir_api/views/home/botnav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // ✅ inisialisasi locale
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: RegisterPage(),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        LoginPage.id: (context) => LoginPage(),
        BotnavPage.id: (context) => BotnavPage(),
      },
    );
  }
}
