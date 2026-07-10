import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/services/room_service.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/widgets/common.dart';
import 'package:flutter_application_1/widgets/game_card.dart';
import 'package:intl/intl.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final _nameController = TextEditingController();
  final _sizeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _inTimeController = TextEditingController();
  final _outTimeController = TextEditingController();

  String _visibility = 'Public';
  String _sport = 'Cricket';
  bool _loading = false;

  static const sports = [
    'Cricket',
    'Football',
    'Handball',
    'Basketball',
    'Volleyball',
    'Throwball',
    'Kabaddi',
    'Badminton',
    'Ball Badminton',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _descriptionController.dispose();
    _inTimeController.dispose();
    _outTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.surface,
              dialBackgroundColor: AppTheme.surfaceLight,
              hourMinuteTextColor: AppTheme.textPrimary,
              dayPeriodTextColor: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted = DateFormat('HH:mm:ss').format(
        DateTime(2024, 1, 1, picked.hour, picked.minute),
      );
      controller.text = formatted;
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final size = int.tryParse(_sizeController.text) ?? 0;

    if (name.length < 4) {
      showAppSnackBar(context, 'Game name must be at least 4 characters.', isError: true);
      return;
    }
    if (size <= 0) {
      showAppSnackBar(context, 'Enter a valid player count.', isError: true);
      return;
    }
    if (_inTimeController.text.isEmpty || _outTimeController.text.isEmpty) {
      showAppSnackBar(context, 'Select start and end time.', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final room = await RoomService.createRoom(
        name: name,
        size: size,
        description: _descriptionController.text.trim(),
        isPublic: _visibility == 'Public',
        sport: _sport,
        inTime: _inTimeController.text,
        outTime: _outTimeController.text,
      );
      if (!mounted) return;
      showAppSnackBar(context, 'Hosted ${room.name} successfully!');
      Navigator.pop(context, room);
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
        title: const Text('Host a Game'),
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
                    'Set up your match',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Like TurfTown — create a game and let players join.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<String>(
                    initialValue: _sport,
                    dropdownColor: AppTheme.surfaceLight,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Sport'),
                    items: sports
                        .map((sport) => DropdownMenuItem(
                              value: sport,
                              child: Row(
                                children: [
                                  Icon(sportIcon(sport), size: 18, color: AppTheme.textSecondary),
                                  const SizedBox(width: 10),
                                  Text(sport),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _sport = value ?? _sport),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Game Name',
                      hintText: 'e.g. Evening Football 5v5',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _sizeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Total Players Needed',
                      hintText: 'e.g. 10',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _visibility,
                    dropdownColor: AppTheme.surfaceLight,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Visibility'),
                    items: const [
                      DropdownMenuItem(value: 'Public', child: Text('Public — anyone can join')),
                      DropdownMenuItem(value: 'Private', child: Text('Private — invite only')),
                    ],
                    onChanged: (value) => setState(() => _visibility = value ?? _visibility),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    maxLength: 300,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Notes for players',
                      hintText: 'Skill level, venue, equipment, etc.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TimeRow(
                    label: 'Start Time',
                    controller: _inTimeController,
                    onPick: () => _pickTime(_inTimeController),
                  ),
                  const SizedBox(height: 12),
                  _TimeRow(
                    label: 'End Time',
                    controller: _outTimeController,
                    onPick: () => _pickTime(_outTimeController),
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
                      onPressed: _loading ? null : _submit,
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
                          : const Text('Create & Host Game'),
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

class _TimeRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onPick;

  const _TimeRow({
    required this.label,
    required this.controller,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: true,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: const Icon(Icons.schedule),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: onPick,
          child: const Text('Pick'),
        ),
      ],
    );
  }
}
