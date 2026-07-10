import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/widgets/common.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  static final List<EventItem> events = [
    EventItem(
      title: 'AU University Alumni Fair',
      description: 'Venue: American Center Chennai',
      date: 'November 18',
      imageAssetPath: 'lib/events/event2.jpg',
    ),
    EventItem(
      title: 'CTF Projects',
      description: 'Long term and short term projects',
      date: '2023-11-27',
      imageAssetPath: 'lib/events/event3.jpg',
    ),
    EventItem(
      title: 'VYUHAA 23',
      description: 'Events and carnivals',
      date: 'October 14',
      imageAssetPath: 'lib/events/event1.jpg',
    ),
    EventItem(
      title: 'VYUHAA 23 - EEE',
      description: 'X Hall, EEE Department',
      date: 'October 14',
      imageAssetPath: 'lib/events/event5.jpg',
    ),
    EventItem(
      title: 'Alumni Meet 23',
      description: 'Ramanujam Hall',
      date: 'October 15',
      imageAssetPath: 'lib/events/event4.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Events'),
      ),
      body: AppBackground(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
          itemCount: events.length,
          itemBuilder: (context, index) => EventCard(event: events[index]),
        ),
      ),
    );
  }
}

class EventItem {
  final String title;
  final String description;
  final String date;
  final String imageAssetPath;

  const EventItem({
    required this.title,
    required this.description,
    required this.date,
    required this.imageAssetPath,
  });
}

class EventCard extends StatelessWidget {
  final EventItem event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppTheme.glassCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Image.asset(
                event.imageAssetPath,
                fit: BoxFit.cover,
                height: 180,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: AppTheme.surfaceLight,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50, color: AppTheme.textSecondary),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.background.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Text(
                  event.title,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppTheme.accent),
                    const SizedBox(width: 8),
                    Text(
                      event.date,
                      style: GoogleFonts.outfit(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewImageScreen(
                          imagePath: event.imageAssetPath,
                          title: event.title,
                        ),
                      ),
                    ),
                    child: const Text('View Poster'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ViewImageScreen extends StatelessWidget {
  final String imagePath;
  final String title;

  const ViewImageScreen({super.key, required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title),
      ),
      body: InteractiveViewer(
        child: Center(
          child: Image.asset(
            imagePath,
            errorBuilder: (context, error, stackTrace) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 100, color: AppTheme.textSecondary),
                SizedBox(height: 16),
                Text('Image not found', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
