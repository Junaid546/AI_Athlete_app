import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import '../models/ai_message.dart';
import '../models/ai_conversation.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';

class AiChatNotifier extends StateNotifier<List<AiConversation>> {
  GenerativeModel? _model;
  static const String _defaultModel = 'gemini-2.0-flash';

  AiChatNotifier() : super([]) {
    // Initialize model with error handling
    _initializeModel();
  }

  void _initializeModel() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY_CHAT'] ?? '';
      if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
        throw Exception('API key is not configured properly');
      }
      _model = GenerativeModel(
        model: _defaultModel,
        apiKey: apiKey,
      );
    debugPrint('AI Model initialized successfully');
    } catch (e) {
    debugPrint('Failed to initialize AI model: $e');
      _model = null;
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
      isActive: true, // Make it active by default
    );

    // Mark all other conversations as inactive
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

  // Send message and get AI response
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
      // Check for simple greetings first
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

      // Reinitialize model if null
      if (_model == null) {
    debugPrint('Model is null, attempting reinitialization...');
        _initializeModel();
      }

      // Check if model is available after reinitialization
      if (_model == null) {
        throw Exception('AI model could not be initialized. Please check your API key.');
      }

      // Generate AI response with context
      final context = _buildContextPrompt(profile, sessions);
      final prompt = '''
$context

User: $userMessage

Please provide a helpful, personalized response as an AI fitness coach. Be encouraging, knowledgeable, and specific to their training data and goals.
Keep your response under 500 characters.
''';

      // Add timeout and retry logic
      GenerateContentResponse response;
      try {
        response = await _model!.generateContent([Content.text(prompt)]).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Request timed out after 30 seconds'),
        );
      } on TimeoutException catch (e) {
        throw Exception('API request timed out: ${e.message}');
      }

      final aiResponse = response.text?.trim() ?? 'I apologize, but I couldn\'t generate a response right now. Please try again.';

      if (aiResponse.isEmpty) {
        throw Exception('Empty response from AI model');
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
    debugPrint('AI response generated successfully');
    } catch (e) {
    debugPrint('AI Chat Error: $e'); // Debug logging

      // Provide specific error messages based on the actual error
      String errorMessage = 'Sorry, I encountered an error. Please try again.';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('quota') || errorString.contains('exceed')) {
        errorMessage = '⚠️ API quota exceeded. The AI service has reached its limit. Please try again later or contact support.';
      } else if (errorString.contains('api key') || errorString.contains('invalid_argument') || errorString.contains('unauthenticated')) {
        errorMessage = '⚠️ API authentication failed. Please check the API key configuration.';
      } else if (errorString.contains('network') || errorString.contains('connection') || errorString.contains('sockexception')) {
        errorMessage = '📡 Network connection issue. Please check your internet connection and try again.';
      } else if (errorString.contains('timed out') || errorString.contains('timeout')) {
        errorMessage = '⏱️ The request took too long. Please try again with a shorter message.';
      } else if (errorString.contains('could not be initialized')) {
        errorMessage = '⚙️ AI service is not properly configured. Please contact support.';
      } else if (errorString.contains('empty response')) {
        errorMessage = '❌ AI service returned an empty response. Please try again.';
      }

      // Remove loading message and add error message
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

  // Simple responses for common greetings
  String? _getSimpleResponse(String message) {
    if (message.contains('hello') || message.contains('hi') || message == 'hey') {
      return 'Hello! I\'m your AI fitness coach. I can help you with training advice, nutrition guidance, injury prevention, and workout planning. What would you like to know about your fitness journey? 💪';
    }
    if (message.contains('how are you') || message.contains('what\'s up')) {
      return 'I\'m doing great, thanks for asking! Ready to help you crush your fitness goals. What can I assist you with today?';
    }
    if (message.contains('thank you') || message.contains('thanks')) {
      return 'You\'re welcome! Keep up the great work with your training. I\'m here whenever you need advice or motivation! 💪';
    }
    return null; // Use AI for complex queries
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

  String _buildContextPrompt(UserProfile? profile, List<WorkoutSession> sessions) {
    final buffer = StringBuffer();

    buffer.writeln('You are an AI fitness coach for an athlete. Here\'s their profile and recent training data:');

    if (profile != null) {
      buffer.writeln('\nATHLETE PROFILE:');
      buffer.writeln('- Name: ${profile.name}');
      buffer.writeln('- Age: ${profile.calculatedAge}');
      buffer.writeln('- Gender: ${profile.gender.name}');
      buffer.writeln('- Primary Sport: ${profile.primarySport ?? 'General Fitness'}');
      buffer.writeln('- Experience Level: ${profile.experienceLevel.name}');
      buffer.writeln('- Training Goals: ${profile.trainingGoals.join(', ')}');
      buffer.writeln('- Training Frequency: ${profile.trainingFrequency.name.replaceAll('Days', ' days/week')}');
      buffer.writeln('- Current Weight: ${profile.weight ?? 'Not set'} kg');
      buffer.writeln('- Height: ${profile.height ?? 'Not set'} cm');
      buffer.writeln('- Total Workouts: ${profile.totalWorkouts}');
      buffer.writeln('- Current Streak: ${profile.currentStreak} days');
    }

    if (sessions.isNotEmpty) {
      buffer.writeln('\nRECENT TRAINING DATA:');
      buffer.writeln('- Total Sessions: ${sessions.length}');

      // Last 5 sessions
      final recentSessions = sessions.take(5).toList();
      for (final session in recentSessions) {
        buffer.writeln('- ${session.startTime.toString().split(' ')[0]}: ${session.planName} (${session.totalVolume.toStringAsFixed(1)} kg, ${session.actualDuration?.inMinutes ?? 0} min)');
      }

      // Calculate some stats
      final totalVolume = sessions.fold<double>(0, (sum, s) => sum + s.totalVolume);
      final avgVolume = totalVolume / sessions.length;
      buffer.writeln('- Average Volume per Session: ${avgVolume.toStringAsFixed(1)} kg');
    }

    buffer.writeln('\nProvide personalized, actionable advice based on this data. Be encouraging and specific.');

    return buffer.toString();
  }

  // Get active conversation
  AiConversation? getActiveConversation() {
    return state.where((c) => c.isActive).firstOrNull;
  }

  // Ensure there's always an active conversation
  void ensureActiveConversation(String userId) {
    final activeConv = getActiveConversation();
    if (activeConv != null) {
      return; // Active conversation already exists
    }

    // Create a new conversation if there's none
    if (state.isEmpty) {
      createConversation(userId, 'AI Training Coach - ${DateTime.now().toString().split(' ')[0]}');
    debugPrint('Created new active conversation');
    } else {
      // Activate the first conversation if available
      final firstConv = state.first;
      setActiveConversation(firstConv.id);
    debugPrint('Activated existing conversation: ${firstConv.id}');
    }
  }

  // Set active conversation
  void setActiveConversation(String conversationId) {
    state = state.map((conversation) {
      return conversation.copyWith(isActive: conversation.id == conversationId);
    }).toList();
  }

  // Delete conversation
  void deleteConversation(String conversationId) {
    state = state.where((c) => c.id != conversationId).toList();
  }

  // Clear all conversations
  void clearAllConversations() {
    state = [];
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, List<AiConversation>>((ref) {
  return AiChatNotifier();
});

// Current active conversation
final activeConversationProvider = Provider<AiConversation?>((ref) {
  final conversations = ref.watch(aiChatProvider);
  return conversations.where((c) => c.isActive).firstOrNull;
});
