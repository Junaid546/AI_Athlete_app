import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/ai_chat_interface.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/ai_conversation_suggestions.dart';
import '../providers/user_profile_provider.dart';
import '../providers/workout_sessions_provider.dart';
import '../providers/ai_insights_provider.dart';
import '../providers/ai_chat_provider.dart';

class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Generate insights when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateInsights();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateInsights() {
    final profile = ref.read(userProfileProvider);
    final sessions = ref.read(workoutSessionsProvider);
    ref.read(aiInsightsProvider.notifier).generateInsights(profile, sessions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Training Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMenu(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chat'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildInsightsTab(),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    final orientation = MediaQuery.of(context).orientation;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Column(
      children: [
        // Chat Interface
        Expanded(
          child: Container(
            margin: orientation == Orientation.landscape
                ? const EdgeInsets.all(8)
                : const EdgeInsets.all(8),
            child: const AiChatInterface(),
          ),
        ),

        // Conversation Suggestions and Recent Conversations
        if (keyboardHeight == 0 || orientation == Orientation.portrait)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: orientation == Orientation.landscape
                ? const SizedBox.shrink()
                : const AiConversationSuggestions(),
          ),

        if (keyboardHeight == 0 || orientation == Orientation.portrait)
          const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInsightsTab() {
    final insights = ref.watch(aiInsightsProvider);
    final unreadInsights = ref.watch(unreadInsightsProvider);
    final highPriorityInsights = ref.watch(highPriorityInsightsProvider);
    final orientation = MediaQuery.of(context).orientation;

    return RefreshIndicator(
      onRefresh: () async {
        final profile = ref.read(userProfileProvider);
        final sessions = ref.read(workoutSessionsProvider);
        await ref.read(aiInsightsProvider.notifier).regenerateInsights(profile, sessions);
      },
      child: CustomScrollView(
        slivers: [
          // Header with stats
          SliverToBoxAdapter(
            child: Container(
              padding: orientation == Orientation.landscape
                  ? const EdgeInsets.all(8)
                  : const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Unread',
                      unreadInsights.length.toString(),
                      Icons.notifications,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'High Priority',
                      highPriorityInsights.length.toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      insights.length.toString(),
                      Icons.insights,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Insights list
          if (insights.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No insights yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete workouts to get personalized AI insights',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: orientation == Orientation.landscape
                  ? const EdgeInsets.all(8)
                  : const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => AiInsightCard(insight: insights[index]),
                  childCount: insights.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Regenerate Insights'),
              onTap: () {
                Navigator.of(context).pop();
                _generateInsights();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Regenerating insights...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('View Insight History'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement insight history
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('AI Settings'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement AI settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Export Chat'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement chat export
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Clear Conversation'),
              onTap: () {
                Navigator.of(context).pop();
                _showClearConfirmation(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback on AI'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement feedback
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text('Are you sure you want to clear all conversations? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(aiChatProvider.notifier).clearAllConversations();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversation cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
