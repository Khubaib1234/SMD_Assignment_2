// 22K-4376 Khubaib Ahmed Jamil
// 22K-4367 Ayan Hasan
// 22K-4482 Muhammad Ahmed


import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_module/firebase_module.dart';
import 'package:uni_forums/auth/bloc/auth_bloc.dart';
import 'package:uni_forums/auth/bloc/auth_event.dart';
import 'package:uni_forums/auth/login_page.dart';
import 'package:uni_forums/topics/bloc/topics_bloc.dart';
import 'package:uni_forums/topics/bloc/topics_event.dart';
import 'package:uni_forums/topics/bloc/topics_state.dart';
import 'package:uni_forums/replies_page.dart';
import 'package:uni_forums/utility.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authService = AuthService();
  final dbService = DbService();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(create: (_) => authService),
        RepositoryProvider<DbService>(create: (_) => dbService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authService),
          ),
          BlocProvider<TopicsBloc>(
            create: (_) => TopicsBloc(dbService, authService)..add(LoadTopics()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAST NUCES Forums',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      // Check if user is already logged in
      home: context.read<AuthService>().currentUser != null
          ? const ForumsHome(title: 'FAST NUCES Forums')
          : const LoginPage(),
    );
  }
}

class ForumsHome extends StatelessWidget {
  const ForumsHome({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      drawer: const Drawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start new topic button
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
                            value: context.read<TopicsBloc>(),
                            child: const _NewTopicDialog(),
                          ),
                        );
                      },
                      child: const Text(
                        'Start new topic',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'Topics',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
            // ← NOW CONNECTED TO BLOC
            BlocBuilder<TopicsBloc, TopicsState>(
              builder: (context, state) {
                if (state is TopicsLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is TopicsError) {
                  return Center(child: Text(state.message));
                }
                if (state is TopicsLoaded) {
                  final topics = state.topics;
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: topics.length,
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          return Padding(
                            padding: index == 0
                                ? const EdgeInsets.only(top: 12.0)
                                : EdgeInsets.zero,
                            child: ListTile(
                              leading: topic.isNew
                                  ? const CircleAvatar(
                                      radius: 6,
                                      backgroundColor: Colors.deepOrange,
                                    )
                                  : Icon(
                                      Icons.star,
                                      size: 18,
                                      color: Colors.deepOrange.shade100,
                                    ),
                              trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatDate(topic.creationDate),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                topic.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "By ${topic.originalPoster}, ${formatDate(topic.creationDate)}"
                                "\n${topic.replies.length} REPLIES",
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RepliesPage(
                                      title: title,
                                      topic: topic,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('FAST NUCES Forums')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New Topic Dialog
class _NewTopicDialog extends StatefulWidget {
  const _NewTopicDialog();

  @override
  State<_NewTopicDialog> createState() => _NewTopicDialogState();
}

class _NewTopicDialogState extends State<_NewTopicDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TopicsBloc, TopicsState>(
      listener: (context, state) {
        if (state is TopicCreated) {
          Navigator.pop(context);
          // Reload topics after creating
          context.read<TopicsBloc>().add(LoadTopics());
        }
        if (state is TopicsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: const Text('New Topic'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Topic title',
                hintText: 'Enter your topic...',
              ),
              validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (state is TopicCreating)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<TopicsBloc>().add(
                          CreateTopic(_controller.text.trim()),
                        );
                  }
                },
                child: const Text(
                  'Post',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }
}