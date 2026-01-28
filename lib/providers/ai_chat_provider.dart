import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/ai_message.dart';
import '../models/ai_conversation.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';

// ⚠️ IMPORTANT: Update this URL to your actual Firebase Cloud Function URL
// Format: https://us-central1-your-project-id.cloudfunctions.net/aiCoach
// DO NOT hardcode API keys here - all keys are stored securely in backend
const String backendBaseUrl = 'https://your-project-id.cloudfunctions.net/aiCoach';

class AiChatNotifier extends StateNotifier<List<AiConversation>> {
  static const int maxRetries = 2;

  AiChatNotifier() : super([]) {
    _initializeBackendClient();
  }

  void _initializeBackendClient() {
    try {
      // Verify backend URL is configured
      if (backendBaseUrl.isEmpty || backendBaseUrl.contains('your-project-id')) {
        throw Exception('Backend URL not configured. Update backendBaseUrl in ai_chat_provider.dart');
      }
    debugPrint('✅ AI Chat backend client initialized');
    debugPrint('📡 Backend URL: $backendBaseUrl');
    } catch (e) {
    debugPrint('❌ Failed to initialize backend client: $e');
    }
  }

  // Create a new conversation
  void createConversation(String userId, String title) {
    final conversation = AiConversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    final updatedState = state.map((c) => c.copyWith(isActive: false)).toList();
    state = [...updatedState, conversation];
  }

  // Add message to conversation
  void addMessage(String conversationId, AiMessage message) {
    state = state.map((conversation) {
      if (conversation.id == conversationId) {
        return conversation.copyWith(
          messages: [...conversation.messages, message],
          updatedAt: DateTime.now(),
        );
      }
      return conversation;
    }).toList();
  }

  // Send message and get AI response from secure backend
  Future<void> sendMessage(
    String conversationId,
    String userMessage,
    UserProfile? profile,
    List<WorkoutSession> sessions,
  ) async {
    // Add user message
    final userAiMessage = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );
    addMessage(conversationId, userAiMessage);

