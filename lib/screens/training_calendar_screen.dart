import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/class_schedule.dart';

class TrainingCalendarScreen extends StatefulWidget {
  const TrainingCalendarScreen({super.key});

  @override
  State<TrainingCalendarScreen> createState() => _TrainingCalendarScreenState();
}

class _TrainingCalendarScreenState extends State<TrainingCalendarScreen> {
  List<ClassScheduleEntry> _schedule = [];

  // TODO: Replace with actual profile integration
  List<String> get _availableClassTypes => [
    'BJJ',
    'Muay Thai',
    'Judo',
    'Karate',
    'Boxing',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: _schedule.isEmpty
            ? const Center(
                child: Text(
                  'No classes scheduled yet.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: _schedule.length,
                itemBuilder: (context, index) {
                  final entry = _schedule[index];
                  return ListTile(
                    title: Text(
                      '${_weekdayName(entry.dayOfWeek)}: ${entry.classType}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${entry.startTime.format(context)} - ${entry.endTime.format(context)}'
                      '${entry.location != null ? '\n@ ${entry.location}' : ''}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteEntry(index),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClassDialog,
        child: const Icon(Icons.add),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  String _weekdayName(int day) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[day % 7];
  }

  void _deleteEntry(int index) {
    setState(() {
      _schedule.removeAt(index);
    });
  }

  Future<void> _addClassDialog() async {
    int dayOfWeek = 0;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    String? classType = _availableClassTypes.isNotEmpty ? _availableClassTypes[0] : null;
    String? location;
    String? notes;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Class', style: TextStyle(color: Colors.white)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: dayOfWeek,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(labelText: 'Day', labelStyle: TextStyle(color: Colors.white)),
                    items: List.generate(7, (i) => DropdownMenuItem(
                      value: i,
                      child: Text(_weekdayName(i), style: const TextStyle(color: Colors.white)),
                    )),
                    onChanged: (v) => dayOfWeek = v ?? 0,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: classType,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(labelText: 'Class Type', labelStyle: TextStyle(color: Colors.white)),
                    items: _availableClassTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type, style: const TextStyle(color: Colors.white)),
                    )).toList(),
                    onChanged: (v) => classType = v,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: 18, minute: 0),
                            );
                            if (picked != null) {
                              setState(() => startTime = picked);
                            }
                          },
                          child: Text(startTime == null ? 'Start Time' : startTime!.format(context)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: 19, minute: 0),
                            );
                            if (picked != null) {
                              setState(() => endTime = picked);
                            }
                          },
                          child: Text(endTime == null ? 'End Time' : endTime!.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Location (optional)', labelStyle: TextStyle(color: Colors.white)),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) => location = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Notes (optional)', labelStyle: TextStyle(color: Colors.white)),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) => notes = v,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (classType != null && startTime != null && endTime != null) {
                  setState(() {
                    _schedule.add(ClassScheduleEntry(
                      dayOfWeek: dayOfWeek,
                      startTime: startTime!,
                      endTime: endTime!,
                      classType: classType!,
                      location: location,
                      notes: notes,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
} 