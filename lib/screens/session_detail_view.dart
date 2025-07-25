import 'package:flutter/material.dart';
import '../models/session.dart';
import '../theme/ghostroll_theme.dart';

class SessionDetailView extends StatelessWidget {
  final Session session;

  const SessionDetailView({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GhostRollTheme.background,
      appBar: AppBar(
        title: Text('Session Details', style: GhostRollTheme.titleLarge),
        backgroundColor: GhostRollTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: GhostRollTheme.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildSessionInfoCard(),
            const SizedBox(height: 16),
            _buildTechniquesCard(),
            const SizedBox(height: 16),
            if (session.sparringNotes != null && session.sparringNotes!.isNotEmpty) ...[
              _buildNotesCard('Sparring Notes', session.sparringNotes!),
              const SizedBox(height: 16),
            ],
            if (session.reflection != null && session.reflection!.isNotEmpty) ...[
              _buildNotesCard('Reflection', session.reflection!),
              const SizedBox(height: 16),
            ],
            if (session.mood != null && session.mood!.isNotEmpty) ...[
              _buildMoodCard(),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhostRollTheme.overlayDark),
        boxShadow: GhostRollTheme.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Details',
            style: GhostRollTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Class Type', session.classTypeDisplay),
          _buildDetailRow('Focus Area', session.focusArea),
          _buildDetailRow('Rounds', '${session.rounds}'),
          _buildDetailRow('Date', _formatSessionDate(session.date)),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhostRollTheme.overlayDark),
        boxShadow: GhostRollTheme.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Information',
            style: GhostRollTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Duration', session.durationDisplay),
          if (session.location != null && session.location!.isNotEmpty)
            _buildDetailRow('Location', session.location!),
          if (session.instructor != null && session.instructor!.isNotEmpty)
            _buildDetailRow('Instructor', session.instructor!),
          _buildDetailRow('Session Type', _getSessionTypeDisplay(session.isScheduledClass)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GhostRollTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: GhostRollTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniquesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhostRollTheme.overlayDark),
        boxShadow: GhostRollTheme.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Techniques Learned',
            style: GhostRollTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (session.techniquesLearned.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: session.techniquesLearned.map((technique) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: GhostRollTheme.flowBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: GhostRollTheme.flowBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    technique,
                    style: GhostRollTheme.bodySmall.copyWith(
                      color: GhostRollTheme.flowBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ).toList(),
            )
          else
            Text(
              'No techniques recorded',
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhostRollTheme.overlayDark),
        boxShadow: GhostRollTheme.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GhostRollTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GhostRollTheme.bodyMedium.copyWith(
              color: GhostRollTheme.text,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GhostRollTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhostRollTheme.overlayDark),
        boxShadow: GhostRollTheme.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood',
            style: GhostRollTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: GhostRollTheme.recoveryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: GhostRollTheme.recoveryGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              session.mood!,
              style: GhostRollTheme.bodyMedium.copyWith(
                color: GhostRollTheme.recoveryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSessionDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _getSessionTypeDisplay(bool isScheduledClass) {
    return isScheduledClass ? 'Scheduled Class' : 'Drop-in Session';
  }
} 