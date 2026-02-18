import 'package:flutter/material.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  Map<String, List<Message>> _messages = {};
  String? _currentConversationId;

  List<Conversation> get conversations => _conversations;
  String? get currentConversationId => _currentConversationId;

  List<Message> getConversationMessages(String conversationId) {
    return _messages[conversationId] ?? [];
  }

  int get totalUnreadCount {
    return _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
  }

  // Initialize with sample data
  ChatProvider() {
    _loadSampleConversations();
  }

  void _loadSampleConversations() {
    _conversations = [
      Conversation(
        id: '1',
        participantId: 'user1',
        participantName: 'Ahmed Ben',
        participantRole: 'company',
        jobTitle: 'Senior Developer',
        lastMessage: Message(
          id: 'msg1',
          conversationId: '1',
          senderId: 'user1',
          senderName: 'Ahmed Ben',
          message: 'Pouvez-vous commencer demain?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        unreadCount: 1,
      ),
      Conversation(
        id: '2',
        participantId: 'user2',
        participantName: 'Tech Solutions Inc',
        participantRole: 'company',
        jobTitle: 'Product Manager',
        lastMessage: Message(
          id: 'msg2',
          conversationId: '2',
          senderId: 'user2',
          senderName: 'Tech Solutions Inc',
          message: 'Merci pour votre candidature!',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        unreadCount: 0,
      ),
    ];

    // Load sample messages
    _messages['1'] = [
      Message(
        id: 'msg1a',
        conversationId: '1',
        senderId: 'me',
        senderName: 'You',
        message: 'Bonjour, je suis intéressé par ce poste',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Message(
        id: 'msg1b',
        conversationId: '1',
        senderId: 'user1',
        senderName: 'Ahmed Ben',
        message: 'Excellent CV! Quand pouvez-vous démarrer?',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Message(
        id: 'msg1c',
        conversationId: '1',
        senderId: 'me',
        senderName: 'You',
        message: 'Je suis disponible immédiatement',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      ),
      Message(
        id: 'msg1d',
        conversationId: '1',
        senderId: 'user1',
        senderName: 'Ahmed Ben',
        message: 'Pouvez-vous commencer demain?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ];

    _messages['2'] = [
      Message(
        id: 'msg2a',
        conversationId: '2',
        senderId: 'me',
        senderName: 'You',
        message: 'Intéressé par ce poste',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Message(
        id: 'msg2b',
        conversationId: '2',
        senderId: 'user2',
        senderName: 'Tech Solutions Inc',
        message: 'Merci pour votre candidature!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }

  void selectConversation(String conversationId) {
    _currentConversationId = conversationId;
    markConversationAsRead(conversationId);
    notifyListeners();
  }

  void sendMessage(String conversationId, String messageText) {
    final newMessage = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: 'me',
      senderName: 'You',
      message: messageText,
      timestamp: DateTime.now(),
    );

    if (!_messages.containsKey(conversationId)) {
      _messages[conversationId] = [];
    }

    _messages[conversationId]!.add(newMessage);

    // Update conversation's last message
    final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (conversationIndex != -1) {
      final updatedConv = _conversations[conversationIndex];
      _conversations[conversationIndex] = Conversation(
        id: updatedConv.id,
        participantId: updatedConv.participantId,
        participantName: updatedConv.participantName,
        participantRole: updatedConv.participantRole,
        jobTitle: updatedConv.jobTitle,
        lastMessage: newMessage,
        unreadCount: updatedConv.unreadCount,
      );
    }

    notifyListeners();
  }

  void markConversationAsRead(String conversationId) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final conv = _conversations[index];
      _conversations[index] = Conversation(
        id: conv.id,
        participantId: conv.participantId,
        participantName: conv.participantName,
        participantRole: conv.participantRole,
        jobTitle: conv.jobTitle,
        lastMessage: conv.lastMessage,
        unreadCount: 0,
      );
      notifyListeners();
    }
  }

  void createConversation(
    String participantId,
    String participantName,
    String participantRole,
    {String? jobTitle,}
  ) {
    final newConv = Conversation(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      participantId: participantId,
      participantName: participantName,
      participantRole: participantRole,
      jobTitle: jobTitle,
      unreadCount: 0,
    );

    _conversations.insert(0, newConv);
    _messages[newConv.id] = [];
    notifyListeners();
  }

  void deleteConversation(String conversationId) {
    _conversations.removeWhere((c) => c.id == conversationId);
    _messages.remove(conversationId);
    if (_currentConversationId == conversationId) {
      _currentConversationId = null;
    }
    notifyListeners();
  }
}
