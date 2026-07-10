import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/services/room_service.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/utils/parse_utils.dart';

IconData sportIcon(String sport) {
  switch (sport.toLowerCase()) {
    case 'cricket':
      return Icons.sports_cricket;
    case 'football':
      return Icons.sports_soccer;
    case 'basketball':
      return Icons.sports_basketball;
    case 'volleyball':
      return Icons.sports_volleyball;
    case 'badminton':
    case 'ball badminton':
      return Icons.sports_tennis;
    case 'kabaddi':
    case 'handball':
    case 'throwball':
      return Icons.sports_martial_arts;
    default:
      return Icons.sports;
  }
}

Color _sportAccentColor(String sport) {
  switch (sport.toLowerCase()) {
    case 'cricket':
      return const Color(0xFF22C55E);
    case 'football':
      return const Color(0xFF0EA5E9);
    case 'basketball':
      return const Color(0xFFF97316);
    case 'volleyball':
      return const Color(0xFFEAB308);
    case 'badminton':
    case 'ball badminton':
      return const Color(0xFF8B5CF6);
    case 'kabaddi':
    case 'handball':
    case 'throwball':
      return const Color(0xFFEC4899);
    default:
      return AppTheme.primary;
  }
}

class SportChipBar extends StatelessWidget {
  final List<String> sports;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const SportChipBar({
    super.key,
    required this.sports,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildChip('All', null, selected == null),
          ),
          ...sports.map(
            (sport) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(sport, sport, selected == sport),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String? sport, bool isSelected) {
    final accentColor = sport != null ? _sportAccentColor(sport) : AppTheme.primary;

    return GestureDetector(
      onTap: () => onSelected(sport),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                )
              : null,
          color: isSelected ? null : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.5)
                : AppTheme.dividerColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sport != null) ...[
              Icon(sportIcon(sport), size: 16,
                color: isSelected ? Colors.white : AppTheme.textSecondary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback? onJoin;
  final VoidCallback? onTap;
  final bool showJoinButton;

  const GameCard({
    super.key,
    required this.room,
    this.onJoin,
    this.onTap,
    this.showJoinButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final spotsLeft = room.spotsLeft;
    final sportColor = _sportAccentColor(room.sport);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: AppTheme.glassCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: sportColor.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [sportColor, sportColor.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: sportColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(sportIcon(room.sport), color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            room.sport,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: sportColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusPill(
                      label: room.isJoinedByMe
                          ? 'Joined'
                          : room.isFull
                              ? 'Full'
                              : '$spotsLeft left',
                      color: room.isJoinedByMe
                          ? AppTheme.success
                          : room.isFull
                              ? AppTheme.error
                              : AppTheme.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.schedule,
                      label: '${formatTime(room.inTime)} - ${formatTime(room.outTime)}',
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.people_outline,
                      label: '${room.memberCount}/${room.size}',
                    ),
                  ],
                ),
                if (room.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    room.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (room.hostRollnumber != null && room.hostRollnumber!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Host roll: ${room.hostRollnumber}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                if (showJoinButton && onJoin != null) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: _GradientButton(
                      onPressed: room.isJoinedByMe || room.isFull ? null : onJoin,
                      label: room.isJoinedByMe
                          ? 'Already Joined'
                          : room.isFull
                              ? 'Game Full'
                              : 'Join Game',
                      gradient: room.isJoinedByMe || room.isFull
                          ? null
                          : LinearGradient(
                              colors: [sportColor, sportColor.withValues(alpha: 0.7)],
                            ),
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
}

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final LinearGradient? gradient;

  const _GradientButton({
    required this.onPressed,
    required this.label,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: isDisabled ? null : gradient ?? AppTheme.primaryGradient,
          color: isDisabled ? AppTheme.surfaceLight : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: (gradient?.colors.first ?? AppTheme.primary)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDisabled ? AppTheme.textSecondary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Icon(icon, size: 48, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
