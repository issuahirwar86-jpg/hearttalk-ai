import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class HeartTalkApiClient {
  // Never store GEMINI_API_KEY in Flutter; pass via --dart-define=API_BASE_URL=https://...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ais-pre-df2flsftpiv5aai2ewqdy3-817611524917.asia-northeast1.run.app',
  );

  Stream<String> streamChat({
    required String modelId,
    required String message,
    required String language,
    required bool useWebSearch,
  }) async* {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final request = http.Request('POST', Uri.parse('$baseUrl/api/chat'))
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'text/event-stream';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.body = jsonEncode({
      'modelId': modelId,
      'provider': 'gemini',
      'message': message,
      'preferredLanguage': language,
      'useWebSearch': useWebSearch,
      'history': [],
    });

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('HeartTalk API error: ${response.statusCode}');
    }

    await for (final chunk in response.stream.transform(utf8.decoder)) {
      for (final line in chunk.split('\n')) {
        if (line.startsWith('data:')) {
          final payload = jsonDecode(line.substring(5).trim()) as Map<String, dynamic>;
          if (payload['text'] is String) {
            yield payload['text'] as String;
          }
        }
      }
    }
  }
}
