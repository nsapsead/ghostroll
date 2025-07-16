import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/app_text_field.dart';
import '../components/app_button.dart';
import '../components/gradient_card.dart';

// Body area data class
class BodyAreaData {
  final String name;
  final String displayName;
  final Color color;
  final IconData icon;
  final String description;
  final List<String> commonTechniques;

  const BodyAreaData({
    required this.name,
    required this.displayName,
    required this.color,
    required this.icon,
    required this.description,
    required this.commonTechniques,
  });
}

class LogSessionForm extends StatefulWidget {
  const LogSessionForm({super.key});

  @override
  State<LogSessionForm> createState() => _LogSessionFormState();
}

class _LogSessionFormState extends State<LogSessionForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _instructorController = TextEditingController();
  final _seedIdeaController = TextEditingController();
  final List<TextEditingController> _techniqueControllers = [TextEditingController()];
  final _keyTakeawayController = TextEditingController();
  int _comfortLevel = 1; // 0: happy, 1: neutral, 2: sad
  final _moodController = TextEditingController();
  final _winsControllers = List.generate(3, (_) => TextEditingController());
  final _stuckController = TextEditingController();
  final _questionsController = TextEditingController();
  final Map<String, BodyAreaData> _selectedBodyAreas = {};

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _instructorController.dispose();
    _seedIdeaController.dispose();
    for (final c in _techniqueControllers) c.dispose();
    _keyTakeawayController.dispose();
    _moodController.dispose();
    for (final c in _winsControllers) c.dispose();
    _stuckController.dispose();
    _questionsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      // Save logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Entry saved!'),
          backgroundColor: Colors.white.withOpacity(0.1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  // Body area definitions
  static const Map<String, BodyAreaData> _bodyAreas = {
    'head': BodyAreaData(
      name: 'head',
      displayName: 'Head',
      color: Colors.blue,
      icon: Icons.face,
      description: 'Head strikes, defense, and positioning',
      commonTechniques: ['Jab', 'Cross', 'Hook', 'Uppercut', 'Head movement', 'Blocking'],
    ),
    'neck': BodyAreaData(
      name: 'neck',
      displayName: 'Neck',
      color: Colors.cyan,
      icon: Icons.accessibility,
      description: 'Neck control and chokes',
      commonTechniques: ['Guillotine', 'Rear naked choke', 'Triangle', 'Neck control'],
    ),
    'shoulders': BodyAreaData(
      name: 'shoulders',
      displayName: 'Shoulders',
      color: Colors.indigo,
      icon: Icons.accessibility_new,
      description: 'Shoulder strikes and control',
      commonTechniques: ['Shoulder strikes', 'Shoulder control', 'Takedowns'],
    ),
    'chest': BodyAreaData(
      name: 'chest',
      displayName: 'Chest',
      color: Colors.green,
      icon: Icons.favorite,
      description: 'Chest strikes and control',
      commonTechniques: ['Body shots', 'Chest control', 'Pressure'],
    ),
    'core': BodyAreaData(
      name: 'core',
      displayName: 'Core',
      color: Colors.teal,
      icon: Icons.fitness_center,
      description: 'Core strength and control',
      commonTechniques: ['Core control', 'Hip movement', 'Balance'],
    ),
    'leftArm': BodyAreaData(
      name: 'leftArm',
      displayName: 'Left Arm',
      color: Colors.orange,
      icon: Icons.pan_tool,
      description: 'Left arm techniques and control',
      commonTechniques: ['Left jab', 'Left hook', 'Arm control', 'Grips'],
    ),
    'rightArm': BodyAreaData(
      name: 'rightArm',
      displayName: 'Right Arm',
      color: Colors.deepOrange,
      icon: Icons.pan_tool_alt,
      description: 'Right arm techniques and control',
      commonTechniques: ['Right cross', 'Right hook', 'Arm control', 'Grips'],
    ),
    'leftLeg': BodyAreaData(
      name: 'leftLeg',
      displayName: 'Left Leg',
      color: Colors.purple,
      icon: Icons.directions_walk,
      description: 'Left leg techniques and movement',
      commonTechniques: ['Left kick', 'Left knee', 'Footwork', 'Balance'],
    ),
    'rightLeg': BodyAreaData(
      name: 'rightLeg',
      displayName: 'Right Leg',
      color: Colors.deepPurple,
      icon: Icons.directions_run,
      description: 'Right leg techniques and movement',
      commonTechniques: ['Right kick', 'Right knee', 'Footwork', 'Balance'],
    ),
  };

  void _toggleBodyArea(String area) {
    setState(() {
      if (_selectedBodyAreas.containsKey(area)) {
        _selectedBodyAreas.remove(area);
      } else {
        _selectedBodyAreas[area] = _bodyAreas[area]!;
      }
    });
  }

  void _addTechnique() {
    setState(() {
      _techniqueControllers.add(TextEditingController());
    });
  }

  void _removeTechnique(int index) {
    if (_techniqueControllers.length > 1) {
      setState(() {
        _techniqueControllers[index].dispose();
        _techniqueControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          children: [
                            _buildFantasticSectionTitle('My breakdown of the class:'),
                            const SizedBox(height: AppSpacing.md),
                            _buildFantasticLabeledField(
                              label: 'Instructor:',
                              controller: _instructorController,
                              hintText: 'Who taught the class?',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildFantasticLabeledField(
                              label: 'Seed idea:',
                                controller: _seedIdeaController,
                              hintText: 'What was the main concept or technique?',
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildFantasticSectionTitle('Techniques I learned:'),
                            const SizedBox(height: AppSpacing.md),
                            ...List.generate(_techniqueControllers.length, (index) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildFantasticLabeledField(
                                      label: 'Technique ${index + 1}:',
                                      controller: _techniqueControllers[index],
                                      hintText: 'Describe the technique',
                                    ),
                                  ),
                                  if (_techniqueControllers.length > 1) ...[
                                    const SizedBox(width: AppSpacing.sm),
                                    GestureDetector(
                                      onTap: () => _removeTechnique(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.red.withOpacity(0.2),
                                              Colors.red.withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )),
                            const SizedBox(height: AppSpacing.sm),
                            GestureDetector(
                              onTap: _addTechnique,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'Add Technique',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  ),
                                ],
                              ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildFantasticSectionTitle('Key takeaway:'),
                            const SizedBox(height: AppSpacing.md),
                            _buildFantasticLabeledField(
                              label: 'What I learned:',
                              controller: _keyTakeawayController,
                              hintText: 'The most important thing I learned today',
                              minLines: 2,
                              maxLines: 3,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildFantasticSectionTitle('How I felt:'),
                            const SizedBox(height: AppSpacing.md),
                            _buildMoodSelector(),
                            const SizedBox(height: AppSpacing.md),
                            _buildFantasticLabeledField(
                              label: 'Mood notes:',
                                controller: _moodController,
                              hintText: 'Additional thoughts about how I felt',
                              minLines: 2,
                              maxLines: 3,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildFantasticSectionTitle('Body areas worked:'),
                            const SizedBox(height: AppSpacing.md),
                            _buildSimpleBodySection(),
                            const SizedBox(height: AppSpacing.lg),
                            _buildFantasticSectionTitle('My wins:'),
                            const SizedBox(height: AppSpacing.md),
                            ...List.generate(3, (index) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: _buildFantasticLabeledField(
                                label: 'Win ${index + 1}:',
                                controller: _winsControllers[index],
                                hintText: 'Something I did well',
                              ),
                            )),
                            const SizedBox(height: AppSpacing.lg),
                            _buildFantasticSectionTitle('Where I got stuck:'),
                            const SizedBox(height: AppSpacing.md),
                            _buildFantasticLabeledField(
                              label: 'Struggles:',
                                controller: _stuckController,
                              hintText: 'What was challenging or where I got stuck',
                              minLines: 2,
                              maxLines: 3,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildFantasticSectionTitle('Questions:'),
                            const SizedBox(height: AppSpacing.md),
                            _buildFantasticLabeledField(
                              label: 'Questions:',
                                controller: _questionsController,
                              hintText: 'What questions do I have?',
                              minLines: 2,
                              maxLines: 3,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            _buildSaveButton(),
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
      ),
    );
  }

  Widget _buildFantasticAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
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
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/ghostroll_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _save,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFantasticSectionTitle(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildFantasticLabeledField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int minLines = 1,
    int maxLines = 1,
    required String hintText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              validator: validator,
              minLines: minLines,
              maxLines: maxLines,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFantasticBlockLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

  Widget _buildFantasticOutlinedBlock(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildFantasticTextFormField({
    required TextEditingController controller,
    int minLines = 1,
    int maxLines = 1,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildFantasticNumberedField(int number, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildFantasticComfortIcon({
    required int value,
    required IconData icon,
    required String tooltip,
    required int groupValue,
    required ValueChanged<int> onChanged,
  }) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.3),
                    Colors.amber.withOpacity(0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.amber.withOpacity(0.5) : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 32,
          color: isSelected ? Colors.amber : Colors.white54,
        ),
      ),
    );
  }

  Widget _buildFantasticSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _save,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Text(
              'Save Entry',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return _buildFantasticOutlinedBlock([
      _buildFantasticBlockLabel('What was my mood coming into class?'),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFantasticComfortIcon(
            value: 0,
            icon: Icons.sentiment_satisfied_alt,
            tooltip: 'Happy',
            groupValue: _comfortLevel,
            onChanged: (v) => setState(() => _comfortLevel = v),
          ),
          _buildFantasticComfortIcon(
            value: 1,
            icon: Icons.sentiment_neutral,
            tooltip: 'Neutral',
            groupValue: _comfortLevel,
            onChanged: (v) => setState(() => _comfortLevel = v),
          ),
          _buildFantasticComfortIcon(
            value: 2,
            icon: Icons.sentiment_dissatisfied,
            tooltip: 'Uncomfortable',
            groupValue: _comfortLevel,
            onChanged: (v) => setState(() => _comfortLevel = v),
          ),
        ],
      ),
    ]);
  }

  Widget _buildSimpleBodySection() {
    return Column(
      children: [
        // Simple body selection
        _buildSimpleBodySelection(),
        const SizedBox(height: AppSpacing.lg),
        // Selected areas display
        if (_selectedBodyAreas.isNotEmpty) ...[
          _buildSelectedAreasDisplay(),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }

  Widget _buildSimpleBodySelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select body areas worked:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _bodyAreas.entries.map((entry) {
              final area = entry.value;
              final isSelected = _selectedBodyAreas.containsKey(area.name);
              
              return GestureDetector(
                onTap: () => _toggleBodyArea(area.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            area.color.withOpacity(0.3),
                            area.color.withOpacity(0.1),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                        ? area.color.withOpacity(0.6)
                        : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        area.icon,
                        color: isSelected ? area.color : Colors.white.withOpacity(0.6),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        area.displayName,
                        style: TextStyle(
                          color: isSelected ? area.color : Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: area.color,
                          size: 16,
                        ),
                      ],
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

  Widget _buildSelectedAreasDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Selected areas (${_selectedBodyAreas.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedBodyAreas.values.map((area) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: area.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: area.color.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      area.icon,
                      color: area.color,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      area.displayName,
                      style: TextStyle(
                        color: area.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _toggleBodyArea(area.name),
                      child: Icon(
                        Icons.close,
                        color: area.color,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }



  Widget _buildSaveButton() {
    return _buildFantasticSaveButton();
  }
}

 