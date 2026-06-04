import 'package:flow_queue/flow_queue.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final queue = FlowQueue('post_queue');

  await queue.init();

  runApp(MyApp(queue));
}

class MyApp extends StatelessWidget {
  final FlowQueue queue;

  const MyApp(this.queue, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(queue: queue),
    );
  }
}

class HomePage extends StatelessWidget {
  final FlowQueue queue;

  const HomePage({
    super.key,
    required this.queue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow Queue'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final id = await queue.add(
              processName: 'upload_post',
              priority: QueuePriority.high,
              function: () async {
                await Future<void>.delayed(
                  const Duration(seconds: 5),
                );

                debugPrint('Uploaded');
              },
            );

            queue.listen(id).listen((task) {
              debugPrint(task.state.name);
            });
          },
          child: const Text('Upload'),
        ),
      ),
    );
  }
}
