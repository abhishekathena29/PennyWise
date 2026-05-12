import 'package:flutter/foundation.dart';

import '../../../core/services/gemini_service.dart';
import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._geminiService);

  final GeminiService _geminiService;

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitializing = false;
  String? _errorMessage;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  bool get isReady => _geminiService.isInitialized;

  /// Initializes Gemini and sends a welcome message.
  Future<void> initialize({String? financialContext}) async {
    if (_geminiService.isInitialized || _isInitializing) return;
    _isInitializing = true;
    _errorMessage = null;
    notifyListeners();

    await _geminiService.ensureInitialized();

    _isInitializing = false;
    if (!_geminiService.isInitialized) {
      _errorMessage = _geminiService.initError;
      notifyListeners();
      return;
    }

    // Add welcome message from AI
    if (_messages.every((message) => message.id != 'welcome')) {
      _messages.add(
        ChatMessage(
          id: 'welcome',
          text:
              "Hi! I'm your PennyWise AI assistant 👋\n\nI can help you with:\n"
              "• Understanding your spending patterns\n"
              "• Tips on budgeting and saving\n"
              "• Advice on reaching your financial goals\n\n"
              "What would you like to know?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  /// Sends a user message and gets an AI response.
  Future<void> sendMessage(String text, {String? financialContext}) async {
    if (text.trim().isEmpty) return;
    if (!_geminiService.isInitialized) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);

    // Add loading placeholder
    final loadingId = '${userMsg.id}_loading';
    _messages.add(
      ChatMessage(
        id: loadingId,
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: true,
      ),
    );

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Build history from all non-loading messages except the latest user message
      final history = _messages
          .where((m) => !m.isLoading && m.id != userMsg.id && m.id != 'welcome')
          .map((m) => (role: m.isUser ? 'user' : 'model', text: m.text))
          .toList();

      final response = await _geminiService.sendChatMessage(
        text.trim(),
        financialContext: financialContext,
        history: history,
      );

      // Replace loading placeholder with actual response
      final loadingIndex = _messages.indexWhere((m) => m.id == loadingId);
      if (loadingIndex != -1) {
        _messages[loadingIndex] = ChatMessage(
          id: loadingId,
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      final loadingIndex = _messages.indexWhere((m) => m.id == loadingId);
      if (loadingIndex != -1) {
        _messages[loadingIndex] = ChatMessage(
          id: loadingId,
          text: 'Sorry, something went wrong. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