    // Add loading message
    final loadingMessage = AiMessage(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    addMessage(conversationId, loadingMessage);

    try {
      // Check for simple greetings first (no backend call needed)
      final simpleResponse = _getSimpleResponse(userMessage.toLowerCase().trim());
      if (simpleResponse != null) {
        _removeLoadingMessage(conversationId);
        final aiMessage = AiMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: simpleResponse,
          isUser: false,
          timestamp: DateTime.now(),
        );
        addMessage(conversationId, aiMessage);
        return;
      }

      // Call backend API with retry logic
      String aiResponse = '';
      int attempts = 0;

      while (attempts < maxRetries && aiResponse.isEmpty) {
        try {
          aiResponse = await _callBackendAPI(userMessage, profile, sessions);
          if (aiResponse.isEmpty) {
            throw Exception('Empty response from backend');
          }
        } catch (e) {
          attempts++;
          if (attempts >= maxRetries) {
            rethrow;
          }
          // Wait before retrying
          await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('⚠️ Retry attempt ${attempts + 1}/$maxRetries');
        }
      }

      // Remove loading message and add real response
      _removeLoadingMessage(conversationId);
      final aiMessage = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );
      addMessage(conversationId, aiMessage);
    debugPrint('✅ AI response received from backend');
    } catch (e) {
    debugPrint('❌ AI Chat Error: $e');

      String errorMessage = 'Sorry, I encountered an error. Please try again.';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('unauthorized') || errorString.contains('authentication')) {
        errorMessage = '⚠️ Authentication failed. Please log in again.';
      } else if (errorString.contains('backend url') || errorString.contains('configured')) {
        errorMessage = '⚙️ Backend not configured. Contact support.';
      } else if (errorString.contains('network') || errorString.contains('connection') || errorString.contains('socketexception')) {
        errorMessage = '📡 Network error. Check your internet connection.';
      } else if (errorString.contains('timed out') || errorString.contains('timeout')) {
        errorMessage = '⏱️ Request timed out. Please try again.';
      } else if (errorString.contains('rate limit')) {
        errorMessage = '⏱️ Too many requests. Please wait a moment.';
      } else if (errorString.contains('empty response')) {
        errorMessage = '❌ Backend returned empty response. Try again.';
      }

      _removeLoadingMessage(conversationId);
      final aiMessage = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: errorMessage,
        isUser: false,
        timestamp: DateTime.now(),
      );
      addMessage(conversationId, aiMessage);
    }
  }

  // Call backend API securely
  Future<String> _callBackendAPI(
    String userMessage,
    UserProfile? profile,
    List<WorkoutSession> sessions,
  ) async {
    try {
      // Verify backend URL is configured
      if (backendBaseUrl.contains('your-project-id')) {
        throw Exception('Backend URL not configured in ai_chat_provider.dart');
      }

      // Get Firebase ID token for authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final idToken = await user.getIdToken();

      // Prepare request body
      final requestBody = {
        'message': userMessage,
        'context': {
          'userId': user.uid,
          'userName': user.displayName ?? 'User',
          'profileData': profile != null
              ? {
                  'name': profile.name,
                  'age': profile.calculatedAge,
                  'gender': profile.gender.name,
                  'sport': profile.primarySport ?? 'General Fitness',
                  'experienceLevel': profile.experienceLevel.name,
                  'goals': profile.trainingGoals,
                  'weight': profile.weight,
                }
              : null,
          'recentSessions': sessions.take(5).map((s) => {
            'planName': s.planName,
            'totalVolume': s.totalVolume,
            'actualDuration': s.actualDuration?.inMinutes ?? 0,
          }).toList(),
        }
      };

    debugPrint('📤 Sending request to backend: $backendBaseUrl/chat');

      // Make HTTP request to backend
      final response = await http
          .post(
            Uri.parse('$backendBaseUrl/chat'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

    debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['response'];
        
        if (content == null || content.toString().isEmpty) {
          throw Exception('Empty response from backend');
        }

        return content.toString().trim();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Authentication token expired');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else if (response.statusCode == 503) {
        throw Exception('Backend service temporarily unavailable');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Backend error: ${errorBody['error'] ?? 'Unknown error'}');
      }
    } on TimeoutException catch (e) {
      throw Exception('Request timed out: ${e.message}');
    }
  }

  // Simple responses for common greetings
  String? _getSimpleResponse(String message) {
    if (message.contains('hello') || message.contains('hi') || message == 'hey') {
      return 'Hello! I\'m your AI fitness coach. I can help with training, nutrition, recovery, and injury prevention. What would you like to know? 💪';
    }
    if (message.contains('how are you') || message.contains('what\'s up')) {
      return 'Doing great! Ready to help you crush your fitness goals. What can I assist with today?';
    }
    if (message.contains('thank you') || message.contains('thanks')) {
      return 'You\'re welcome! Keep up the amazing work with your training! 💪';
    }
    return null;
  }

  void _removeLoadingMessage(String conversationId) {
    state = state.map((conversation) {
      if (conversation.id == conversationId) {
        return conversation.copyWith(
          messages: conversation.messages.where((msg) => !msg.isLoading).toList(),
        );
      }
      return conversation;
    }).toList();
  }

  AiConversation? getActiveConversation() {
    return state.where((c) => c.isActive).firstOrNull;
  }

  void ensureActiveConversation(String userId) {
    final activeConv = getActiveConversation();
    if (activeConv != null) {
      return;
    }

    if (state.isEmpty) {
      createConversation(userId, 'AI Training Coach - ${DateTime.now().toString().split(' ')[0]}');
    debugPrint('✅ Created new active conversation');
    } else {
      final firstConv = state.first;
      setActiveConversation(firstConv.id);
    debugPrint('✅ Activated existing conversation');
    }
  }

  void setActiveConversation(String conversationId) {
    state = state.map((conversation) {
      return conversation.copyWith(isActive: conversation.id == conversationId);
    }).toList();
  }

  void deleteConversation(String conversationId) {
    state = state.where((c) => c.id != conversationId).toList();
  }

  void clearAllConversations() {
    state = [];
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, List<AiConversation>>((ref) {
  return AiChatNotifier();
});

final activeConversationProvider = Provider<AiConversation?>((ref) {
  final conversations = ref.watch(aiChatProvider);
  return conversations.where((c) => c.isActive).firstOrNull;
});
