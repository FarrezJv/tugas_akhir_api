import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tugas_akhir_api/api/register_user.dart';
import 'package:tugas_akhir_api/extension/navigator.dart';
import 'package:tugas_akhir_api/model/list_batch_model.dart';
import 'package:tugas_akhir_api/model/list_training_model.dart';
import 'package:tugas_akhir_api/model/register_model.dart';
import 'package:tugas_akhir_api/preference/preference.dart';
import 'package:tugas_akhir_api/views/auth/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool hidePassword = true;
  bool isLoading = false;
  String? errorMessage;
  RegisterUserModel? user;

  String? selectedGender;
  batches? selectedBatch;
  Datum? selectedTraining; // dari ListTrainingModel

  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  /// Map untuk gender (display → value)
  Map<String, String> genderMap = {"Laki-laki": "L", "Perempuan": "P"};

  List<batches> batchList = [];
  List<Datum> trainingList = [];

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      final batchResponse = await AuthenticationAPI.getAllBatches();
      final trainingResponse = await AuthenticationAPI.getAllTrainings();
      setState(() {
        batchList = batchResponse.data ?? [];
        trainingList = trainingResponse.data ?? [];
      });
    } catch (e) {
      print("Error fetch dropdown: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal load data dropdown: $e")));
    }
  }

  Future<void> pickFoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      pickedFile = image;
    });
  }

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final pass = passController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }
    PreferenceHandler.saveToken(user?.data?.token.toString() ?? "");

    if (selectedGender == null ||
        selectedBatch == null ||
        selectedTraining == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gender, batch, dan training")),
      );
      return;
    }
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto profil belum dipilih")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      RegisterUserModel result = await AuthenticationAPI.registerUser(
        name: name,
        email: email,
        password: pass,
        jenisKelamin: selectedGender!, // ini tetap L atau P
        profilePhoto: File(pickedFile!.path),
        batchId: selectedBatch!.id!,
        trainingId: selectedTraining!.id!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? "Register berhasil")),
      );
      context.push(const LoginPage());
    } catch (e) {
      setState(() => errorMessage = e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal daftar: $errorMessage")));
    } finally {
      setState(() => isLoading = false);
    }
  }

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
              const SizedBox(height: 24),

              /// Foto Profil
              pickedFile != null
                  ? CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(File(pickedFile!.path)),
                    )
                  : CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: pickFoto,
                icon: const Icon(Icons.camera_alt, color: Color(0xFF2F57E4)),
                label: const Text(
                  "Pilih Foto Profil",
                  style: TextStyle(color: Color(0xFF2F57E4)),
                ),
              ),
              const SizedBox(height: 32),

              /// Nama
              TextField(
                controller: nameController,
                decoration: _inputDecoration("Masukkan Nama"),
              ),
              const SizedBox(height: 16),

              /// Email
              TextField(
                controller: emailController,
                decoration: _inputDecoration("Masukkan Email"),
              ),
              const SizedBox(height: 16),

              /// Password
              TextField(
                controller: passController,
                obscureText: hidePassword,
                decoration: _inputDecoration("Masukkan Password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => hidePassword = !hidePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// Gender
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: genderMap.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.value, // L atau P
                        child: Text(
                          entry.key,
                        ), // tampil "Laki-laki / Perempuan"
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedGender = val),
                decoration: _inputDecoration("Pilih Jenis Kelamin"),
              ),
              const SizedBox(height: 16),

              /// Batch (from API)
              DropdownButtonFormField<batches>(
                value: selectedBatch,
                items: batchList
                    .map(
                      (b) => DropdownMenuItem(
                        value: b,
                        child: Text(b.batchKe ?? "Batch ${b.id}"),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedBatch = val),
                decoration: _inputDecoration("Pilih Batch"),
              ),
              const SizedBox(height: 16),

              /// Training (from API)
              DropdownButtonFormField<Datum>(
                value: selectedTraining,
                items: trainingList
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: SizedBox(
                          width: 220, // atur sesuai kebutuhan
                          child: Text(
                            t.title ?? "Pelatihan ${t.id}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedTraining = val),
                decoration: _inputDecoration("Pilih Pelatihan"),
              ),

              const SizedBox(height: 32),

              /// Tombol Daftar
              ElevatedButton(
                onPressed: isLoading ? null : registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F57E4),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      )
                    : const Text(
                        "Buat Akun",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun?"),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => context.push(const LoginPage()),
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
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
