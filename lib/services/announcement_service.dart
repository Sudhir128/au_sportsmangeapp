import 'package:flutter_application_1/services/session_service.dart';
import 'package:flutter_application_1/utils/parse_utils.dart';
import 'package:flutter_application_1/widgets/common.dart';

class AnnouncementModel {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final String authorName;
  final DateTime? createdAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.authorName,
    this.createdAt,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: parseId(map['id']),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['image_url'] as String?,
      authorName: map['author_name'] as String? ?? 'AU Sports',
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
    );
  }
}

class AnnouncementService {
  static Future<List<AnnouncementModel>> fetchAnnouncements() async {
    final rows = await supabase
        .from('announcements')
        .select()
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => AnnouncementModel.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  static Future<void> createAnnouncement({
    required String title,
    required String description,
  }) async {
    final user = SessionService.currentUser;
    if (user == null) {
      throw Exception('Please log in to post an announcement.');
    }

    await supabase.from('announcements').insert({
      'title': title.trim(),
      'description': description.trim(),
      'author_name': user.name,
      'created_by': user.id,
    });
  }
}
