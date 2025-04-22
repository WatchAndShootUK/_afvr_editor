// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:afvr_editor/globals.dart';
import 'package:afvr_editor/services/github_read_service.dart';
import 'package:flutter/material.dart';
import 'package:afvr_editor/ui/vehicle_tab.dart';
import 'package:afvr_editor/ui/weapons_tab.dart';
import 'package:afvr_editor/ui/armour_tab.dart';
import 'package:afvr_editor/ui/sensors_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

@override
void initState() {
  super.initState();
  loadAll();
}

Future<void> loadAll() async {
  setState(() => isLoading = true);

  await Future.wait([
    githubRead('vehicles.json', vehicles),
    githubRead('weapons.json', weapons),
    githubRead('armour.json', armours),
    githubRead('sensors.json', sensors),
  ]);

  setState(() => isLoading = false);
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('AFV Recognition Editor'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Vehicles'),
              Tab(text: 'Weapons'),
              Tab(text: 'Armour'),
              Tab(text: 'Sensors'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [VehicleTab(), WeaponsTab(), ArmourTab(), SensorsTab()],
        ),
      ),
    );
  }
}
