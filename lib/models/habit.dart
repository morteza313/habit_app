import 'package:isar/isar.dart';
part 'habit.g.dart';

@Collection()
class Habit {
  // habit id
  Id id = Isar.autoIncrement;
//habit name
  late String name;
//completed Day

  List<DateTime> completedDay = [
    // DataTime(year , month , day ) ,
    //DataTime(2024 , 1 , 2),
    //DataTime(2024 , 1 , 2),
  ];
}
