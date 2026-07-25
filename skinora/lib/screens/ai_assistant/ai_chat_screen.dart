import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_message.dart';
import '../../models/conversation.dart';
import '../../services/ai_chat_service.dart';
import '../../widgets/chat/chat_bubble.dart';
import '../../widgets/chat/typing_indicator.dart';
import '../../widgets/chat/suggestion_chip.dart';
import '../../widgets/chat/chat_empty_state.dart';

class AiChatScreen extends StatefulWidget {
  /// Pass an existing conversation to continue it, or leave null to start fresh.
  final Conversation? conversation;
  /// If provided, this question is sent automatically when the screen opens
  /// (used when tapping a suggestion chip from the AI Home screen).
  final String? initialMessage;

  const AiChatScreen({super.key, this.conversation, this.initialMessage});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final AiChatService _aiService = AiChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  late Conversation _conversation;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversation ??
        Conversation(id: _generateId(), title: 'New Conversation', messages: [], updatedAt: DateTime.now());

    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sendMessage(widget.initialMessage!));
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: _generateId(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _conversation.messages.add(userMessage);
      if (_conversation.messages.length == 1) {
        _conversation.title = _aiService.generateConversationTitle(text.trim());
      }
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

final reply = await _aiService.sendMessage(
      text.trim(),
      history: _conversation.messages.sublist(0, _conversation.messages.length - 1),
    );
    if (!mounted) return;
    setState(() {
      _conversation.messages.add(
        ChatMessage(id: _generateId(), text: reply, isUser: false, timestamp: DateTime.now()),
      );
      _conversation.updatedAt = DateTime.now();
      _isTyping = false;
    });
    _scrollToBottom();
    await _aiService.saveConversation(_conversation);
  }

  Future<void> _regenerateLastResponse() async {
    if (_conversation.messages.length < 2) return;
    // find last user message
    final lastUserMsg = _conversation.messages.lastWhere((m) => m.isUser, orElse: () => _conversation.messages.first);

    setState(() {
      _conversation.messages.removeLast(); // remove old AI reply
      _isTyping = true;
    });
    _scrollToBottom();

final reply = await _aiService.sendMessage(
      lastUserMsg.text,
      history: _conversation.messages.sublist(0, _conversation.messages.length - 1),
    );
    if (!mounted) return;
    setState(() {
      _conversation.messages.add(
        ChatMessage(id: _generateId(), text: reply, isUser: false, timestamp: DateTime.now()),
      );
      _isTyping = false;
    });
    await _aiService.saveConversation(_conversation);
  }

  Future<void> _clearConversation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear conversation'),
        content: const Text('This will remove all messages in this chat. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _conversation.messages.clear());
      await _aiService.deleteConversation(_conversation.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMessages = _conversation.messages.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          hasMessages ? _conversation.title : 'AI Assistant',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (hasMessages)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _clearConversation,
              tooltip: 'Clear conversation',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: !hasMessages && !_isTyping
                  ? const ChatEmptyState(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Ask me anything about skin, hair or wellness',
                      subtitle: 'I can help with routines, concerns, and general skincare guidance.',
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _conversation.messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _conversation.messages.length) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: TypingIndicator(),
                          );
                        }
                        final message = _conversation.messages[index];
                        final isLastAi = !message.isUser &&
                            index == _conversation.messages.length - 1;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ChatBubble(
                            message: message,
                            isLastAiMessage: isLastAi,
                            onRegenerate: isLastAi ? _regenerateLastResponse : null,
                          ),
                        );
                      },
                    ),
            ),

            // ---------- Quick suggestions (only show when chat is empty) ----------
            if (!hasMessages)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _aiService.suggestedQuestions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => SuggestionChip(
                      text: _aiService.suggestedQuestions[index],
                      onTap: () => _sendMessage(_aiService.suggestedQuestions[index]),
                    ),
                  ),
                ),
              ),

            // ---------- Input bar ----------
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
                        controller: _inputController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                        decoration: const InputDecoration(
                          hintText: 'Ask about skin, hair, or wellness...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendMessage(_inputController.text),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
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