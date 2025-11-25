import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event.dart';

class CalendarRepository {
  final FirebaseFirestore _firestore;

  CalendarRepository(this._firestore);

  // Get stream of calendar events for a user
  Stream<List<CalendarEvent>> getEventsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('calendar_events')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure ID is set from doc ID if not present
        data['id'] = doc.id;
        return CalendarEvent.fromJson(data);
      }).toList();
    });
  }

  // Add a new event
  Future<void> addEvent(String userId, CalendarEvent event) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('calendar_events')
        .doc(event.id)
        .set(event.toJson());
  }

  // Update an existing event
  Future<void> updateEvent(String userId, CalendarEvent event) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('calendar_events')
        .doc(event.id)
        .update(event.toJson());
  }

  // Delete an event
  Future<void> deleteEvent(String userId, String eventId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('calendar_events')
        .doc(eventId)
        .delete();
  }

  // Delete a specific instance of a recurring event
  Future<void> deleteRecurringEventInstance(String userId, String eventId, DateTime date) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('calendar_events')
        .doc(eventId);

    final dateString = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final deletedInstances = List<String>.from(data['deletedInstances'] ?? []);

      if (!deletedInstances.contains(dateString)) {
        deletedInstances.add(dateString);
        transaction.update(docRef, {'deletedInstances': deletedInstances});
      }
    });
  }

  // Delete recurring event from a specific date forward
  Future<void> deleteRecurringEventFromDate(String userId, String eventId, DateTime fromDate) async {
    final endDate = fromDate.subtract(const Duration(days: 1));
    
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('calendar_events')
        .doc(eventId)
        .update({
      'recurringEndDate': endDate.toIso8601String(),
    });
  }
}
