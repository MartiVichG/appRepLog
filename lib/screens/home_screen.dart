import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';
import '../services/api_storage_service.dart';
import 'workout_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiStorageService _storageService = ApiStorageService();
  List<Workout> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final workouts = await _storageService.loadWorkouts();
    setState(() {
      _workouts = workouts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_id');
              
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _workouts.isEmpty 
              ? const Center(child: Text('No hay entrenamientos registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _workouts.length,
                  itemBuilder: (context, index) {
                    final workout = _workouts[index];
                    return _buildWorkoutCard(workout);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to WorkoutScreen
          final Object? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkoutScreen()),
          );
          if (result == true) { // Re-load if saved
            setState(() { _isLoading = true; });
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Entrenar', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    final dateStr = DateFormat('dd/MM/yyyy').format(workout.date);
    
    Set<String> uniqueExercises = {};
    for (var set in workout.sets) {
      uniqueExercises.add(set.exerciseName);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Theme.of(context).colorScheme.primary,
          collapsedIconColor: Theme.of(context).colorScheme.secondary,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          title: Text(
            dateStr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          subtitle: Text(
            '${uniqueExercises.length} ejercicios • ${workout.sets.length} series', 
            style: const TextStyle(fontSize: 14, color: Colors.white70)
          ),
          children: [
            Container(
              color: Colors.black12,
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                children: workout.sets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(set.exerciseName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    trailing: Text(
                      '${set.weight} kg x ${set.reps}', 
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
