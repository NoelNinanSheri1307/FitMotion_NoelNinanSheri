import 'package:hive/hive.dart';

part 'workout_model.g.dart';

@HiveType(typeId: 0)
class WorkoutModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int duration;

  @HiveField(2)
  final int calories;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final double intensity;

  @HiveField(6)
  final String notes;

  WorkoutModel({
    required this.name,
    required this.duration,
    required this.calories,
    required this.type,
    required this.date,
    required this.intensity,
    required this.notes,
  });
}
