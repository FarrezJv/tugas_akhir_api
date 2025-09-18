import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tugas_akhir_api/api/endpoint/endpoint.dart';
import 'package:tugas_akhir_api/model/absen_today_model.dart';
import 'package:tugas_akhir_api/model/checkout.dart';
import 'package:tugas_akhir_api/model/chekin.dart';
import 'package:tugas_akhir_api/preference/preference.dart';

class AbsenAPI {
  static Future<CheckInModel?> checkInUser({
    required double checkInLat,
    required double checkInLng,
    required String checkInLocation,
    required String checkInAddress,
  }) async {
    try {
      final token = await PreferenceHandler.getToken();

      final now = DateTime.now();
      final attendanceDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final checkInTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse(Endpoint.checkin),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "attendance_date": attendanceDate,
          "check_in": checkInTime,
          "check_in_lat": checkInLat.toString(),
          "check_in_lng": checkInLng.toString(),
          "check_in_location": checkInLocation,
          "check_in_address": checkInAddress,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return CheckInModel.fromJson(jsonResponse);
      } else {
        print("CheckIn Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error CheckIn: $e");
      return null;
    }
  }

  static Future<CheckOutModel?> checkOut({
    required double checkOutLat,
    required double checkOutLng,
    required String checkOutLocation,
    required String checkOutAddress,
  }) async {
    try {
      final token = await PreferenceHandler.getToken();

      final now = DateTime.now();
      final attendanceDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final checkOutTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse(Endpoint.checkout),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "attendance_date": attendanceDate,
          "check_out": checkOutTime,
          "check_out_lat": checkOutLat.toString(),
          "check_out_lng": checkOutLng.toString(),
          "check_out_location": checkOutLocation,
          "check_out_address": checkOutAddress,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return CheckOutModel.fromJson(jsonResponse);
      } else {
        print("CheckOut Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error CheckOut: $e");
      return null;
    }
  }

  //  Absen Today
  static Future<AbsenTodayModel?> getAbsenToday() async {
    try {
      final token = await PreferenceHandler.getToken();
      final now = DateTime.now();
      final attendanceDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final response = await http.get(
        Uri.parse("${Endpoint.absentoday}?attendance_date=$attendanceDate"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return AbsenTodayModel.fromJson(jsonDecode(response.body));
      } else {
        print("Get Absen Today Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error Get Absen Today: $e");
      return null;
    }
  }
}
