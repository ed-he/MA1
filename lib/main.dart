import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Counter App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My Counter App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  int _secondsCounter = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _secondsCounter++;
      });
    });
  }

  void _resetSecondCounter() {
    _secondsCounter = 0;
  }

  void _submitMessage() {
    if (_controller.text.isNotEmpty) {
      String message = _controller.text;
      String timestamp = _getCurrentTimestamp();
      setState(() {
        _messages.add({
          'message': message,
          'timestamp': timestamp,
          'isResponse': false,
        });
        _controller.clear();

        _scrollToBottom();

        _addSystemResponse();
      });
    }
  }

  void _addSystemResponse() {
    final timestamp = DateTime.now().toString();

    _resetSecondCounter();

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _messages.add({
          'message': _secondsCounter.toString(),
          'timestamp': timestamp,
          'isResponse': true,
        });
      });
      _scrollToBottom();
    });
    _timer?.cancel();
    const Duration duration = Duration(seconds: 1);
    _timer = Timer.periodic(duration, (timer) {
      setState(() {
        _messages[_messages.length - 1]['message'] = _secondsCounter.toString();
      });
    });
  }

  String _getCurrentTimestamp() {
    DateTime now = DateTime.now();
    return '${now.day}.${now.month}.${now.year} - ${now.hour}:${now.minute}';
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Counter App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> message = _messages[index];
                final isResponse = message['isResponse'];
                return Align(
                  alignment: isResponse
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: 10,
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isResponse
                          ? Colors.blueAccent.shade100
                          : Colors.blueAccent.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isResponse)
                          Text(
                            message['timestamp'],
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                          const SizedBox(height: 3),
                        Text(
                          message['message'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Text input',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
