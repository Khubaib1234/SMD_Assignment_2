import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/topic_model.dart';
import '../models/reply.dart';

abstract class IDbService {
  Stream<List<TopicModel>> getTopics();
  Future<void> createTopic(TopicModel topic);
  Stream<List<ReplyModel>> getReplies(String topicId);
  Future<void> addReply(String topicId, ReplyModel reply);
}

class DbService implements IDbService {
  final FirebaseFirestore _firestore;

  DbService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<TopicModel>> getTopics() {
    return _firestore
        .collection('topics')
        .orderBy('creationDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TopicModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> createTopic(TopicModel topic) async {
    await _firestore.collection('topics').add(topic.toMap());
  }

  @override
  Stream<List<ReplyModel>> getReplies(String topicId) {
    return _firestore
        .collection('topics')
        .doc(topicId)
        .collection('replies')
        .orderBy('replyDate')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ReplyModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> addReply(String topicId, ReplyModel reply) async {
    await _firestore
    .collection('topics')
    .doc(topicId)
    .collection('replies')
    .add(reply.toMap());
  }
}