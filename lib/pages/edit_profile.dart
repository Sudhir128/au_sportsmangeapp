import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/session_service.dart';
import 'package:flutter_application_1/widgets/common.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/widgets/game_card.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _bioController = TextEditingController();
  String? _selectedLevel;
  String? _selectedSport;
  bool _loading = false;

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced', 'Professional'];
  final List<String> _sports = [
    'Cricket',
    'Football',
    'Basketball',
    'Volleyball',
    'Badminton',
    'Ball Badminton',
    'Handball',
    'Kabaddi',
    'Throwball',
  ];

  @override
  void initState() {
    super.initState();
    final user = SessionService.currentUser;
    if (user != null) {
      _bioController.text = user.bio ?? '';
      if (_levels.contains(user.playerLevel)) _selectedLevel = user.playerLevel;
      if (_sports.contains(user.favoriteSport)) _selectedSport = user.favoriteSport;
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = SessionService.currentUser;
    if (user == null) return;

    setState(() => _loading = true);
    try {
      await AuthService.updateProfile(
        id: user.id,
        playerLevel: _selectedLevel ?? '',
        bio: _bioController.text,
        favoriteSport: _selectedSport ?? '',
      );

      final updatedUser = AppUser(
        id: user.id,
        name: user.name,
        email: user.email,
        rollnumber: user.rollnumber,
        mobileNumber: user.mobileNumber,
        playerLevel: _selectedLevel,
        bio: _bioController.text,
        favoriteSport: _selectedSport,
      );
      await SessionService.setUser(updatedUser);

      if (!mounted) return;
      showAppSnackBar(context, 'Profile updated successfully.');
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, error.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edit Profile'),
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
          child: Container(
            decoration: AppTheme.glassDecoration,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Player Profile',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let others know your skill level and favorite sports.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLevel,
                    dropdownColor: AppTheme.surfaceLight,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Player Level',
                      prefixIcon: Icon(Icons.star_outline),
                    ),
                    items: _levels.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedLevel = value),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSport,
                    dropdownColor: AppTheme.surfaceLight,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Favorite Sport',
                      prefixIcon: Icon(Icons.sports_soccer),
                    ),
                    items: _sports.map((sport) {
                      return DropdownMenuItem(
                        value: sport,
                        child: Row(
                          children: [
                            Icon(sportIcon(sport), size: 18, color: AppTheme.textSecondary),
                            const SizedBox(width: 10),
                            Text(sport),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedSport = value),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 150,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'e.g. Left-arm spinner, plays on weekends',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
