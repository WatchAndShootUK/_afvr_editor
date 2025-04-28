// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:afvr_editor/globals.dart';
import 'package:afvr_editor/main.dart';
import 'package:afvr_editor/services/github_read_service.dart';
import 'package:flutter/material.dart';
import 'package:afvr_editor/ui/vehicle_tab.dart';
import 'package:afvr_editor/ui/weapons_tab.dart';
import 'package:afvr_editor/ui/armour_tab.dart';
import 'package:afvr_editor/ui/sensors_tab.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware{
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    loadAll();
  }
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  routeObserver.subscribe(this, ModalRoute.of(context)!);
}

@override
void dispose() {
  routeObserver.unsubscribe(this);
  super.dispose();
}
  Future<void> loadAll() async {
    setState(() => isLoading = true);

    await Future.wait([
      githubRead('vehicles.json', vehicles),
      githubRead('weapons.json', weapons),
      githubRead('armour.json', armours),
      githubRead('sensors.json', sensors),
      githubRead('version.json', vehicles),
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
          title: ValueListenableBuilder<String>(
            valueListenable: version,
            builder: (context, value, _) {
              return Text('AFV Recognition Editor ($value)');
            },
          ),

          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () async {
                try {
                  final response = await http.get(
                    Uri.parse(
                      'https://script.google.com/macros/s/AKfycbwWmNS3jx2N8H3VJIAVFBGfpg4HnJjmOk5y8Pxf3FjqnAw7re4HrFsXYYvLIUhPOz7b/exec',
                    ),
                  );

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Database pushed to app successfully!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed with status: ${response.statusCode}',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
            ),
          ],
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