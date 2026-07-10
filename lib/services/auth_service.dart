import 'package:flutter_application_1/services/session_service.dart';
import 'package:flutter_application_1/widgets/common.dart';

class AuthService {
  static Future<AppUser> login({
    required String email,
    required String password,
    required String rollnumber,
  }) async {
    final data = await supabase
        .from('user')
        .select()
        .eq('email', email.trim())
        .eq('password', password)
        .eq('rollnumber', rollnumber.trim())
        .maybeSingle();

    if (data == null) {
      throw Exception('Invalid email, roll number, or password.');
    }

    final user = AppUser.fromMap(data);
    await SessionService.setUser(user);
    return user;
  }

  static Future<void> register({
    required String name,
    required String email,
    required String rollnumber,
    required String mobileNumber,
    required String password,
  }) async {
    final existing = await supabase
        .from('user')
        .select('id')
        .eq('email', email.trim())
        .maybeSingle();

    if (existing != null) {
      throw Exception('An account with this email already exists.');
    }

    final existingRoll = await supabase
        .from('user')
        .select('id')
        .eq('rollnumber', rollnumber.trim())
        .maybeSingle();

    if (existingRoll != null) {
      throw Exception('roll number already present');
    }

    await supabase.from('user').insert({
      'name': name.trim(),
      'email': email.trim(),
      'rollnumber': rollnumber.trim(),
      'mobilenumber': int.tryParse(mobileNumber) ?? mobileNumber,
      'password': password,
    });
  }

  static Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final existing = await supabase
        .from('user')
        .select('id')
        .eq('email', email.trim())
        .maybeSingle();

    if (existing == null) {
      throw Exception('No account found for this email.');
    }

    await supabase
        .from('user')
        .update({'password': newPassword})
        .eq('email', email.trim());
  }

  static Future<void> updateProfile({
    required int id,
    required String playerLevel,
    required String bio,
    required String favoriteSport,
  }) async {
    try {
      await supabase.from('user').update({
        'player_level': playerLevel,
        'bio': bio,
        'favorite_sport': favoriteSport,
      }).eq('id', id);
    } catch (e) {
      // Ignore database errors if columns do not exist yet.
    }
  }

  static Future<void> logout() => SessionService.clear();
}
