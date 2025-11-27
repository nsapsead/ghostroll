import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/ghostroll_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_session_providers.dart';
import '../../models/class_session.dart';
import '../../repositories/class_session_repository.dart';
import 'class_session_detail_screen.dart';

class CreateClassSessionScreen extends ConsumerStatefulWidget {
  final String clubId;

  const CreateClassSessionScreen({super.key, required this.clubId});

  @override
  ConsumerState<CreateClassSessionScreen> createState() => _CreateClassSessionScreenState();
}

class _CreateClassSessionScreenState extends ConsumerState<CreateClassSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _focusAreaController = TextEditingController();
  final _durationController = TextEditingController(text: '60');
  
  String _selectedClassType = 'Gi';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isCreating = false;

  final List<String> _classTypes = ['Gi', 'No-Gi', 'Striking', 'Seminar'];

  @override
  void dispose() {
    _focusAreaController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Combine date and time
      final sessionDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final session = ClassSession(
        id: sessionId,
        clubId: widget.clubId,
        date: sessionDateTime,
        classType: _selectedClassType,
        focusArea: _focusAreaController.text.trim().isNotEmpty 
            ? _focusAreaController.text.trim() 
            : null,
        duration: int.tryParse(_durationController.text) ?? 60,
        createdByUserId: user.uid,
        createdAt: DateTime.now(),
        instructorId: user.uid, // Default to creator as instructor for now
      );

      await ref.read(classSessionRepositoryProvider).createClassSession(session);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class session created!')),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ClassSessionDetailScreen(sessionId: sessionId)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating session: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GhostRollTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('New Class Session', style: GhostRollTheme.textTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: GhostRollTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Class Details', style: GhostRollTheme.textSectionHeader),
              const SizedBox(height: 24),
              
              // Class Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedClassType,
                dropdownColor: GhostRollTheme.surface,
                style: const TextStyle(color: GhostRollTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Class Type',
                  labelStyle: const TextStyle(color: GhostRollTheme.textSecondary),
                  filled: true,
                  fillColor: GhostRollTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _classTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => setState(() => _selectedClassType = val!),
              ),
              const SizedBox(height: 16),

              // Focus Area
              TextFormField(
                controller: _focusAreaController,
                style: const TextStyle(color: GhostRollTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Focus / Topic (Optional)',
                  labelStyle: const TextStyle(color: GhostRollTheme.textSecondary),
                  filled: true,
                  fillColor: GhostRollTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: GhostRollTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: GhostRollTheme.textSecondary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM d, y').format(_selectedDate),
                              style: const TextStyle(color: GhostRollTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: GhostRollTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: GhostRollTheme.textSecondary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(color: GhostRollTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Duration
              TextFormField(
                controller: _durationController,
                style: const TextStyle(color: GhostRollTheme.textPrimary),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Duration (minutes)',
                  labelStyle: const TextStyle(color: GhostRollTheme.textSecondary),
                  filled: true,
                  fillColor: GhostRollTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GhostRollTheme.activeHighlight,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isCreating
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Create Class Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
