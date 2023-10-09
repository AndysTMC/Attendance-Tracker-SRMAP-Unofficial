import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'db_helper.dart';
import 'auth_page.dart';
import 'attendance_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  if (kIsWeb || Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
  }
  DBHelper.database;
  if (await DBHelper.isEmpty()) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
  }
  // define a global navigatorKey to access navigator without context
  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    title: 'Attendance Tracker',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    // if user is not authenticated or isAuthenticated is null, show auth page, else show attendance page
    home: await SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool('isAuthenticated') == null ||
          prefs.getBool('isAuthenticated') == false) {
        return AuthPage();
      } else {
        return AttendancePage();
      }
    }),
  ));
}



