import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'db_helper.dart';
import 'ip_scanner.dart';
import 'main.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'auth_page.dart';



class TimetableData {
  final String subject;
  final String lecturer;
  final String ltpc;
  final String sessionRoom;
  final DateTime startTime;
  final DateTime endTime;

  TimetableData({
    required this.subject,
    required this.lecturer,
    required this.ltpc,
    required this.sessionRoom,
    required this.startTime,
    required this.endTime,
  });
}


class AttendancePage extends StatefulWidget {
  AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int _currentIndex = 0;
  late String name;
  List<AttendanceData> attendanceDataList = [];
  List<List<TimetableData>> timetableDataList = [];
  bool isClassRunning = false;
  Timer? _timer;
  TimetableData? runningClass;
  TimetableData? upcomingClass;
  bool isLoading = true;
  List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  late List<Map<String, dynamic>> miscData;
  @override
  void initState() {
    name = "";
    super.initState();
    initializeAll();
  }
  void initializeAll() async{
    await _setMiscData();
    await fetchNameFromDatabase();
    await fetchAttendanceDataFromDatabase();
    await fetchTimetableDataFromDatabase();
    Future.delayed(const Duration(seconds: 2), () {
      _updateClassStatus();
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 2) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _updateClassStatus();
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> fetchAttendanceDataFromDatabase() async {
    final timetableData = await DBHelper.queryData('time_table');
    DBHelper.queryData('attendance').then((value) {
      setState(() {
        attendanceDataList = value
            .map((item) => AttendanceData(
          subjectName: timetableData.firstWhere((element) =>
          element['subject_code'] ==
              item['subject_code'])['subject_name'],
          subjectCode: item['subject_code'],
          presentClasses: item['present_classes'],
          totalClasses: item['total_classes'],
          notAttendedClasses: item['not_attended_classes'],
          percentage: item['percentage'],
          leavesApplicable: item['leaves_applicable'],
          mustAttendClasses: item['must_attend'],
        ))
            .toList();
        isLoading = false;
      });
    });
  }

  Future<void> fetchTimetableDataFromDatabase() async {
    final timeTableData = await DBHelper.queryData('time_table');
    final now = DateTime.now();
    // Assign timetable data to timetableDataList as a list of lists with each index of list referring to a day
    setState(() {
      timetableDataList = List.generate(
        5,
            (index) => timeTableData
            .where((element) => element['day'] == days[index])
            .map((item) => TimetableData(
          subject: item['subject_name'],
          lecturer: item['faculty_name'],
          ltpc: item['l_t_p_c'],
          sessionRoom: item['session_room'],
          startTime: DateTime.parse(
              "${now.toString().split(" ")[0]} ${item['start_time']}"),
          endTime: DateTime.parse(
              "${now.toString().split(" ")[0]} ${item['end_time']}"),
        ))
            .toList(),
      );
    });
  }

  Future<String> getIPAddress(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => IPScanner(), maintainState: true),);
    if (result != null) {
      print("result: $result");
      return result;
    } else {
      return '';
    }
  }

