import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../models/ai_message.dart';
import '../models/ai_conversation.dart';
import '../providers/ai_chat_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/workout_sessions_provider.dart';

class AiChatInterface extends ConsumerStatefulWidget {
  const AiChatInterface({super.key});

  @override
  ConsumerState<AiChatInterface> createState() => _AiChatInterfaceState();
}

class _AiChatInterfaceState extends ConsumerState<AiChatInterface> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeConversation = ref.watch(activeConversationProvider);
    final messages = activeConversation?.messages ?? [];
    final orientation = MediaQuery.of(context).orientation;

    // Initialize conversation on first build
    ref.listen(userProfileProvider, (previous, next) {
      if (next != null && activeConversation == null) {
        ref.read(aiChatProvider.notifier).ensureActiveConversation(next.id);
      }
    });

    // Ensure there's always an active conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider);
      if (profile != null && activeConversation == null) {
        ref.read(aiChatProvider.notifier).ensureActiveConversation(profile.id);
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(orientation == Orientation.landscape ? 12 : 16),
      ),
      child: Column(
        children: [
          // Chat messages area
          Expanded(
            child: messages.isEmpty
                ? _buildWelcomeMessage()
                : _buildMessagesList(messages),
          ),

          // Message input area
          _buildMessageInput(activeConversation),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    final orientation = MediaQuery.of(context).orientation;
    return Center(
      child: Padding(
        padding: orientation == Orientation.landscape
            ? const EdgeInsets.all(16.0)
            : const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                'assets/lottie/chat_bot.json',
                width: 48,
                height: 48,
                frameRate: FrameRate(30), // Limit frame rate for performance
                repeat: true, // Loop the bot animation
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'AI Training Coach',
              style: orientation == Orientation.landscape
                  ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  : Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Ask me anything about your training, nutrition, or recovery!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: orientation == Orientation.landscape ? 2 : 3,
              overflow: orientation == Orientation.landscape ? TextOverflow.ellipsis : TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(List<AiMessage> messages) {
    final orientation = MediaQuery.of(context).orientation;
    return ListView.builder(
      controller: _scrollController,
      padding: orientation == Orientation.landscape
          ? const EdgeInsets.all(8)
          : const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(AiMessage message) {
    final isUser = message.isUser;
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                'assets/lottie/chat_bot.json',
                width: 32,
                height: 32,
                frameRate: FrameRate(15), // Lower frame rate for small avatars
                repeat: true,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: !isUser ? Border.all(color: Colors.grey[300]!) : null,
                boxShadow: isUser ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: message.isLoading
                  ? SizedBox(
                      width: 40,
                      height: 40,
                      child: Lottie.asset(
                        'assets/lottie/thinking_animation.json',
                        frameRate: FrameRate(24), // Moderate frame rate
                        repeat: true, // Loop while thinking
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeFormat.format(message.timestamp),
                          style: TextStyle(
                            color: isUser ? Colors.white70 : Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(AiConversation? conversation) {
    final orientation = MediaQuery.of(context).orientation;
    return Container(
      padding: orientation == Orientation.landscape
          ? const EdgeInsets.all(8)
          : const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask anything about training...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: orientation == Orientation.landscape
                    ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(conversation),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isTyping
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isTyping ? null : () => _sendMessage(conversation),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(AiConversation? conversation) async {
    if (conversation == null || _messageController.text.trim().isEmpty || _isTyping) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isTyping = true);

    try {
      final profile = ref.read(userProfileProvider);
      final sessions = ref.read(workoutSessionsProvider);

      await ref.read(aiChatProvider.notifier).sendMessage(
        conversation.id,
        message,
        profile,
        sessions,
      );

      // Scroll to bottom after message is added
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } finally {
      setState(() => _isTyping = false);
    }
  }
}
