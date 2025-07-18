import 'package:flutter/material.dart';
import '../../theme/ghostroll_theme.dart';
import '../../services/calendar_service.dart';

class MonthlyCalendarView extends StatefulWidget {
  final DateTime month;
  final Function(CalendarEvent) onEventTap;
  final Function(DateTime) onDayTap;

  const MonthlyCalendarView({
    super.key,
    required this.month,
    required this.onEventTap,
    required this.onDayTap,
  });

  @override
  State<MonthlyCalendarView> createState() => _MonthlyCalendarViewState();
}

class _MonthlyCalendarViewState extends State<MonthlyCalendarView> {
  Map<DateTime, List<CalendarEvent>> _monthEvents = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthEvents();
  }

  @override
  void didUpdateWidget(MonthlyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month) {
      _loadMonthEvents();
    }
  }

  Future<void> _loadMonthEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final events = await CalendarService.getEventsForMonth(widget.month);
      setState(() {
        _monthEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading month events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: GhostRollTheme.card.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: GhostRollTheme.medium,
      ),
      child: Column(
        children: [
          _buildDaysOfWeekHeader(),
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GhostRollTheme.overlayDark.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getMonthYearString(widget.month),
            style: GhostRollTheme.titleLarge.copyWith(
              color: GhostRollTheme.text,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeekHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(
            color: GhostRollTheme.textSecondary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: List.generate(7, (index) {
          final dayOfWeek = index + 1; // 1 = Monday, 7 = Sunday
          return Expanded(
            child: Center(
              child: Text(
                CalendarService.getShortDayName(dayOfWeek),
                style: GhostRollTheme.bodySmall.copyWith(
                  color: GhostRollTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(widget.month.year, widget.month.month, 1);
    final lastDay = DateTime(widget.month.year, widget.month.month + 1, 0);
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday - 1));
    final endDate = lastDay.add(Duration(days: 7 - lastDay.weekday));

    final weeks = <List<DateTime>>[];
    var currentDate = startDate;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final week = <DateTime>[];
      for (int i = 0; i < 7; i++) {
        week.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
      weeks.add(week);
    }

    return Column(
      children: weeks.map((week) => _buildWeekRow(week)).toList(),
    );
  }

  Widget _buildWeekRow(List<DateTime> week) {
    return Expanded(
      child: Row(
        children: week.map((date) => _buildDayCell(date)).toList(),
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isCurrentMonth = date.month == widget.month.month;
    final isToday = _isToday(date);
    final dateKey = DateTime(date.year, date.month, date.day);
    final eventsForDay = _monthEvents[dateKey] ?? [];
    
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onDayTap(date),
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: isToday 
                ? GhostRollTheme.flowBlue.withOpacity(0.1)
                : Colors.transparent,
            border: isToday 
                ? Border.all(color: GhostRollTheme.flowBlue, width: 2)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day number
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isToday 
                              ? GhostRollTheme.flowBlue 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            date.day.toString(),
                            style: GhostRollTheme.bodySmall.copyWith(
                              color: isToday 
                                  ? Colors.white
                                  : isCurrentMonth 
                                      ? GhostRollTheme.text 
                                      : GhostRollTheme.textTertiary,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      // Event indicators
                      if (eventsForDay.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Expanded(
                          child: _buildEventIndicators(eventsForDay),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventIndicators(List<CalendarEvent> events) {
    // Group events by type for better display
    final recurringEvents = events.where((e) => e.type == CalendarEventType.recurringClass).toList();
    final dropInEvents = events.where((e) => e.type == CalendarEventType.dropInEvent).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show up to 3 event indicators
        ...events.take(3).map((event) => _buildEventIndicator(event)),
        // Show count if more than 3 events
        if (events.length > 3)
          Container(
            margin: const EdgeInsets.only(top: 1),
            child: Text(
              '+${events.length - 3} more',
              style: GhostRollTheme.bodySmall.copyWith(
                color: GhostRollTheme.textTertiary,
                fontSize: 8,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventIndicator(CalendarEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getEventColor(event),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              event.title,
              style: GhostRollTheme.bodySmall.copyWith(
                color: GhostRollTheme.text,
                fontSize: 8,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(CalendarEvent event) {
    switch (event.type) {
      case CalendarEventType.recurringClass:
        return GhostRollTheme.flowBlue;
      case CalendarEventType.dropInEvent:
        return GhostRollTheme.grindRed;
      default:
        return GhostRollTheme.recoveryGreen;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month]} ${date.year}';
  }
} 