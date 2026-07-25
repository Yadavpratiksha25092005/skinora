import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/doctor_models.dart';

class _LocalMessage {
  final String text;
  final bool isMe;
  _LocalMessage(this.text, this.isMe);
}

/// A local-only chat UI for testing the consultation flow.
/// NOTE: This does not connect to a real-time backend yet — messages only
/// exist within this screen's session. Real-time messaging (e.g. via
/// WebSocket or Firebase) is a future backend task.
class ConsultationChatScreen extends StatefulWidget {
  final Appointment appointment;

  const ConsultationChatScreen({super.key, required this.appointment});

  @override
  State<ConsultationChatScreen> createState() => _ConsultationChatScreenState();
}

class _ConsultationChatScreenState extends State<ConsultationChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_LocalMessage> _messages = [];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add(_LocalMessage(text, true)));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.appointment.patientName),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: const Color(0xFFFDF1E4),
              child: const Text(
                'This is a local test chat — not yet connected to real-time messaging.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: Color(0xFFB07A2E)),
              ),
            ),
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text('Say hello to start the consultation', style: TextStyle(color: Colors.grey.shade500)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return Align(
                          alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: msg.isMe ? AppTheme.primaryColor : AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(msg.text, style: TextStyle(color: msg.isMe ? Colors.white : AppTheme.textPrimaryColor)),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}