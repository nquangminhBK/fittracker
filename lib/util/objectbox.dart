import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:fittracker/dbModels/session_entry_model.dart';
import 'package:fittracker/dbModels/session_item_model.dart';
import 'package:fittracker/objectbox.g.dart';
import 'package:fittracker/dbModels/workout_entry_model.dart';
import 'package:fittracker/dbModels/routine_entry_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// https://github.com/objectbox/objectbox-dart/blob/main/objectbox/example/flutter/objectbox_demo/lib/objectbox.dart
/// Provides access to the ObjectBox Store throughout the app.
///
/// Create this in the apps main function.
class ObjectBox {
  /// The Store of this app.
  late Store store;
  late final SharedPreferences prefs;

  late Box<WorkoutEntry> workoutBox;
  late Box<RoutineEntry> routineBox;
  late Box<SessionItem> sessionItemBox;
  late Box<SessionEntry> sessionBox;

  List<WorkoutEntry> workoutList = [];
  List<RoutineEntry> routineList = [];
  List<SessionItem> itemList = [];
  List<SessionEntry> sessionList = [];

  Map<String, dynamic> prefMap = Map();

  ObjectBox._create(this.store, this.prefs) {
    initObjectBox();
  }

  void initObjectBox()
  {
    workoutBox = Box<WorkoutEntry>(store);
    routineBox = Box<RoutineEntry>(store);
    sessionItemBox = Box<SessionItem>(store);
    sessionBox = Box<SessionEntry>(store);

    workoutList = workoutBox.getAll();
    routineList = routineBox.getAll();

    DateTime now = new DateTime.now();
    updateSessionList(now.year, now.month);

    // itemList = sessionItemBox.getAll();
    // sessionList = sessionBox.getAll();

    for(String key in prefs.getKeys())
      setPref(key, prefs.get(key));
  }

  void updateSessionList(int year, int month)
  {
    DateTime start = new DateTime(year, month - 1, 23);
    DateTime end = new DateTime(year, month + 1, 7);

    sessionList = sessionBox.query(
        SessionEntry_.startTime.greaterOrEqual(start.millisecondsSinceEpoch).and(
            SessionEntry_.startTime.lessOrEqual(end.millisecondsSinceEpoch)
        )
    ).build().find();

    itemList = sessionItemBox.query(
        SessionItem_.time.greaterOrEqual(start.millisecondsSinceEpoch).and(
            SessionItem_.time.lessOrEqual(end.millisecondsSinceEpoch)
        )
    ).build().find();
  }

  void setPref(String key, dynamic value)
  {
    if(value.runtimeType == String)
      prefs.setString(key, value);
    if(value.runtimeType == double)
      prefs.setDouble(key, value);
    if(value.runtimeType == bool)
      prefs.setBool(key, value);
    if(value.runtimeType == int)
      prefs.setInt(key, value);

    prefMap[key] = value;
  }

  dynamic getPref(String key)
  {
    return prefMap[key];
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore();
    final prefs = await SharedPreferences.getInstance();
    return ObjectBox._create(store, prefs);
  }

  Future<String> objectBoxDataFilePath() async{
    final directory = (await getApplicationDocumentsDirectory()).path;
    return "$directory/objectbox/data.mdb";
  }

  bool closeStore(){
    store.close();
    return true;
  }

  restartDB() async{
    store = await openStore();
    initObjectBox();
  }
}