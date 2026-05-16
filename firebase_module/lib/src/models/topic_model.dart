import 'package:cloud_firestore/cloud_firestore.dart';
import 'reply.dart';

class TopicModel {
  final String id;
  final String title;
  final String originalPoster;  // ← matches main.dart usage
  final String authorId;
  final DateTime creationDate;  // ← matches main.dart usage
  final bool isNew;             // ← matches main.dart usage
  List<ReplyModel> replies;     // ← matches main.dart usage

  TopicModel({
    required this.id,
    required this.title,
    required this.originalPoster,
    required this.authorId,
    required this.creationDate,
    required this.isNew,
    required this.replies,
  });

  factory TopicModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TopicModel(
      id: id,
      title: data['title'] ?? '',
      originalPoster: data['originalPoster'] ?? '',
      authorId: data['authorId'] ?? '',
      creationDate: (data['creationDate'] as Timestamp).toDate(),
      isNew: data['isNew'] ?? true,
      replies: (data['replies'] as List<dynamic>? ?? [])
          .map((r) => ReplyModel.fromMap(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'originalPoster': originalPoster,
      'authorId': authorId,
      'creationDate': Timestamp.fromDate(creationDate),
      'isNew': isNew,
      'replies': replies.map((r) => r.toMap()).toList(),
    };
  }
}