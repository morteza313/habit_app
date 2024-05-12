import 'package:flutter/material.dart';
import 'package:habits/models/app_settings.dart';
import 'package:habits/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

//initialize DB

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  //save first date of app startup (for heatmap)
  static Future<void> saveFirstLunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLunchDay = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  //get first date of app startup (for heatmap)
  Future<DateTime?> getFirstLunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLunchDay;
  }

  //List of Habits
  final List<Habit> currentHabits = [];

  //create a new habit
  Future<void> addHabit(String habiteName) async {
    //creaete habit obj
    final habit = Habit()..name = habiteName;

    //save to db
    await isar.writeTxn(() => isar.habits.put(habit));

    //re_read from db
    readHabits();
  }

  Future<void> readHabits() async {
    //get all habits from db
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    //update UI
    notifyListeners();
  }

  //Update - chack habit on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //find our habit
    final habit = await isar.habits.get(id);

    //update completion status
    if (habit != null) {
      isar.writeTxn(() async {
        if (isCompleted && !habit.completedDay.contains(DateTime.now())) {
          //today
          final today = DateTime.now();

          // add current date if it is not in the list
          habit.completedDay.add(DateTime(
            today.year,
            today.month,
            today.day,
          ));

          //if habit is Not compleate -> remove the current date from the list
        } else {
          //remove current date if the habit marked as not completed
          habit.completedDay.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }
        //save the updated habit back to db
        await isar.habits.put(habit);
      });
    }
    //re_read from db
    readHabits();
  }

//update  - edite habite name
  Future<void> updateHabitName(int id, String newName) async {
    // finad habit
    final habit = await isar.habits.get(id);

    //update name

    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        //save habit back to db
        await isar.habits.put(habit);
      });
    }
    //re_read from db
    readHabits();
  }

  // delete habit from db
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    //re_read from db
    readHabits();
  }
}
