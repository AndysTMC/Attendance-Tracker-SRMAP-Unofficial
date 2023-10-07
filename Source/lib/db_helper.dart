import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:intl/intl.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'attendance_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await createTables(db);
      },
    );
  }

  static Future<void> insertData(
      String tableName, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(tableName, data);
  }

  static Future<List<Map<String, dynamic>>> queryData(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  static Future<void> createTables(Database db) async {
    await db.execute('CREATE TABLE IF NOT EXISTS misc ('
        'key TEXT PRIMARY KEY, '
        'value TEXT '
        ')');
    await db.execute('CREATE TABLE IF NOT EXISTS time_table ('
        'tt_id INTEGER PRIMARY KEY, '
        'day TEXT, '
        'start_time TEXT, '
        'end_time TEXT, '
        'subject_code TEXT, '
        'subject_name TEXT, '
        'faculty_name TEXT, '
        'session_room TEXT, '
        'l_t_p_c TEXT '
        ')');
    await db.execute('CREATE TABLE IF NOT EXISTS attendance ('
        'at_id INTEGER PRIMARY KEY, '
        'subject_code TEXT, '
        'present_classes INTEGER, '
        'total_classes INTEGER, '
        'not_attended_classes INTEGER, '
        'percentage REAL, '
        'leaves_applicable INTEGER, '
        'must_attend INTEGER '
        ')');
    await db.execute('CREATE TABLE IF NOT EXISTS holidays ('
        'id INTEGER PRIMARY KEY, '
        'name TEXT, '
        'date TEXT '
        ')'
    );
  }

  static Future<void> insertHolidaysData(List<dynamic> holidays) async {
    for (dynamic info in holidays) {
      await DBHelper.insertData('holidays', {'name': info[0], 'date': info[1]});
    }
  }

  static Future<void> insertTimetableData(var scheduleDays, var scheduleTimings,
      var scheduleSubjects, var subjectsInfo) async {
    for (var day in scheduleDays) {
      for (var timing in scheduleTimings) {
        String cellData = scheduleSubjects[scheduleDays.indexOf(day)]
        [scheduleTimings.indexOf(timing)];
        if (cellData == "") {
          continue;
        }
        late String subjectCode;
        late String sessionRoom;
        if (cellData.contains(")")) {
          // must start with a letter
          if (cellData.startsWith("(")) {
            continue;
          }
          var subjectData = scheduleSubjects[scheduleDays.indexOf(day)]
          [scheduleTimings.indexOf(timing)]
              .toString()
              .split("(");
          subjectCode = subjectData[0];
          sessionRoom = subjectData[1].split(")")[0];
        } else {
          subjectCode =
          scheduleSubjects[scheduleDays.indexOf(day)][scheduleTimings.indexOf(timing)];
          sessionRoom = subjectsInfo[subjectCode][3];
        }
        String getTimes(String time) {
          int value = int.parse(time.split(":")[0]);
          if (value >= 9 && value <= 12) {
            return time;
          } else {
            return "${value + 12}:${time.split(":")[1]}";
          }
        }
        var subjectName = subjectsInfo[subjectCode][0];
        var ltpc = subjectsInfo[subjectCode][1];
        var facultyName = subjectsInfo[subjectCode][2];
        await DBHelper.insertData('time_table', {
          'day': day,
          'start_time': "${getTimes(timing.split(' To ')[0])}:00",
          'end_time': "${getTimes(timing.split(' To ')[1])}:00",
          'subject_code': subjectCode,
          'subject_name': subjectName,
          'faculty_name': facultyName,
          'session_room': sessionRoom,
          'l_t_p_c': ltpc,
        });
      }
    }
  }

  static insertMiscData(String name, String regiId, String pass,
      String sdate_str, String edate_str) {
    DBHelper.insertData('misc', {
      'key': 'name',
      'value': name,
    });
    DBHelper.insertData('misc', {
      'key': 'regId',
      'value': regiId,
    });
    DBHelper.insertData('misc', {
      'key': 'pass',
      'value': pass,
    });
    DBHelper.insertData('misc', {
      'key': 'sdate_str',
      'value': sdate_str,
    });
    DBHelper.insertData('misc', {
      'key': 'edate_str',
      'value': edate_str,
    });
    DBHelper.insertData('misc', {
      'key': 'lastUpdated',
      'value': DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
    });
  }

  static insertAttendanceData(var attendancedata) async {
    // clear all the rows in the attendance table before inserting new data
    final db = await database;
    await db.execute('DELETE FROM attendance');
    var miscData = await DBHelper.queryData('misc');
    var holidays = await DBHelper.queryData('holidays');
    List<String> holidayDates = holidays.map((map) => map['date'] as String).toList();
    // Assign semEndDate with the end date of the semester
    var semEndDateStr = miscData[4]['value'];
    var semStartDateStr = miscData[3]['value'];
    Map<String, List<String>> days = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': []
    };
    // Assign the days of the week to the days map
    var timeTableData = await DBHelper.queryData('time_table');
    for (var element in timeTableData) {
      days[element['day']]!.add(element['subject_code']);
    }
    attendancedata.forEach((key, value) async {
      late int mustAttend;
      if(value[3] < 75) {
        mustAttend = ((0.75 * value[1] - value[0]) / 0.25).ceil();
        var daysCount = mustAttend;
        for (var i = DateTime.now(); i.isBefore(
            DateTime.parse(semEndDateStr.toString()));
        i = i.add(const Duration(days: 1))) {
          if (holidayDates.any((holidayDate) => DateFormat('yyyy-mm-dd').format(i) == holidayDate)) {
            continue;
          }
          var day = DateFormat('EEEE').format(i);
          for (String sub in days[day]!) {
            if (sub == key) {
              daysCount--;
            }
          }
          if (daysCount <= 0) {
            break;
          }
        }
        if (daysCount > 0) {
          mustAttend = -1;
        }
      } else {
        mustAttend = 0;
      }
      var totalScheduleClasses = 0;
      for (var i = DateTime.parse(semStartDateStr.toString()); i.isBefore(DateTime.parse(semEndDateStr)); i = i.add(const Duration(days: 1))) {
        if (holidayDates.any((holidayDate) => DateFormat('yyyy-mm-dd').format(i) == holidayDate)) {
          continue;
        }
        var day = DateFormat('EEEE').format(i);
        for (String sub in days[day]!) {
          if (sub == key) {
            totalScheduleClasses++;
          }
        }
      }
      var remainingClasses = totalScheduleClasses - value[1];
      int leavesApplicable = value[0] + remainingClasses - (0.75 * totalScheduleClasses).ceil();
      if (leavesApplicable % 2 == 1) {
        leavesApplicable -= 1;
      }
      await DBHelper.insertData('attendance', {
        'subject_code': key,
        'present_classes': value[0],
        'total_classes': value[1],
        'not_attended_classes': value[2],
        'percentage': double.parse(value[3].toString()),
        'leaves_applicable': leavesApplicable,
        'must_attend': mustAttend.toInt(),
      });
    });
  }

  static Future<void> clearAllDataInAllTables() async {
    final db = await database;
    final miscTableExists = (await db.rawQuery("PRAGMA table_info(misc)")).isNotEmpty;
    final timeTableExists = (await db.rawQuery("PRAGMA table_info(time_table)")).isNotEmpty;
    final attendanceTableExists = (await db.rawQuery("PRAGMA table_info(attendance)")).isNotEmpty;
    final holidaysTableExists = (await db.rawQuery("PRAGMA table_info(holidays)")).isNotEmpty;
    if (miscTableExists) {
      await db.execute('DELETE FROM misc');
    }
    if (timeTableExists) {
      await db.execute('DELETE FROM time_table');
    }
    if (attendanceTableExists) {
      await db.execute('DELETE FROM attendance');
    }
    if (holidaysTableExists) {
      await db.execute('DELETE FROM holidays');
    }
  }
}
