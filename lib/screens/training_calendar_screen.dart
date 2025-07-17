import 'package:flutter/material.dart';
import '../theme/ghostroll_theme.dart';
import '../widgets/common/glow_text.dart';
import '../services/calendar_service.dart';
import '../services/profile_service.dart';

class TrainingCalendarScreen extends StatefulWidget {
  const TrainingCalendarScreen({super.key});

  @override
  State<TrainingCalendarScreen> createState() => _TrainingCalendarScreenState();
}

class _TrainingCalendarScreenState extends State<TrainingCalendarScreen> {
  List<Map<String, dynamic>> _schedule = [];
  bool _isLoading = true;
  List<String> _availableClassTypes = [];
  bool _isLoadingClassTypes = true;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
    _loadAvailableClassTypes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh class types when screen becomes visible (in case profile was updated)
    _loadAvailableClassTypes();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final schedule = await CalendarService.loadSchedule();
      setState(() {
        _schedule = schedule;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading schedule: $e');
    }
  }

  Future<void> _loadAvailableClassTypes() async {
    try {
      final selectedStyles = await ProfileService.loadSelectedStyles();
      final classTypes = _convertStylesToClassTypes(selectedStyles);
      setState(() {
        _availableClassTypes = classTypes;
        _isLoadingClassTypes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingClassTypes = false;
      });
      print('Error loading class types: $e');
    }
  }

