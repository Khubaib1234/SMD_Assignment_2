import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_forums/utility.dart';
import 'package:firebase_module/firebase_module.dart';
import 'package:uni_forums/replies/bloc/replies_bloc.dart';
import 'package:uni_forums/replies/bloc/replies_event.dart';
import 'package:uni_forums/replies/bloc/replies_state.dart';

class RepliesPage extends StatelessWidget {
  const RepliesPage({super.key, required this.title, required this.topic});

  final String title;
  final TopicModel topic;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RepliesBloc(
        context.read<DbService>(),
        context.read<AuthService>(),
      )..add(LoadReplies(topic.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _RepliesBody(topic: topic),
          ),
        ),
      ),
    );
  }
}

class _RepliesBody extends StatelessWidget {
  const _RepliesBody({required this.topic});
  final TopicModel topic;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepliesBloc, RepliesState>(
      builder: (context, state) {
        return Column(
          children: [
            const SizedBox(height: 16),

            // Topic header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    Text(
                      'By ${topic.originalPoster},',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatDate(topic.creationDate),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            // Reply button
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Colors.deepOrange,
                        ),
                      ),
                      onPressed: () {
                        // ← NOW CONNECTED
                        showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: context.read<RepliesBloc>(),
                            child: _ReplyDialog(topicId: topic.id),
                          ),
                        );
                      },
                      child: const Text(
                        'Reply to this topic',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Loading state
            if (state is RepliesLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            // Error state
            else if (state is RepliesError)
              Center(child: Text(state.message))
            // Loaded state
            else if (state is RepliesLoaded)
              ...state.replies.map((reply) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey.shade200,
                            child: ClipOval(
                              child: Image.network(
                                reply.avatarUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.person,
                                  size: 24,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_horiz),
                          ),
                          title: Text(
                            reply.replier,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Posted ${formatDate(reply.replyDate)}',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            reply.content,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {},
                                label: const Text('Quote'),
                                icon: const Icon(Icons.add),
                              ),
                              Expanded(child: Container()),
                              IconButton(
                                onPressed: () {},
                                icon: Badge(
                                  isLabelVisible: true,
                                  label: Text(reply.likes.toString()),
                                  child: const Icon(Icons.favorite),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

// Reply Dialog
class _ReplyDialog extends StatefulWidget {
  const _ReplyDialog({required this.topicId});
  final String topicId;

  @override
  State<_ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<_ReplyDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RepliesBloc, RepliesState>(
      listener: (context, state) {
        if (state is ReplyPosted) {
          Navigator.pop(context);
          // Reload replies after posting
          context.read<RepliesBloc>().add(LoadReplies(widget.topicId));
        }
        if (state is RepliesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Add Reply'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your reply',
                hintText: 'Write your reply here...',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Please enter a reply' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (state is ReplyPosting)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<RepliesBloc>().add(
                          AddReply(
                            widget.topicId,
                            _controller.text.trim(),
                          ),
                        );
                  }
                },
                child: const Text(
                  'Post Reply',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }
}