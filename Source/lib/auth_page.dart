import 'dart:async';
import 'dart:io';

import 'package:attendance_tracker/ip_scanner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:attendance_tracker/db_helper.dart';
import 'attendance_page.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'main.dart';

class AuthPage extends StatefulWidget {
  AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _regIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    DBHelper.clearAllDataInAllTables();
    super.initState();
  }

  Future<void> saveAuthStatus(bool isAuthenticated) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', isAuthenticated);
  }

  Future<void> navigateToAttendancePage(BuildContext context) async {
    final result = Navigator.push(context, MaterialPageRoute(builder: (context) => AttendancePage()),);

  }

  Future<String> getIPAddress(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => IPScanner(), maintainState: true),);
    if (result != null) {
      return result;
    } else {
      return '-1';
    }
  }


  void submitForm(BuildContext context) async {
    String? ip = '';
    if (Platform.isAndroid) {
      ip = await getIPAddress(context);
      print("$ip is IP Address");
      if (ip == '-1') {
        return;
      }
    } else {
      ip = await NetworkInfo().getWifiIP();
    }
    if (_formKey.currentState!.validate() && ip != '') {
      setState(() {
        _isLoading = true;
      });
      try {
        Uri url =
        Uri.parse('http://$ip:8000/attendance/');
        final response = await http.post(url, body: {
          'student_id': _regIdController.value.text,
          'student_dob': _passwordController.value.text,
          'first_time_login': true.toString(),
        });
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          // Parse the JSON data and store it in attendanceDataList
          if (data['status'] == 0) {
            await saveAuthStatus(true);
            var scheduleDays =
            data['timetable']['time_schedule']['schedule_days'];
            var scheduleTimings =
            data['timetable']['time_schedule']['schedule_timings'];
            var scheduleSubjects =
            data['timetable']['time_schedule']['schedule_subjects'];
            var subjectsInfo = data['timetable']['subjects_info'];
            await DBHelper.insertMiscData(
                data['name'],
                _regIdController.value.text,
                _passwordController.value.text,
                data['timetable']['sem_period'][0],
                data['timetable']['sem_period'][1]);
            await DBHelper.insertTimetableData(
                scheduleDays, scheduleTimings, scheduleSubjects, subjectsInfo);
            await DBHelper.insertAttendanceData(data['attendance']);
            setState(() {
              _isLoading = false;
            });
            navigateToAttendancePage(context);
          } else {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid Credentials'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('There is a problem with the server'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } on Exception {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection (or Invalid Server QR)'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: (MediaQuery.of(context).orientation == Orientation.portrait) ? false : true,
      body: SingleChildScrollView(
        child: _isLoading ? SizedBox(
          height: MediaQuery.of(context).size.height,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.black),
          ),
        ) :
        Column(
          children: [
            // Add an image that stands as a logo
            Container(
              padding:
              // const EdgeInsets.symmetric(horizontal: 30, vertical: 200)
              // Adjust the padding based on if the device is horizontal or vertical orientation
              // If its web, adjust the padding based on the screen size

              (kIsWeb || Platform.isWindows || Platform.isLinux) ? EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.height * 0.3) :
              (MediaQuery.of(context).orientation == Orientation.portrait
                  ? const EdgeInsets.symmetric(horizontal: 30, vertical: 200)
                  : const EdgeInsets.symmetric(horizontal: 50, vertical: 60)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/attendance_black.png',
                          width: 37,
                          height: 25,
                          fit: BoxFit.cover,
                        ),
                        const Text(
                          ' Attendance Tracker',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            textBaseline: TextBaseline.alphabetic,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    TextFormField(
                      onFieldSubmitted: (value) {
                        submitForm(context);
                      },
                      controller: _regIdController,
                      onTapOutside: (dynamic value) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      decoration: const InputDecoration(
                        labelText: 'ID',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Enter ID';
                        }
                        if (!(value!.startsWith('AP'))) {
                          return 'ID should start with AP';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      onFieldSubmitted: (value) {
                        submitForm(context);
                      },
                      controller: _passwordController,
                      onTapOutside: (dynamic value) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Enter Password';
                        }
                        return null;
                      },
                      obscureText: true,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          '*Use the credentials of school\'s parent portal',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        submitForm(context);
                      },
                      child: const Text(' GET IN '),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

