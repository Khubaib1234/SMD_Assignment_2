import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_module/firebase_module.dart';
import 'replies_event.dart';
import 'replies_state.dart';

class RepliesBloc extends Bloc<RepliesEvent, RepliesState> {
  final IDbService _dbService;
  final IAuthService _authService;

  RepliesBloc(this._dbService, this._authService) : super(RepliesInitial()) {
    on<LoadReplies>(_onLoad);
    on<AddReply>(_onAddReply);
  }

  Future<void> _onLoad(LoadReplies event, Emitter<RepliesState> emit) async {
    emit(RepliesLoading());
    try {
      await emit.forEach(
        _dbService.getReplies(event.topicId),
        onData: (replies) => RepliesLoaded(replies),
        onError: (_, __) => RepliesError('Failed to load replies'),
      );
    } catch (e) {
      emit(RepliesError(e.toString()));
    }
  }

  Future<void> _onAddReply(AddReply event, Emitter<RepliesState> emit) async {
    emit(ReplyPosting());
    try {
      final user = _authService.currentUser!;
      await _dbService.addReply(
        event.topicId,
        ReplyModel(
          id: '',
          content: event.content,
          replier: user.displayName ?? 'Anonymous',
          authorId: user.uid,
          avatarUrl: '',
          replyDate: DateTime.now(),
          likes: 0,
        ),
      );
      emit(ReplyPosted());
    } catch (e) {
      emit(RepliesError(e.toString()));
    }
  }
}