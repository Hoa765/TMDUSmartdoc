import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/widgets/widgets.dart';

class ChatMessage {
  final String text;
  final bool isAi;
  final List<CitationData> citations;

  ChatMessage({
    required this.text,
    required this.isAi,
    this.citations = const [],
  });
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Hello! I have finished analyzing "AI_Research_Paper_2026.pdf". How can I help you today?',
      isAi: true,
    ),
  ];

  bool _isTyping = false;
  bool _isLoadingHistory = false;
  bool _hasLoadedHistory = false;
  Timer? _responseTimer;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isLoadingHistory => _isLoadingHistory;

  Future<void> loadHistory() async {
    if (_hasLoadedHistory || _isLoadingHistory) return;

    _isLoadingHistory = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 650));
    _isLoadingHistory = false;
    _hasLoadedHistory = true;
    notifyListeners();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, isAi: false));
    _isTyping = true;
    notifyListeners();

    // Mock AI Response
    _responseTimer?.cancel();
    _responseTimer = Timer(const Duration(milliseconds: 1500), () {
      _isTyping = false;
      _messages.add(
        ChatMessage(
          text:
              'Based on the document, Artificial Intelligence is increasingly adopting multi-modal architectures to improve contextual understanding. This aligns directly with your question about generative limits.',
          isAi: true,
          citations: [CitationData('Page', '12'), CitationData('Page', '20')],
        ),
      );
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _responseTimer?.cancel();
    super.dispose();
  }
}
