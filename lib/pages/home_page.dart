import 'package:flutter/material.dart';
import 'package:habits/components/my_drawer.dart';
import 'package:habits/components/my_habit_tile.dart';
import 'package:habits/components/my_heat_map.dart';
import 'package:habits/database/habit_database.dart';
import 'package:habits/models/habit.dart';
import 'package:habits/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    //read existing habits on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();

    super.initState();
  }

// text controller
  final TextEditingController textController = TextEditingController();

//create new habit
  void createNewHabite() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Create a New Habit'),
        ),
        actions: [
          //save button
          MaterialButton(
            onPressed: () {
              //get habit name
              String newHabitName = textController.text;

              //save to db
              context.read<HabitDatabase>().addHabit(newHabitName);

              //pop box
              Navigator.pop(context);

              //clear text controller
              textController.clear();
            },
            child: const Text('Save'),
          ),

          //cancel button
          MaterialButton(
            onPressed: () {
              // pop the box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

//check habit on & off
  void checkHabitOnOff(bool? value, Habit habit) {
    //update habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

//edit habit box
  void editHabitBox(Habit habit) {
    //set the controller's text to the habit's current name
    textController.text = habit.name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: textController,
          ),
          actions: [
            //save button
            MaterialButton(
              onPressed: () {
                //get habit name
                String newHabitName = textController.text;

                //save to db
                context
                    .read<HabitDatabase>()
                    .updateHabitName(habit.id, newHabitName);

                //pop box
                Navigator.pop(context);

                //clear text controller
                textController.clear();
              },
              child: const Text('Save'),
            ),

            //cancel button
            MaterialButton(
              onPressed: () {
                // pop the box
                Navigator.pop(context);

                //clear controller
                textController.clear();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

//delete habit box

  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text('Are you sure you want to delete ?'),
          actions: [
            //delete button
            MaterialButton(
              onPressed: () {
                //delete from db
                context.read<HabitDatabase>().deleteHabit(habit.id);

                //pop box
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),

            //cancel button
            MaterialButton(
              onPressed: () {
                // pop the box
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        drawer: const MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewHabite,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          foregroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(
            Icons.add_rounded,
          ),
        ),
        body: ListView(
          children: [
            //HeatMap
            _buildHeatMap(),

            //Habit List
            _buildHabitList(),
          ],
        ));
  }

  //build Heat Map
  Widget _buildHeatMap() {
    //habit database
    final habitDatabase = context.watch<HabitDatabase>();

    //currnet Habit
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //return heat map ui
    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLunchDate(),
      builder: (context, snapshot) {
        //once the date is available -> build heat Map
        if (snapshot.hasData) {
          return MyHeatMap(
              startDate: snapshot.data!,
              datasets: prepareHeatMapDatasets(currentHabits));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  //build habit list
  Widget _buildHabitList() {
    //habit db
    final habitDatabase = context.watch<HabitDatabase>();

    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //return list of habits UI
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentHabits.length,
      itemBuilder: (context, index) {
        //get habit
        var habit = currentHabits[index];
        // check if the habit is completed today
        bool isCompletedToday = isHabitComletedToday(habit.completedDay);
        //return habit tile UI
        return ListTile(
          title: MyHabitTile(
            text: habit.name,
            isCompleted: isCompletedToday,
            onChanged: (value) => checkHabitOnOff(value, habit),
            editeHabit: (value) => editHabitBox(habit),
            deleteHabit: (value) => deleteHabitBox(habit),
          ),
        );
      },
    );
  }
}