  List<String> _convertStylesToClassTypes(List<String> selectedStyles) {
    if (selectedStyles.isEmpty) {
      // If no styles are selected, show a default set
      return ['BJJ', 'Muay Thai', 'Boxing', 'Judo', 'Karate'];
    }

    // Mapping from martial arts styles to class types
    final styleToClassTypeMapping = {
      'Brazilian Jiu-Jitsu (BJJ)': 'BJJ',
      'Muay Thai': 'Muay Thai',
      'Boxing': 'Boxing',
      'Wrestling': 'Wrestling',
      'Judo': 'Judo',
      'Karate': 'Karate',
      'Taekwondo': 'Taekwondo',
      'Kickboxing': 'Kickboxing',
      'Krav Maga': 'Krav Maga',
      'Aikido': 'Aikido',
    };

    final classTypes = <String>[];
    for (final style in selectedStyles) {
      final classType = styleToClassTypeMapping[style];
      if (classType != null) {
        classTypes.add(classType);
      }
    }

    // If no valid mappings found, return the original styles
    return classTypes.isNotEmpty ? classTypes : selectedStyles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ghost watermark background
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                'assets/images/GhostRollBeltMascot.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Main content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: GhostRollTheme.primaryGradient,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _availableClassTypes.isEmpty ? _showNoClassTypesDialog : _addClassDialog,
        backgroundColor: _availableClassTypes.isEmpty ? GhostRollTheme.grindRed : GhostRollTheme.flowBlue,
        foregroundColor: GhostRollTheme.text,
        elevation: 12,
        child: Icon(_availableClassTypes.isEmpty ? Icons.warning : Icons.add),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: GhostRollTheme.flowGradient,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: GhostRollTheme.glow,
            ),
            child: Icon(
              Icons.calendar_today,
              color: GhostRollTheme.text,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GlowText(
              text: 'Training Calendar',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              textColor: Colors.white,
              glowColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    
    if (_schedule.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: GhostRollTheme.flowGradient,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: GhostRollTheme.glow,
                ),
                child: Icon(
                  Icons.calendar_today,
                  size: 64,
                  color: GhostRollTheme.text,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No classes scheduled yet',
                style: GhostRollTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the + button to add your first training class',
                style: GhostRollTheme.bodyMedium.copyWith(
                  color: GhostRollTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _schedule.length,
      itemBuilder: (context, index) {
        final entry = _schedule[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: GhostRollTheme.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: GhostRollTheme.medium,
            border: Border.all(
              color: GhostRollTheme.textSecondary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: GhostRollTheme.flowGradient,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: GhostRollTheme.small,
              ),
              child: Icon(
                Icons.sports_martial_arts,
                color: GhostRollTheme.text,
                size: 24,
              ),
            ),
            title: Text(
              '${CalendarService.getDayName(entry['dayOfWeek'])}: ${entry['classType']}',
              style: GhostRollTheme.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  '${CalendarService.formatTime(entry['startTime'])} - ${CalendarService.formatTime(entry['endTime'])}',
                  style: GhostRollTheme.bodyMedium.copyWith(
                    color: GhostRollTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (entry['location'] != null && entry['location'].isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@ ${entry['location']}',
                    style: GhostRollTheme.bodySmall.copyWith(
                      color: GhostRollTheme.textTertiary,
                    ),
                  ),
                ],
                if (entry['notes'] != null && entry['notes'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: GhostRollTheme.overlayDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry['notes'],
                      style: GhostRollTheme.bodySmall.copyWith(
                        color: GhostRollTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: GhostRollTheme.textSecondary,
              ),
              color: GhostRollTheme.card,
              onSelected: (value) {
                if (value == 'edit') {
                  _editClassDialog(entry);
                } else if (value == 'delete') {
                  _deleteEntry(entry['id']);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: GhostRollTheme.flowBlue, size: 20),
                      const SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: GhostRollTheme.text)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: GhostRollTheme.grindRed, size: 20),
                      const SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: GhostRollTheme.text)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteEntry(String entryId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GhostRollTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Class', style: GhostRollTheme.titleLarge),
        content: Text(
          'Are you sure you want to delete this class?',
          style: GhostRollTheme.bodyMedium.copyWith(color: GhostRollTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: GhostRollTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: GhostRollTheme.grindRed,
              foregroundColor: GhostRollTheme.text,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CalendarService.deleteScheduleEntry(entryId);
        setState(() {
          _schedule.removeWhere((entry) => entry['id'] == entryId);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Class deleted successfully'),
              backgroundColor: GhostRollTheme.recoveryGreen.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        print('Error deleting class: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete class. Please try again.'),
              backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  void _showNoClassTypesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: GhostRollTheme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: GhostRollTheme.grindRed,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'No Class Types Available',
                style: GhostRollTheme.titleLarge.copyWith(
                  color: GhostRollTheme.grindRed,
                ),
              ),
            ],
          ),
          content: Text(
            'You need to select martial arts styles in your Profile before you can add training classes.',
            style: GhostRollTheme.bodyMedium.copyWith(
              color: GhostRollTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: GhostRollTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to profile screen
                Navigator.pushNamed(context, '/profile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GhostRollTheme.grindRed,
                foregroundColor: GhostRollTheme.text,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Go to Profile'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addClassDialog() async {
    int dayOfWeek = 1; // Default to Monday (1-based)
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    String? classType = _availableClassTypes.isNotEmpty ? _availableClassTypes[0] : null;
    String? location;
    String? notes;
    String? instructor;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: GhostRollTheme.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Add Class',
                style: GhostRollTheme.headlineSmall,
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        value: dayOfWeek,
                        dropdownColor: GhostRollTheme.card,
                        decoration: InputDecoration(
                          labelText: 'Day',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                          ),
                        ),
                        items: List.generate(7, (i) => DropdownMenuItem(
                          value: i + 1, // 1-based (Monday = 1, Sunday = 7)
                          child: Text(
                            CalendarService.getDayName(i + 1),
                            style: TextStyle(color: GhostRollTheme.text),
                          ),
                        )),
                        onChanged: (v) => dayOfWeek = v ?? 1,
                      ),
                      const SizedBox(height: 16),
                      if (_availableClassTypes.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: GhostRollTheme.grindRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: GhostRollTheme.grindRed.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: GhostRollTheme.grindRed,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Please select martial arts styles in your profile first',
                                  style: GhostRollTheme.bodySmall.copyWith(
                                    color: GhostRollTheme.grindRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: classType,
                          dropdownColor: GhostRollTheme.card,
                          decoration: InputDecoration(
                            labelText: 'Class Type',
                            labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                            ),
                          ),
                          items: _availableClassTypes.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: TextStyle(color: GhostRollTheme.text),
                            ),
                          )).toList(),
                          onChanged: (v) => classType = v,
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: startTime ?? const TimeOfDay(hour: 18, minute: 0),
                                );
                                if (picked != null) {
                                  setDialogState(() => startTime = picked);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: GhostRollTheme.flowBlue,
                                side: BorderSide(color: GhostRollTheme.flowBlue.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                startTime == null ? 'Start Time' : '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(color: GhostRollTheme.text),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: endTime ?? const TimeOfDay(hour: 19, minute: 0),
                                );
                                if (picked != null) {
                                  setDialogState(() => endTime = picked);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: GhostRollTheme.flowBlue,
                                side: BorderSide(color: GhostRollTheme.flowBlue.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                endTime == null ? 'End Time' : '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(color: GhostRollTheme.text),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Instructor (optional)',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                          ),
                          prefixIcon: Icon(Icons.person, color: GhostRollTheme.textSecondary),
                        ),
                        style: TextStyle(color: GhostRollTheme.text),
                        onChanged: (v) => instructor = v,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Location (optional)',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                          ),
                          prefixIcon: Icon(Icons.location_on, color: GhostRollTheme.textSecondary),
                        ),
                        style: TextStyle(color: GhostRollTheme.text),
                        onChanged: (v) => location = v,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Notes (optional)',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                          ),
                          prefixIcon: Icon(Icons.note, color: GhostRollTheme.textSecondary),
                        ),
                        style: TextStyle(color: GhostRollTheme.text),
                        onChanged: (v) => notes = v,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: GhostRollTheme.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_availableClassTypes.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please select martial arts styles in your Profile first'),
                          backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      return;
                    }
                    
                    if (classType != null && startTime != null && endTime != null) {
                      final newEntry = CalendarService.createScheduleEntry(
                        classType: classType!,
                        dayOfWeek: dayOfWeek,
                        startTime: '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                        endTime: '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                        instructor: instructor,
                        location: location,
                        notes: notes,
                      );
                      
                      try {
                        await CalendarService.addScheduleEntry(newEntry);
                        setState(() {
                          _schedule.add(newEntry);
                        });
                        Navigator.pop(context);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Class added successfully'),
                              backgroundColor: GhostRollTheme.recoveryGreen.withOpacity(0.9),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error adding class: $e');
                        // Show error message to user
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Failed to save class. Please try again.'),
                            backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GhostRollTheme.flowBlue,
                    foregroundColor: GhostRollTheme.text,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editClassDialog(Map<String, dynamic> entry) async {
    int dayOfWeek = entry['dayOfWeek'];
    final startTimeParts = entry['startTime'].split(':');
    final endTimeParts = entry['endTime'].split(':');
    TimeOfDay? startTime = TimeOfDay(hour: int.parse(startTimeParts[0]), minute: int.parse(startTimeParts[1]));
    TimeOfDay? endTime = TimeOfDay(hour: int.parse(endTimeParts[0]), minute: int.parse(endTimeParts[1]));
    String? classType = entry['classType'];
    String? instructor = entry['instructor'];
    String? location = entry['location'];
    String? notes = entry['notes'];
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: GhostRollTheme.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Edit Class',
                style: GhostRollTheme.headlineSmall,
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        value: dayOfWeek,
                        dropdownColor: GhostRollTheme.card,
                        decoration: InputDecoration(
                          labelText: 'Day',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                          ),
                        ),
                        items: List.generate(7, (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(
                            CalendarService.getDayName(i + 1),
                            style: TextStyle(color: GhostRollTheme.text),
                          ),
                        )),
                        onChanged: (v) => dayOfWeek = v ?? 1,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: classType,
                        dropdownColor: GhostRollTheme.card,
                        decoration: InputDecoration(
                          labelText: 'Class Type',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                          ),
                        ),
                        items: _availableClassTypes.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: TextStyle(color: GhostRollTheme.text),
                          ),
                        )).toList(),
                        onChanged: (v) => classType = v,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: startTime ?? const TimeOfDay(hour: 18, minute: 0),
                                );
                                if (picked != null) {
                                  setDialogState(() => startTime = picked);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: GhostRollTheme.flowBlue,
                                side: BorderSide(color: GhostRollTheme.flowBlue.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(color: GhostRollTheme.text),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: endTime ?? const TimeOfDay(hour: 19, minute: 0),
                                );
                                if (picked != null) {
                                  setDialogState(() => endTime = picked);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: GhostRollTheme.flowBlue,
                                side: BorderSide(color: GhostRollTheme.flowBlue.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(color: GhostRollTheme.text),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: instructor ?? '',
                        decoration: InputDecoration(
                          labelText: 'Instructor (optional)',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                          ),
                        ),
                        style: TextStyle(color: GhostRollTheme.text),
                        onChanged: (v) => instructor = v,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: location ?? '',
                        decoration: InputDecoration(
                          labelText: 'Location (optional)',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                          ),
                        ),
                        style: TextStyle(color: GhostRollTheme.text),
                        onChanged: (v) => location = v,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: notes ?? '',
                        decoration: InputDecoration(
                          labelText: 'Notes (optional)',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                          ),
                        ),
                        style: TextStyle(color: GhostRollTheme.text),
                        onChanged: (v) => notes = v,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: GhostRollTheme.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (classType != null && startTime != null && endTime != null) {
                      final updatedEntry = CalendarService.createScheduleEntry(
                        classType: classType!,
                        dayOfWeek: dayOfWeek,
                        startTime: '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                        endTime: '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                        instructor: instructor,
                        location: location,
                        notes: notes,
                      );
                      
                      try {
                        await CalendarService.updateScheduleEntry(entry['id'], updatedEntry);
                        final index = _schedule.indexWhere((e) => e['id'] == entry['id']);
                        if (index != -1) {
                          setState(() {
                            _schedule[index] = {...updatedEntry, 'id': entry['id']};
                          });
                        }
                        Navigator.pop(context);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Class updated successfully'),
                              backgroundColor: GhostRollTheme.recoveryGreen.withOpacity(0.9),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error updating class: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Failed to update class. Please try again.'),
                            backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GhostRollTheme.flowBlue,
                    foregroundColor: GhostRollTheme.text,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
} 