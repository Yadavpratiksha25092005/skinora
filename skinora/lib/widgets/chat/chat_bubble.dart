import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRegenerate;
  final bool isLastAiMessage;

  const ChatBubble({
    super.key,
    required this.message,
    this.onRegenerate,
    this.isLastAiMessage = false,
  });

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              gradient: isUser
                  ? const LinearGradient(colors: [AppTheme.primaryColor, Color(0xFFF7A8C4)])
                  : null,
              color: isUser ? null : AppTheme.surfaceColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: isUser ? Colors.white : AppTheme.textPrimaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                if (!isUser) ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _copyMessage(context),
                    child: Icon(Icons.copy_rounded, size: 14, color: Colors.grey.shade500),
                  ),
                  if (isLastAiMessage && onRegenerate != null) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onRegenerate,
                      child: Icon(Icons.refresh_rounded, size: 15, color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}