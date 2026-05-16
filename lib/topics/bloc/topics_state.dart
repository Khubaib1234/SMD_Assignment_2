import 'package:firebase_module/firebase_module.dart';

abstract class TopicsState {}
class TopicsInitial extends TopicsState {}
class TopicsLoading extends TopicsState {}
class TopicsLoaded extends TopicsState {
  final List<TopicModel> topics;
  TopicsLoaded(this.topics);
}
class TopicsError extends TopicsState {
  final String message;
  TopicsError(this.message);
}
class TopicCreating extends TopicsState {}
class TopicCreated extends TopicsState {}