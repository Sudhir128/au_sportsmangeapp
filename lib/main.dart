import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/supabase_config.dart';
import 'package:flutter_application_1/pages/Anouncement.dart';
import 'package:flutter_application_1/pages/Events.dart';
import 'package:flutter_application_1/pages/createroom.dart';
import 'package:flutter_application_1/pages/joinroom.dart';
import 'package:flutter_application_1/pages/loadpage.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/myApp_materialPage.dart';
import 'package:flutter_application_1/pages/myrooms.dart';
import 'package:flutter_application_1/pages/register.dart';
import 'package:flutter_application_1/pages/reset_password.dart';
import 'package:flutter_application_1/pages/room.dart';
import 'package:flutter_application_1/services/session_service.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  await SessionService.init();
  runApp(const AuSportsApp());
}

class AuSportsApp extends StatelessWidget {
  const AuSportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AU Sports',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoadingPage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const Home(),
        '/Sports': (_) => const RoomPage(),
        '/Anouncement': (_) => const AnnouncementsScreen(),
        '/Events': (_) => const EventListScreen(),
        '/Create Room': (_) => const CreateRoomPage(),
        '/Join Room': (_) => const JoinRoomPage(),
        '/My Room': (_) => const MyRoomsPage(),
        '/reset-password': (_) => const ResetPasswordPage(),
      },
    );
  }
}
