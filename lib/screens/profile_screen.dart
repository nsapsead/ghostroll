import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/instructor_service.dart';
import '../theme/app_theme.dart';
import '../components/gradient_card.dart';
import '../components/app_button.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _experienceController = TextEditingController();


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
  final Map<String, bool> _beltRanksSaved = {}; // Track if belt ranks are saved for each style
  final Map<String, bool> _bjjInstructor = {}; // Track if BJJ black belt is instructor
  
  // Instructor data
  List<Map<String, dynamic>> _instructors = [];
  bool _isLoadingInstructors = true;

  final List<Map<String, dynamic>> _martialArtsStyles = [
    {'name': 'Brazilian Jiu-Jitsu (BJJ)', 'belts': ['White', 'Blue', 'Purple', 'Brown', 'Black'], 'hasStripes': true, 'isKarate': false},
    {'name': 'Judo', 'belts': ['White', 'Yellow', 'Orange', 'Green', 'Blue', 'Brown', 'Black'], 'hasStripes': false, 'isKarate': false},
    {'name': 'Karate', 'belts': ['White', 'Yellow', 'Orange', 'Green', 'Blue', 'Purple', 'Brown', 'Black'], 'hasStripes': false, 'isKarate': true},
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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _experienceController.dispose();

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

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved successfully!'),
          backgroundColor: Colors.white.withOpacity(0.1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1A1A),
                      const Color(0xFF2A2A2A),
                      const Color(0xFF1F1F1F),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
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
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.reorder,
                            size: 20,
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Customize Belts',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add, remove, or reorder belts for $styleName:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
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
                              hintStyle: TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
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
                                  backgroundColor: Colors.grey[900],
                                  title: const Text('Pick a color', style: TextStyle(color: Colors.white)),
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
                                      child: const Text('Select', style: TextStyle(color: Colors.white)),
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
                              border: Border.all(color: Colors.white, width: 2),
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
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.drag_handle,
                                  color: Colors.grey[500],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: tempBelts[index]['color'],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.white, width: 1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    tempBelts[index]['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      tempBelts.removeAt(index);
                                    });
                                  },
                                ),
                                Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
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
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.withOpacity(0.2),
                                    Colors.grey.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
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
                              this.setState(() {
                                _customBeltOrders[styleName] = List<Map<String, dynamic>>.from(tempBelts);
                              });
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.grey[100]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildFantasticAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: AppSpacing.xl),
                          _buildSectionCard(
                            title: 'Personal Information',
                            child: _buildPersonalInfoSection(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildSectionCard(
                            title: 'Martial Arts Styles',
                            child: _buildMartialArtsStylesSection(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildSectionCard(
                            title: 'Belt Ranks',
                            child: _buildBeltRanksSection(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildSectionCard(
                            title: 'Instructors',
                            child: _buildInstructorsSection(),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildSaveButton(),
                          const SizedBox(height: AppSpacing.md),
                          _buildSignOutButton(),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingClassesSection() {
    // TODO: Connect to real schedule data
    final upcoming = [
      {'day': 'Monday', 'time': '18:00', 'type': 'BJJ'},
      {'day': 'Wednesday', 'time': '19:00', 'type': 'Muay Thai'},
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Classes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...upcoming.map((c) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${c['day']} - ${c['type']} @ ${c['time']}',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFantasticAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.small,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Image.asset(
                'assets/images/ghostroll_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Spacer(),
          GradientCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: Text(
              'Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GradientCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: Text(
              _nameController.text.isNotEmpty
                  ? _nameController.text[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _nameController.text.isNotEmpty ? _nameController.text : 'Your Name',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Martial Arts Journal',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return GradientCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Form(
                      key: _formKey,
      child: Column(
                        children: [
          _buildTextFormField(
                            controller: _nameController,
                            label: 'Full Name',
                            hintText: 'Enter your full name',
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
          const SizedBox(height: AppSpacing.md),
          _buildDropdownField(
                            label: 'Gender',
                            value: _selectedGender,
                            items: _genderOptions,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                          ),
          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                child: _buildTextFormField(
                                  controller: _ageController,
                                  label: 'Age',
                                  hintText: 'Age',
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                ),
                              ),
              const SizedBox(width: AppSpacing.md),
                              Expanded(
                child: _buildTextFormField(
                                  controller: _weightController,
                                  label: 'Weight (kg)',
                                  hintText: 'Weight',
                                ),
                              ),
                            ],
                          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextFormField(
                            controller: _heightController,
                            label: 'Height (cm)',
                            hintText: 'Height',
                          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextFormField(
                            controller: _experienceController,
                            label: 'Years of Experience',
                            hintText: 'How many years have you been training?',
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),

        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int minLines = 1,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(color: AppColors.textTertiary),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Color _getStandardBeltColor(String beltName) {
    final name = beltName.toLowerCase();
    
    // Standard martial arts belt colors
    if (name.contains('white')) return Colors.white;
    if (name.contains('yellow')) return const Color(0xFFFFD700); // Gold yellow
    if (name.contains('orange')) return const Color(0xFFFF8C00); // Dark orange
    if (name.contains('green')) return const Color(0xFF228B22); // Forest green
    if (name.contains('blue')) return const Color(0xFF0066CC); // Navy blue
    if (name.contains('purple')) return const Color(0xFF800080); // Purple
    if (name.contains('brown')) return const Color(0xFF8B4513); // Saddle brown
    if (name.contains('black')) return Colors.black;
    if (name.contains('red')) return const Color(0xFFDC143C); // Crimson red
    
    // BJJ specific colors (more vibrant)
    if (name.contains('bjj') && name.contains('white')) return Colors.white;
    if (name.contains('bjj') && name.contains('blue')) return const Color(0xFF1E90FF); // Dodger blue
    if (name.contains('bjj') && name.contains('purple')) return const Color(0xFF9370DB); // Medium purple
    if (name.contains('bjj') && name.contains('brown')) return const Color(0xFFD2691E); // Chocolate
    if (name.contains('bjj') && name.contains('black')) return Colors.black;
    
    // Karate specific colors
    if (name.contains('karate') && name.contains('white')) return Colors.white;
    if (name.contains('karate') && name.contains('yellow')) return const Color(0xFFFFD700);
    if (name.contains('karate') && name.contains('orange')) return const Color(0xFFFF8C00);
    if (name.contains('karate') && name.contains('green')) return const Color(0xFF228B22);
    if (name.contains('karate') && name.contains('blue')) return const Color(0xFF0066CC);
    if (name.contains('karate') && name.contains('purple')) return const Color(0xFF800080);
    if (name.contains('karate') && name.contains('brown')) return const Color(0xFF8B4513);
    if (name.contains('karate') && name.contains('black')) return Colors.black;
    
    // Judo colors
    if (name.contains('judo') && name.contains('white')) return Colors.white;
    if (name.contains('judo') && name.contains('yellow')) return const Color(0xFFFFD700);
    if (name.contains('judo') && name.contains('orange')) return const Color(0xFFFF8C00);
    if (name.contains('judo') && name.contains('green')) return const Color(0xFF228B22);
    if (name.contains('judo') && name.contains('blue')) return const Color(0xFF0066CC);
    if (name.contains('judo') && name.contains('brown')) return const Color(0xFF8B4513);
    if (name.contains('judo') && name.contains('black')) return Colors.black;
    
    // Taekwondo colors
    if (name.contains('taekwondo') || name.contains('tkd')) {
      if (name.contains('white')) return Colors.white;
      if (name.contains('yellow')) return const Color(0xFFFFD700);
      if (name.contains('orange')) return const Color(0xFFFF8C00);
      if (name.contains('green')) return const Color(0xFF228B22);
      if (name.contains('blue')) return const Color(0xFF0066CC);
      if (name.contains('red')) return const Color(0xFFDC143C);
      if (name.contains('black')) return Colors.black;
    }
    
    // Muay Thai / Boxing / Wrestling (no formal belts)
    if (name.contains('beginner')) return const Color(0xFF87CEEB); // Sky blue
    if (name.contains('intermediate')) return const Color(0xFF32CD32); // Lime green
    if (name.contains('advanced')) return const Color(0xFFFF6347); // Tomato red
    if (name.contains('amateur')) return const Color(0xFF9370DB); // Medium purple
    if (name.contains('professional')) return const Color(0xFFDAA520); // Goldenrod
    
    // Default fallback colors for unknown belts
    if (name.contains('no formal')) return const Color(0xFF696969); // Dim gray
    if (name.contains('instructor')) return const Color(0xFFDAA520); // Goldenrod
    if (name.contains('master')) return const Color(0xFF4169E1); // Royal blue
    
    // If no match found, return white as default
    return Colors.white;
  }

  Widget _buildLargeBeltGraphic(String styleName, String currentRank, int currentStripes, List<Map<String, dynamic>> belts) {
    // Find the belt data for the current rank
    final beltData = belts.firstWhere(
      (belt) => belt['name'] == currentRank,
      orElse: () => {'name': currentRank, 'color': Colors.white},
    );
    
    // Get standard belt color based on name
    final Color beltColor = _getStandardBeltColor(currentRank);
    
    // Check if this is a BJJ style
    final bool isBJJ = styleName.toLowerCase().contains('bjj') || styleName.toLowerCase().contains('brazilian jiu-jitsu');
    
    final bool showStripes = currentStripes > 0 && (currentRank != 'Black' || isBJJ);
    
    return Container(
      width: double.infinity,
      height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
        borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large belt graphic - more square and authentic
          Container(
            width: 280,
            height: 32,
            decoration: BoxDecoration(
              color: beltColor,
              borderRadius: BorderRadius.circular(4), // Much less rounded for square appearance
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
                        child: Stack(
              children: [
                // Main belt body (no stripes here)
                Container(
                  width: isBJJ ? 192 : double.infinity, // Leave space for end bar
                  height: double.infinity,
                ),
                // BJJ end bar with stripes (black for all belts except black belt which has red) - 2.5x larger
                if (isBJJ) Positioned(
                  right: 20, // Moved further left to show more of the main belt body
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 88, // 2.5x larger: 35 * 2.5 = 87.5, rounded to 88
                    decoration: BoxDecoration(
                      color: currentRank.toLowerCase().contains('black') ? Colors.red : Colors.black,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(2),
                        bottomRight: Radius.circular(2),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Regular stripes (if any) - full height and centered
                        if (showStripes) Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(currentStripes, (index) => 
                            Container(
                              width: 6, // Increased width for better visibility
                              height: 32, // Full height of the belt
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                        // Instructor stripes at both ends (for BJJ black belt) - thicker and full height
                        if (isBJJ && currentRank.toLowerCase().contains('black') && (_bjjInstructor[styleName] ?? false)) ...[
                          // Left end stripe
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 6, // Thicker stripe
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                          // Right end stripe
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 6, // Thicker stripe
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Belt name
          Text(
            currentRank,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
                ),
          if (showStripes) ...[
            const SizedBox(height: 6),
            Text(
              '$currentStripes stripe${currentStripes == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
            ),
          ),
          ],
        ],
      ),
    );
  }

  Widget _buildBeltGraphic(String styleName, String currentRank, int currentStripes, List<Map<String, dynamic>> belts) {
    // Find the belt data for the current rank
    final beltData = belts.firstWhere(
      (belt) => belt['name'] == currentRank,
      orElse: () => {'name': currentRank, 'color': Colors.white},
    );
    
    // Get standard belt color based on name
    final Color beltColor = _getStandardBeltColor(currentRank);
    final bool showStripes = currentStripes > 0 && currentRank != 'Black';
    
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Belt graphic
          Container(
            width: 60,
            height: 12,
      decoration: BoxDecoration(
              color: beltColor,
              borderRadius: BorderRadius.circular(6),
        border: Border.all(
                color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: showStripes ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(currentStripes, (index) => 
            Container(
                  width: 2,
                  height: 8,
              decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ) : null,
          ),
          const SizedBox(height: 4),
          // Belt name
          Text(
            currentRank,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            ),
          ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
          style: TextStyle(
                fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
        const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
            borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: value,
                onChanged: onChanged,
            style: const TextStyle(color: AppColors.textPrimary),
            dropdownColor: AppColors.primary,
                decoration: const InputDecoration(
                  border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppSpacing.md),
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                  style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
    );
  }

  Widget _buildMartialArtsStylesSection() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tap to select the martial arts styles you practice:',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
        const SizedBox(height: AppSpacing.md),
            Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
              children: _martialArtsStyles.map((style) {
                final isSelected = _selectedStyles.contains(style['name']);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedStyles.remove(style['name']);
                        _beltRanks.remove(style['name']);
                      } else {
                        _selectedStyles.add(style['name']);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.02),
                              ],
                            ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                    color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      style['name'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        if (_selectedStyles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
                'Selected: ${_selectedStyles.length} style${_selectedStyles.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildBeltRanksSection() {
    if (_selectedStyles.isEmpty) {
    return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
          borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
            Icon(Icons.info_outline, color: AppColors.textTertiary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Select martial arts styles above to set belt ranks.',
                      style: TextStyle(
                  color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                ),
                      ),
                    ),
                  ],
                ),
      );
    }
    return Column(
      children: _selectedStyles.map((styleName) {
                final style = _martialArtsStyles.firstWhere((s) => s['name'] == styleName);
                final hasStripes = style['hasStripes'] ?? false;
                final isKarate = style['isKarate'] ?? false;
        List<Map<String, dynamic>> belts;
        if (_customBeltOrders.containsKey(styleName)) {
          belts = List<Map<String, dynamic>>.from(_customBeltOrders[styleName]!);
                } else {
          belts = List<Map<String, dynamic>>.from(style['belts'].map((b) => {'name': b, 'color': Colors.white}));
                }
        final currentRank = _beltRanks[styleName] ?? belts.first['name'];
                final currentStripes = _bjjStripes[styleName] ?? 0;
                return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ],
                    ),
            borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              styleName,
                      style: TextStyle(
                                fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 16,
                              ),
                            ),
                          ),
                            GestureDetector(
                    onTap: () {
                      // If belt rank is saved, allow editing it
                      if (_beltRanksSaved[styleName] ?? false) {
                        setState(() {
                          _beltRanksSaved[styleName] = false;
                        });
                      } else {
                        // Show belt customization dialog
                        List<Map<String, dynamic>> currentBelts;
                        if (_customBeltOrders.containsKey(styleName)) {
                          currentBelts = List<Map<String, dynamic>>.from(_customBeltOrders[styleName]!);
                        } else {
                          currentBelts = List<Map<String, dynamic>>.from(style['belts'].map((b) => {'name': b, 'color': Colors.white}));
                        }
                        _showCustomBeltOrderDialog(styleName, currentBelts);
                      }
                    },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                                ),
                                child: Icon(
                                  Icons.edit,
                        color: AppColors.textSecondary,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                            const SizedBox(height: AppSpacing.sm),
              // Check if belt rank is saved for this style and show appropriate content
              (_beltRanksSaved[styleName] ?? false) 
                ? _buildLargeBeltGraphic(styleName, currentRank, currentStripes, belts)
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Belt Rank',
                        value: currentRank,
                              items: belts.map<String>((b) => b['name'] as String).toList(),
                        onChanged: (value) {
                          setState(() {
                            _beltRanks[styleName] = value!;
                            if (hasStripes) {
                              _bjjStripes[styleName] = 0;
                            }
                          });
                        },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          _buildBeltGraphic(styleName, currentRank, currentStripes, belts),
                        ],
                      ),
                      if (hasStripes && (currentRank != 'Black' || (styleName.toLowerCase().contains('bjj') || styleName.toLowerCase().contains('brazilian jiu-jitsu')))) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Stripes:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            ...List.generate(
                              // BJJ Black Belt can have up to 6 stripes, others up to 4
                              (styleName.toLowerCase().contains('bjj') || styleName.toLowerCase().contains('brazilian jiu-jitsu')) && currentRank.toLowerCase().contains('black') ? 6 : 4, 
                              (index) {
                              final isSelected = index < currentStripes;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _bjjStripes[styleName] = index + 1;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: AppSpacing.xs),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.star, size: 14, color: Colors.white)
                                      : null,
                                ),
                              );
                            }),
                            const SizedBox(width: AppSpacing.sm),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _bjjStripes[styleName] = 0;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Instructor option for BJJ Black Belt
                      if ((styleName.toLowerCase().contains('bjj') || styleName.toLowerCase().contains('brazilian jiu-jitsu')) && currentRank.toLowerCase().contains('black')) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _bjjInstructor[styleName] = !(_bjjInstructor[styleName] ?? false);
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: (_bjjInstructor[styleName] ?? false) ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: (_bjjInstructor[styleName] ?? false) ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: (_bjjInstructor[styleName] ?? false)
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Instructor (end stripes)',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _beltRanksSaved[styleName] = true;
                          });
                        },
                        child: Container(
          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey[100]!,
              ],
            ),
                            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
              ),
            ],
          ),
              child: const Center(
                child: Text(
                              'Save Belt Rank',
                  style: TextStyle(
                    color: Colors.black,
                                fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
                    ],
                  ),
      ],
      ),
    );
        }).toList(),
      );
  }

  Widget _buildInstructorsSection() {
    if (_isLoadingInstructors) {
      return const Center(child: CircularProgressIndicator(color: AppColors.textPrimary));
    }
    
    return Column(
          children: [
        if (_instructors.isEmpty)
                Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
              borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                Icon(Icons.person_add, size: 40, color: AppColors.textTertiary),
                const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No instructors added yet',
                      style: TextStyle(
                        fontSize: 16,
                    color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tap the + button to add your first instructor',
                      style: TextStyle(
                        fontSize: 14,
                    color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
          ),
        if (_instructors.isNotEmpty)
          ..._instructors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final instructor = entry.value;
                  return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                      leading: CircleAvatar(
                  radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        child: Text(
                          instructor['name'][0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                      fontSize: 16,
                          ),
                        ),
                      ),
                      title: Text(
                        instructor['name'],
                  style: TextStyle(
                          fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            instructor['style'],
                            style: TextStyle(
                        color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          if (instructor['rank'] != null && instructor['rank'].isNotEmpty)
                            Text(
                              'Rank: ${instructor['rank']}',
                              style: TextStyle(
                          color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
                      onPressed: () => _showEditInstructorDialog(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[300], size: 20),
                      onPressed: () => _deleteInstructor(index),
                    ),
                  ],
                                 ),
                               ),
            );
          }).toList(),
        const SizedBox(height: AppSpacing.md),
                             GestureDetector(
          onTap: _showAddInstructorDialog,
                               child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
                                 decoration: BoxDecoration(
                                   gradient: LinearGradient(
                                     colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                                     ],
                                   ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
                style: BorderStyle.solid,
              ),
                                 ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Add Instructor',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                               ),
                             ),
                           ],
                         ),
                       ),
                    ),
      ],
                  );
  }



  Widget _buildSaveButton() {
    return AppButton(
      text: 'Save Profile',
      onPressed: _saveProfile,
      backgroundColor: Colors.white,
      textColor: AppColors.primary,
    );
  }

  Widget _buildSignOutButton() {
    return AppButton(
      text: 'Sign Out',
      onPressed: _signOut,
      isOutlined: true,
      isDestructive: true,
    );
  }

  Future<void> _signOut() async {
    final authService = AuthService();
    
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      try {
        await authService.signOut();
        // The AuthWrapper will automatically redirect to login screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red.withOpacity(0.1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
      }
    }
  }

  void _showAddInstructorDialog() {
    final nameController = TextEditingController();
    final styleController = TextEditingController();
    final rankController = TextEditingController();
    final contactController = TextEditingController();
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1A1A),
                      const Color(0xFF2A2A2A),
                      const Color(0xFF1F1F1F),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person_add,
                              size: 20,
                              color: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Add Instructor',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDialogTextField(
                        controller: nameController,
                        label: 'Instructor Name',
                        hintText: 'Enter instructor name',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: styleController,
                        label: 'Martial Art Style',
                        hintText: 'e.g., BJJ, Karate, Muay Thai',
                        icon: Icons.sports_martial_arts,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: rankController,
                        label: 'Rank/Belt (Optional)',
                        hintText: 'e.g., Black Belt, Purple Belt',
                        icon: Icons.emoji_events,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: contactController,
                        label: 'Contact Info (Optional)',
                        hintText: 'Phone, email, or social media',
                        icon: Icons.contact_phone,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: notesController,
                        label: 'Notes (Optional)',
                        hintText: 'Additional notes about the instructor',
                        icon: Icons.note,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.withOpacity(0.2),
                                      Colors.grey.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                if (nameController.text.trim().isNotEmpty) {
                                  final newInstructor = {
                                    'name': nameController.text.trim(),
                                    'style': styleController.text.trim(),
                                    'rank': rankController.text.trim(),
                                    'contact': contactController.text.trim(),
                                    'notes': notesController.text.trim(),
                                  };
                                  
                                  await InstructorService.addInstructor(newInstructor);
                                  await _loadInstructors();
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.grey[100]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Add Instructor',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
              ),
            );
          },
        );
      },
    );
  }

  void _showEditInstructorDialog(int index) {
    final instructor = _instructors[index];
    final nameController = TextEditingController(text: instructor['name']);
    final styleController = TextEditingController(text: instructor['style']);
    final rankController = TextEditingController(text: instructor['rank'] ?? '');
    final contactController = TextEditingController(text: instructor['contact'] ?? '');
    final notesController = TextEditingController(text: instructor['notes'] ?? '');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1A1A),
                      const Color(0xFF2A2A2A),
                      const Color(0xFF1F1F1F),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Edit Instructor',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDialogTextField(
                        controller: nameController,
                        label: 'Instructor Name',
                        hintText: 'Enter instructor name',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: styleController,
                        label: 'Martial Art Style',
                        hintText: 'e.g., BJJ, Karate, Muay Thai',
                        icon: Icons.sports_martial_arts,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: rankController,
                        label: 'Rank/Belt (Optional)',
                        hintText: 'e.g., Black Belt, Purple Belt',
                        icon: Icons.emoji_events,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: contactController,
                        label: 'Contact Info (Optional)',
                        hintText: 'Phone, email, or social media',
                        icon: Icons.contact_phone,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: notesController,
                        label: 'Notes (Optional)',
                        hintText: 'Additional notes about the instructor',
                        icon: Icons.note,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.withOpacity(0.2),
                                      Colors.grey.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                if (nameController.text.trim().isNotEmpty) {
                                  final updatedInstructor = {
                                    'name': nameController.text.trim(),
                                    'style': styleController.text.trim(),
                                    'rank': rankController.text.trim(),
                                    'contact': contactController.text.trim(),
                                    'notes': notesController.text.trim(),
                                  };
                                  
                                  await InstructorService.updateInstructor(index, updatedInstructor);
                                  await _loadInstructors();
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.grey[100]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
              ),
            );
          },
        );
      },
    );
  }

  void _deleteInstructor(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Instructor',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${_instructors[index]['name']}?',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                await InstructorService.deleteInstructor(index);
                await _loadInstructors();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
} 