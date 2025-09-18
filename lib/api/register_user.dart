import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tugas_akhir_api/api/endpoint/endpoint.dart';
import 'package:tugas_akhir_api/model/get_user_model.dart';
import 'package:tugas_akhir_api/model/list_batch_model.dart';
import 'package:tugas_akhir_api/model/list_training_model.dart';
import 'package:tugas_akhir_api/model/register_model.dart';
import 'package:tugas_akhir_api/preference/preference.dart';

class AuthenticationAPI {
  static Future<RegisterUserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required File profilePhoto,
    required int batchId,
    required int trainingId,
  }) async {
    final url = Uri.parse(Endpoint.register);

    // baca file -> bytes -> base64
    final readImage = profilePhoto.readAsBytesSync();
    final b64 = base64Encode(readImage);

    // tambahkan prefix agar dikenali backend
    final imageWithPrefix = "data:image/png;base64,$b64";

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": imageWithPrefix,
        "batch_id": batchId,
        "training_id": trainingId,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return RegisterUserModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Failed to Register");
    }
  }

  static Future<RegisterUserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);
    final response = await http.post(
      url,
      body: {"email": email, "password": password},
      headers: {"Accept": "application/json"},
    );
    if (response.statusCode == 200) {
      final data = RegisterUserModel.fromJson(json.decode(response.body));
      await PreferenceHandler.saveToken(data.data?.token?.toString() ?? "");
      await PreferenceHandler.saveLogin();
      await PreferenceHandler.saveUserId(data.data?.user?.id ?? 0);
      print("UserId saved: ${data.data?.user?.id}");
      return data;
      // return RegisterUserModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Register gagal");
    }
  }

  static Future<ListBatchModel> getAllBatches() async {
    final url = Uri.parse(Endpoint.batches);
    final response = await http.get(
      url,
      headers: {"Accept": "application/json"},
    );

    print("STATUS BATCH: ${response.statusCode}");
    print("BODY BATCH: ${response.body}");

    if (response.statusCode == 200) {
      return ListBatchModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Gagal mengambil data batch");
    }
  }

  static Future<ListTrainingModel> getAllTrainings() async {
    final url = Uri.parse(Endpoint.trainings);
    final response = await http.get(
      url,
      headers: {"Accept": "application/json"},
    );

    print("STATUS TRAINING: ${response.statusCode}");
    print("BODY TRAINING: ${response.body}");

    if (response.statusCode == 200) {
      return ListTrainingModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Gagal mengambil data training");
    }
  }

  static Future<GetUserModel> updateUser({required String name}) async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandler.getToken();
    final response = await http.put(
      url,
      body: {"name": name},
      headers: {
        "Accept": "application/json",
        // "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      return GetUserModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Register gagal");
    }
  }

  static Future<GetUserModel> updateProfile({required String name}) async {
    final url = Uri.parse(Endpoint.updateProfile);
    final token = await PreferenceHandler.getToken();
    final response = await http.put(
      url,
      body: {"name": name},
      headers: {
        "Accept": "application/json",
        // "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      return GetUserModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Register gagal");
    }
  }

  static Future<GetUserModel> getProfile() async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandler.getToken();
    print(token);
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        // "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      return GetUserModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Register gagal");
    }
  }
}
