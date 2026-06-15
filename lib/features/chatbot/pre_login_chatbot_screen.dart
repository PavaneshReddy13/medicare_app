import 'package:flutter/material.dart';

class PreLoginChatbotScreen extends StatefulWidget {
  const PreLoginChatbotScreen({super.key});

  @override
  State<PreLoginChatbotScreen> createState() => _PreLoginChatbotScreenState();
}

class _PreLoginChatbotScreenState extends State<PreLoginChatbotScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'bot', 'text': 'Hello! I am the MediCare Assistant. How can I help you today?'}
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _messageController.clear();
    });

    // Simple rule-based bot
    Future.delayed(const Duration(seconds: 1), () {
      String reply = "I'm sorry, I don't understand that. Please login to speak to a real doctor or receptionist.";
      final lower = text.toLowerCase();
      if (lower.contains('appointment') || lower.contains('book')) {
        reply = "To book an appointment, please create a Patient account and login. Then select 'Book Appointment' from your dashboard.";
      } else if (lower.contains('hello') || lower.contains('hi')) {
        reply = "Hi there! Welcome to MediCare.";
      } else if (lower.contains('emergency')) {
        reply = "If this is a medical emergency, please call your local emergency services immediately (e.g. 911).";
      }

      if (mounted) {
        setState(() {
          _messages.add({'role': 'bot', 'text': reply});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MediCare Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
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
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
