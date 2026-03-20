import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exercise_set.dart';
import '../models/workout.dart';
import '../services/api_storage_service.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<ExerciseSet> _sets = [];
  final ApiStorageService _storageService = ApiStorageService();

  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  void _addSet() {
    final exercise = _exerciseController.text.trim();
    final weightStr = _weightController.text.trim();
    final repsStr = _repsController.text.trim();

    if (exercise.isEmpty || weightStr.isEmpty || repsStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos')),
      );
      return;
    }

    final weight = double.tryParse(weightStr);
    final reps = int.tryParse(repsStr);

    if (weight == null || reps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peso y repeticiones deben ser números válidos')),
      );
      return;
    }

    setState(() {
      _sets.add(ExerciseSet(
        exerciseName: exercise,
        weight: weight,
        reps: reps,
      ));
    });

    // We do NOT clear exercise name, as users usually do multiple sets of the same exercise!
    _weightController.clear();
    _repsController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveWorkout() async {
    if (_sets.isEmpty) {
      if (!context.mounted) return;
      Navigator.pop(context);
      return;
    }

    try {
      final workout = Workout(date: _selectedDate, sets: _sets);
      await _storageService.saveWorkout(workout);
      
      if (!mounted) return;
      Navigator.pop(context, true); // Devuelve 'true' para indicar éxito
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error guardando entrenamiento: $e')),
      );
      Navigator.pop(context, false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Entrenamiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveWorkout,
            tooltip: 'Guardar Sesión',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date Selector
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Form to Add Set
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _exerciseController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Ejercicio (ej. Press de Banca)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Peso (kg)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _repsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Repeticiones',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, // Full width button
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _addSet,
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir Serie', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Series de hoy:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            
            // List of Added Sets
            Expanded(
              child: _sets.isEmpty 
               ? Center(
                   child: Text(
                     'No has añadido series aún.', 
                     style: TextStyle(color: Colors.grey[500])
                   )
                 )
               : ListView.builder(
                itemCount: _sets.length,
                itemBuilder: (context, index) {
                  final set = _sets[index];
                  return Card(
                    color: Theme.of(context).colorScheme.surface.withAlpha(128),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(set.exerciseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text('${set.weight} kg x ${set.reps} reps', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
                      ),
                      // Allow removing a set
                      onLongPress: () {
                        setState(() {
                          _sets.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary, // Vibrant accent
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56), // Tall button
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _saveWorkout,
            child: const Text('GUARDAR ENTRENAMIENTO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ),
      ),
    );
  }
}
