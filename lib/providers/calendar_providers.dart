import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/calendar_repository.dart';
import '../models/calendar_event.dart';
import 'auth_provider.dart';
import 'class_session_providers.dart';
import 'package:rxdart/rxdart.dart';

// Repository Provider
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository(FirebaseFirestore.instance);
});

// Stream of all calendar events for the current user
// Stream of personal calendar events
final personalCalendarEventsProvider = StreamProvider<List<CalendarEvent>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  
  return ref.watch(calendarRepositoryProvider).getEventsStream(user.uid);
});

// Stream of ALL calendar events (personal + club classes)
final calendarEventsProvider = StreamProvider<List<CalendarEvent>>((ref) {
  final personalEventsStream = ref.watch(personalCalendarEventsProvider.stream);
  final classSessionsStream = ref.watch(allUserClassSessionsProvider.stream);
  
  return Rx.combineLatest2(
    personalEventsStream, 
    classSessionsStream, 
    (List<CalendarEvent> personalEvents, List<dynamic> classSessions) {
      // Convert ClassSessions to CalendarEvents
      final classEvents = classSessions.map((session) {
        // We need to cast because dynamic is used in the signature above due to Riverpod type inference sometimes
        // But we know it's List<ClassSession>
        // Actually, let's just use dynamic and cast inside
        final s = session; 
        
        // Create a synthetic CalendarEvent from ClassSession
        // We prefix ID to avoid collision
        return CalendarEvent(
          id: 'class_${s.id}',
          title: s.focusArea ?? '${s.classType} Class',
          type: CalendarEventType.dropInEvent, // Treat as drop-in for display
          classType: s.classType, // This matches the string expected by UI
          specificDate: s.date,
          startTime: '${s.date.hour.toString().padLeft(2, '0')}:${s.date.minute.toString().padLeft(2, '0')}',
          endTime: '${s.date.add(Duration(minutes: s.duration ?? 60)).hour.toString().padLeft(2, '0')}:${s.date.add(Duration(minutes: s.duration ?? 60)).minute.toString().padLeft(2, '0')}',
          createdAt: s.createdAt,
          instructor: 'Club Class', // Or fetch instructor name if we had it
          location: 'Club', // Or fetch club name if we had it
          notes: 'Shared class session',
        );
      }).toList();
      
      return [...personalEvents, ...classEvents];
    }
  );
});

// Provider for upcoming classes (next 7 days)
final upcomingClassesProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final eventsAsync = ref.watch(calendarEventsProvider);
  
  return eventsAsync.whenData((events) {
    final now = DateTime.now();
    List<Map<String, dynamic>> upcomingClasses = [];
    
    // Check next 7 days
    for (int i = 0; i < 7; i++) {
      final dateToCheck = now.add(Duration(days: i));
      
      for (final event in events) {
        if (event.type == CalendarEventType.dropInEvent) {
          // Check if drop-in event is on this specific date
          if (event.specificDate != null && 
              event.specificDate!.year == dateToCheck.year &&
              event.specificDate!.month == dateToCheck.month &&
              event.specificDate!.day == dateToCheck.day) {
            
            // Parse start time
            final startTimeParts = event.startTime.split(':');
            final classDateTime = DateTime(
              dateToCheck.year,
              dateToCheck.month,
              dateToCheck.day,
              int.parse(startTimeParts[0]),
              int.parse(startTimeParts[1]),
            );
            
            if (classDateTime.isAfter(now)) {
              upcomingClasses.add(_createClassMap(event, dateToCheck, classDateTime));
            }
          }
        } else if (event.type == CalendarEventType.recurringClass) {
          // Check if recurring class occurs on this day of week and within date range
          final checkDate = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
          final startDate = event.recurringStartDate != null 
              ? DateTime(event.recurringStartDate!.year, event.recurringStartDate!.month, event.recurringStartDate!.day)
              : DateTime(event.createdAt.year, event.createdAt.month, event.createdAt.day);
          
          final dateString = checkDate.toIso8601String().split('T')[0];
          final isInDateRange = !checkDate.isBefore(startDate) && 
              (event.recurringEndDate == null || !checkDate.isAfter(
                  DateTime(event.recurringEndDate!.year, event.recurringEndDate!.month, event.recurringEndDate!.day)));
          final isNotDeleted = !event.deletedInstances.contains(dateString);
          
          if (event.dayOfWeek == dateToCheck.weekday && isInDateRange && isNotDeleted) {
            // Parse start time
            final startTimeParts = event.startTime.split(':');
            final classDateTime = DateTime(
              dateToCheck.year,
              dateToCheck.month,
              dateToCheck.day,
              int.parse(startTimeParts[0]),
              int.parse(startTimeParts[1]),
            );
            
            if (classDateTime.isAfter(now)) {
              upcomingClasses.add(_createClassMap(event, dateToCheck, classDateTime));
            }
          }
        }
      }
    }
    
    // Sort by date and time
    upcomingClasses.sort((a, b) {
      final dateTimeA = DateTime.parse(a['dateTime']);
      final dateTimeB = DateTime.parse(b['dateTime']);
      return dateTimeA.compareTo(dateTimeB);
    });
    
    return upcomingClasses;
  });
});

Map<String, dynamic> _createClassMap(CalendarEvent event, DateTime date, DateTime dateTime) {
  return {
    'id': event.id,
    'classType': event.classType,
    'dayOfWeek': event.dayOfWeek ?? date.weekday,
    'startTime': event.startTime,
    'endTime': event.endTime,
    'location': event.location ?? '',
    'instructor': event.instructor ?? '',
    'notes': event.notes ?? '',
    'date': date.toIso8601String().split('T')[0],
    'dateTime': dateTime.toIso8601String(),
    'type': event.type.name,
  };
}
