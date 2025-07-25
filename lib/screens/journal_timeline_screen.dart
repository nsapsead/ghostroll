import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../theme/ghostroll_theme.dart';
import '../theme/app_theme.dart';
import 'session_detail_view.dart';
import 'log_session_form.dart';
import '../services/session_service.dart';
import '../widgets/common/glow_text.dart';
import '../widgets/common/app_components.dart';

class JournalTimelineScreen extends StatefulWidget {
  const JournalTimelineScreen({super.key});

  @override
  State<JournalTimelineScreen> createState() => _JournalTimelineScreenState();
}

class _JournalTimelineScreenState extends State<JournalTimelineScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Session data
  List<Session> _sessions = [];
  List<Session> _filteredSessions = [];
  bool _isLoading = true;
  
  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  ClassType? _selectedClassTypeFilter;
  String? _selectedInstructorFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  bool _showFilters = false;
  
  // Available filter options
  List<String> _availableInstructors = [];

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
    
    _loadSessions();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Load sessions from storage
  Future<void> _loadSessions() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final sessions = await SessionService.loadSessions();
      
      // Get unique instructors for filter dropdown
      final instructors = sessions
          .where((s) => s.instructor != null && s.instructor!.isNotEmpty)
          .map((s) => s.instructor!)
          .toSet()
          .toList();
      
      setState(() {
        _sessions = sessions;
        _filteredSessions = sessions;
        _availableInstructors = instructors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading sessions: $e');
    }
  }

  // Refresh sessions when returning from other screens
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSessions();
  }

  // Perform search and filtering
  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredSessions = _sessions.where((session) {
        // Text search
        bool matchesSearch = true;
        if (query.isNotEmpty) {
          matchesSearch = session.focusArea.toLowerCase().contains(query) ||
              session.techniquesLearned.any((technique) => technique.toLowerCase().contains(query)) ||
              (session.sparringNotes?.toLowerCase().contains(query) ?? false) ||
              (session.reflection?.toLowerCase().contains(query) ?? false) ||
              (session.instructor?.toLowerCase().contains(query) ?? false);
        }
        
        // Class type filter
        bool matchesClassType = _selectedClassTypeFilter == null || 
            session.classType == _selectedClassTypeFilter;
        
        // Instructor filter
        bool matchesInstructor = _selectedInstructorFilter == null ||
            session.instructor == _selectedInstructorFilter;
        
        // Date range filter
        bool matchesDateRange = true;
        if (_startDateFilter != null && _endDateFilter != null) {
          matchesDateRange = session.date.isAfter(_startDateFilter!.subtract(const Duration(days: 1))) &&
              session.date.isBefore(_endDateFilter!.add(const Duration(days: 1)));
        }
        
        return matchesSearch && matchesClassType && matchesInstructor && matchesDateRange;
      }).toList();
    });
  }

  // Clear all filters
  void _clearFilters() {
    setState(() {
      _selectedClassTypeFilter = null;
      _selectedInstructorFilter = null;
      _startDateFilter = null;
      _endDateFilter = null;
      _searchController.clear();
    });
    _performSearch();
  }

  // Navigate to log session form
  void _navigateToLogSession() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogSessionForm()),
    ).then((_) {
      // Refresh sessions when returning
      _loadSessions();
    });
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
                        child: _isLoading
                            ? _buildLoadingState()
                            : _sessions.isEmpty
                                ? _buildEmptyState()
                                : Column(
                                    children: [
                                      _buildSearchAndFilters(),
                                      Expanded(
                                        child: _filteredSessions.isEmpty
                                            ? _buildNoResultsState()
                                            : SingleChildScrollView(
                                                padding: const EdgeInsets.all(24),
                                                child: _buildTimeline(),
                                              ),
                                      ),
                                    ],
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

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = ResponsiveUtils.isSmallPhone(screenWidth);
    
    return ResponsiveContainer(
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: GhostRollTheme.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: GhostRollTheme.medium,
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: GhostRollTheme.text,
                fontSize: ResponsiveUtils.responsiveFontSize(screenWidth, baseSize: 16),
              ),
              decoration: InputDecoration(
                hintText: isSmallScreen ? 'Search techniques...' : 'Search techniques, notes, focus areas...',
                hintStyle: TextStyle(
                  color: GhostRollTheme.textSecondary,
                  fontSize: ResponsiveUtils.responsiveFontSize(screenWidth, baseSize: 14),
                ),
                prefixIcon: Icon(
                  Icons.search, 
                  color: GhostRollTheme.textSecondary,
                  size: ResponsiveUtils.responsiveIconSize(screenWidth),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: Icon(
                          Icons.clear, 
                          color: GhostRollTheme.textSecondary,
                          size: ResponsiveUtils.responsiveIconSize(screenWidth),
                        ),
                      )
                    : IconButton(
                        onPressed: () => setState(() => _showFilters = !_showFilters),
                        icon: Icon(
                          _showFilters ? Icons.filter_list : Icons.tune,
                          color: _hasActiveFilters() ? GhostRollTheme.flowBlue : GhostRollTheme.textSecondary,
                          size: ResponsiveUtils.responsiveIconSize(screenWidth),
                        ),
                      ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              ),
            ),
          ),
          
          // Filters panel
          if (_showFilters) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GhostRollTheme.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: GhostRollTheme.medium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: GhostRollTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_hasActiveFilters())
                        TextButton(
                          onPressed: _clearFilters,
                          child: Text(
                            'Clear All',
                            style: TextStyle(color: GhostRollTheme.grindRed),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Class type filter
                  Text(
                    'Class Type',
                    style: GhostRollTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ClassType.values.map((classType) {
                      final isSelected = _selectedClassTypeFilter == classType;
                      return FilterChip(
                        selected: isSelected,
                        label: Text(classType.displayName),
                        onSelected: (selected) {
                          setState(() {
                            _selectedClassTypeFilter = selected ? classType : null;
                          });
                          _performSearch();
                        },
                        selectedColor: _getClassTypeColor(classType).withOpacity(0.3),
                        checkmarkColor: _getClassTypeColor(classType),
                      );
                    }).toList(),
                  ),
                  
                  if (_availableInstructors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Instructor',
                      style: GhostRollTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedInstructorFilter,
                      dropdownColor: GhostRollTheme.card,
                      decoration: InputDecoration(
                        hintText: 'Select instructor',
                        hintStyle: TextStyle(color: GhostRollTheme.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('All Instructors', style: TextStyle(color: GhostRollTheme.textSecondary)),
                        ),
                        ..._availableInstructors.map((instructor) => DropdownMenuItem(
                          value: instructor,
                          child: Text(instructor, style: TextStyle(color: GhostRollTheme.text)),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedInstructorFilter = value;
                        });
                        _performSearch();
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  Text(
                    'Date Range',
                    style: GhostRollTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDateFilter ?? DateTime.now().subtract(const Duration(days: 30)),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _startDateFilter = picked;
                              });
                              _performSearch();
                            }
                          },
                          child: Text(
                            _startDateFilter != null 
                                ? DateFormat('MMM dd').format(_startDateFilter!)
                                : 'Start Date',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _endDateFilter ?? DateTime.now(),
                              firstDate: _startDateFilter ?? DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _endDateFilter = picked;
                              });
                              _performSearch();
                            }
                          },
                          child: Text(
                            _endDateFilter != null 
                                ? DateFormat('MMM dd').format(_endDateFilter!)
                                : 'End Date',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedClassTypeFilter != null ||
           _selectedInstructorFilter != null ||
           _startDateFilter != null ||
           _endDateFilter != null;
  }

  Widget _buildNoResultsState() {
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
                Icons.search_off,
                size: 64,
                color: GhostRollTheme.text,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No sessions found',
              style: GhostRollTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _hasActiveFilters() 
                  ? 'Try adjusting your filters or search terms'
                  : 'No sessions match your search',
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: GhostRollTheme.flowBlue,
                foregroundColor: GhostRollTheme.text,
              ),
              child: const Text('Clear Filters'),
            ),
          ],
        ),
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
                Icons.history,
                size: 64,
                color: GhostRollTheme.text,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No sessions yet',
              style: GhostRollTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Log your first training session to get started',
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToLogSession,
              icon: const Icon(Icons.add),
              label: const Text('Log Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GhostRollTheme.flowBlue,
                foregroundColor: GhostRollTheme.text,
                elevation: 12,
                shadowColor: GhostRollTheme.flowBlue.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Training History',
          style: GhostRollTheme.headlineLarge.copyWith(
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
        ..._filteredSessions.map((session) => _buildSessionCard(session)),
      ],
    );
  }

  Widget _buildSessionCard(Session session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SessionDetailView(session: session),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GhostRollTheme.card,
            borderRadius: BorderRadius.circular(16),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getClassTypeColor(session.classType).withOpacity(0.2),
                              _getClassTypeColor(session.classType).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getClassTypeColor(session.classType).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _getClassTypeIcon(session.classType),
                          color: _getClassTypeColor(session.classType),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(session.date),
                            style: GhostRollTheme.titleLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE').format(session.date),
                            style: GhostRollTheme.bodySmall.copyWith(
                              color: GhostRollTheme.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      // Session type indicator (Scheduled vs Drop-in)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: session.isScheduledClass 
                            ? GhostRollTheme.recoveryGreen.withOpacity(0.2)
                            : GhostRollTheme.textTertiary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: session.isScheduledClass 
                              ? GhostRollTheme.recoveryGreen.withOpacity(0.4)
                              : GhostRollTheme.textTertiary.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          session.isScheduledClass ? 'Scheduled' : 'Drop-in',
                          style: GhostRollTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: session.isScheduledClass 
                              ? GhostRollTheme.recoveryGreen
                              : GhostRollTheme.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Class type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getClassTypeColor(session.classType),
                              _getClassTypeColor(session.classType).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _getClassTypeColor(session.classType).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          session.classTypeDisplay,
                          style: GhostRollTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                session.focusArea,
                style: GhostRollTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: GhostRollTheme.overlayDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.timer,
                      size: 16,
                      color: GhostRollTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${session.rounds} rounds',
                    style: GhostRollTheme.bodyMedium.copyWith(
                      color: GhostRollTheme.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (session.techniquesLearned.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: session.techniquesLearned
                      .take(3)
                      .map((technique) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: GhostRollTheme.overlayDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: GhostRollTheme.textSecondary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              technique,
                              style: GhostRollTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                if (session.techniquesLearned.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${session.techniquesLearned.length - 3} more techniques',
                      style: GhostRollTheme.bodySmall.copyWith(
                        color: GhostRollTheme.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getClassTypeColor(ClassType classType) {
    switch (classType) {
      case ClassType.gi:
        return GhostRollTheme.flowBlue;
      case ClassType.noGi:
        return GhostRollTheme.grindRed;
      case ClassType.striking:
        return GhostRollTheme.recoveryGreen;
      case ClassType.seminar:
        return const Color(0xFF9C27B0); // Purple for seminars
    }
  }

  IconData _getClassTypeIcon(ClassType classType) {
    switch (classType) {
      case ClassType.gi:
        return Icons.sports_martial_arts;
      case ClassType.noGi:
        return Icons.fitness_center;
      case ClassType.striking:
        return Icons.sports_kabaddi;
      case ClassType.seminar:
        return Icons.school;
    }
  }
} 