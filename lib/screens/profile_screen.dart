import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../services/auth_service.dart';
import '../services/instructor_service.dart';
import '../services/profile_service.dart';
import '../theme/ghostroll_theme.dart';

import '../widgets/common/glow_text.dart';

class ProfileScreen extends StatefulWidget {
  final bool initialEditMode;
  
  const ProfileScreen({super.key, this.initialEditMode = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  // Date of birth for auto-calculated age
  DateTime? _dateOfBirth;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Profile data
  String _selectedGender = 'Prefer not to say';
  final List<String> _selectedStyles = [];
  final Map<String, String> _beltRanks = {};
  final Map<String, int> _bjjStripes = {};
  final Map<String, List<Map<String, dynamic>>> _customBeltOrders = {};
  final Map<String, bool> _beltRanksSaved = {};
  final Map<String, bool> _bjjInstructor = {};
  final Map<String, bool> _beltEditingMode = {};
  
  // Edit mode state
  bool _isEditMode = false;
  
  // Instructor data
  List<Map<String, dynamic>> _instructors = [];
  bool _isLoadingInstructors = true;

  final List<Map<String, dynamic>> _martialArtsStyles = [
    {'name': 'Brazilian Jiu-Jitsu (BJJ)', 'belts': ['White', 'Blue', 'Purple', 'Brown', 'Black'], 'hasStripes': true, 'isKarate': false},
    {'name': 'Judo', 'belts': ['White', 'Yellow', 'Orange', 'Green', 'Blue', 'Brown', 'Black'], 'hasStripes': false, 'isKarate': false},
    {'name': 'Karate', 'belts': ['White', 'Yellow', 'Orange', 'Green', 'Blue', 'Purple', 'Brown', 'Red', 'Black'], 'hasStripes': false, 'isKarate': true},
    {'name': 'Taekwondo', 'belts': ['White', 'Yellow', 'Orange', 'Green', 'Blue', 'Red', 'Black'], 'hasStripes': false, 'isKarate': false},
    {'name': 'Muay Thai', 'belts': ['No formal belt system', 'Beginner', 'Intermediate', 'Advanced'], 'hasStripes': false, 'isKarate': false},
    {'name': 'Boxing', 'belts': ['No formal belt system', 'Amateur', 'Professional'], 'hasStripes': false, 'isKarate': false},
    {'name': 'Wrestling', 'belts': ['No formal belt system', 'Beginner', 'Intermediate', 'Advanced'], 'hasStripes': false, 'isKarate': false},
    {'name': 'Kickboxing', 'belts': ['No formal belt system', 'Beginner', 'Intermediate', 'Advanced'], 'hasStripes': false, 'isKarate': false},
    {'name': 'Krav Maga', 'belts': ['White', 'Yellow', 'Orange', 'Green', 'Blue', 'Brown', 'Black'], 'hasStripes': false, 'isKarate': false},
    {'name': 'Aikido', 'belts': ['White', 'Yellow', 'Orange', 'Green', 'Blue', 'Brown', 'Black'], 'hasStripes': false, 'isKarate': false},
  ];

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize edit mode based on parameter
    _isEditMode = widget.initialEditMode;
    
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
    
    _loadInstructors();
    _loadSelectedStyles();
    _loadProfileData();
    
    // Add listeners for auto-save
    _firstNameController.addListener(_autoSaveProfile);
    _surnameController.addListener(_autoSaveProfile);
    _weightController.addListener(_autoSaveProfile);
    _heightController.addListener(_autoSaveProfile);
  }

  @override
  void dispose() {
    // Remove listeners before disposing controllers
    _firstNameController.removeListener(_autoSaveProfile);
    _surnameController.removeListener(_autoSaveProfile);
    _weightController.removeListener(_autoSaveProfile);
    _heightController.removeListener(_autoSaveProfile);
    
    _fadeController.dispose();
    _slideController.dispose();
    _firstNameController.dispose();
    _surnameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructors() async {
    try {
      final instructors = await InstructorService.loadInstructors();
      setState(() {
        _instructors = instructors;
        _isLoadingInstructors = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingInstructors = false;
      });
    }
  }

  Future<void> _loadSelectedStyles() async {
    try {
      final selectedStyles = await ProfileService.loadSelectedStyles();
      setState(() {
        _selectedStyles.clear();
        _selectedStyles.addAll(selectedStyles);
      });
    } catch (e) {
      debugPrint('Error loading selected styles: $e');
    }
  }

  Future<void> _loadProfileData() async {
    // Load saved profile data
    final data = await ProfileService.loadProfileData();
    
    // Get current authenticated user
    final authService = AuthService();
    final displayName = authService.currentUserDisplayName;
    
    setState(() {
      // Handle backward compatibility with existing 'name' field
      if (data['firstName'] != null && data['surname'] != null) {
        _firstNameController.text = data['firstName'] ?? '';
        _surnameController.text = data['surname'] ?? '';
      } else if (data['name'] != null) {
        // Split existing full name into first and last name
        final nameParts = data['name'].toString().trim().split(' ');
        _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
        _surnameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      } else if (displayName != null && displayName.isNotEmpty) {
        // Use authentication display name if no saved profile data
        final nameParts = displayName.trim().split(' ');
        _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
        _surnameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      }
      
      _selectedGender = data['gender'] ?? 'Prefer not to say';
      _weightController.text = data['weight'] ?? '';
      _heightController.text = data['height'] ?? '';
      if (data['dob'] != null) {
        _dateOfBirth = DateTime.tryParse(data['dob']);
      }
      if (data['beltRanks'] != null) {
        _beltRanks.clear();
        (data['beltRanks'] as Map<String, dynamic>).forEach((k, v) => _beltRanks[k] = v as String);
      }
      if (data['bjjStripes'] != null) {
        _bjjStripes.clear();
        (data['bjjStripes'] as Map<String, dynamic>).forEach((k, v) => _bjjStripes[k] = v as int);
      }
      if (data['bjjInstructor'] != null) {
        _bjjInstructor.clear();
        (data['bjjInstructor'] as Map<String, dynamic>).forEach((k, v) => _bjjInstructor[k] = v as bool);
      }
      if (data['customBeltOrders'] != null) {
        _customBeltOrders.clear();
        (data['customBeltOrders'] as Map<String, dynamic>).forEach((k, v) => _customBeltOrders[k] = List<Map<String, dynamic>>.from(v));
      }
    });
  }

  Future<void> _saveSelectedStyles() async {
    try {
      await ProfileService.saveSelectedStyles(_selectedStyles);
    } catch (e) {
      debugPrint('Error saving selected styles: $e');
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final data = {
        'firstName': _firstNameController.text,
        'surname': _surnameController.text,
        'gender': _selectedGender,
        'dob': _dateOfBirth?.toIso8601String(),
        'weight': _weightController.text,
        'height': _heightController.text,
        'beltRanks': _beltRanks,
        'bjjStripes': _bjjStripes,
        'bjjInstructor': _bjjInstructor,
        'customBeltOrders': _customBeltOrders,
      };
      
      // Save to local storage
      await ProfileService.saveProfileData(data);
      
      // Update Firebase Auth display name if name changed
      final authService = AuthService();
      final currentDisplayName = authService.currentUserDisplayName;
      final fullName = '${_firstNameController.text} ${_surnameController.text}'.trim();
      
      if (currentDisplayName != null && currentDisplayName != fullName) {
        try {
          await authService.updateUserProfile(displayName: fullName);
        } catch (e) {
          debugPrint('Error updating Firebase Auth display name: $e');
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile saved successfully!'),
            backgroundColor: GhostRollTheme.flowBlue.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // Auto-save profile data without showing snackbar
  void _autoSaveProfile() {
    try {
      final data = {
        'firstName': _firstNameController.text,
        'surname': _surnameController.text,
        'gender': _selectedGender,
        'dob': _dateOfBirth?.toIso8601String(),
        'weight': _weightController.text,
        'height': _heightController.text,
        'beltRanks': _beltRanks,
        'bjjStripes': _bjjStripes,
        'bjjInstructor': _bjjInstructor,
        'customBeltOrders': _customBeltOrders,
      };
      ProfileService.saveProfileData(data);
    } catch (e) {
      debugPrint('Error auto-saving profile: $e');
    }
  }

  void _saveBeltConfiguration(String styleName) {
    setState(() {
      _beltRanksSaved[styleName] = true;
      _beltEditingMode[styleName] = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Belt configuration saved for $styleName'),
        backgroundColor: GhostRollTheme.recoveryGreen.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _editBeltConfiguration(String styleName) {
    setState(() {
      _beltEditingMode[styleName] = true;
    });
  }

  void _showCustomBeltOrderDialog(String styleName, List<Map<String, dynamic>> currentBelts) {
    List<Map<String, dynamic>> tempBelts = List<Map<String, dynamic>>.from(currentBelts);
    final TextEditingController _beltNameController = TextEditingController();
    Color _selectedColor = Colors.white;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: GhostRollTheme.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: GhostRollTheme.textSecondary.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: GhostRollTheme.glow,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: GhostRollTheme.flowGradient,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: GhostRollTheme.small,
                          ),
                          child: Icon(
                            Icons.reorder,
                            size: 20,
                            color: GhostRollTheme.text,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Customize Belts',
                            style: GhostRollTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add, remove, or reorder belts for $styleName:',
                      style: GhostRollTheme.bodyMedium.copyWith(
                        color: GhostRollTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _beltNameController,
                            decoration: InputDecoration(
                              hintText: 'Belt name',
                              hintStyle: TextStyle(color: GhostRollTheme.textTertiary),
                              filled: true,
                              fillColor: GhostRollTheme.card,
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
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            Color? picked = await showDialog<Color>(
                              context: context,
                              builder: (context) {
                                Color tempColor = _selectedColor;
                                return AlertDialog(
                                  backgroundColor: GhostRollTheme.card,
                                  title: Text('Pick a color', style: TextStyle(color: GhostRollTheme.text)),
                                  content: SingleChildScrollView(
                                    child: BlockPicker(
                                      pickerColor: tempColor,
                                      onColorChanged: (color) {
                                        tempColor = color;
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('Select', style: TextStyle(color: GhostRollTheme.flowBlue)),
                                      onPressed: () => Navigator.of(context).pop(tempColor),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedColor = picked;
                              });
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: GhostRollTheme.text, width: 2),
                              boxShadow: GhostRollTheme.small,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_beltNameController.text.trim().isNotEmpty) {
                              setState(() {
                                tempBelts.add({
                                  'name': _beltNameController.text.trim(),
                                  'color': _selectedColor,
                                });
                                _beltNameController.clear();
                              });
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
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        itemCount: tempBelts.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = tempBelts.removeAt(oldIndex);
                            tempBelts.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            key: ValueKey(tempBelts[index]['name']),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: GhostRollTheme.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: GhostRollTheme.textSecondary.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: GhostRollTheme.small,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.drag_handle,
                                  color: GhostRollTheme.textTertiary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: tempBelts[index]['color'],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: GhostRollTheme.text, width: 1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    tempBelts[index]['name'],
                                    style: GhostRollTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: GhostRollTheme.grindRed, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      tempBelts.removeAt(index);
                                    });
                                  },
                                ),
                                Text(
                                  '${index + 1}',
                                  style: GhostRollTheme.bodySmall.copyWith(
                                    color: GhostRollTheme.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: GhostRollTheme.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: GhostRollTheme.textSecondary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: GhostRollTheme.labelMedium.copyWith(
                                    color: GhostRollTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _customBeltOrders[styleName] = tempBelts;
                                _beltRanksSaved[styleName] = true;
                              });
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: GhostRollTheme.flowGradient,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: GhostRollTheme.small,
                              ),
                              child: Center(
                                child: Text(
                                  'Save',
                                  style: GhostRollTheme.labelMedium.copyWith(
                                    color: GhostRollTheme.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                                _buildPersonalInfoSection(),
                                SizedBox(height: _isEditMode ? 24 : 16),
                                if (_isEditMode) ...[
                          _buildMartialArtsStylesSection(),
                                  SizedBox(height: _isEditMode ? 24 : 16),
                                ],
                          _buildBeltRanksSection(),
                                SizedBox(height: _isEditMode ? 24 : 16),
                          _buildInstructorsSection(),
                                SizedBox(height: _isEditMode ? 24 : 16),
                          _buildNotificationSettingsSection(),
                                SizedBox(height: _isEditMode ? 24 : 16),
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
          if (!_isEditMode)
          Container(
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: GhostRollTheme.flowGradient,
                ),
              borderRadius: BorderRadius.circular(12),
                boxShadow: GhostRollTheme.small,
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isEditMode = true;
                  });
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                tooltip: 'Edit Profile',
              ),
            )
          else
            Row(
              children: [
                Container(
              decoration: BoxDecoration(
                    color: GhostRollTheme.grindRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                border: Border.all(
                      color: GhostRollTheme.grindRed.withOpacity(0.5),
                  width: 1,
                ),
              ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditMode = false;
                      });
                    },
                    icon: Icon(Icons.close, color: GhostRollTheme.grindRed),
                    tooltip: 'Cancel Edit',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: GhostRollTheme.flowGradient,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: GhostRollTheme.small,
                  ),
                  child: IconButton(
                    onPressed: () {
                      _saveProfile();
                      setState(() {
                        _isEditMode = false;
                      });
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    tooltip: 'Save Changes',
                  ),
                ),
              ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: EdgeInsets.all(_isEditMode ? 24 : 16),
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
                Icons.person,
                color: GhostRollTheme.flowBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Personal Information',
                style: GhostRollTheme.titleLarge.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isEditMode) ...[
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  style: GhostRollTheme.bodyMedium.copyWith(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: GhostRollTheme.bodyMedium.copyWith(
                      fontSize: 14,
                      color: GhostRollTheme.textSecondary,
                    ),
                    prefixIcon: Icon(Icons.person_outline, color: GhostRollTheme.textSecondary, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: GhostRollTheme.flowBlue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _surnameController,
                  style: GhostRollTheme.bodyMedium.copyWith(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Surname',
                    labelStyle: GhostRollTheme.bodyMedium.copyWith(
                      fontSize: 14,
                      color: GhostRollTheme.textSecondary,
                    ),
                    prefixIcon: Icon(Icons.person_outline, color: GhostRollTheme.textSecondary, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: GhostRollTheme.flowBlue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your surname';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Email display (read-only from authentication)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: GhostRollTheme.overlayDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GhostRollTheme.textSecondary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.email_outlined, color: GhostRollTheme.textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: GhostRollTheme.bodySmall.copyWith(
                          color: GhostRollTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AuthService().currentUserEmail ?? 'Not available',
                        style: GhostRollTheme.bodyMedium.copyWith(
                          color: GhostRollTheme.text,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.lock_outline,
                  color: GhostRollTheme.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 6570)), // Default to 18 years ago
                      firstDate: DateTime.now().subtract(const Duration(days: 36500)), // 100 years ago
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _dateOfBirth = picked;
                      });
                    }
                  },
                  icon: Icon(Icons.calendar_today, color: GhostRollTheme.flowBlue, size: 20),
                  label: Text(
                    _dateOfBirth == null ? 'Date of Birth' : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                    style: GhostRollTheme.bodyMedium.copyWith(
                      fontSize: 16,
                      color: GhostRollTheme.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.person_outline, color: GhostRollTheme.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: GhostRollTheme.bodyMedium.copyWith(
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isExpanded: true,
                  items: _genderOptions.map((gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(
                        gender,
                        style: GhostRollTheme.bodyMedium.copyWith(
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value ?? 'Prefer not to say';
                    });
                    _autoSaveProfile(); // Auto-save when gender changes
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  style: GhostRollTheme.bodyMedium.copyWith(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    labelStyle: GhostRollTheme.bodyMedium.copyWith(
                      fontSize: 14,
                      color: GhostRollTheme.textSecondary,
                    ),
                    prefixIcon: Icon(Icons.monitor_weight_outlined, color: GhostRollTheme.textSecondary, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: GhostRollTheme.flowBlue, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  style: GhostRollTheme.bodyMedium.copyWith(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Height (cm)',
                    labelStyle: GhostRollTheme.bodyMedium.copyWith(
                      fontSize: 14,
                      color: GhostRollTheme.textSecondary,
                    ),
                    prefixIcon: Icon(Icons.height, color: GhostRollTheme.textSecondary, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: GhostRollTheme.textSecondary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: GhostRollTheme.flowBlue, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
          ],
        ),
          const SizedBox(height: 24),
          ] else ...[
            // Display mode
            _buildPersonalInfoDisplay(),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalInfoDisplay() {
    return Column(
      children: [
        _buildCompactInfoRow('Full Name', 
          (_firstNameController.text.isEmpty && _surnameController.text.isEmpty) 
            ? 'Not specified' 
            : '${_firstNameController.text} ${_surnameController.text}'.trim(), 
          Icons.person_outline),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildCompactInfoRow('Age', _dateOfBirth == null ? 'Not specified' : '${_calculateAge()} years', Icons.cake_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _buildCompactInfoRow('Gender', _selectedGender, Icons.person_outline)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildCompactInfoRow('Weight', _weightController.text.isEmpty ? 'Not specified' : '${_weightController.text} kg', Icons.monitor_weight_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _buildCompactInfoRow('Height', _heightController.text.isEmpty ? 'Not specified' : '${_heightController.text} cm', Icons.height)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GhostRollTheme.overlayDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GhostRollTheme.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: GhostRollTheme.flowBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
                  style: GhostRollTheme.bodySmall.copyWith(
                    color: GhostRollTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GhostRollTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GhostRollTheme.overlayDark,
        borderRadius: BorderRadius.circular(8),
                border: Border.all(
          color: GhostRollTheme.textSecondary.withOpacity(0.2),
                  width: 1,
                ),
              ),
      child: Row(
        children: [
          Icon(
            icon,
            color: GhostRollTheme.flowBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GhostRollTheme.bodySmall.copyWith(
                    color: GhostRollTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: GhostRollTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildMartialArtsStylesSection() {
    return Container(
      padding: EdgeInsets.all(_isEditMode ? 24 : 16),
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
                    Icons.sports_martial_arts,
                color: GhostRollTheme.grindRed,
                    size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Martial Arts Styles',
                style: GhostRollTheme.titleLarge,
                ),
              ],
            ),
          SizedBox(height: _isEditMode ? 16 : 12),
          if (_isEditMode) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _martialArtsStyles.map((style) {
                final styleName = style['name'] as String;
                final isSelected = _selectedStyles.contains(styleName);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedStyles.remove(styleName);
                      } else {
                        _selectedStyles.add(styleName);
                      }
                    });
                    _saveSelectedStyles();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                    color: isSelected 
                        ? GhostRollTheme.grindRed.withOpacity(0.2)
                        : GhostRollTheme.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? GhostRollTheme.grindRed.withOpacity(0.5)
                          : GhostRollTheme.textSecondary.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: isSelected ? GhostRollTheme.small : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        styleName,
                        style: GhostRollTheme.bodyMedium.copyWith(
                          color: isSelected ? GhostRollTheme.grindRed : GhostRollTheme.text,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: GhostRollTheme.grindRed,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          ] else ...[
            // Display mode
            if (_selectedStyles.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: GhostRollTheme.overlayDark,
                  borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                    color: GhostRollTheme.textSecondary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: GhostRollTheme.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                    child: Text(
                        'No martial arts styles selected',
                        style: GhostRollTheme.bodySmall.copyWith(
                          color: GhostRollTheme.textSecondary,
                      ),
                    ),
                  ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _selectedStyles.map((styleName) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: GhostRollTheme.grindRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: GhostRollTheme.grindRed.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
              Text(
                          styleName,
                          style: GhostRollTheme.bodySmall.copyWith(
                            color: GhostRollTheme.grindRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_circle,
                          color: GhostRollTheme.grindRed,
                          size: 14,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildBeltRanksSection() {
    if (_selectedStyles.isEmpty) {
    return Container(
        padding: EdgeInsets.all(_isEditMode ? 24 : 16),
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
                    Icons.emoji_events,
                  color: GhostRollTheme.recoveryGreen,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text(
                  'Current Rank',
                  style: GhostRollTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Select martial arts styles above to configure your belt ranks',
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
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
                Icons.emoji_events,
                color: GhostRollTheme.recoveryGreen,
                      size: 20,
                    ),
              const SizedBox(width: 8),
                    Text(
                'Current Rank',
                style: GhostRollTheme.titleLarge,
                    ),
                  ],
                ),
          const SizedBox(height: 16),
              ..._selectedStyles.map((styleName) {
            final style = _martialArtsStyles.firstWhere((s) => (s['name'] as String) == styleName);
            final belts = _customBeltOrders[styleName] ?? 
                (style['belts'] as List<dynamic>).map<Map<String, dynamic>>((belt) => {
                  'name': belt.toString(),
                  'color': _getBeltColor(belt.toString(), style['isKarate'] as bool),
                }).toList();
            
            return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              styleName,
                        style: GhostRollTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                    if (_isEditMode)
                      IconButton(
                        icon: Icon(Icons.edit, color: GhostRollTheme.flowBlue, size: 20),
                        onPressed: () => _showCustomBeltOrderDialog(styleName, belts),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (!_isEditMode && _beltRanks[styleName] != null && _beltRanks[styleName]!.isNotEmpty) ...[
                  // Display mode - show saved belt info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GhostRollTheme.overlayDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GhostRollTheme.recoveryGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.military_tech,
                              color: GhostRollTheme.recoveryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_beltRanks[styleName]}${(_bjjStripes[styleName] ?? 0) > 0 ? ' (${_bjjStripes[styleName]} stripe${(_bjjStripes[styleName] ?? 0) > 1 ? 's' : ''})' : ''}',
                                style: GhostRollTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildBeltVisualization(styleName, belts),
                      ],
                    ),
                  ),
                ] else if (_beltRanksSaved[styleName] == true && _beltEditingMode[styleName] != true) ...[
                  // Saved state - show belt info and edit button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GhostRollTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GhostRollTheme.recoveryGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: GhostRollTheme.recoveryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Belt: ${_beltRanks[styleName]}',
                                style: GhostRollTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (_isEditMode)
                              TextButton.icon(
                                onPressed: () => _editBeltConfiguration(styleName),
                                icon: Icon(Icons.edit, size: 16, color: GhostRollTheme.flowBlue),
                                label: Text('Edit', style: TextStyle(color: GhostRollTheme.flowBlue)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildBeltVisualization(styleName, belts),
                      ],
                    ),
                  ),
                ] else if (_isEditMode) ...[
                  // Editing state - show controls and save button
                  DropdownButtonFormField<String>(
                    value: _beltRanks[styleName],
                    decoration: InputDecoration(
                      labelText: 'Select Belt',
                      prefixIcon: Icon(Icons.emoji_events_outlined, color: GhostRollTheme.textSecondary),
                    ),
                    items: belts.map<DropdownMenuItem<String>>((belt) {
                      return DropdownMenuItem<String>(
                        value: belt['name'],
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: belt['color'],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: GhostRollTheme.text, width: 1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(belt['name']),
                          ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _beltRanks[styleName] = value ?? '';
                      });
                      _autoSaveProfile(); // Auto-save when belt rank changes
                    },
                      ),
                ],
                if (_isEditMode && (_beltRanksSaved[styleName] != true || _beltEditingMode[styleName] == true)) ...[
                  if (_beltRanks[styleName] != null && _beltRanks[styleName]!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                    _buildBeltVisualization(styleName, belts),
                    if ((style['hasStripes'] as bool)) ...[
                      const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Stripes: ',
                            style: GhostRollTheme.bodyMedium,
                          ),
                          Expanded(
                            child: Slider(
                              value: (_bjjStripes[styleName] ?? 0).toDouble(),
                              min: 0,
                              max: (styleName == 'Brazilian Jiu-Jitsu (BJJ)' && _beltRanks[styleName] == 'Black') ? 6.0 : 4.0,
                              divisions: (styleName == 'Brazilian Jiu-Jitsu (BJJ)' && _beltRanks[styleName] == 'Black') ? 6 : 4,
                              activeColor: GhostRollTheme.flowBlue,
                              inactiveColor: GhostRollTheme.textSecondary.withOpacity(0.3),
                              label: (_bjjStripes[styleName] ?? 0).toString(),
                              onChanged: (value) {
                                  setState(() {
                                  _bjjStripes[styleName] = value.round();
                                  });
                                },
                            ),
                          ),
                          Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                              color: GhostRollTheme.flowBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                              '${_bjjStripes[styleName] ?? 0}',
                              style: GhostRollTheme.labelSmall.copyWith(
                                color: GhostRollTheme.flowBlue,
                                fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        ],
                      ),
                      if (styleName == 'Brazilian Jiu-Jitsu (BJJ)' && _beltRanks[styleName] == 'Black') ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _bjjInstructor[styleName] ?? false,
                              onChanged: (value) {
                                setState(() {
                                  _bjjInstructor[styleName] = value ?? false;
                                });
                              },
                              activeColor: GhostRollTheme.flowBlue,
                            ),
                            Text(
                              'Instructor (Red bar with stripes)',
                              style: GhostRollTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _saveBeltConfiguration(styleName),
                        icon: const Icon(Icons.save, size: 20),
                        label: Text(
                          'Save Belt Configuration',
                          style: GhostRollTheme.labelMedium.copyWith(
                                fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GhostRollTheme.recoveryGreen,
                          foregroundColor: GhostRollTheme.text,
                          elevation: 8,
                          shadowColor: GhostRollTheme.recoveryGreen.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ),
                      ],
                    ],
                const SizedBox(height: 16),
              ],
                );
              }).toList(),
          ],
      ),
    );
  }

  Widget _buildBeltVisualization(String styleName, List<Map<String, dynamic>> belts) {
    final selectedBelt = belts.firstWhere(
      (belt) => belt['name'] == _beltRanks[styleName],
      orElse: () => belts.first,
    );
    final stripes = _bjjStripes[styleName] ?? 0;
    final isInstructor = _bjjInstructor[styleName] ?? false;
    final isBJJ = styleName == 'Brazilian Jiu-Jitsu (BJJ)';
    final isBlackBelt = selectedBelt['name'] == 'Black';
    
    return Container(
      padding: EdgeInsets.all(_isEditMode ? 16 : 12),
          decoration: BoxDecoration(
        color: GhostRollTheme.overlayDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GhostRollTheme.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditMode) ...[
            Text(
              'Your Belt',
              style: GhostRollTheme.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Center(
            child: Container(
              width: _isEditMode ? 400 : 300,
              height: _isEditMode ? 60 : 45,
              decoration: BoxDecoration(
                color: selectedBelt['color'],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: GhostRollTheme.text,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: selectedBelt['color'].withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: GhostRollTheme.text.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Main belt body
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedBelt['color'],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // BJJ belt end bar (for all BJJ belts)
                  if (isBJJ)
                    Positioned(
                      right: 40, // Inset from right end
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 100, // 25% of 400px = 100px
                        decoration: BoxDecoration(
                          color: isBlackBelt ? Colors.red : Colors.black,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: GhostRollTheme.text,
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Instructor stripes at both ends (for black belt only)
                            if (isBlackBelt && isInstructor) ...[
                              Positioned(
                                left: -4,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -4,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                            // Regular stripes for all BJJ belts
                            if (stripes > 0)
                              Positioned(
                                right: 15, // 15% of 100px = 15px inset from right
                                top: 2,
                                bottom: 2,
                                child: Row(
                                  children: List.generate(stripes, (index) => 
                                    Container(
                                      width: 6,
                                      height: double.infinity,
                                      margin: EdgeInsets.only(right: index < stripes - 1 ? 8 : 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  // Regular stripes for non-BJJ belts
                  if (!isBJJ && stripes > 0)
                    Positioned(
                      right: 8,
                      top: 2,
                      bottom: 2,
                      child: Row(
                        children: List.generate(stripes, (index) => 
                          Container(
                            width: 6,
                            height: double.infinity,
                            margin: EdgeInsets.only(right: index < stripes - 1 ? 2 : 0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorsSection() {
    return Container(
      padding: EdgeInsets.all(_isEditMode ? 24 : 16),
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
                Icons.school,
                color: GhostRollTheme.recoveryGreen,
                    size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Instructors',
                style: GhostRollTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingInstructors)
            const Center(
              child: CircularProgressIndicator(),
              )
            else if (_instructors.isEmpty)
            Column(
                  children: [
                    Text(
                  'No instructors found. Add some to track your training progress.',
                  style: GhostRollTheme.bodyMedium.copyWith(
                    color: GhostRollTheme.textSecondary,
                  ),
                ),
                if (_isEditMode) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addInstructorDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Instructor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GhostRollTheme.flowBlue,
                      foregroundColor: GhostRollTheme.text,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
              )
            else
              Column(
              children: [
                ..._instructors.map((instructor) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GhostRollTheme.overlayDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GhostRollTheme.textSecondary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: GhostRollTheme.flowBlue.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            color: GhostRollTheme.flowBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                                instructor['name'] ?? 'Unknown',
                                style: GhostRollTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            Text(
                                instructor['style'] ?? 'Unknown Style',
                                style: GhostRollTheme.bodyMedium.copyWith(
                                  color: GhostRollTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                        ),
                        if (_isEditMode)
                          IconButton(
                            icon: Icon(Icons.edit, color: GhostRollTheme.flowBlue, size: 16),
                            onPressed: () => _editInstructorDialog(instructor),
                          ),
                        Icon(
                          Icons.verified,
                          color: GhostRollTheme.recoveryGreen,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                if (_isEditMode) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addInstructorDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Instructor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GhostRollTheme.flowBlue,
                      foregroundColor: GhostRollTheme.text,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
                             ),
                           ],
                         ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveProfile,
        icon: const Icon(Icons.save, size: 24),
        label: Text(
          'Save Profile',
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
      ),
    );
  }



  int _calculateAge() {
    if (_dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - _dateOfBirth!.year;
    if (now.month < _dateOfBirth!.month || (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  void _addInstructorDialog() {
    final nameController = TextEditingController();
    String? selectedStyle = _selectedStyles.isNotEmpty ? _selectedStyles[0] : null;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: GhostRollTheme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Add Instructor',
            style: GhostRollTheme.titleLarge,
          ),
          content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Instructor Name',
                  prefixIcon: Icon(Icons.person, color: GhostRollTheme.textSecondary),
                ),
                style: TextStyle(color: GhostRollTheme.text),
              ),
              const SizedBox(height: 16),
              if (_selectedStyles.isEmpty)
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
                  value: selectedStyle,
                  decoration: InputDecoration(
                    labelText: 'Martial Art Style',
                    prefixIcon: Icon(Icons.sports_martial_arts, color: GhostRollTheme.textSecondary),
                  ),
                  items: _selectedStyles.map((style) => DropdownMenuItem(
                    value: style,
                    child: Text(style),
                  )).toList(),
                  onChanged: (value) => selectedStyle = value,
                ),
            ],
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
                if (nameController.text.trim().isNotEmpty && selectedStyle != null) {
                                  final newInstructor = {
                                    'name': nameController.text.trim(),
                    'style': selectedStyle!,
                                  };
                                  
                  try {
                                  await InstructorService.addInstructor(newInstructor);
                    setState(() {
                      _instructors.add(newInstructor);
                    });
                                  Navigator.pop(context);
                  } catch (e) {
                    debugPrint('Error adding instructor: $e');
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
  }

  void _editInstructorDialog(Map<String, dynamic> instructor) {
    final nameController = TextEditingController(text: instructor['name'] ?? '');
    String? selectedStyle = instructor['style'] ?? (_selectedStyles.isNotEmpty ? _selectedStyles[0] : null);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: GhostRollTheme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Edit Instructor',
            style: GhostRollTheme.titleLarge,
          ),
          content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Instructor Name',
                  prefixIcon: Icon(Icons.person, color: GhostRollTheme.textSecondary),
                ),
                style: TextStyle(color: GhostRollTheme.text),
              ),
              const SizedBox(height: 16),
              if (_selectedStyles.isEmpty)
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
                  value: selectedStyle,
                  decoration: InputDecoration(
                    labelText: 'Martial Art Style',
                    prefixIcon: Icon(Icons.sports_martial_arts, color: GhostRollTheme.textSecondary),
                  ),
                  items: _selectedStyles.map((style) => DropdownMenuItem(
                    value: style,
                    child: Text(style),
                  )).toList(),
                  onChanged: (value) => selectedStyle = value,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                style: TextStyle(color: GhostRollTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                                  try {
                    final index = _instructors.indexOf(instructor);
                    if (index != -1) {
                      await InstructorService.deleteInstructor(index);
                      setState(() {
                        _instructors.removeAt(index);
                      });
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    debugPrint('Error removing instructor: $e');
                  }
              },
              style: TextButton.styleFrom(
                foregroundColor: GhostRollTheme.grindRed,
              ),
              child: const Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () async {
                                if (nameController.text.trim().isNotEmpty) {
                                  final updatedInstructor = {
                                    'name': nameController.text.trim(),
                                    'style': selectedStyle!,
                                  };
                                  
                  try {
                    final index = _instructors.indexOf(instructor);
                    if (index != -1) {
                                  await InstructorService.updateInstructor(index, updatedInstructor);
                      setState(() {
                        _instructors[index] = updatedInstructor;
                      });
                    }
                                  Navigator.pop(context);
                  } catch (e) {
                    debugPrint('Error updating instructor: $e');
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
  }

  Color _getBeltColor(String beltName, bool isKarate) {
    switch (beltName.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'brown':
        return Colors.brown;
      case 'black':
        return Colors.black;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildNotificationSettingsSection() {
    return Container(
      padding: EdgeInsets.all(_isEditMode ? 24 : 16),
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
                Icons.notifications_active,
                color: GhostRollTheme.flowBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Notification Settings',
                style: GhostRollTheme.titleLarge.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: GhostRollTheme.flowGradient,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: GhostRollTheme.small,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/notification-preferences');
                },
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Configure Notifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GhostRollTheme.overlayDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GhostRollTheme.textSecondary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: GhostRollTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Customize your notification preferences to stay motivated with helpful reminders and celebrate your progress! 👻',
                    style: GhostRollTheme.bodySmall.copyWith(
                      color: GhostRollTheme.textSecondary,
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
} 