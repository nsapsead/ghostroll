import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/ghostroll_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/club_providers.dart';
import '../../models/club.dart';
import '../../models/club_member.dart';
import '../../repositories/club_repository.dart';
import 'club_detail_screen.dart';

class CreateClubScreen extends ConsumerStatefulWidget {
  const CreateClubScreen({super.key});

  @override
  ConsumerState<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends ConsumerState<CreateClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _styleController = TextEditingController();
  final _websiteController = TextEditingController();
  
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _styleController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<void> _createClub() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final clubId = DateTime.now().millisecondsSinceEpoch.toString(); // Simple ID generation
      final joinCode = _generateJoinCode();

      final club = Club(
        id: clubId,
        name: _nameController.text.trim(),
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        style: _styleController.text.trim(),
        website: _websiteController.text.trim().isNotEmpty ? _websiteController.text.trim() : null,
        createdByUserId: user.uid,
        createdAt: DateTime.now(),
        joinCode: joinCode,
      );

      // Create club
      await ref.read(clubRepositoryProvider).createClub(club);

      // Add creator as owner
      final member = ClubMember(
        id: '${clubId}_${user.uid}',
        clubId: clubId,
        userId: user.uid,
        role: ClubRole.owner,
        joinedAt: DateTime.now(),
        displayNameOverride: user.displayName,
      );

      await ref.read(clubRepositoryProvider).addMember(member);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Club created successfully!')),
        );
        
        // Navigate to Club Detail, replacing the create screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ClubDetailScreen(clubId: clubId)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating club: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GhostRollTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create a Club', style: GhostRollTheme.textTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: GhostRollTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Club Details',
                style: GhostRollTheme.textSectionHeader,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: 'Club Name',
                icon: Icons.business,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      icon: Icons.location_city,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _countryController,
                      label: 'Country',
                      icon: Icons.public,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _styleController,
                label: 'Style (e.g. BJJ, MMA)',
                icon: Icons.sports_martial_arts,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _websiteController,
                label: 'Website (Optional)',
                icon: Icons.language,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createClub,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GhostRollTheme.activeHighlight,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Text('Create Club', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: GhostRollTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: GhostRollTheme.textSecondary),
        prefixIcon: Icon(icon, color: GhostRollTheme.textSecondary),
        filled: true,
        fillColor: GhostRollTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GhostRollTheme.activeHighlight),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }
}
