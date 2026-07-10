import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/widgets/common.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Announcements'),
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
          children: const [
            AnnouncementCard(
              title: 'Football Tryouts Next Week',
              content: 'The university football team is holding open tryouts next Wednesday at 5 PM on the main field. Bring your own cleats.',
              date: 'Oct 15, 2023',
              icon: Icons.sports_soccer,
              color: Color(0xFF0EA5E9),
            ),
            AnnouncementCard(
              title: 'Basketball Court Maintenance',
              content: 'Indoor basketball courts 1 and 2 will be closed for floor maintenance until Friday.',
              date: 'Oct 14, 2023',
              icon: Icons.sports_basketball,
              color: Color(0xFFF97316),
            ),
            AnnouncementCard(
              title: 'New Badminton Nets Installed',
              content: 'We have installed brand new professional nets in the badminton arena. Enjoy your games!',
              date: 'Oct 12, 2023',
              icon: Icons.sports_tennis,
              color: Color(0xFF8B5CF6),
            ),
            AnnouncementCard(
              title: 'Inter-Department Cricket Tournament',
              content: 'Registration is now open for the annual inter-department cricket tournament. Submit your team rosters to the sports desk by next Friday.',
              date: 'Oct 10, 2023',
              icon: Icons.sports_cricket,
              color: Color(0xFF22C55E),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final IconData icon;
  final Color color;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.glassCardDecoration.copyWith(
        border: Border(
          left: BorderSide(color: color, width: 4),
          top: BorderSide(color: AppTheme.dividerColor),
          right: BorderSide(color: AppTheme.dividerColor),
          bottom: BorderSide(color: AppTheme.dividerColor),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Spacer(),
                Text(
                  date,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
