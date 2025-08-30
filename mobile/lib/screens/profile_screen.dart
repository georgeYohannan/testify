import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testify/models/quiz.dart';
import 'package:testify/models/user.dart';
import 'package:testify/services/quiz_service.dart';
import 'package:testify/supabase/supabase_config.dart';
import 'package:testify/widgets/elephant_mascot.dart';
import 'package:testify/widgets/liquid_glass_container.dart';
import 'package:testify/widgets/liquid_background.dart';
import 'package:testify/theme.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser? _currentUser;
  List<QuizResult> _quizHistory = [];
  bool _isLoading = true;
  Map<String, double> _bookAverages = {};
  Map<String, int> _bookQuizCounts = {};
  Map<DateTime, List<QuizResult>> _dailyQuizzes = {};
  int _currentStreak = 0;
  int _longestStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = await SupabaseAuth.getCurrentAppUser();
      if (user != null) {
        final history = await QuizService.getQuizHistory(user.id);
        
        if (mounted) {
          setState(() {
            _currentUser = user;
            _quizHistory = history;
            _calculateStatistics();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          context.go('/auth');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load profile data: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _calculateStatistics() {
    // Calculate book averages
    _bookAverages.clear();
    _bookQuizCounts.clear();
    _dailyQuizzes.clear();
    
    final bookScores = <String, List<int>>{};
    
    for (final quiz in _quizHistory) {
      // Group by book
      bookScores.putIfAbsent(quiz.book, () => []);
      bookScores[quiz.book]!.add(quiz.score);
      
      // Group by date
      final date = DateTime(quiz.createdAt.year, quiz.createdAt.month, quiz.createdAt.day);
      _dailyQuizzes.putIfAbsent(date, () => []);
      _dailyQuizzes[date]!.add(quiz);
    }
    
    // Calculate averages
    for (final entry in bookScores.entries) {
      final book = entry.key;
      final scores = entry.value;
      // Calculate average percentage (score out of total questions)
      double totalPercentage = 0;
      
      for (final quiz in _quizHistory.where((q) => q.book == book)) {
        totalPercentage += (quiz.score / quiz.totalQuestions) * 100;
      }
      
      _bookAverages[book] = totalPercentage / scores.length;
      _bookQuizCounts[book] = scores.length;
    }
    
    // Calculate streaks
    _calculateStreaks();
  }

  void _calculateStreaks() {
    final dates = _dailyQuizzes.keys.toList()..sort();
    if (dates.isEmpty) return;
    
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    
    for (int i = dates.length - 1; i >= 0; i--) {
      final date = dates[i];
      final nextDate = i > 0 ? dates[i - 1] : null;
      
      if (nextDate != null) {
        final daysDiff = date.difference(nextDate).inDays;
        if (daysDiff == 1) {
          tempStreak++;
        } else {
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
          }
          tempStreak = 0;
        }
      } else {
        tempStreak++;
      }
      
      // Check if this is part of current streak
      if (date.isAtSameMomentAs(DateTime(today.year, today.month, today.day)) ||
          date.isAtSameMomentAs(yesterday)) {
        currentStreak = tempStreak;
      }
    }
    
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }
    
    setState(() {
      _currentStreak = currentStreak;
      _longestStreak = longestStreak;
    });
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: GradientLiquidBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: DesignTokens.xl),
                
                // Profile Header
                LiquidGlassCard(
                  margin: const EdgeInsets.only(bottom: DesignTokens.xl),
                  child: Column(
                    children: [
                      const ElephantMascot(size: 80),
                      const SizedBox(height: DesignTokens.lg),
                      Text(
                        _currentUser?.displayName ?? 'User',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.sm),
                      Text(
                        _currentUser?.email ?? 'user@example.com',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard('Total Quizzes', '${_quizHistory.length}'),
                          _buildStatCard('Current Streak', '$_currentStreak days'),
                          _buildStatCard('Longest Streak', '$_longestStreak days'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Quiz Calendar
                _buildSectionHeader('Quiz Calendar', Icons.calendar_today),
                const SizedBox(height: DesignTokens.md),
                _buildQuizCalendar(),
                
                const SizedBox(height: DesignTokens.xl),
                
                // Book Performance
                _buildSectionHeader('Performance by Book', Icons.bar_chart),
                const SizedBox(height: DesignTokens.md),
                _buildBookPerformance(),
                
                const SizedBox(height: DesignTokens.xl),
                
                // Recent Quiz History
                _buildSectionHeader('Recent Quizzes', Icons.history),
                const SizedBox(height: DesignTokens.md),
                _buildRecentQuizzes(),
                
                const SizedBox(height: DesignTokens.xl),
                
                // Back Button
                LiquidGlassContainer(
                  onTap: () => context.go('/dashboard'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.lg,
                    vertical: DesignTokens.md,
                  ),
                  backgroundColor: Colors.transparent,
                  borderColor: theme.colorScheme.outline.withValues(alpha: 0.3),
                  child: Text(
                    'Back to Dashboard',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    final theme = Theme.of(context);
    
    return LiquidGlassContainer(
      padding: const EdgeInsets.all(DesignTokens.md),
      backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
      borderColor: theme.colorScheme.primary.withValues(alpha: 0.3),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: DesignTokens.xs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCalendar() {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: DesignTokens.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final date = DateTime(now.year, now.month, day);
              final hasQuizzes = _dailyQuizzes.containsKey(date);
              final isToday = date.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
              
              return GestureDetector(
                onTap: hasQuizzes ? () => _showDayDetails(date) : null,
                child: LiquidGlassContainer(
                  padding: const EdgeInsets.all(4),
                  backgroundColor: hasQuizzes 
                      ? theme.colorScheme.primary.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderColor: isToday 
                      ? theme.colorScheme.primary.withValues(alpha: 0.8)
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: DesignTokens.radiusSm,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: hasQuizzes ? FontWeight.bold : FontWeight.normal,
                            color: hasQuizzes 
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (hasQuizzes)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookPerformance() {
    if (_bookAverages.isEmpty) {
      return LiquidGlassContainer(
        padding: const EdgeInsets.all(DesignTokens.lg),
        child: Text(
          'No quiz data available yet. Take your first quiz to see your performance!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final sortedBooks = _bookAverages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return LiquidGlassCard(
      child: Column(
        children: sortedBooks.take(10).map((entry) {
          final book = entry.key;
          final average = entry.value;
          final quizCount = _bookQuizCounts[book] ?? 0;
          final percentage = (average / 100 * 100).round();
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.sm),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    book,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: average / 100,
                    backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getGradeColor(percentage),
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.sm),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${percentage}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getGradeColor(percentage),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: DesignTokens.sm),
                Text(
                  '($quizCount)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentQuizzes() {
    if (_quizHistory.isEmpty) {
      return LiquidGlassContainer(
        padding: const EdgeInsets.all(DesignTokens.lg),
        child: Text(
          'No quiz history available yet. Take your first quiz to see your results!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final recentQuizzes = _quizHistory.take(10).toList();

    return LiquidGlassCard(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentQuizzes.length,
        itemBuilder: (context, index) {
          final quiz = recentQuizzes[index];
          final percentage = (quiz.score / quiz.totalQuestions * 100).round();
          final gradeColor = _getGradeColor(percentage);
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: gradeColor.withValues(alpha: 0.2),
              child: Icon(
                _getGradeIcon(percentage),
                color: gradeColor,
                size: 20,
              ),
            ),
            title: Text(
              quiz.book,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${quiz.score}/${quiz.totalQuestions} • ${quiz.timeInSeconds}s • ${_formatDate(quiz.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.sm,
                vertical: DesignTokens.xs,
              ),
              decoration: BoxDecoration(
                color: gradeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                border: Border.all(
                  color: gradeColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${percentage}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: gradeColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: DesignTokens.sm),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _showDayDetails(DateTime date) {
    final quizzes = _dailyQuizzes[date] ?? [];
    if (quizzes.isEmpty) return;

    final totalScore = quizzes.fold<int>(0, (sum, quiz) => sum + quiz.score);
    final totalQuestions = quizzes.fold<int>(0, (sum, quiz) => sum + quiz.totalQuestions);
    final averageScore = totalScore / totalQuestions;
    final mostFrequentBook = _getMostFrequentBook(quizzes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz Details - ${_formatDate(date)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quizzes taken: ${quizzes.length}'),
            Text('Average score: ${(averageScore * 100).round()}%'),
            Text('Most frequent book: $mostFrequentBook'),
            const SizedBox(height: DesignTokens.sm),
            Text('Books quizzed:'),
            ...quizzes.map((quiz) => Text('• ${quiz.book} (${quiz.score}/${quiz.totalQuestions})')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getMostFrequentBook(List<QuizResult> quizzes) {
    final bookCounts = <String, int>{};
    for (final quiz in quizzes) {
      bookCounts[quiz.book] = (bookCounts[quiz.book] ?? 0) + 1;
    }
    
    String mostFrequent = '';
    int maxCount = 0;
    for (final entry in bookCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostFrequent = entry.key;
      }
    }
    
    return mostFrequent;
  }

  Color _getGradeColor(int percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.yellow;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getGradeIcon(int percentage) {
    if (percentage >= 90) return Icons.star;
    if (percentage >= 80) return Icons.check_circle;
    if (percentage >= 70) return Icons.trending_up;
    if (percentage >= 60) return Icons.help;
    return Icons.trending_down;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final quizDate = DateTime(date.year, date.month, date.day);
    
    if (quizDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (quizDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
