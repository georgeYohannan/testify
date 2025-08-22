import 'package:flutter/material.dart';
import 'package:word__way/models/quiz.dart';
import 'package:word__way/models/verse.dart';
import 'package:word__way/services/quiz_service.dart';
import 'package:word__way/supabase/supabase_config.dart';
import 'package:word__way/widgets/elephant_mascot.dart';
import 'package:word__way/widgets/verse_card.dart';
import 'package:word__way/screens/dashboard_screen.dart';
import 'package:word__way/screens/quiz_setup_screen.dart';

class ResultsScreen extends StatefulWidget {
  final List<Question> questions;
  final Map<String, String> answers;
  final String book;
  final Difficulty difficulty;

  const ResultsScreen({
    super.key,
    required this.questions,
    required this.answers,
    required this.book,
    required this.difficulty,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late int _score;
  late int _correctAnswers;
  List<Verse> _encouragementVerses = [];
  bool _hasSubmitted = false;
  
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _calculateScore();
    _loadEncouragementVerses();
    _saveResult();
    _initializeAnimations();
  }

  void _calculateScore() {
    _correctAnswers = 0;
    for (final question in widget.questions) {
      if (widget.answers[question.id] == question.correctOption) {
        _correctAnswers++;
      }
    }
    _score = QuizService.calculateScore(widget.questions, widget.answers);
  }

  void _loadEncouragementVerses() {
    _encouragementVerses = QuizService.getEncouragementVerses(_score);
  }

  Future<void> _saveResult() async {
    if (_hasSubmitted) return;
    
    try {
      final user = SupabaseAuth.currentUser;
      if (user != null) {
        final result = QuizResult(
          id: '',
          userId: user.id,
          book: widget.book,
          difficulty: widget.difficulty.displayName,
          score: _score,
          answers: widget.answers,
          createdAt: DateTime.now(),
        );
        
        await QuizService.saveQuizResult(result);
        _hasSubmitted = true;
      }
    } catch (e) {
      print('Error saving result: \$e');
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: _score.toDouble(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getScoreMessage() {
    if (_score >= 90) return 'Outstanding! 🏆';
    if (_score >= 80) return 'Excellent! ⭐';
    if (_score >= 70) return 'Great job! 👏';
    if (_score >= 60) return 'Good work! 👍';
    if (_score >= 50) return 'Keep learning! 📚';
    return "Don't give up! 💪";
  }

  Color _getScoreColor(BuildContext context) {
    final theme = Theme.of(context);
    if (_score >= 80) return theme.colorScheme.tertiary;
    if (_score >= 60) return theme.colorScheme.secondary;
    return theme.colorScheme.error;
  }

  ElephantState _getElephantState() {
    if (_score >= 70) return ElephantState.encouraging;
    if (_score >= 50) return ElephantState.correct;
    return ElephantState.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = _getScoreColor(context);
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scoreColor.withValues(alpha: 0.1),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Score Display
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: scoreColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              ElephantMascot(
                                state: _getElephantState(),
                                size: 100,
                                message: _getScoreMessage(),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Your Score',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              AnimatedBuilder(
                                animation: _scoreAnimation,
                                builder: (context, child) {
                                  return Text(
                                    '${_scoreAnimation.value.round()}%',
                                    style: theme.textTheme.displayLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: scoreColor,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$_correctAnswers out of ${widget.questions.length} correct',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Quiz Info
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Quiz Details',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  'Book',
                                  widget.book,
                                  Icons.menu_book,
                                  theme,
                                ),
                                _buildInfoRow(
                                  'Difficulty',
                                  widget.difficulty.displayName,
                                  Icons.speed,
                                  theme,
                                ),
                                _buildInfoRow(
                                  'Questions',
                                  '${widget.questions.length}',
                                  Icons.quiz,
                                  theme,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Encouragement Verse
                        if (_encouragementVerses.isNotEmpty)
                          VerseCard(
                            verse: _encouragementVerses.first,
                            isCompact: true,
                          ),
                        
                        const SizedBox(height: 32),
                        
                        // Answer Review Section
                        ExpansionTile(
                          title: const Text('Review Answers'),
                          leading: const Icon(Icons.visibility),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.questions.length,
                              itemBuilder: (context, index) {
                                final question = widget.questions[index];
                                final userAnswer = widget.answers[question.id];
                                final isCorrect = userAnswer == question.correctOption;
                                
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  color: isCorrect
                                      ? theme.colorScheme.tertiary.withValues(alpha: 0.1)
                                      : theme.colorScheme.error.withValues(alpha: 0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              isCorrect ? Icons.check_circle : Icons.cancel,
                                              color: isCorrect
                                                  ? theme.colorScheme.tertiary
                                                  : theme.colorScheme.error,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Question ${index + 1}',
                                                style: theme.textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          question.question,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        if (!isCorrect) ...[
                                          Text(
                                            'Your answer: \$userAnswer',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                          Text(
                                            'Correct answer: ${question.correctOption}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.tertiary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ] else
                                          Text(
                                            'Correct: \$userAnswer',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.tertiary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          question.verseReference,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontStyle: FontStyle.italic,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Action Buttons
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const QuizSetupScreen(),
                                    ),
                                    (route) => route.settings.name == '/dashboard',
                                  );
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Take Another Quiz'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const DashboardScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(Icons.home),
                                label: const Text('Back to Dashboard'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '\$label:',
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}