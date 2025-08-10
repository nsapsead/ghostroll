import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/ghostroll_theme.dart';
import '../../services/calendar_service.dart';
import '../../models/class_schedule.dart';

class WeeklyCalendarView extends StatefulWidget {
  final DateTime weekStart;
  final Function(CalendarEvent) onEventTap;
  final Function(DateTime, TimeOfDay) onEmptySlotTap;

  const WeeklyCalendarView({
    super.key,
    required this.weekStart,
    required this.onEventTap,
    required this.onEmptySlotTap,
  });

  @override
  State<WeeklyCalendarView> createState() => _WeeklyCalendarViewState();
}

class _WeeklyCalendarViewState extends State<WeeklyCalendarView> {
  Map<DateTime, List<CalendarEvent>> _weekEvents = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeekEvents();
  }

  @override
  void didUpdateWidget(WeeklyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weekStart != widget.weekStart) {
      _loadWeekEvents();
    }
  }

  // Load events for the current week
  Future<void> _loadWeekEvents() async {
    try {
      final events = await CalendarService.getEventsForWeek(widget.weekStart);
      setState(() {
        _weekEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error loading week events: $e');
      setState(() {
        _isLoading = false;
      });
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
          _buildWeekHeader(),
          Expanded(
            child: _buildWeekGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader() {
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
        children: [
          // Time column header
          SizedBox(
            width: 60,
            child: Text(
              'Time',
              style: GhostRollTheme.bodySmall.copyWith(
                color: GhostRollTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Day headers
          ...List.generate(7, (index) {
            final date = widget.weekStart.add(Duration(days: index));
            final isToday = _isToday(date);
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      CalendarService.getShortDayName(date.weekday),
                      style: GhostRollTheme.bodySmall.copyWith(
                        color: isToday 
                            ? GhostRollTheme.flowBlue 
                            : GhostRollTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                                : GhostRollTheme.text,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeekGrid() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(24, (hour) => _buildHourRow(hour)),
      ),
    );
  }

  Widget _buildHourRow(int hour) {
    final timeString = '${hour.toString().padLeft(2, '0')}:00';
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: GhostRollTheme.textSecondary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Time label
          Container(
            width: 60,
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              CalendarService.formatTime(timeString),
              style: GhostRollTheme.bodySmall.copyWith(
                color: GhostRollTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Day columns
          ...List.generate(7, (dayIndex) {
            final date = widget.weekStart.add(Duration(days: dayIndex));
            final dateKey = DateTime(date.year, date.month, date.day);
            final eventsForDay = _weekEvents[dateKey] ?? [];
            final eventsForHour = eventsForDay.where((event) {
              final startHour = int.parse(event.startTime.split(':')[0]);
              final endHour = int.parse(event.endTime.split(':')[0]);
              return hour >= startHour && hour < endHour;
            }).toList();

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (eventsForHour.isEmpty) {
                    widget.onEmptySlotTap(date, TimeOfDay(hour: hour, minute: 0));
                  }
                },
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(right: 1),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: GhostRollTheme.textSecondary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    color: eventsForHour.isNotEmpty 
                        ? Colors.transparent
                        : GhostRollTheme.background.withOpacity(0.5),
                  ),
                  child: eventsForHour.isNotEmpty
                      ? _buildEventColumn(eventsForHour)
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEventColumn(List<CalendarEvent> events) {
    return Stack(
      children: events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;
        final offset = index * 2.0; // Slight offset for overlapping events
        
        return Positioned(
          left: offset,
          right: offset,
          top: 2,
          bottom: 2,
          child: GestureDetector(
            onTap: () => widget.onEventTap(event),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getEventColor(event),
                borderRadius: BorderRadius.circular(6),
                boxShadow: GhostRollTheme.small,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GhostRollTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CalendarService.formatTimeRange(event.startTime, event.endTime),
                    style: GhostRollTheme.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.location != null && event.location!.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      event.location!,
                      style: GhostRollTheme.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
} 