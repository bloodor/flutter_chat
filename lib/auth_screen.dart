import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  late StreamChatClient _client;
  Channel? _channel;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _client = StreamChatClient(
      's7yt6hcn3q85',
      logLevel: Level.INFO,
    );
  }

  Future<void> _register() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storage.write(key: 'token', value: data['token']);
      await _connectUser(data['streamToken']);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User registered')));
      Navigator.pushReplacementNamed(context, '/channelList');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed')));
    }
  }

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storage.write(key: 'token', value: data['token']);
      await _connectUser(data['streamToken']);
      Navigator.pushReplacementNamed(context, '/channelList');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed')));
    }
  }

Future<void> _connectUser(String token) async {
  // Extract the user ID from the token
  final userId = _usernameController.text;

  await _client.connectUser(
    User(id: userId),
    token,
  );

  final channel = _client.channel('messaging', id: '0dcf37de-a492-4ee1-ad9b-2b3a81e56c99');
  await channel.watch();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),
            const SizedBox(height: 10), // Add space between the buttons
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}