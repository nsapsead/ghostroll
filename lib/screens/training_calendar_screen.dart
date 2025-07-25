import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/ghostroll_theme.dart';
import '../theme/app_theme.dart';
import '../widgets/common/glow_text.dart';
import '../widgets/calendar/weekly_calendar_view.dart';
import '../widgets/calendar/monthly_calendar_view.dart';
import '../services/calendar_service.dart';
import '../services/profile_service.dart';
import '../services/instructor_service.dart';
import '../services/session_service.dart';

enum CalendarViewType { weekly, monthly }

class TrainingCalendarScreen extends StatefulWidget {
  const TrainingCalendarScreen({super.key});

  @override
  State<TrainingCalendarScreen> createState() => _TrainingCalendarScreenState();
}

class _TrainingCalendarScreenState extends State<TrainingCalendarScreen> {
  CalendarViewType _currentView = CalendarViewType.monthly;
  DateTime _selectedDate = DateTime.now();
  List<String> _availableClassTypes = [];
  bool _isLoadingClassTypes = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableClassTypes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAvailableClassTypes();
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
      return ['BJJ', 'Muay Thai', 'Boxing', 'Judo', 'Karate'];
    }

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

    return classTypes.isNotEmpty ? classTypes : selectedStyles;
  }

  // Convert class type back to full style name for instructor lookup
  String _convertClassTypeToStyleName(String classType) {
    final classTypeToStyleMapping = {
      'BJJ': 'Brazilian Jiu-Jitsu (BJJ)',
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

    return classTypeToStyleMapping[classType] ?? classType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: GhostRollTheme.primaryGradient,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          
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
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildViewControls(),
                _buildDateNavigation(),
                Expanded(
                  child: _buildCalendarView(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: GhostRollTheme.medium,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: GlowText(
                    text: 'GhostRoll',
                    fontSize: 20,
                    textColor: Colors.white,
                    glowColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
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
        ],
      ),
    );
  }

  Widget _buildViewControls() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.responsiveHorizontal(screenWidth), 
        vertical: 8
      ),
      padding: EdgeInsets.all(isSmallScreen ? 3 : 4),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GhostRollTheme.medium,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildViewButton(
              'Week',
              Icons.view_week,
              CalendarViewType.weekly,
            ),
          ),
          SizedBox(width: isSmallScreen ? 3 : 4),
          Expanded(
            child: _buildViewButton(
              'Month',
              Icons.calendar_view_month,
              CalendarViewType.monthly,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(String label, IconData icon, CalendarViewType viewType) {
    final isSelected = _currentView == viewType;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentView = viewType;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? GhostRollTheme.flowBlue
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? GhostRollTheme.small : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Colors.white 
                  : GhostRollTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GhostRollTheme.titleMedium.copyWith(
                color: isSelected 
                    ? Colors.white 
                    : GhostRollTheme.textSecondary,
                fontWeight: isSelected 
                    ? FontWeight.bold 
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GhostRollTheme.medium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _navigatePrevious,
            icon: Icon(
              Icons.chevron_left,
              color: GhostRollTheme.text,
              size: 28,
            ),
          ),
          GestureDetector(
            onTap: _showDatePicker,
            child: Text(
              _getDateRangeText(),
              style: GhostRollTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _navigateNext,
            icon: Icon(
              Icons.chevron_right,
              color: GhostRollTheme.text,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: _currentView == CalendarViewType.weekly
          ? WeeklyCalendarView(
              weekStart: CalendarService.getWeekStart(_selectedDate),
              onEventTap: _onEventTap,
              onEmptySlotTap: _onEmptySlotTap,
            )
          : MonthlyCalendarView(
              month: CalendarService.getMonthStart(_selectedDate),
              onEventTap: _onEventTap,
              onDayTap: _onDayTap,
            ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _availableClassTypes.isEmpty ? _showNoClassTypesDialog : _showAddEventMenu,
      backgroundColor: _availableClassTypes.isEmpty ? GhostRollTheme.grindRed : GhostRollTheme.flowBlue,
      foregroundColor: GhostRollTheme.text,
      elevation: 12,
      icon: Icon(_availableClassTypes.isEmpty ? Icons.warning : Icons.add),
      label: Text(
        _availableClassTypes.isEmpty ? 'Setup Required' : 'Add Event',
        style: GhostRollTheme.labelLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getDateRangeText() {
    if (_currentView == CalendarViewType.weekly) {
      final weekStart = CalendarService.getWeekStart(_selectedDate);
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      if (weekStart.month == weekEnd.month) {
        return '${_getMonthName(weekStart.month)} ${weekStart.day}-${weekEnd.day}, ${weekStart.year}';
      } else {
        return '${_getShortMonthName(weekStart.month)} ${weekStart.day} - ${_getShortMonthName(weekEnd.month)} ${weekEnd.day}, ${weekStart.year}';
      }
    } else {
      return '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  String _getShortMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  void _navigatePrevious() {
    setState(() {
      if (_currentView == CalendarViewType.weekly) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _navigateNext() {
    setState(() {
      if (_currentView == CalendarViewType.weekly) {
        _selectedDate = _selectedDate.add(const Duration(days: 7));
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _onEventTap(CalendarEvent event) {
    _showEventDetailsDialog(event);
  }

  void _onEmptySlotTap(DateTime date, TimeOfDay time) {
    _showAddDropInEventDialog(date, time);
  }

  void _onDayTap(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentView = CalendarViewType.weekly;
    });
  }

  void _showAddEventMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: GhostRollTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: GhostRollTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Training Event',
              style: GhostRollTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuOption(
              'Recurring Class',
              'Weekly training sessions',
              Icons.repeat,
              GhostRollTheme.flowBlue,
              () {
                Navigator.pop(context);
                _showAddRecurringClassDialog();
              },
            ),
            const SizedBox(height: 16),
            _buildMenuOption(
              'Drop-in Event',
              'One-time training session',
              Icons.event,
              GhostRollTheme.grindRed,
              () {
                Navigator.pop(context);
                _showAddDropInEventDialog(DateTime.now(), const TimeOfDay(hour: 18, minute: 0));
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GhostRollTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GhostRollTheme.bodyMedium.copyWith(
                      color: GhostRollTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
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
                'Setup Required',
                style: GhostRollTheme.titleLarge.copyWith(
                  color: GhostRollTheme.grindRed,
                ),
              ),
            ],
          ),
          content: Text(
            'You need to select martial arts styles in your Profile before you can add training events.',
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

  void _showAddRecurringClassDialog() async {
    int dayOfWeek = DateTime.now().weekday;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    DateTime recurringStartDate = DateTime.now();
    String? classType = _availableClassTypes.isNotEmpty ? _availableClassTypes[0] : null;
    String? location;
    String? notes;
    String? instructor;
    List<String> availableInstructors = [];
    final formKey = GlobalKey<FormState>();
    
    // If no class types available, show error and return
    if (_availableClassTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No martial arts styles selected in profile. Please add styles in your profile first.'),
          backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    
    // Load instructors for initial class type
    if (classType != null) {
      final styleName = _convertClassTypeToStyleName(classType);
      availableInstructors = await InstructorService.getInstructorNamesForStyle(styleName);
      instructor = availableInstructors.isNotEmpty ? availableInstructors.first : null;
    }

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
                'Add Recurring Class',
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
                          labelText: 'Day of Week',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
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
                        onChanged: (v) => setDialogState(() {
                          dayOfWeek = v ?? 1;
                        }),
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
                        onChanged: (v) async {
                          classType = v;
                          if (v != null) {
                            // Load instructors for the new class type
                            final styleName = _convertClassTypeToStyleName(v);
                            availableInstructors = await InstructorService.getInstructorNamesForStyle(styleName);
                            instructor = availableInstructors.isNotEmpty ? availableInstructors.first : null;
                          } else {
                            availableInstructors = [];
                            instructor = null;
                          }
                          setDialogState(() {});
                        },
                      ),
                      const SizedBox(height: 16),
                      // Start date picker
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: recurringStartDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              recurringStartDate = picked;
                              // Update day of week to match the selected start date
                              dayOfWeek = picked.weekday;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: GhostRollTheme.textSecondary),
                              const SizedBox(width: 8),
                              Text(
                                'Start Date: ${recurringStartDate.day}/${recurringStartDate.month}/${recurringStartDate.year}',
                                style: TextStyle(color: GhostRollTheme.text),
                              ),
                            ],
                          ),
                        ),
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
                      // Instructor selection - dropdown if instructors available, text field otherwise
                      availableInstructors.isNotEmpty
                          ? DropdownButtonFormField<String>(
                              value: instructor,
                              dropdownColor: GhostRollTheme.card,
                              decoration: InputDecoration(
                                labelText: 'Instructor',
                                labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                                ),
                              ),
                              items: [
                                ...availableInstructors.map((name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(name, style: TextStyle(color: GhostRollTheme.text)),
                                )),
                                DropdownMenuItem(
                                  value: 'custom',
                                  child: Text('Other...', style: TextStyle(color: GhostRollTheme.textSecondary)),
                                ),
                              ],
                              onChanged: (v) => setDialogState(() {
                                instructor = v == 'custom' ? '' : v;
                              }),
                            )
                          : TextFormField(
                              initialValue: instructor,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: 'Instructor (optional)',
                                labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                                ),
                              ),
                              style: TextStyle(color: GhostRollTheme.text),
                              onChanged: (v) => instructor = v,
                            ),
                      // Custom instructor field when "Other..." is selected
                      if (availableInstructors.isNotEmpty && instructor == '') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            labelText: 'Custom Instructor Name',
                            labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: GhostRollTheme.flowBlue),
                            ),
                          ),
                          style: TextStyle(color: GhostRollTheme.text),
                          onChanged: (v) => instructor = v,
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: location,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: 'Location (optional)',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                        initialValue: notes,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: 'Notes (optional)',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                  child: Text('Cancel', style: TextStyle(color: GhostRollTheme.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Validate required fields
                    if (classType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please select a class type'),
                          backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }
                    
                    if (startTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please select a start time'),
                          backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }
                    
                    if (endTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please select an end time'),
                          backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }
                    
                    // Validate that end time is after start time
                    final startMinutes = startTime!.hour * 60 + startTime!.minute;
                    final endMinutes = endTime!.hour * 60 + endTime!.minute;
                    
                    if (endMinutes <= startMinutes) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('End time must be after start time'),
                          backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }

                    final newEvent = CalendarService.createRecurringClass(
                      classType: classType!,
                      dayOfWeek: dayOfWeek,
                      startTime: '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                      endTime: '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                      recurringStartDate: recurringStartDate,
                      instructor: instructor,
                      location: location,
                      notes: notes,
                    );
                    
                    try {
                      await CalendarService.addEvent(newEvent);
                      Navigator.pop(context);
                      setState(() {}); // Refresh the calendar
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Recurring class added successfully'),
                            backgroundColor: GhostRollTheme.recoveryGreen.withOpacity(0.9),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    } catch (e) {
                      print('Error adding recurring class: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to save class: $e'),
                            backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GhostRollTheme.flowBlue,
                    foregroundColor: GhostRollTheme.text,
                  ),
                  child: const Text('Add Class'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddDropInEventDialog(DateTime date, TimeOfDay time) async {
    String title = '';
    String? classType = _availableClassTypes.isNotEmpty ? _availableClassTypes[0] : null;
    DateTime selectedDate = date;
    TimeOfDay? startTime = time;
    TimeOfDay? endTime = TimeOfDay(hour: time.hour + 1, minute: time.minute);
    String? location;
    String? notes;
    String? instructor;
    final formKey = GlobalKey<FormState>();
    
    // Text controllers for better text input handling
    final titleController = TextEditingController();
    final instructorController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();

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
                'Add Drop-in Event',
                style: GhostRollTheme.headlineSmall,
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: 'Event Title',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.grindRed),
                          ),
                        ),
                        style: TextStyle(color: GhostRollTheme.text),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an event title';
                          }
                          return null;
                        },
                        onChanged: (v) => title = v,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: classType,
                        dropdownColor: GhostRollTheme.card,
                        decoration: InputDecoration(
                          labelText: 'Class Type',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.grindRed),
                          ),
                        ),
                        items: _availableClassTypes.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type, style: TextStyle(color: GhostRollTheme.text)),
                        )).toList(),
                        onChanged: (v) => setDialogState(() {
                          classType = v;
                        }),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: GhostRollTheme.overlayDark,
                            border: Border.all(color: GhostRollTheme.flowBlue.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: GhostRollTheme.flowBlue, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Session Date:',
                                style: GhostRollTheme.bodySmall.copyWith(color: GhostRollTheme.textSecondary),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatSessionDate(selectedDate),
                                style: GhostRollTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: GhostRollTheme.text,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
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
                                foregroundColor: GhostRollTheme.grindRed,
                                side: BorderSide(color: GhostRollTheme.grindRed.withOpacity(0.5)),
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
                                foregroundColor: GhostRollTheme.grindRed,
                                side: BorderSide(color: GhostRollTheme.grindRed.withOpacity(0.5)),
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
                        controller: instructorController,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: 'Instructor (optional)',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.grindRed),
                          ),
                        ),
                        style: TextStyle(color: GhostRollTheme.text),
                        onChanged: (v) => instructor = v,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: locationController,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: 'Location (optional)',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.grindRed),
                          ),
                        ),
                        style: TextStyle(color: GhostRollTheme.text),
                        onChanged: (v) => location = v,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: notesController,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: 'Notes (optional)',
                          labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: GhostRollTheme.grindRed),
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
                  child: Text('Cancel', style: TextStyle(color: GhostRollTheme.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate() && classType != null && startTime != null && endTime != null) {
                      final newEvent = CalendarService.createDropInEvent(
                        title: titleController.text,
                        classType: classType!,
                        date: selectedDate,
                        startTime: '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                        endTime: '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                        instructor: instructorController.text.isNotEmpty ? instructorController.text : null,
                        location: locationController.text.isNotEmpty ? locationController.text : null,
                        notes: notesController.text.isNotEmpty ? notesController.text : null,
                      );
                      
                      try {
                        await CalendarService.addEvent(newEvent);
                        Navigator.pop(context);
                        setState(() {}); // Refresh the calendar
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Drop-in event added successfully'),
                              backgroundColor: GhostRollTheme.recoveryGreen.withOpacity(0.9),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Failed to save event. Please try again.'),
                            backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GhostRollTheme.grindRed,
                    foregroundColor: GhostRollTheme.text,
                  ),
                  child: const Text('Add Event'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Dispose controllers when dialog is closed
      titleController.dispose();
      instructorController.dispose();
      locationController.dispose();
      notesController.dispose();
    });
  }

  String _formatSessionDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  void _showEventDetailsDialog(CalendarEvent event) {
    final bool isRecurring = event.type == CalendarEventType.recurringClass;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: GhostRollTheme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isRecurring ? GhostRollTheme.flowBlue : GhostRollTheme.grindRed,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.title,
                  style: GhostRollTheme.headlineSmall,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventDetailRow('Type', isRecurring ? 'Recurring Class' : 'Drop-in Event'),
              _buildEventDetailRow('Class', event.classType),
              _buildEventDetailRow('Time', CalendarService.formatTimeRange(event.startTime, event.endTime)),
              if (isRecurring) ...[
                _buildEventDetailRow('Day', CalendarService.getDayName(event.dayOfWeek!)),
                if (event.recurringStartDate != null)
                  _buildEventDetailRow('Starts', '${event.recurringStartDate!.day}/${event.recurringStartDate!.month}/${event.recurringStartDate!.year}'),
                if (event.recurringEndDate != null)
                  _buildEventDetailRow('Ends', '${event.recurringEndDate!.day}/${event.recurringEndDate!.month}/${event.recurringEndDate!.year}'),
              ] else ...[
                _buildEventDetailRow('Date', '${event.specificDate!.day}/${event.specificDate!.month}/${event.specificDate!.year}'),
              ],
              if (event.instructor?.isNotEmpty == true)
                _buildEventDetailRow('Instructor', event.instructor!),
              if (event.location?.isNotEmpty == true)
                _buildEventDetailRow('Location', event.location!),
              if (event.notes?.isNotEmpty == true)
                _buildEventDetailRow('Notes', event.notes!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: GhostRollTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _logAttendanceFromEvent(event);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GhostRollTheme.recoveryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Attendance'),
            ),
            if (isRecurring) ...[
              PopupMenuButton<String>(
                color: GhostRollTheme.card,
                onSelected: (value) async {
                  Navigator.pop(context);
                  if (value == 'delete_instance') {
                    await _deleteRecurringEventInstance(event);
                  } else if (value == 'delete_from_date') {
                    await _deleteRecurringEventFromDate(event);
                  } else if (value == 'delete_all') {
                    await _deleteEvent(event);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete_instance',
                    child: Row(
                      children: [
                        Icon(Icons.event_busy, color: GhostRollTheme.grindRed, size: 16),
                        const SizedBox(width: 8),
                        Text('Delete This Instance', style: TextStyle(color: GhostRollTheme.text)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete_from_date',
                    child: Row(
                      children: [
                        Icon(Icons.event_repeat, color: GhostRollTheme.grindRed, size: 16),
                        const SizedBox(width: 8),
                        Text('Delete From Date...', style: TextStyle(color: GhostRollTheme.text)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, color: GhostRollTheme.grindRed, size: 16),
                        const SizedBox(width: 8),
                        Text('Delete All', style: TextStyle(color: GhostRollTheme.text)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: GhostRollTheme.grindRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text('Delete', style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteEvent(event);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GhostRollTheme.grindRed,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEventDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GhostRollTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(CalendarEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GhostRollTheme.card,
        title: Text('Delete Event', style: GhostRollTheme.headlineSmall),
        content: Text(
          'Are you sure you want to delete "${event.title}"?',
          style: GhostRollTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: GhostRollTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: GhostRollTheme.grindRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CalendarService.deleteEvent(event.id);
        setState(() {}); // Refresh calendar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Event deleted successfully'),
              backgroundColor: GhostRollTheme.recoveryGreen.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting event: $e'),
              backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteRecurringEventInstance(CalendarEvent event) async {
    // Show date picker to select which instance to delete
    final dateToDelete = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: event.recurringStartDate ?? event.createdAt,
      lastDate: event.recurringEndDate ?? DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select date to delete',
    );

    if (dateToDelete != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: GhostRollTheme.card,
          title: Text('Delete Instance', style: GhostRollTheme.headlineSmall),
          content: Text(
            'Delete the ${event.title} class on ${dateToDelete.day}/${dateToDelete.month}/${dateToDelete.year}?',
            style: GhostRollTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: GhostRollTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: GhostRollTheme.grindRed),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          await CalendarService.deleteRecurringEventInstance(event.id, dateToDelete);
          setState(() {}); // Refresh calendar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Event instance deleted successfully'),
                backgroundColor: GhostRollTheme.recoveryGreen.withOpacity(0.9),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting instance: $e'),
                backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _deleteRecurringEventFromDate(CalendarEvent event) async {
    // Show date picker to select from which date to delete
    final fromDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: event.recurringStartDate ?? event.createdAt,
      lastDate: event.recurringEndDate ?? DateTime.now().add(const Duration(days: 365)),
      helpText: 'Delete from this date forward',
    );

    if (fromDate != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: GhostRollTheme.card,
          title: Text('Delete From Date', style: GhostRollTheme.headlineSmall),
          content: Text(
            'Delete all ${event.title} classes from ${fromDate.day}/${fromDate.month}/${fromDate.year} forward?',
            style: GhostRollTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: GhostRollTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: GhostRollTheme.grindRed),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          await CalendarService.deleteRecurringEventFromDate(event.id, fromDate);
          setState(() {}); // Refresh calendar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Future events deleted successfully'),
                backgroundColor: GhostRollTheme.recoveryGreen.withOpacity(0.9),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting future events: $e'),
                backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _logAttendanceFromEvent(CalendarEvent event) async {
    try {
      // Determine the date for the session
      DateTime sessionDate;
      if (event.type == CalendarEventType.dropInEvent && event.specificDate != null) {
        sessionDate = event.specificDate!;
      } else {
        // For recurring events, use today's date
        sessionDate = DateTime.now();
      }

      // Create session from calendar event
      final session = SessionService.createSessionFromCalendarEvent(
        eventTitle: event.title,
        classType: event.classType,
        date: sessionDate,
        startTime: event.startTime,
        endTime: event.endTime,
        instructor: event.instructor,
        location: event.location,
        notes: event.notes,
      );

      // Add session to journal
      await SessionService.addSession(session);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Attendance logged to journal successfully!'),
            backgroundColor: GhostRollTheme.recoveryGreen.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'View Journal',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to journal tab
                Navigator.pushReplacementNamed(context, '/journal-timeline');
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error logging attendance: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log attendance: $e'),
            backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
} 