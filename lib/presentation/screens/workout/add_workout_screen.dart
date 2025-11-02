import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../viewmodels/workout_viewmodel.dart';

class AddWorkoutScreen extends ConsumerStatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  ConsumerState<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends ConsumerState<AddWorkoutScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();

  String? _workoutType;
  DateTime _selectedDate = DateTime.now();
  double _intensity = 5.0;

  bool _isSubmitting = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> workoutTypes = [
    'Cardio',
    'Strength Training',
    'Yoga',
    'HIIT',
    'Pilates',
    'Stretching',
    'Cycling',
    'Swimming',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 2));

    ref
        .read(workoutListProvider.notifier)
        .addWorkout(
          _nameController.text.trim(),
          int.parse(_durationController.text.trim()),
          int.parse(_caloriesController.text.trim()),
          _workoutType ?? 'Cardio',
          _selectedDate,
          _intensity,
          _notesController.text.trim(),
        );

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Lottie.asset(
          'assets/animations/success.json',
          repeat: false,
          onLoaded: (composition) async {
            await Future.delayed(composition.duration);
            if (mounted) Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Workout",
          style: GoogleFonts.satisfy(
            textStyle: const TextStyle(fontSize: 24, color: Colors.blueAccent),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Workout Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Workout Name",
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Enter a workout name"
                      : null,
                ),
                const SizedBox(height: 16),

                // Workout Type
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Workout Type",
                    prefixIcon: Icon(Icons.category),
                  ),
                  value: _workoutType,
                  items: workoutTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _workoutType = value),
                  validator: (value) =>
                      value == null ? "Select a workout type" : null,
                ),
                const SizedBox(height: 16),

                // Duration
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Duration (minutes)",
                    prefixIcon: Icon(Icons.timer),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter duration" : null,
                ),
                const SizedBox(height: 16),

                // Calories
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Calories Burned",
                    prefixIcon: Icon(Icons.local_fire_department),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter calories" : null,
                ),
                const SizedBox(height: 16),

                // Date
                ListTile(
                  title: Text(
                    "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                  ),
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.blueAccent,
                  ),
                  trailing: TextButton(
                    onPressed: _pickDate,
                    child: const Text("Change"),
                  ),
                ),
                const SizedBox(height: 16),

                // Intensity
                Text(
                  "Intensity Level: ${_intensity.toStringAsFixed(1)}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: _intensity,
                  onChanged: (value) => setState(() => _intensity = value),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _intensity.toStringAsFixed(1),
                  activeColor: Colors.blueAccent,
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Notes / Description",
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 32),

                Center(
                  child: _isSubmitting
                      ? Lottie.asset(
                          'assets/animations/loading.json',
                          height: 80,
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text("Save Workout"),
                          onPressed: _submitWorkout,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
