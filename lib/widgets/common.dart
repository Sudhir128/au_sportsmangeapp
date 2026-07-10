import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

final supabase = Supabase.instance.client;

/// Animated dark gradient background with floating orb effects
class AppBackground extends StatefulWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: CustomPaint(
            painter: _OrbPainter(_controller.value),
            child: SafeArea(child: widget.child),
          ),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double animationValue;

  _OrbPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Floating orb 1 - blue
    final orb1X = size.width * 0.2 + sin(animationValue * 2 * pi) * 40;
    final orb1Y = size.height * 0.3 + cos(animationValue * 2 * pi) * 30;
    paint.shader = RadialGradient(
      colors: [
        AppTheme.primary.withValues(alpha: 0.15),
        AppTheme.primary.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(orb1X, orb1Y), radius: 120));
    canvas.drawCircle(Offset(orb1X, orb1Y), 120, paint);

    // Floating orb 2 - teal
    final orb2X = size.width * 0.8 + cos(animationValue * 2 * pi + 1) * 50;
    final orb2Y = size.height * 0.6 + sin(animationValue * 2 * pi + 1) * 40;
    paint.shader = RadialGradient(
      colors: [
        AppTheme.tertiary.withValues(alpha: 0.12),
        AppTheme.tertiary.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(orb2X, orb2Y), radius: 100));
    canvas.drawCircle(Offset(orb2X, orb2Y), 100, paint);

    // Floating orb 3 - cyan
    final orb3X = size.width * 0.5 + sin(animationValue * 2 * pi + 2) * 35;
    final orb3Y = size.height * 0.15 + cos(animationValue * 2 * pi + 2) * 25;
    paint.shader = RadialGradient(
      colors: [
        AppTheme.accent.withValues(alpha: 0.1),
        AppTheme.accent.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(orb3X, orb3Y), radius: 80));
    canvas.drawCircle(Offset(orb3X, orb3Y), 80, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class MenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: AppTheme.glassCardDecoration.copyWith(
            border: Border.all(
              color: _isHovered
                  ? AppTheme.primary.withValues(alpha: 0.3)
                  : AppTheme.primary.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onTap,
              onHover: (hovering) {
                setState(() => _isHovered = hovering);
                if (hovering) {
                  _hoverController.forward();
                } else {
                  _hoverController.reverse();
                }
              },
              splashColor: AppTheme.primary.withValues(alpha: 0.1),
              highlightColor: AppTheme.primary.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Gradient-accented snack bar with icon
void showAppSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (isError ? AppTheme.error : AppTheme.success)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppTheme.error : AppTheme.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.outfit(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: (isError ? AppTheme.error : AppTheme.success)
              .withValues(alpha: 0.2),
        ),
      ),
      elevation: 8,
    ),
  );
}
