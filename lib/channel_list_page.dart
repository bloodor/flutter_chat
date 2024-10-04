import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChannelListPage extends StatelessWidget {
  final StreamChatClient client;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  const ChannelListPage({Key? key, required this.client}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    // Clear the token from secure storage
    await storage.delete(key: 'token');
    // Navigate to the AuthScreen
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final controller = StreamChannelListController(
      client: client,
      filter: Filter.in_('type', ['messaging']),
      limit: 20,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Disconnect'),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamChannelListView(controller: controller),
    );
  }
}
class ChannelPage extends StatelessWidget {
  const ChannelPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: StreamChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamMessageListView(),
          ),
          StreamMessageInput(),
        ],
      ),
    );
  }
}