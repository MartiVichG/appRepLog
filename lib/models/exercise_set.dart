class ExerciseSet {
  final String exerciseName;
  final double weight;
  final int reps;

  ExerciseSet({
    required this.exerciseName,
    required this.weight,
    required this.reps,
  });

  // Convert to a List for CSV
  List<dynamic> toCsvRow(DateTime date) {
    // Keep date just as YYYY-MM-DD for easier reading in Excel
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return [dateStr, exerciseName, weight, reps];
  }

  // Parse from CSV row
  static ExerciseSet fromCsvRow(List<dynamic> row) {
    // row[0] is Date, row[1] is Exercise, row[2] is Weight, row[3] is Reps
    return ExerciseSet(
      exerciseName: row[1].toString(),
      weight: double.tryParse(row[2].toString()) ?? 0.0,
      reps: int.tryParse(row[3].toString()) ?? 0,
    );
  }
}
