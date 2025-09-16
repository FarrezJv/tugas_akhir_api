import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:tugas_akhir_api/check.dart';
import 'package:tugas_akhir_api/views/home/halman_utama.dart';
import 'package:tugas_akhir_api/views/home/test.dart';

class BotnavPage extends StatefulWidget {
  const BotnavPage({super.key});
  static const id = "/Botnav";

  @override
  State<BotnavPage> createState() => _BotnavPageState();
}

class _BotnavPageState extends State<BotnavPage> {
  int _selectedIndex = 0;

  /// Controller untuk Notch Bottom Bar
  final NotchBottomBarController _controller = NotchBottomBarController(
    index: 0,
  );

  /// Halaman yang dipanggil sesuai index
  static const List<Widget> _widgetOptions = <Widget>[
    HalamanPage(),
    AbsensiApp(),
    TESTEST(),
  ];

  /// Item menu untuk bottom navigation
  final List<BottomBarItem> bottomBarItems = const [
    BottomBarItem(
      inActiveItem: Icon(Icons.home, color: Colors.grey),
      activeItem: Icon(Icons.home, color: Colors.blue),
      itemLabel: 'Home',
    ),
    BottomBarItem(
      inActiveItem: Icon(Icons.access_time, color: Colors.grey),
      activeItem: Icon(Icons.access_time, color: Colors.blue),
      itemLabel: 'Absensi',
    ),
    BottomBarItem(
      inActiveItem: Icon(Icons.settings, color: Colors.grey),
      activeItem: Icon(Icons.settings, color: Colors.blue),
      itemLabel: 'Test',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions[_selectedIndex]),
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Colors.white,
        showLabel: true,
        kIconSize: 24,
        kBottomRadius: 28,
        bottomBarItems: bottomBarItems,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
