// firebase_module/lib/src/models/reply_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReplyModel {
  final String id;
  final String content;
  final String replier;      // ← keep your name
  final String authorId;
  final String avatarUrl;    // ← keep your field
  final DateTime replyDate;  // ← keep your name
  final int likes;

  ReplyModel({
    required this.id,
    required this.content,
    required this.replier,
    required this.authorId,
    required this.avatarUrl,
    required this.replyDate,
    required this.likes,
  });

  // For reading from subcollection
  factory ReplyModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReplyModel(
      id: id,
      content: data['content'] ?? '',
      replier: data['replier'] ?? '',
      authorId: data['authorId'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      replyDate: (data['replyDate'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
    );
  }

  // For reading from embedded list inside topic
  factory ReplyModel.fromMap(Map<String, dynamic> data) {
    return ReplyModel(
      id: data['id'] ?? '',
      content: data['content'] ?? '',
      replier: data['replier'] ?? '',
      authorId: data['authorId'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      replyDate: (data['replyDate'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'replier': replier,
      'authorId': authorId,
      'avatarUrl': avatarUrl,
      'replyDate': Timestamp.fromDate(replyDate),
      'likes': likes,
    };
  }
}