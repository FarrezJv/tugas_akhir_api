import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tugas_akhir_api/extension/navigator.dart';
import 'package:tugas_akhir_api/views/auth/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool hidePassword = true;

  String? selectedGender;
  String? selectedBatch;
  String? selectedTraining;

  File? selectedImage;

  final List<String> genderList = ['Laki-laki', 'Perempuan'];
  final List<String> batchList = ['Batch 1', 'Batch 2', 'Batch 3'];
  final List<String> trainingList = [
    'Data Management Staff',
    'Desain Grafis',
    'Web Developer',
  ];

  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final picked = await picker.pickImage(source: ImageSource.gallery);
  //   if (picked != null) {
  //     setState(() {
  //       selectedImage = File(picked.path);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Text(
                "Daftar",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F57E4),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Daftar sekarang untuk mendapatkan pengalaman terbaik.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Foto Profil
              GestureDetector(
                // onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : null,
                  child: selectedImage == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Ketuk untuk pilih foto profil",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Nama
              TextField(
                decoration: InputDecoration(
                  hintText: "Masukkan Nama",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                decoration: InputDecoration(
                  hintText: "Masukkan Email",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                obscureText: hidePassword,
                decoration: InputDecoration(
                  hintText: "Masukkan Password",
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Jenis Kelamin
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: genderList
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) {
                  setState(() => selectedGender = val);
                },
                decoration: InputDecoration(
                  hintText: 'Pilih Jenis Kelamin',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Batch
              DropdownButtonFormField<String>(
                value: selectedBatch,
                items: batchList
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (val) {
                  setState(() => selectedBatch = val);
                },
                decoration: InputDecoration(
                  hintText: 'Pilih Batch',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Training
              DropdownButtonFormField<String>(
                value: selectedTraining,
                items: trainingList
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  setState(() => selectedTraining = val);
                },
                decoration: InputDecoration(
                  hintText: 'Pilih Pelatihan',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Daftar
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F57E4),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Buat Akun",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),

              // Punya Akun?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun?"),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      context.push(LoginPage());
                    },
                    child: const Text(
                      "Masuk",
                      style: TextStyle(
                        color: Color(0xFF2F57E4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
