import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PasswordGate extends StatefulWidget {
  final Widget child;
  const PasswordGate({required this.child, super.key});

  @override
  State<PasswordGate> createState() => _PasswordGateState();
}

class _PasswordGateState extends State<PasswordGate> {
  final TextEditingController _controller = TextEditingController();
  bool _unlocked = false;
  bool _checking = false;
  String? _error;
  final String _localStorageKey = 'afvr_unlocked';

  @override
  void initState() {
    super.initState();
    final unlocked = html.window.localStorage[_localStorageKey];
    if (unlocked == 'true') {
      setState(() => _unlocked = true);
    }
  }

  Future<void> _checkPassword() async {
    setState(() {
      _checking = true;
      _error = null;
    });

    final isValid = await _validatePassword(_controller.text);

    setState(() {
      _checking = false;
    });

    if (isValid) {
      html.window.localStorage[_localStorageKey] = 'true';
      setState(() => _unlocked = true);
    } else {
      setState(() => _error = 'Incorrect password');
    }
  }

Future<bool> _validatePassword(String input) async {
  final url = Uri.parse('https://script.google.com/macros/s/AKfycbySgTTsnK71SjkfWvjFKH6PThZhgMIl6SIaf-nAWALLcR1e5Nhveik3rgWROxL-VwaE/exec?password=$input');

  try {
    print('Sending GET to $url');
    final response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response.statusCode == 200 && response.body.trim() == 'ok';
  } catch (e) {
    print('Error during HTTP GET: $e');
    setState(() => _error = 'Network error');
    return false;
  }
}


  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter Password",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.grey,
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checking ? null : _checkPassword,
                child:
                    _checking
                        ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text("Unlock"),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
