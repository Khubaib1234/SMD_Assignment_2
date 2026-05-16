import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_module/firebase_module.dart';
import 'topics_event.dart';
import 'topics_state.dart';

class TopicsBloc extends Bloc<TopicsEvent, TopicsState> {
  final IDbService _dbService;
  final IAuthService _authService;

  TopicsBloc(this._dbService, this._authService) : super(TopicsInitial()) {
    on<LoadTopics>(_onLoad);
    on<CreateTopic>(_onCreate);
  }

  Future<void> _onLoad(LoadTopics event, Emitter<TopicsState> emit) async {
    emit(TopicsLoading());
    try {
      await emit.forEach(
        _dbService.getTopics(),
        onData: (topics) {
          print('Topics loaded: ${topics.length}'); // ← add this
          return TopicsLoaded(topics);
        },
        onError: (e, __) {
          print('Error loading topics: $e');        // ← add this
          return TopicsError('Failed to load topics');
        },
      );
    } catch (e) {
      print('Caught error: $e');                    // ← add this
      emit(TopicsError(e.toString()));
    }
  }

  Future<void> _onCreate(CreateTopic event, Emitter<TopicsState> emit) async {
    emit(TopicCreating());
    try {
      final user = _authService.currentUser!;
      await _dbService.createTopic(TopicModel(
        id: '',
        title: event.title,
        originalPoster: user.displayName ?? 'Anonymous', // ← matches your model
        authorId: user.uid,
        creationDate: DateTime.now(),                    // ← matches your model
        isNew: true,                                     // ← matches your model
        replies: [],                                     // ← matches your model
      ));
      emit(TopicCreated());
    } catch (e) {
      emit(TopicsError(e.toString()));
    }
  }
}