import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir_api/api/checkin.dart';
import 'package:tugas_akhir_api/model/chekin.dart'; // pastikan ada AbsenService + AbsenCheckIn

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  String currentTime = DateFormat('HH:mm').format(DateTime.now());
  TextEditingController noteController = TextEditingController();

  GoogleMapController? mapController;
  LatLng _currentPosition = const LatLng(-6.200000, 106.816666);
  String _currentAddress = "Mencari lokasi...";
  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _getCurrentLocation();
  }

  void _updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        currentTime = DateFormat('HH:mm').format(DateTime.now());
      });
      _updateTime();
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng pos = LatLng(position.latitude, position.longitude);
    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    Placemark place = placemarks[0];

    if (!mounted) return;
    setState(() {
      _currentPosition = pos;
      _marker = Marker(
        markerId: const MarkerId("lokasi_saya"),
        position: pos,
        infoWindow: InfoWindow(
          title: 'Lokasi Anda',
          snippet: "${place.street}, ${place.locality}",
        ),
      );
      _currentAddress =
          "${place.name}, ${place.street}, ${place.locality}, ${place.country}";
    });

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: 16)),
    );
  }

  /// === Function Absensi dari temenmu (sudah tested) ===
  Future<void> _absenCheckIn() async {
    try {
      // Ambil lokasi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = "Alamat tidak ditemukan";
      String locationName = "Lokasi Tidak Diketahui";

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        locationName = place.locality ?? "Lokasi Tidak Diketahui";
      }

      // Panggil API absen check-in
      CheckInModel? result = await AbsenAPI.checkInUser(
        checkInLat: position.latitude,
        checkInLng: position.longitude,
        checkInLocation: locationName,
        checkInAddress: address,
      );

      if (!mounted) return;

      if (result != null && result.data != null) {
        // ✅ Berhasil absen
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ ${result.message}")));
      } else {
        // ❌ Sudah absen / gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ ${result?.message ?? "Sudah absen hari ini"}"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 12,
            ),
            onMapCreated: (controller) => mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            markers: _marker != null ? {_marker!} : {},
          ),

          /// Jam overlay
          SafeArea(
            child: Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  Text(
                    currentTime,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 6,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.access_time,
                    color: Colors.black54,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          /// Tombol refresh lokasi
          Positioned(
            bottom: 260,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          /// Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.25,
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
                  physics: const ClampingScrollPhysics(),
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
                          children: [
                            const Text(
                              "Lokasi Anda",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentAddress,
                              style: const TextStyle(
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
                    // TextField(
                    //   controller: noteController,
                    //   maxLines: 2,
                    //   decoration: InputDecoration(
                    //     labelText: "Catatan (opsional)",
                    //     prefixIcon: const Icon(Icons.note_alt_outlined),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 20),

                    /// Tombol Absen
                    ElevatedButton(
                      onPressed: _absenCheckIn, // ⬅️ diganti
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue,
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
