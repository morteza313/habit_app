// given a habit list of completion days
// is the habit completd today
import 'package:habits/models/habit.dart';

bool isHabitComletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();
  return completedDays.any(
    (date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day,
  );
}

//prepare heat Map datasets
Map<DateTime, int> prepareHeatMapDatasets(List<Habit> habits) {
  Map<DateTime, int> datasets = {};

  for (var habit in habits) {
    for (var date in habit.completedDay) {
      // normalize date to avoid time mismatch
      final normalizedDate = DateTime(date.year, date.month, date.day);

      //if the date is already exists in datasets, increament it's count
      if (datasets.containsKey(normalizedDate)) {
        datasets[normalizedDate] = datasets[normalizedDate]! + 1;
      } else {
        //else intialize with count of 1
        datasets[normalizedDate] = 1;
      }
    }
  }
  return datasets;
}
