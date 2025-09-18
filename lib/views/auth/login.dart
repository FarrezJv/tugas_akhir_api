import 'package:flutter/material.dart';
import 'package:tugas_akhir_api/api/register_user.dart';
import 'package:tugas_akhir_api/extension/navigator.dart';
import 'package:tugas_akhir_api/model/register_model.dart';
import 'package:tugas_akhir_api/preference/preference.dart';
import 'package:tugas_akhir_api/views/auth/register.dart';
import 'package:tugas_akhir_api/views/home/botnav.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const id = "/Login";
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool isVisibility = false;
  bool _obscurePassword = true;
  bool isLoading = false;

  RegisterUserModel? user;
  String? errorMessage;

  void loginUser() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    // final name = nameController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email, Password, dan Nama tidak boleh kosong"),
        ),
      );
      isLoading = false;

      return;
    }
    try {
      final result = await AuthenticationAPI.loginUser(
        email: email,
        password: password,
        // name: name,
      );
      setState(() {
        user = result;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login berhasil")));
      PreferenceHandler.saveToken(user?.data?.token.toString() ?? "");
      final savedUserId = await PreferenceHandler.getUserId();
      print("Saved User Id: $savedUserId");
      // Navigator.pushReplacementNamed(Dashboard1.id);
      context.pushReplacement(BotnavPage());

      print(user?.toJson());
    } catch (e) {
      print(e);
      setState(() {
        errorMessage = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage.toString())));
    } finally {
      setState(() {});
      isLoading = false;
    }
  }
  // bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===================== LOGO BESAR =====================
              Center(
                child: Image.asset('assets/images/full_logo.png', height: 150),
              ),
              const SizedBox(height: 40),

              // ===================== JUDUL & SUB =====================
              const Text(
                "Masuk",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Login untuk mengakses akun dan fitur lengkap.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // ===================== EMAIL =====================
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Masukkan Email',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // ===================== PASSWORD =====================
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Masukkan Password',
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Lupa Password?",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ===================== TOMBOL LOGIN =====================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    loginUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2F57E4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Log In",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // ===================== DAFTAR =====================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum Punya Akun? "),
                  GestureDetector(
                    onTap: () {
                      context.push(RegisterPage());
                    },
                    child: const Text(
                      "Daftar",
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
