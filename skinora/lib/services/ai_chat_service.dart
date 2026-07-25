import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import 'api_service.dart';

/// Central service for all AI Assistant chat logic.
///
/// Sends messages to the backend's /user/chat endpoint, which forwards
/// them to Gemini with a skincare-assistant system prompt.
class AiChatService {
  static const String _prefsKey = 'ai_conversations_v1';
  final ApiService _apiService = ApiService();

  final List<String> suggestedQuestions = const [
    'Why is my skin dry?',
    'How can I reduce acne?',
    'Hair fall solutions',
    'Dandruff remedies',
    'Skincare routine for oily skin',
    'Night skincare routine',
    'How much water should I drink?',
    'PCOS skincare tips',
  ];

  // ---------- Insights (dashboard-style cards on AI Home) ----------

  List<Map<String, String>> getInsights() {
    return [
      {
        'title': "Today's Skin Tip",
        'body': 'Double cleansing at night removes sunscreen and pollution buildup more effectively than a single wash.',
        'icon': 'skin',
      },
      {
        'title': 'Hair Care Tip',
        'body': 'Avoid tying wet hair tightly — it weakens strands at the root and increases breakage over time.',
        'icon': 'hair',
      },
      {
        'title': 'Hydration Reminder',
        'body': "You're at 4 of 8 glasses today. Try to finish 2 more before evening for better skin elasticity.",
        'icon': 'water',
      },
      {
        'title': 'UV Protection Advice',
        'body': 'UV index is high today. Reapply SPF 50+ every 2 hours if you\'re outdoors.',
        'icon': 'uv',
      },
      {
        'title': 'Sleep Insight',
        'body': 'Skin repairs itself most actively between 10 PM and 2 AM. Aim to be asleep before 11 PM.',
        'icon': 'sleep',
      },
    ];
  }

  // ---------- Real AI reply via backend (Gemini) ----------

  /// [history] should be the prior messages in this conversation (NOT
  /// including the new [message] being sent), so the AI has context.
  Future<String> sendMessage(String message, {List<ChatMessage> history = const []}) async {
    final apiHistory = history
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
        .toList();

    try {
      return await _apiService.sendChatMessage(message, apiHistory);
    } on ApiException catch (e) {
      return "Sorry, I couldn't reach the AI assistant right now. ${e.message}";
    }
  }

  // ---------- Conversation persistence ----------

  Future<List<Conversation>> getConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    final conversations = raw.map((s) => Conversation.fromJson(jsonDecode(s))).toList();
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations;
  }

  Future<void> saveConversation(Conversation conversation) async {
    final prefs = await SharedPreferences.getInstance();
    final conversations = await getConversations();
    conversations.removeWhere((c) => c.id == conversation.id);
    conversations.insert(0, conversation);
    final raw = conversations.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_prefsKey, raw);
  }

  Future<void> deleteConversation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final conversations = await getConversations();
    conversations.removeWhere((c) => c.id == id);
    final raw = conversations.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_prefsKey, raw);
  }

  String generateConversationTitle(String firstMessage) {
    final trimmed = firstMessage.trim();
    if (trimmed.length <= 40) return trimmed;
    return '${trimmed.substring(0, 40)}...';
  }
}