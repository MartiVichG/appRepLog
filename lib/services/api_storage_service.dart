import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';
import '../models/exercise_set.dart';

class ApiStorageService {
  String get _baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/gym_api';
    }
    return 'http://127.0.0.1/gym_api';
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<void> saveWorkout(Workout workout) async {
    final userId = await _getUserId();
    if (userId == null) throw Exception('Sesión de usuario no válida');

    final url = Uri.parse('$_baseUrl/save_workout.php');
    
    // Anexamos explícitamente el session id `user_id`
    final Map<String, dynamic> data = {
      'user_id': userId,
      'date': "${workout.date.year}-${workout.date.month.toString().padLeft(2, '0')}-${workout.date.day.toString().padLeft(2, '0')}",
      'sets': workout.sets.map((set) => {
        'exercise_name': set.exerciseName,
        'weight': set.weight,
        'reps': set.reps,
      }).toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) throw Exception('Error del servidor: ${response.body}');
      
      final respuestaJson = jsonDecode(response.body);
      if (respuestaJson['error'] != null) throw Exception('Error Interno: ${respuestaJson['error']}');
      
    } catch (e) {
      debugPrint('HTTP POST Error: $e');
      rethrow;
    }
  }

  Future<List<Workout>> loadWorkouts() async {
    final userId = await _getUserId();
    if (userId == null) throw Exception('Sesión de usuario no válida');

    List<Workout> workouts = [];
    final url = Uri.parse('$_baseUrl/get_workouts.php?user_id=$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        for (var workoutJson in data) {
          DateTime date = DateTime.parse(workoutJson['date']);
          
          List<ExerciseSet> sets = [];
          if (workoutJson['sets'] != null) {
            for (var setJson in workoutJson['sets']) {
              sets.add(ExerciseSet(
                exerciseName: setJson['exercise_name'],
                weight: double.tryParse(setJson['weight'].toString()) ?? 0.0,
                reps: int.tryParse(setJson['reps'].toString()) ?? 0,
              ));
            }
          }
          
          workouts.add(Workout(date: date, sets: sets));
        }
      } else {
        debugPrint('Servidor devolvió estado HTTP distinto a 200: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('HTTP GET Error (probablemente API no disponible): $e');
    }
    
    return workouts;
  }
}
