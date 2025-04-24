import 'dart:ui';

import 'package:flutter/foundation.dart';

List<Map<String, dynamic>> vehicles = [];
List<Map<String, dynamic>> weapons = [];
List<Map<String, dynamic>> armours = [];
List<Map<String, dynamic>> sensors = [];
ValueNotifier<String> version = ValueNotifier<String>('');

const wasdColour = Color(0xFF958B60);
String token = '';