  Future<void> fetchAttendanceDataFromApi(BuildContext context) async {
    String? ip = '';
    if (Platform.isAndroid == true) {
      ip = await getIPAddress(context);
      if (ip == '-1') {
        return;
      }
    } else {
      ip = await NetworkInfo().getWifiIP();
    }
    if (ip != '') {
      try {
        // Write a query to update the value where key = 'last_updated' with new date string
        // Make API call to fetch attendance data
        Uri url = Uri.parse('http://$ip:8000/attendance/');
        String regId = miscData.firstWhere((item) => item['key'] == 'regId', orElse: () => {})['value'];
        String pass = miscData.firstWhere((item) => item['key'] == 'pass', orElse: () => {})['value'];
        final response = await http.post(url, body: {
          'student_id': regId,
          'student_dob': pass,
          'first_time_login': false.toString(),
        });
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 0) {
            await DBHelper.insertAttendanceData(data['attendance']);// Assuming this method sets the state with the fetched data
          } else {
            print('Failed to fetch attendance data');
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid credentials'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        } else {
          print('Failed to fetch attendance data');
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('There is a problem within the server'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        print('Error: $e');
        if(Platform.isAndroid == false)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection (or Invalid Server QR)'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
    await fetchAttendanceDataFromDatabase();
  }


  void navigateToAuthPage(BuildContext context) {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) => AuthPage(),
        maintainState: true,
      ),
    );
  }

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    // Navigate back to the authentication page
    navigateToAuthPage(context);
  }

  Widget _buildChipContainer(var subjectCode, var subjectName, var percentage) {
    bool flag = percentage >= 75;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: flag ? Colors.grey[100] : Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${subjectCode} - ${subjectName}',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: flag ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Don't forget to cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildClassDetailsWidget(String subject, String lecturer, String ltpc,
      DateTime startTime, DateTime endTime) {
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: Container(
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border:
          Border.fromBorderSide(BorderSide(color: Colors.grey.shade400)),
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '-ONGOING SESSION-',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subject,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'by $lecturer',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'at $ltpc',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildCountdownTimer(startTime, endTime),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingClassWidget(
      String subject, String lecturer, String ltpc, DateTime startTime) {
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: Container(
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border:
          Border.fromBorderSide(BorderSide(color: Colors.grey.shade400)),
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '-UPCOMING SESSION-',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subject,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'by $lecturer',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'at $ltpc',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildCountdownTimer(startTime),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownTimer(DateTime startTime, [DateTime? endTime]) {
    Duration remainingTime = startTime.difference(DateTime.now());
    if (remainingTime.isNegative) {
      // Class has already started, show the end countdown timer
      remainingTime = endTime!.difference(DateTime.now());
      int minutes = remainingTime.inMinutes;
      int seconds = remainingTime.inSeconds % 60;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, size: 20),
          const SizedBox(width: 5),
          Text(
            'Ends in: $minutes min $seconds sec',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      );
    }

    int minutes = remainingTime.inMinutes;
    int seconds = remainingTime.inSeconds % 60;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.access_time, size: 20),
        const SizedBox(width: 5),
        Text(
          'Starts in: $minutes min $seconds sec',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // Make the text appear at the center of app bar
        title: Row(
          children: [
            Image.asset(
              'images/attendance_white.png',
              width: 28,
              filterQuality: FilterQuality.high,
              height: 20,
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.colorBurn,
              matchTextDirection: true,

            ),
            Expanded(
              child: Text(
                '  WELCOME, ${name.split(" ")[0].toUpperCase()} 👋',
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          // Add a reload button to reload the attendance data
          (Platform.isAndroid == false) ?
          IconButton(
            // Rotate the refresh icon for one time when the data is being fetched
            icon: isLoading
                ? const RotationTransition(
              turns: AlwaysStoppedAnimation(120 / 360),
              child: Icon(Icons.refresh, color: Colors.white),
            )
                : const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              setState(() {
                isLoading = true;
                attendanceDataList = [];
              });
              await fetchAttendanceDataFromApi(context);
            },
          ): IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () async {
              setState(() {
                isLoading = true;
                attendanceDataList = [];
              });
              await fetchAttendanceDataFromApi(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (attendanceDataList.isNotEmpty)
              if (_currentIndex == 0)
                Column(
                  children: [
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          plotAreaBackgroundColor: Colors.transparent,
                          primaryXAxis: CategoryAxis(
                            maximumLabelWidth: 75,
                            axisLine: const AxisLine(width: 0),
                            placeLabelsNearAxisLine: true,
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            majorGridLines: const MajorGridLines(width: 0),
                            majorTickLines: const MajorTickLines(width: 0),
                            autoScrollingMode: AutoScrollingMode.end,
                            // Place the label into multiple rows when the text length is greater than 15
                            labelIntersectAction:
                            AxisLabelIntersectAction.multipleRows,
                          ),
                          primaryYAxis: NumericAxis(
                            minimum: 0,
                            maximum: 100,
                            desiredIntervals: 10,
                            majorGridLines: const MajorGridLines(width: 0),
                            majorTickLines: const MajorTickLines(width: 0),
                            labelFormat: '{value}%',
                          ),
                          tooltipBehavior: TooltipBehavior(
                            enable: true,
                            header: '',
                            canShowMarker: false,
                            format: 'point.x : point.y',
                          ),
                          series: <ChartSeries>[
                            BarSeries<AttendanceData, String>(
                              borderRadius: BorderRadius.circular(5),
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelAlignment: ChartDataLabelAlignment.top,
                                textStyle: TextStyle( // fontSize is 11 if phone is horizontal, 9 if vertical
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              spacing: 0.1,
                              dataSource: attendanceDataList,
                              xValueMapper: (AttendanceData data, _) =>
                              data.subjectCode,
                              yValueMapper: (AttendanceData data, _) =>
                              data.percentage,
                              enableTooltip: true,
                              // Need two gradients to the bars (one that is current and other reddish one if the attendance is below 75%)
                              gradient: const LinearGradient(
                                // Add good color gradient
                                colors: <Color>[
                                  Color.fromRGBO(
                                      20, 218, 149, 0.6705882352941176),
                                  Color.fromRGBO(
                                      22, 168, 175, 0.7333333333333333),
                                ],
                                stops: <double>[0.2, 0.8],
                              ),
                              width: 0.8,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Display subject codes and names in a ListView
                          ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: attendanceDataList.map((data) {
                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 5),
                                child: _buildChipContainer(data.subjectCode,
                                    data.subjectName, data.percentage),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )
                  ],
                )
              else if (_currentIndex == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Subject',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Status',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Leaves Applicable',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Must Attend',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          // Add a divider line for better separation
                          ...attendanceDataList.map((data) {
                            bool isSafe = data.percentage >= 75.0;

                            return Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          data.subjectName,
                                          style: const TextStyle(fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          isSafe ? 'Safe' : 'Not Safe',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: isSafe
                                                  ? Colors.blueGrey
                                                  : Colors.brown[400],
                                              fontSize: 13),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          (data.leavesApplicable > 0) ? data.leavesApplicable.toString() : 'N/A',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          (data.mustAttendClasses != -1 ) ? data.mustAttendClasses.toString() : 'N/A',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_currentIndex == 2)
                // Add the new section here
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Case 1: If a class starts within 15 minutes and no class is running currently
                      if (!isClassRunning && upcomingClass != null)
                        _buildUpcomingClassWidget(
                          upcomingClass!.subject,
                          upcomingClass!.lecturer,
                          upcomingClass!.sessionRoom,
                          upcomingClass!.startTime,
                        ),
                      // Case 2: If there within 15 minutes and already a class is running currently
                      if (isClassRunning && upcomingClass == null)
                        _buildClassDetailsWidget(
                          runningClass!.subject,
                          runningClass!.lecturer,
                          runningClass!.sessionRoom,
                          runningClass!.startTime,
                          runningClass!.endTime,
                        ),
                      // Case 3: If a class starts within 15 minutes and already a class is running currently
                      if (isClassRunning && upcomingClass != null)
                        Column(
                          children: [
                            _buildClassDetailsWidget(
                              runningClass!.subject,
                              runningClass!.lecturer,
                              runningClass!.sessionRoom,
                              runningClass!.startTime,
                              runningClass!.endTime,
                            ),
                            _buildUpcomingClassWidget(
                              upcomingClass!.subject,
                              upcomingClass!.lecturer,
                              upcomingClass!.sessionRoom,
                              upcomingClass!.startTime,
                            ),
                          ],
                        ),
                      // Case 4: If no class is running
                      if (!isClassRunning && upcomingClass == null)
                      // Cover all the width of the screen
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            foregroundDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.fromBorderSide(
                                  BorderSide(color: Colors.grey.shade400)),
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  '-NO SESSIONS SCHEDULED-',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        )

                      // ... Implement the timetable table here ...
                    ],
                  ),
            if (attendanceDataList.isEmpty && isLoading)
            // Display a loading indicator while waiting for the data to load
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }

  void _updateClassStatus() {
    DateTime now = DateTime.now();
    runningClass = null;
    upcomingClass = null;
    // wait until the timetable data is loaded
    if (now
        .isBefore(DateTime.parse("${now.toString().split(" ")[0]} 08:45:00")) && now.isAfter(DateTime.parse("${now.toString().split(" ")[0]} 17:40:00"))) {
      // Before 8:45 AM
      isClassRunning = false;
      return;
    }
    // Compare two TimeOfDay objects only by their hour and minute
    for (int i = 0; i < timetableDataList[now.weekday - 1].length; i++) {
      if (now.isAfter(timetableDataList[now.weekday - 1][i].startTime) &&
          now.isBefore(timetableDataList[now.weekday - 1][i].endTime)) {
        // Class is running currently
        isClassRunning = true;
        runningClass = timetableDataList[now.weekday - 1][i];
        if (i + 1 < timetableDataList[now.weekday - 1].length &&
            now.isBefore(timetableDataList[now.weekday - 1][i + 1].startTime)) {
          int diff = timetableDataList[now.weekday - 1][i + 1].startTime
              .difference(now)
              .inMinutes;
          if (diff <= 15 && diff >= 0) {
            upcomingClass = timetableDataList[now.weekday - 1][i + 1];
          }
        }
        break; // No need to check further if we found the running class
      } else if (now
          .isBefore(timetableDataList[now.weekday - 1][i].startTime)) {
        int diff = timetableDataList[now.weekday - 1][i].startTime
            .difference(now)
            .inMinutes;
        if (diff <= 15 && diff >= 0) {
          // Upcoming class within 15 minutes
          upcomingClass = timetableDataList[now.weekday - 1][i];
          break;
        } // No need to check further as we have found an upcoming class
      }
    }
    if (runningClass == null) {
      // No class is running
      isClassRunning = false;
    }
  }

  Future<void> fetchNameFromDatabase() async {
    name = miscData.firstWhere((item) => item['key'] == 'name',
        orElse: () => {})['value'];
  }


  Future<void> _setMiscData() async {
    final misc = await DBHelper.queryData('misc');
    setState(() {
      miscData = misc;
    });
    _updateIfNewDate(context);
  }

  Future<void> _updateIfNewDate(BuildContext context) async {
    final lastUpdated = miscData.firstWhere((item) => item['key'] == 'lastUpdated',
        orElse: () => {})['value'];
    final database = await DBHelper.database;
    await database.rawUpdate(
        'UPDATE misc SET value = ? WHERE key = ?', [DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(), 'lastUpdated']);
    final now = DateTime.now();
    if (lastUpdated != null) {
      if (lastUpdated != DateFormat('yyyy-MM-dd').format(now).toString()) {
        await fetchAttendanceDataFromApi(context);
      }
    }
  }
}

class AttendanceData {
  final String subjectName;
  final String subjectCode;
  final int presentClasses;
  final int totalClasses;
  final int notAttendedClasses;
  final double percentage;
  final int leavesApplicable;
  final int mustAttendClasses;

  AttendanceData({
    required this.subjectName,
    required this.subjectCode,
    required this.presentClasses,
    required this.totalClasses,
    required this.notAttendedClasses,
    required this.percentage,
    required this.leavesApplicable,
    required this.mustAttendClasses,
  });
}