import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testify/models/quiz.dart';
import 'package:testify/models/user.dart';
import 'package:testify/models/verse.dart';
import 'package:testify/services/quiz_service.dart';
import 'package:testify/supabase/supabase_config.dart';
import 'package:testify/widgets/elephant_mascot.dart';
import 'package:testify/widgets/verse_card.dart';
import 'package:flutter/foundation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AppUser? _currentUser;
  Verse? _dailyVerse;
  List<QuizResult> _quizHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      if (kDebugMode) {
        print('Loading dashboard data...');
      }
      
      final futures = await Future.wait([
        SupabaseAuth.getCurrentAppUser(),
        QuizService.getDailyVerse(),
      ]);

      final user = futures[0] as AppUser?;
      final verse = futures[1] as Verse;

      if (kDebugMode) {
        print('✓ Current user: ${user?.email ?? 'None'}');
        print('✓ Daily verse loaded: ${verse.reference}');
      }

      if (user != null) {
        final history = await QuizService.getQuizHistory(user.id);
        
        if (kDebugMode) {
          print('✓ Quiz history loaded: ${history.length} results');
        }
        
        if (mounted) {
          setState(() {
            _currentUser = user;
            _dailyVerse = verse;
            _quizHistory = history;
            _isLoading = false;
          });
        }
      } else {
        if (kDebugMode) {
          print('⚠ No current user found, redirecting to auth');
        }
        if (mounted) {
          context.go('/auth');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('✗ Dashboard loading failed: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show error and redirect to auth
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/auth');
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await SupabaseAuth.signOut();
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _signOut,
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const ElephantMascot(size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome back, ${_currentUser?.displayName ?? 'Friend'}! 🎉',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ready to test your Bible knowledge?',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                Text(
                  'Quick Actions',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.go('/quiz-setup'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.quiz),
                        label: const Text('Start Quiz'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to quiz history or profile
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile feature coming soon!')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.person),
                        label: const Text('Profile'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Daily Verse
                if (_dailyVerse != null) ...[
                  Text(
                    'Verse of the Day',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  VerseCard(verse: _dailyVerse!),
                  const SizedBox(height: 32),
                ],
                
                // Recent Quiz History
                if (_quizHistory.isNotEmpty) ...[
                  Text(
                    'Recent Quizzes',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _quizHistory.take(3).length,
                    itemBuilder: (context, index) {
                      final result = _quizHistory[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: result.score >= (result.totalQuestions / 2)
                                ? Colors.green
                                : Colors.orange,
                            child: Icon(
                              result.score >= (result.totalQuestions / 2)
                                  ? Icons.check
                                  : Icons.trending_up,
                              color: Colors.white,
                            ),
                          ),
                          title: Text('Quiz ${index + 1}'),
                          subtitle: Text('Score: ${result.score}/${result.totalQuestions}'),
                          trailing: Text(
                            '${result.timeInSeconds}s',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      );
                    },
                  ),
                ],
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}