import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  final int id;
  final String name;
  final String email;
  final String rollnumber;
  final String? mobileNumber;
  final String? playerLevel;
  final String? bio;
  final String? favoriteSport;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.rollnumber,
    this.mobileNumber,
    this.playerLevel,
    this.bio,
    this.favoriteSport,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      rollnumber: map['rollnumber'] as String? ?? '',
      mobileNumber: map['mobilenumber']?.toString(),
      playerLevel: map['player_level'] as String?,
      bio: map['bio'] as String?,
      favoriteSport: map['favorite_sport'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'rollnumber': rollnumber,
        'mobilenumber': mobileNumber,
        'player_level': playerLevel,
        'bio': bio,
        'favorite_sport': favoriteSport,
      };
}

class SessionService {
  static const _userKey = 'au_sports_user';
  static AppUser? currentUser;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return;
    currentUser = AppUser.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> setUser(AppUser user) async {
    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }

  static Future<void> clear() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static bool get isLoggedIn => currentUser != null;
}
