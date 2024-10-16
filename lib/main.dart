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
  List<Map<String, dynamic>> _messages = []; // Store messages with timestamps
  int _secondsCounter = 0; // For counting seconds

  @override
  void initState() {
    super.initState();
    // Start the timer to count seconds
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _secondsCounter++;
      });
    });
  }

  void _resetSecondCounter() {
    _secondsCounter = 0;
  }

  // Function to handle message submission
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
        _controller.clear(); // Clear the text input

        _scrollToBottom();

        _addSystemResponse();
      });// Scroll to the bottom of the list
    }
  }

  void _addSystemResponse() {
    final timestamp = DateTime.now().toString();

    // Delay the system response by a short period to simulate real-time response
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _messages.add({
          'message': _secondsCounter.toString(),
          'timestamp': '',
          'isResponse': true,
        });
      });
      _scrollToBottom();
      _resetSecondCounter();
    });// Scroll to the bottom of the list
  }

  // Get the current time as a formatted string
  String _getCurrentTimestamp() {
    DateTime now = DateTime.now();
    return '${now.day}.${now.month}.${now.year} - ${now.hour}:${now.minute}';
  }

  // Scroll the list to the bottom whenever a new message is added
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
                final isResponse = _messages[index]['isResponse'];
                return Align(
                  alignment: isResponse
                      ? Alignment.centerLeft // System message (left side)
                      : Alignment.centerRight, // User message (right side)
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: 10, // Minimum width of the message container
                      maxWidth: MediaQuery.of(context).size.width * 0.7, // Maximum width (70% of screen width)
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isResponse
                          ? Colors.blueAccent.shade100 // Response message bubble color
                          : Colors.blueAccent.shade100, // User message bubble color
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Aligns text inside the bubble
                      children: [
                        if (!_messages[index]['isResponse'])
                          Text(
                            _messages[index]['timestamp']!,
                            style: const TextStyle(color: Colors.white70, fontSize: 10), // Timestamp styling
                          ),
                          const SizedBox(height: 3),
                        Text(
                          _messages[index]['message']!,
                          style: const TextStyle(color: Colors.white), // Message text color
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
                Text('$_secondsCounter'),
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
