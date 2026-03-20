import 'exercise_set.dart';

class Workout {
  final DateTime date;
  final List<ExerciseSet> sets;

  Workout({
    required this.date,
    required this.sets,
  });
}
