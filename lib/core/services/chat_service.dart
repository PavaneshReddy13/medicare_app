import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendMessage(String chatId, String text) async {
    final user = _auth.currentUser;
    if (user == null || text.trim().isEmpty) return;

    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': user.uid,
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String getChatId(String user1Id, String user2Id) {
    // Ensures a consistent chat ID regardless of who initiates
    final ids = [user1Id, user2Id];
    ids.sort();
    return ids.join('_');
  }
}
