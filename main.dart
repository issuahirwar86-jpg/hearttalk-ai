import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/chat/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // After running `flutterfire configure`, pass options: DefaultFirebaseOptions.currentPlatform
  await Firebase.initializeApp();
  runApp(const HeartTalkApp());
}

class HeartTalkApp extends StatelessWidget {
  const HeartTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartTalk AI',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFBE123C),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFBE123C),
        brightness: Brightness.dark,
      ),
      home: const ChatScreen(),
    );
  }
}
