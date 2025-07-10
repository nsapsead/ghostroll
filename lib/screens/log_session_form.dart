import 'package:flutter/material.dart';

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
  final _techniqueControllers = List.generate(4, (_) => TextEditingController());
  final _keyTakeawayController = TextEditingController();
  int _comfortLevel = 1; // 0: happy, 1: neutral, 2: sad
  final _moodController = TextEditingController();
  final _winsControllers = List.generate(3, (_) => TextEditingController());
  final _stuckController = TextEditingController();
  final _questionsController = TextEditingController();
  final Set<String> _selectedBodyAreas = {};

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

  void _handleBodyTap(Offset position, Size size) {
    final headRadius = size.width * 0.12;
    final headCenter = Offset(size.width * 0.5, headRadius + 8);
    final headRect = Rect.fromCircle(center: headCenter, radius: headRadius);
    
    final neckWidth = size.width * 0.06;
    final neckHeight = size.height * 0.06;
    final neckTop = headCenter.dy + headRadius;
    final neckLeft = size.width * 0.5 - neckWidth / 2;
    final neckRect = Rect.fromLTWH(neckLeft, neckTop, neckWidth, neckHeight);
    
    final torsoWidth = size.width * 0.5;
    final torsoHeight = size.height * 0.35;
    final torsoTop = neckTop + neckHeight;
    final torsoLeft = size.width * 0.5 - torsoWidth / 2;
    final torsoRect = Rect.fromLTWH(torsoLeft, torsoTop, torsoWidth, torsoHeight);
    
    final armWidth = size.width * 0.06;
    final armHeight = size.height * 0.2;
    
    final leftArmLeft = torsoLeft - armWidth;
    final leftArmTop = torsoTop + torsoHeight * 0.1;
    final leftArmRect = Rect.fromLTWH(leftArmLeft, leftArmTop, armWidth, armHeight);
    
    final rightArmLeft = torsoLeft + torsoWidth;
    final rightArmTop = torsoTop + torsoHeight * 0.1;
    final rightArmRect = Rect.fromLTWH(rightArmLeft, rightArmTop, armWidth, armHeight);
    
    final legWidth = size.width * 0.1;
    final legHeight = size.height * 0.2;
    final legTop = torsoTop + torsoHeight;
    
    final leftLegLeft = size.width * 0.5 - legWidth - size.width * 0.04;
    final leftLegRect = Rect.fromLTWH(leftLegLeft, legTop, legWidth, legHeight);
    
    final rightLegLeft = size.width * 0.5 + size.width * 0.04;
    final rightLegRect = Rect.fromLTWH(rightLegLeft, legTop, legWidth, legHeight);
    
    setState(() {
      if (headRect.contains(position)) {
        _toggleBodyArea('head');
      } else if (neckRect.contains(position)) {
        _toggleBodyArea('neck');
      } else if (torsoRect.contains(position)) {
        _toggleBodyArea('torso');
      } else if (leftArmRect.contains(position)) {
        _toggleBodyArea('leftArm');
      } else if (rightArmRect.contains(position)) {
        _toggleBodyArea('rightArm');
      } else if (leftLegRect.contains(position)) {
        _toggleBodyArea('leftLeg');
      } else if (rightLegRect.contains(position)) {
        _toggleBodyArea('rightLeg');
      }
    });
  }

  void _toggleBodyArea(String area) {
    if (_selectedBodyAreas.contains(area)) {
      _selectedBodyAreas.remove(area);
    } else {
      _selectedBodyAreas.add(area);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0A0A),
                const Color(0xFF1A1A1A),
                const Color(0xFF0F0F0F),
              ],
              stops: const [0.0, 0.5, 1.0],
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
                          padding: const EdgeInsets.all(20),
                          children: [
                            _buildFantasticSectionTitle('My breakdown of the class:'),
                            const SizedBox(height: 16),
                            _buildFantasticLabeledField(
                              label: 'Instructor:',
                              controller: _instructorController,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 20),
                            _buildFantasticOutlinedBlock([
                              _buildFantasticBlockLabel('What was the seed idea/concept?'),
                              _buildFantasticTextFormField(
                                controller: _seedIdeaController,
                                minLines: 2,
                                maxLines: 4,
                                hintText: 'Describe the main concept...',
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildFantasticBlockLabel('What techniques came from this?'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _buildFantasticNumberedField(1, _techniqueControllers[0])),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildFantasticNumberedField(3, _techniqueControllers[2])),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _buildFantasticNumberedField(2, _techniqueControllers[1])),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildFantasticNumberedField(4, _techniqueControllers[3])),
                                ],
                              ),
                            ]),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildFantasticOutlinedBlock([
                                    _buildFantasticBlockLabel('What was my key take away?'),
                                    _buildFantasticTextFormField(
                                      controller: _keyTakeawayController,
                                      minLines: 2,
                                      maxLines: 3,
                                      hintText: 'Main lesson or insight...',
                                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                    ),
                                  ]),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFantasticOutlinedBlock([
                                    _buildFantasticBlockLabel('What was I using/attacking?'),
                                    const SizedBox(height: 16),
                                    _buildFantasticBodyDiagram(),
                                  ]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildFantasticOutlinedBlock([
                              _buildFantasticBlockLabel('What is my comfort level with these technique(s)?'),
                              const SizedBox(height: 16),
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
                            ]),
                            const SizedBox(height: 32),
                            _buildFantasticSectionTitle('Self reflection:'),
                            const SizedBox(height: 16),
                            _buildFantasticOutlinedBlock([
                              _buildFantasticBlockLabel('What was my mood coming into class?'),
                              _buildFantasticTextFormField(
                                controller: _moodController,
                                minLines: 1,
                                maxLines: 2,
                                hintText: 'Describe your mood...',
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _buildFantasticOutlinedBlock([
                              _buildFantasticBlockLabel('What 3 wins did I take away from this class?'),
                              const SizedBox(height: 12),
                              _buildFantasticNumberedField(1, _winsControllers[0]),
                              const SizedBox(height: 12),
                              _buildFantasticNumberedField(2, _winsControllers[1]),
                              const SizedBox(height: 12),
                              _buildFantasticNumberedField(3, _winsControllers[2]),
                            ]),
                            const SizedBox(height: 16),
                            _buildFantasticOutlinedBlock([
                              _buildFantasticBlockLabel('Where did I get stuck?'),
                              _buildFantasticTextFormField(
                                controller: _stuckController,
                                minLines: 1,
                                maxLines: 2,
                                hintText: 'Describe any challenges...',
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _buildFantasticOutlinedBlock([
                              _buildFantasticBlockLabel('What questions did I ask?'),
                              _buildFantasticTextFormField(
                                controller: _questionsController,
                                minLines: 1,
                                maxLines: 2,
                                hintText: 'List your questions...',
                              ),
                            ]),
                            const SizedBox(height: 40),
                            _buildFantasticSaveButton(),
                            const SizedBox(height: 40),
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
            height: 40,
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
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              validator: validator,
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

  Widget _buildFantasticBodyDiagram() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: GestureDetector(
        onTapDown: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final localPosition = renderBox.globalToLocal(details.globalPosition);
          _handleBodyTap(localPosition, renderBox.size);
        },
        child: CustomPaint(
          painter: BodyOutlinePainter(selectedAreas: _selectedBodyAreas),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app,
                  size: 24,
                  color: Colors.white54,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap body areas',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_selectedBodyAreas.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedBodyAreas.length} selected',
                    style: TextStyle(
                      color: Colors.red.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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
}

class BodyOutlinePainter extends CustomPainter {
  final Set<String> selectedAreas;
  
  BodyOutlinePainter({this.selectedAreas = const {}});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final selectedPaint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final selectedStrokePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Head
    final headRadius = size.width * 0.12;
    final headCenter = Offset(size.width * 0.5, headRadius + 8);
    final headRect = Rect.fromCircle(center: headCenter, radius: headRadius);
    
    if (selectedAreas.contains('head')) {
      canvas.drawOval(headRect, selectedPaint);
      canvas.drawOval(headRect, selectedStrokePaint);
    } else {
      canvas.drawOval(headRect, paint);
    }
    
    // Neck
    final neckWidth = size.width * 0.06;
    final neckHeight = size.height * 0.06;
    final neckTop = headCenter.dy + headRadius;
    final neckLeft = size.width * 0.5 - neckWidth / 2;
    final neckRect = Rect.fromLTWH(neckLeft, neckTop, neckWidth, neckHeight);
    
    if (selectedAreas.contains('neck')) {
      canvas.drawRect(neckRect, selectedPaint);
      canvas.drawRect(neckRect, selectedStrokePaint);
    } else {
      canvas.drawRect(neckRect, paint);
    }
    
    // Torso
    final torsoWidth = size.width * 0.5;
    final torsoHeight = size.height * 0.35;
    final torsoTop = neckTop + neckHeight;
    final torsoLeft = size.width * 0.5 - torsoWidth / 2;
    final torsoRect = Rect.fromLTWH(torsoLeft, torsoTop, torsoWidth, torsoHeight);
    
    if (selectedAreas.contains('torso')) {
      canvas.drawRect(torsoRect, selectedPaint);
      canvas.drawRect(torsoRect, selectedStrokePaint);
    } else {
      canvas.drawRect(torsoRect, paint);
    }
    
    // Arms
    final armWidth = size.width * 0.06;
    final armHeight = size.height * 0.2;
    
    // Left arm
    final leftArmLeft = torsoLeft - armWidth;
    final leftArmTop = torsoTop + torsoHeight * 0.1;
    final leftArmRect = Rect.fromLTWH(leftArmLeft, leftArmTop, armWidth, armHeight);
    
    if (selectedAreas.contains('leftArm')) {
      canvas.drawRect(leftArmRect, selectedPaint);
      canvas.drawRect(leftArmRect, selectedStrokePaint);
    } else {
      canvas.drawRect(leftArmRect, paint);
    }
    
    // Right arm
    final rightArmLeft = torsoLeft + torsoWidth;
    final rightArmTop = torsoTop + torsoHeight * 0.1;
    final rightArmRect = Rect.fromLTWH(rightArmLeft, rightArmTop, armWidth, armHeight);
    
    if (selectedAreas.contains('rightArm')) {
      canvas.drawRect(rightArmRect, selectedPaint);
      canvas.drawRect(rightArmRect, selectedStrokePaint);
    } else {
      canvas.drawRect(rightArmRect, paint);
    }
    
    // Legs
    final legWidth = size.width * 0.1;
    final legHeight = size.height * 0.2;
    final legTop = torsoTop + torsoHeight;
    
    // Left leg
    final leftLegLeft = size.width * 0.5 - legWidth - size.width * 0.04;
    final leftLegRect = Rect.fromLTWH(leftLegLeft, legTop, legWidth, legHeight);
    
    if (selectedAreas.contains('leftLeg')) {
      canvas.drawRect(leftLegRect, selectedPaint);
      canvas.drawRect(leftLegRect, selectedStrokePaint);
    } else {
      canvas.drawRect(leftLegRect, paint);
    }
    
    // Right leg
    final rightLegLeft = size.width * 0.5 + size.width * 0.04;
    final rightLegRect = Rect.fromLTWH(rightLegLeft, legTop, legWidth, legHeight);
    
    if (selectedAreas.contains('rightLeg')) {
      canvas.drawRect(rightLegRect, selectedPaint);
      canvas.drawRect(rightLegRect, selectedStrokePaint);
    } else {
      canvas.drawRect(rightLegRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 