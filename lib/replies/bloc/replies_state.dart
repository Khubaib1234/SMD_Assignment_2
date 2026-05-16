import 'package:firebase_module/firebase_module.dart';  

abstract class RepliesState {}
class RepliesInitial extends RepliesState {}
class RepliesLoading extends RepliesState {}
class RepliesLoaded extends RepliesState {
  final List<ReplyModel> replies;
  RepliesLoaded(this.replies);
}
class RepliesError extends RepliesState {
  final String message;
  RepliesError(this.message);
}
class ReplyPosting extends RepliesState {}
class ReplyPosted extends RepliesState {}