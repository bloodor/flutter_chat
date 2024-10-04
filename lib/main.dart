import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'channel_list_page.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  final client = StreamChatClient(
    's7yt6hcn3q85',
    logLevel: Level.INFO,
  );
  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final StreamChatClient client;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  const MyApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloodor\'s Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, widget) {
        return StreamChat(
          client: client,
          child: widget,
        );
      },
      home: FutureBuilder<String?>(
        future: storage.read(key: 'token'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData && snapshot.data != null) {
            return ChannelListPage(client: client); // Navigate to ChatListPage if token exists
          } else {
            return AuthScreen();
          }
        },
      ),
      routes: {
        '/channelList': (context) => ChannelListPage(client: client), // Define the route for ChatListPage
      },
    );
  }
}