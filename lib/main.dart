import 'package:flutter/material.dart';
import 'screens/call_screen.dart';

void main() {
  runApp(VideoCallApp());
}

class VideoCallApp extends StatelessWidget {
  const VideoCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Call App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CallScreen(),
    );
  }
}
