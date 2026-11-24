import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class HeartTalkFirestoreService {
  static const String databaseId = 'ai-studio-0e3707ae-4557-48df-a5a7-d3ae7d01a008';

  FirebaseFirestore get db => FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      );

  User? get currentUser => FirebaseAuth.instance.currentUser;

  bool get isVerifiedUser =>
      currentUser != null && (currentUser?.emailVerified ?? false);

  Future<void> ensureUserProfile(User user) async {
    if (!user.emailVerified) return;
    final ref = db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;

    final rawName = user.displayName?.trim();
    final safeName = (rawName != null && rawName.isNotEmpty)
        ? rawName.substring(0, rawName.length > 100 ? 100 : rawName.length)
        : 'HeartTalk User';

    await ref.set({
      'userId': user.uid,
      'email': (user.email ?? 'user@hearttalk.ai').trim(),
      'displayName': safeName,
      'preferredLanguage': 'en',
      'memoryConsent': false,
      'ageConfirmed': false,
      'systemPrompt': '',
      'theme': 'light',
      'preferredModel': 'gemini-3.1-flash-lite',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createSession({
    required String sessionId,
    required String title,
    required String modelId,
    required String provider,
    required String preview,
  }) async {
    final user = currentUser;
    if (user == null || !user.emailVerified) return;

    await db
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .doc(sessionId)
        .set({
      'id': sessionId,
      'userId': user.uid,
      'title': title.length > 140 ? title.substring(0, 140) : title,
      'modelId': modelId,
      'provider': provider,
      'lastMessagePreview': preview.length > 240 ? preview.substring(0, 240) : preview,
      'messageCount': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveMessage({
    required String sessionId,
    required String messageId,
    required String role,
    required String content,
    required String modelId,
    required int tokenEstimate,
  }) async {
    final user = currentUser;
    if (user == null || !user.emailVerified) return;

    await db
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .doc(messageId)
        .set({
      'id': messageId,
      'userId': user.uid,
      'sessionId': sessionId,
      'role': role,
      'content': content.length > 32000 ? content.substring(0, 32000) : content,
      'modelId': modelId,
      'attachmentNames': <String>[],
      'citationTitles': <String>[],
      'citationUrls': <String>[],
      'tokenEstimate': tokenEstimate,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
