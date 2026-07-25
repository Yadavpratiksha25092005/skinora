import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../models/conversation.dart';
import '../../services/ai_chat_service.dart';
import '../../widgets/chat/suggestion_chip.dart';
import '../../widgets/chat/ai_insight_card.dart';
import '../../widgets/chat/conversation_tile.dart';
import '../../widgets/chat/chat_empty_state.dart';
import 'ai_chat_screen.dart';

class AiAssistantHomeScreen extends StatefulWidget {
  const AiAssistantHomeScreen({super.key});

  @override
  State<AiAssistantHomeScreen> createState() => _AiAssistantHomeScreenState();
}

class _AiAssistantHomeScreenState extends State<AiAssistantHomeScreen> {
  final AiChatService _aiService = AiChatService();
  List<Conversation> _conversations = [];
  bool _loading = true;

  static const Map<String, IconData> _insightIcons = {
    'skin': Icons.face_retouching_natural_rounded,
    'hair': Icons.spa_rounded,
    'water': Icons.water_drop_rounded,
    'uv': Icons.wb_sunny_rounded,
    'sleep': Icons.bedtime_rounded,
  };

  static const Map<String, Color> _insightColors = {
    'skin': AppTheme.primaryColor,
    'hair': Color(0xFFE0A5C7),
    'water': Color(0xFF6FC3E8),
    'uv': Color(0xFFE8A85B),
    'sleep': Color(0xFF8E8FE0),
  };

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final conversations = await _aiService.getConversations();
    if (!mounted) return;
    setState(() {
      _conversations = conversations;
      _loading = false;
    });
  }

  void _openChat({Conversation? conversation, String? initialMessage}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AiChatScreen(conversation: conversation, initialMessage: initialMessage),
      ),
    );
    _loadConversations(); // refresh history after returning
  }

  Future<void> _deleteConversation(String id) async {
    await _aiService.deleteConversation(id);
    _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    final insights = _aiService.getInsights();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Welcome header ----------
          FadeInDown(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primaryColor, Color(0xFFF7A8C4)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Assistant', style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        'Your personal skin & hair advisor',
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ---------- Start new chat button ----------
          FadeInUp(
            child: GestureDetector(
              onTap: () => _openChat(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primaryColor, Color(0xFFF7A8C4)]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryColor.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_comment_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text('Start New Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ---------- Suggested questions ----------
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Text('Suggested Questions', style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _aiService.suggestedQuestions
                  .map((q) => SuggestionChip(text: q, onTap: () => _openChat(initialMessage: q)))
                  .toList(),
            ),
          ),

          const SizedBox(height: 28),

          // ---------- AI Insights ----------
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            child: Text('AI Insights for You', style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            child: SizedBox(
              height: 165,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: insights.length,
                itemBuilder: (context, index) {
                  final insight = insights[index];
                  final iconKey = insight['icon']!;
                  return AiInsightCard(
                    title: insight['title']!,
                    body: insight['body']!,
                    icon: _insightIcons[iconKey] ?? Icons.auto_awesome_rounded,
                    color: _insightColors[iconKey] ?? AppTheme.primaryColor,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ---------- Recent conversations ----------
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text('Recent Conversations', style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 12),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
            )
          else if (_conversations.isEmpty)
            const ChatEmptyState(
              title: 'No conversations yet',
              subtitle: 'Start a new chat or tap a suggestion above to begin.',
            )
          else
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Column(
                children: _conversations
                    .map((c) => ConversationTile(
                          conversation: c,
                          onTap: () => _openChat(conversation: c),
                          onDelete: () => _deleteConversation(c.id),
                        ))
                    .toList(),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}