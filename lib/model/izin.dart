// To parse this JSON data, do
//
//     final absenIzinModel = absenIzinModelFromJson(jsonString);

import 'dart:convert';

AbsenIzinModel absenIzinModelFromJson(String str) =>
    AbsenIzinModel.fromJson(json.decode(str));

String absenIzinModelToJson(AbsenIzinModel data) => json.encode(data.toJson());

class AbsenIzinModel {
  String? message;
  Excuse? data;

  AbsenIzinModel({this.message, this.data});

  factory AbsenIzinModel.fromJson(Map<String, dynamic> json) => AbsenIzinModel(
    message: json["message"],
    data: json["data"] == null ? null : Excuse.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Excuse {
  int? id;
  DateTime? attendanceDate;
  dynamic checkInTime;
  dynamic checkInLat;
  dynamic checkInLng;
  dynamic checkInLocation;
  dynamic checkInAddress;
  String? status;
  String? alasanIzin;

  Excuse({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkInLat,
    this.checkInLng,
    this.checkInLocation,
    this.checkInAddress,
    this.status,
    this.alasanIzin,
  });

  factory Excuse.fromJson(Map<String, dynamic> json) => Excuse(
    id: json["id"],
    attendanceDate: json["attendance_date"] == null
        ? null
        : DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkInLat: json["check_in_lat"],
    checkInLng: json["check_in_lng"],
    checkInLocation: json["check_in_location"],
    checkInAddress: json["check_in_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date":
        "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
