import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_conversation.dart';
import '../providers/ai_chat_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/workout_sessions_provider.dart';

class AiConversationSuggestions extends ConsumerWidget {
  const AiConversationSuggestions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Conversation Suggestions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '💬 Conversation Suggestions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _getSuggestions().map((suggestion) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _SuggestionChip(
                text: suggestion,
                onTap: () => _sendSuggestion(ref, suggestion),
              ),
            )).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Recent Conversations
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '📜 Recent Conversations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Consumer(
          builder: (context, ref, child) {
            final conversations = ref.watch(aiChatProvider)
                .where((c) => c.messages.isNotEmpty)
                .take(3)
                .toList();

            if (conversations.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'No conversations yet. Start chatting with your AI coach!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }

            return Column(
              children: conversations.map((conversation) => _RecentConversationItem(
                conversation: conversation,
                onTap: () => _openConversation(ref, conversation.id),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  List<String> _getSuggestions() {
    return [
      "How do I break my bench PR?",
      "Create a deload week plan",
      "Why am I always tired?",
      "Best exercises for mobility",
      "How to improve squat depth",
      "Nutrition for muscle gain",
      "Recovery strategies",
      "Form check for deadlifts",
    ];
  }

  void _sendSuggestion(WidgetRef ref, String suggestion) {
    final activeConversation = ref.read(activeConversationProvider);
    if (activeConversation != null) {
      final profile = ref.read(userProfileProvider);
      final sessions = ref.read(workoutSessionsProvider);

      ref.read(aiChatProvider.notifier).sendMessage(
        activeConversation.id,
        suggestion,
        profile,
        sessions,
      );
    }
  }

  void _openConversation(WidgetRef ref, String conversationId) {
    ref.read(aiChatProvider.notifier).setActiveConversation(conversationId);
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentConversationItem extends StatelessWidget {
  final AiConversation conversation;
  final VoidCallback onTap;

  const _RecentConversationItem({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastMessage = conversation.lastMessage;
    final timeAgo = _getTimeAgo(conversation.updatedAt);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (lastMessage != null)
                    Text(
                      lastMessage.content,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Text(
              timeAgo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
