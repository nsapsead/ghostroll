import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../models/session.dart';
import '../theme/ghostroll_theme.dart';
import '../services/calendar_service.dart';
import '../services/profile_service.dart';
import '../services/session_service.dart';
import '../widgets/common/glow_text.dart';

class LogSessionForm extends StatefulWidget {
  const LogSessionForm({super.key});

  @override
  State<LogSessionForm> createState() => _LogSessionFormState();
}

class _LogSessionFormState extends State<LogSessionForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _customClassTypeController = TextEditingController();
  final _customLocationController = TextEditingController();
  
  // Session type selection
  bool _isScheduledClass = true; // true for scheduled, false for drop-in
  Map<String, dynamic>? _selectedScheduledClass;
  List<Map<String, dynamic>> _upcomingClasses = [];
  bool _isLoadingClasses = true;
  
  // Drop-in class details
  String _dropInClassType = 'BJJ';
  String _dropInLocation = '';
  DateTime _sessionDate = DateTime.now();
  TimeOfDay _sessionTime = TimeOfDay.now();
  
  // Session details
  String _selectedFocusArea = '';
  List<String> _techniquesLearned = [''];
  String? _selectedMood;
  String _instructor = '';
  
  // Self Reflection fields
  String? _preClassMood;
  final TextEditingController _winsController = TextEditingController();
  final TextEditingController _stuckController = TextEditingController();
  final TextEditingController _questionsController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  
  final List<Map<String, String>> _preClassMoods = [
    {'emoji': '😟', 'label': 'Anxious'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '😊', 'label': 'Excited'},
    {'emoji': '💪', 'label': 'Pumped'},
    {'emoji': '😴', 'label': 'Tired'},
  ];
  
  final List<Map<String, String>> _comfortLevels = [
    {'emoji': '😰', 'label': 'Completely\nLost'},
    {'emoji': '🤔', 'label': 'Getting\nthe Idea'},
    {'emoji': '😊', 'label': 'Pretty\nComfortable'},
    {'emoji': '😎', 'label': 'Very\nConfident'},
  ];
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
    _loadUpcomingClasses();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _notesController.dispose();
    _customClassTypeController.dispose();
    _customLocationController.dispose();
    _winsController.dispose();
    _stuckController.dispose();
    _questionsController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  Future<void> _loadUpcomingClasses() async {
    try {
      final selectedStyles = await ProfileService.loadSelectedStyles();
      final upcomingClasses = await CalendarService.getUpcomingClasses();
      
      // Filter classes based on selected martial arts styles
      final filteredClasses = upcomingClasses.where((c) => 
        _matchesSelectedStyle(c['classType'], selectedStyles)).toList();
      
      setState(() {
        _upcomingClasses = filteredClasses.take(10).toList(); // Show next 10 classes
        _isLoadingClasses = false;
        
        // Auto-select first upcoming class if available
        if (_upcomingClasses.isNotEmpty) {
          _selectedScheduledClass = _upcomingClasses.first;
          _instructor = _selectedScheduledClass!['instructor'] ?? '';
          _instructorController.text = _instructor;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingClasses = false;
      });
    }
  }

  bool _matchesSelectedStyle(String classType, List<String> selectedStyles) {
    if (selectedStyles.isEmpty) return true;
    
    final classTypeToStyleMapping = {
      'BJJ': 'Brazilian Jiu-Jitsu (BJJ)',
      'Brazilian Jiu-Jitsu': 'Brazilian Jiu-Jitsu (BJJ)',
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
    
    final matchingStyle = classTypeToStyleMapping[classType];
    return matchingStyle != null && selectedStyles.contains(matchingStyle);
  }

  void _addTechnique() {
    setState(() {
      _techniquesLearned.add('');
    });
    HapticFeedback.lightImpact();
  }

  void _removeTechnique(int index) {
    if (_techniquesLearned.length > 1) {
      setState(() {
        _techniquesLearned.removeAt(index);
      });
      HapticFeedback.lightImpact();
    }
  }

  void _updateTechnique(int index, String value) {
    setState(() {
      _techniquesLearned[index] = value;
    });
  }

  void _onMoodTap(String mood) {
    setState(() => _selectedMood = mood);
    HapticFeedback.lightImpact();
  }

  ClassType _getClassTypeFromString(String classType) {
    switch (classType.toLowerCase()) {
      case 'bjj':
      case 'brazilian jiu-jitsu':
        return ClassType.gi;
      case 'muay thai':
      case 'boxing':
      case 'kickboxing':
        return ClassType.striking;
      case 'wrestling':
      case 'judo':
        return ClassType.noGi;
      case 'seminar':
        return ClassType.seminar;
      default:
        return ClassType.gi;
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      
      String classType;
      String location = '';
      
      if (_isScheduledClass && _selectedScheduledClass != null) {
        classType = _selectedScheduledClass!['classType'];
        location = _selectedScheduledClass!['location'] ?? '';
      } else {
        classType = _dropInClassType;
        location = _dropInLocation;
      }
      
      final session = Session(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _isScheduledClass 
            ? (DateTime.tryParse(_selectedScheduledClass?['dateTime'] ?? '') ?? DateTime.now())
            : DateTime(_sessionDate.year, _sessionDate.month, _sessionDate.day, _sessionTime.hour, _sessionTime.minute),
        classType: _getClassTypeFromString(classType),
        focusArea: _selectedFocusArea,
        rounds: 1, // Default to 1 for now
        techniquesLearned: _techniquesLearned.where((t) => t.isNotEmpty).toList(),
        sparringNotes: _notesController.text.isNotEmpty ? _notesController.text : null,
        reflection: null,
        mood: _selectedMood,
        location: location,
        instructor: _instructorController.text.isNotEmpty ? _instructorController.text : null,
        duration: 60, // Default to 60 for now
        isScheduledClass: _isScheduledClass,
      );

      try {
        // Save session to journal
        await SessionService.addSession(session);
        
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Session logged successfully!'),
              backgroundColor: GhostRollTheme.recoveryGreen.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          
          Navigator.pop(context, session);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save session: $e'),
              backgroundColor: GhostRollTheme.grindRed.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  String _formatSessionDate(DateTime date) {
    // Example: 25 Jul 2025
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GhostRollTheme.background,
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
              opacity: 0.02,
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
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width < 375 ? 16 : 24,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              _buildClassTypeSelector(),
                              const SizedBox(height: 24),
                              if (_isScheduledClass) _buildScheduledClassSection(),
                              if (!_isScheduledClass) _buildDropInClassSection(),
                              const SizedBox(height: 24),
                              _buildSessionDetailsSection(),
                              const SizedBox(height: 24),
                              _buildSelfReflectionSection(),
                              const SizedBox(height: 24),
                              _buildSaveButton(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Train. Reflect. Repeat.',
          style: GhostRollTheme.headlineLarge.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track your training progress and insights',
          style: GhostRollTheme.titleMedium.copyWith(
            color: GhostRollTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildClassTypeSelector() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: GhostRollTheme.medium,
        border: Border.all(
          color: GhostRollTheme.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isScheduledClass = true;
                });
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 16, 
                  horizontal: isSmallScreen ? 8 : 20
                ),
                decoration: BoxDecoration(
                  color: _isScheduledClass 
                      ? GhostRollTheme.flowBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isScheduledClass ? GhostRollTheme.small : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      color: _isScheduledClass 
                          ? Colors.white 
                          : GhostRollTheme.textSecondary,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isSmallScreen ? 'Scheduled' : 'Scheduled Class',
                          style: GhostRollTheme.titleMedium.copyWith(
                            color: _isScheduledClass 
                                ? Colors.white 
                                : GhostRollTheme.textSecondary,
                            fontWeight: _isScheduledClass 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 4 : 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isScheduledClass = false;
                });
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 16, 
                  horizontal: isSmallScreen ? 8 : 20
                ),
                decoration: BoxDecoration(
                  color: !_isScheduledClass 
                      ? GhostRollTheme.grindRed
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: !_isScheduledClass ? GhostRollTheme.small : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: !_isScheduledClass 
                          ? Colors.white 
                          : GhostRollTheme.textSecondary,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isSmallScreen ? 'Drop-in' : 'Drop-in Class',
                          style: GhostRollTheme.titleMedium.copyWith(
                            color: !_isScheduledClass 
                                ? Colors.white 
                                : GhostRollTheme.textSecondary,
                            fontWeight: !_isScheduledClass 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledClassSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: GhostRollTheme.medium,
        border: Border.all(
          color: GhostRollTheme.flowBlue.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GhostRollTheme.flowBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event,
                  color: GhostRollTheme.flowBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Scheduled Class',
                style: GhostRollTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoadingClasses)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_upcomingClasses.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GhostRollTheme.overlayDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    color: GhostRollTheme.textSecondary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No upcoming classes found',
                    style: GhostRollTheme.titleMedium.copyWith(
                      color: GhostRollTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add classes to your calendar or log a drop-in session',
                    style: GhostRollTheme.bodySmall.copyWith(
                      color: GhostRollTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: _upcomingClasses.map((classEntry) {
                final isSelected = _selectedScheduledClass == classEntry;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedScheduledClass = classEntry;
                      _instructor = classEntry['instructor'] ?? '';
                      _instructorController.text = _instructor;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? GhostRollTheme.flowBlue.withOpacity(0.1)
                          : GhostRollTheme.overlayDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? GhostRollTheme.flowBlue
                            : GhostRollTheme.textSecondary.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? GhostRollTheme.flowBlue
                                : GhostRollTheme.textSecondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.sports_martial_arts,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classEntry['classType'],
                                style: GhostRollTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected 
                                      ? GhostRollTheme.flowBlue
                                      : GhostRollTheme.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: GhostRollTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${CalendarService.getDayName(classEntry['dayOfWeek'])} @ ${CalendarService.formatTime(classEntry['startTime'])}',
                                    style: GhostRollTheme.bodySmall.copyWith(
                                      color: GhostRollTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              if (classEntry['location'] != null && classEntry['location'].isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: GhostRollTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      classEntry['location'],
                                      style: GhostRollTheme.bodySmall.copyWith(
                                        color: GhostRollTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (classEntry['instructor'] != null && classEntry['instructor'].isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 14,
                                      color: GhostRollTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      classEntry['instructor'],
                                      style: GhostRollTheme.bodySmall.copyWith(
                                        color: GhostRollTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: GhostRollTheme.flowBlue,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDropInClassSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: GhostRollTheme.medium,
        border: Border.all(
          color: GhostRollTheme.grindRed.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GhostRollTheme.grindRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on,
                  color: GhostRollTheme.grindRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Drop-in Class Details',
                style: GhostRollTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _dropInClassType,
            decoration: const InputDecoration(
              labelText: 'Class Type',
              prefixIcon: Icon(Icons.sports_martial_arts, color: GhostRollTheme.textSecondary),
            ),
            items: [
              'BJJ', 'Muay Thai', 'Boxing', 'Wrestling', 'Judo', 
              'Karate', 'Taekwondo', 'Kickboxing', 'Krav Maga', 'Aikido', 'Seminar'
            ].map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _dropInClassType = value!;
                _selectedFocusArea = value; // Set focus area to the selected class type
              });
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Location (e.g., Gym Name, Address)',
              prefixIcon: Icon(Icons.location_on, color: GhostRollTheme.textSecondary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a location';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _dropInLocation = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _sessionDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null && picked != _sessionDate) {
                      setState(() {
                        _sessionDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GhostRollTheme.overlayDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GhostRollTheme.textSecondary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: GhostRollTheme.flowBlue,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Session Date',
                                style: GhostRollTheme.bodySmall.copyWith(
                                  color: GhostRollTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatSessionDate(_sessionDate),
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
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: _sessionTime,
                    );
                    if (picked != null && picked != _sessionTime) {
                      setState(() {
                        _sessionTime = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GhostRollTheme.overlayDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GhostRollTheme.textSecondary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: GhostRollTheme.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time',
                                style: GhostRollTheme.bodySmall.copyWith(
                                  color: GhostRollTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _sessionTime.format(context),
                                style: GhostRollTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetailsSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: GhostRollTheme.medium,
        border: Border.all(
          color: GhostRollTheme.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: GhostRollTheme.flowBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Session Overview',
                style: GhostRollTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Seed Idea / Main Concept',
              hintText: 'What was the core concept or theme? (e.g., "Hip movement from guard", "Timing on takedowns")',
              labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GhostRollTheme.flowBlue, width: 2),
              ),
              prefixIcon: Icon(Icons.psychology, color: GhostRollTheme.textSecondary),
              filled: true,
              fillColor: GhostRollTheme.overlayDark.withOpacity(0.3),
            ),
            style: TextStyle(color: GhostRollTheme.text),
            maxLines: 2,
            onChanged: (value) {
              setState(() {
                _selectedFocusArea = value;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please describe the main concept or focus';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _instructorController,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: 'Instructor (if applicable)',
              labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GhostRollTheme.flowBlue, width: 2),
              ),
              prefixIcon: Icon(Icons.person, color: GhostRollTheme.textSecondary),
              filled: true,
              fillColor: GhostRollTheme.overlayDark.withOpacity(0.3),
            ),
            style: TextStyle(color: GhostRollTheme.text),
            onChanged: (value) {
              setState(() {
                _instructor = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.school,
                color: GhostRollTheme.grindRed,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Techniques Learned',
                style: GhostRollTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._techniquesLearned.asMap().entries.map((entry) {
            final index = entry.key;
            final technique = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: technique,
                      decoration: InputDecoration(
                        labelText: 'Technique ${index + 1}',
                        labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: GhostRollTheme.flowBlue, width: 2),
                        ),
                        prefixIcon: Icon(Icons.sports_martial_arts, color: GhostRollTheme.textSecondary),
                        filled: true,
                        fillColor: GhostRollTheme.overlayDark.withOpacity(0.3),
                      ),
                      style: TextStyle(color: GhostRollTheme.text),
                      onChanged: (value) => _updateTechnique(index, value),
                    ),
                  ),
                  if (_techniquesLearned.length > 1) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeTechnique(index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GhostRollTheme.grindRed.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.remove,
                          color: GhostRollTheme.grindRed,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addTechnique,
              icon: const Icon(Icons.add),
              label: const Text('Add Technique'),
              style: OutlinedButton.styleFrom(
                foregroundColor: GhostRollTheme.flowBlue,
                side: BorderSide(color: GhostRollTheme.flowBlue.withOpacity(0.5)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: GhostRollTheme.flowBlue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'What was my key takeaway?',
                style: GhostRollTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Key insights, "aha" moments, or important realizations',
              hintText: 'What clicked for you today? What will you remember most?',
              alignLabelWithHint: true,
              labelStyle: TextStyle(color: GhostRollTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GhostRollTheme.flowBlue, width: 2),
              ),
              prefixIcon: Icon(Icons.insights, color: GhostRollTheme.textSecondary),
              filled: true,
              fillColor: GhostRollTheme.overlayDark.withOpacity(0.3),
            ),
            style: TextStyle(color: GhostRollTheme.text),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: GhostRollTheme.recoveryGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What is your comfort level with these techniques?',
                    style: GhostRollTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _comfortLevels.map((comfort) {
              final isSelected = _selectedMood == comfort['emoji'];
              return GestureDetector(
                onTap: () => _onMoodTap(comfort['emoji']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected 
                        ? GhostRollTheme.flowBlue.withOpacity(0.2)
                        : Colors.transparent,
                    border: isSelected ? Border.all(
                      color: GhostRollTheme.flowBlue,
                      width: 3,
                    ) : null,
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                            ? GhostRollTheme.flowBlue.withOpacity(0.3)
                            : GhostRollTheme.flowBlue.withOpacity(0.1),
                        blurRadius: isSelected ? 20 : 8,
                        spreadRadius: isSelected ? 2 : 1,
                      ),
                    ],
                  ),
                  child: Text(
                    comfort['emoji']!,
                    style: const TextStyle(fontSize: 36),
                  ),
                ).animate().scale(
                  duration: const Duration(milliseconds: 200),
                  begin: const Offset(1.0, 1.0),
                  end: Offset(isSelected ? 1.1 : 1.0, isSelected ? 1.1 : 1.0),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfReflectionSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: GhostRollTheme.medium,
        border: Border.all(
          color: GhostRollTheme.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.self_improvement,
                color: GhostRollTheme.grindRed,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Self Reflection',
                style: GhostRollTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Pre-class mood section
          Row(
            children: [
              Icon(
                Icons.mood,
                color: GhostRollTheme.recoveryGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What was my mood coming into class?',
                    style: GhostRollTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _preClassMoods.map((mood) {
              final isSelected = _preClassMood == mood['emoji'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _preClassMood = mood['emoji'];
                  });
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected 
                        ? GhostRollTheme.flowBlue.withOpacity(0.2)
                        : Colors.transparent,
                    border: isSelected ? Border.all(
                      color: GhostRollTheme.flowBlue,
                      width: 3,
                    ) : null,
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                            ? GhostRollTheme.flowBlue.withOpacity(0.3)
                            : GhostRollTheme.flowBlue.withOpacity(0.1),
                        blurRadius: isSelected ? 20 : 8,
                        spreadRadius: isSelected ? 2 : 1,
                      ),
                    ],
                  ),
                  child: Text(
                    mood['emoji']!,
                    style: const TextStyle(fontSize: 36),
                  ),
                ).animate().scale(
                  duration: const Duration(milliseconds: 200),
                  begin: const Offset(1.0, 1.0),
                  end: Offset(isSelected ? 1.1 : 1.0, isSelected ? 1.1 : 1.0),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Wins section
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: GhostRollTheme.flowBlue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What wins did I take away from this class?',
                    style: GhostRollTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _winsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'What went well? What are you proud of?',
              hintStyle: TextStyle(color: GhostRollTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GhostRollTheme.flowBlue, width: 2),
              ),
              prefixIcon: Icon(Icons.celebration, color: GhostRollTheme.textSecondary),
              filled: true,
              fillColor: GhostRollTheme.overlayDark.withOpacity(0.3),
            ),
            style: TextStyle(color: GhostRollTheme.text),
          ),
          
          const SizedBox(height: 20),
          
          // Got stuck section
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: GhostRollTheme.grindRed,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Where did I get stuck?',
                    style: GhostRollTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _stuckController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'What was hard? What needs more work?',
              hintStyle: TextStyle(color: GhostRollTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GhostRollTheme.flowBlue, width: 2),
              ),
              prefixIcon: Icon(Icons.block, color: GhostRollTheme.textSecondary),
              filled: true,
              fillColor: GhostRollTheme.overlayDark.withOpacity(0.3),
            ),
            style: TextStyle(color: GhostRollTheme.text),
          ),
          
          const SizedBox(height: 20),
          
          // Questions section
          Row(
            children: [
              Icon(
                Icons.quiz,
                color: GhostRollTheme.recoveryGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What questions did I ask?',
                    style: GhostRollTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _questionsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'What did you ask your instructor or training partners?',
              hintStyle: TextStyle(color: GhostRollTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GhostRollTheme.flowBlue, width: 2),
              ),
              prefixIcon: Icon(Icons.contact_support, color: GhostRollTheme.textSecondary),
              filled: true,
              fillColor: GhostRollTheme.overlayDark.withOpacity(0.3),
            ),
            style: TextStyle(color: GhostRollTheme.text),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _save,
        icon: const Icon(Icons.save, size: 24),
        label: Text(
          'Save Session',
          style: GhostRollTheme.labelLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GhostRollTheme.flowBlue,
          foregroundColor: GhostRollTheme.text,
          elevation: 12,
          shadowColor: GhostRollTheme.flowBlue.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        ),
      ).animate().scale(
        duration: const Duration(milliseconds: 200),
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.05, 1.05),
      ),
    );
  }
} 
