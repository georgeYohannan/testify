import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testify/widgets/elephant_mascot.dart';

class ResultsScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int timeInSeconds;

  const ResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.timeInSeconds,
  });

  double get _percentage => (score / totalQuestions) * 100;
  
  String get _grade {
    if (_percentage >= 90) return 'A+';
    if (_percentage >= 80) return 'A';
    if (_percentage >= 70) return 'B';
    if (_percentage >= 60) return 'C';
    if (_percentage >= 50) return 'D';
    return 'F';
  }
  
  String get _message {
    if (_percentage >= 90) return 'Outstanding! You\'re a Bible expert! 🎉';
    if (_percentage >= 80) return 'Excellent work! You know your Bible well! ⭐';
    if (_percentage >= 70) return 'Good job! Keep studying and improving! 👍';
    if (_percentage >= 60) return 'Not bad! A bit more study will help! 📚';
    if (_percentage >= 50) return 'Keep trying! Practice makes perfect! 💪';
    return 'Don\'t give up! Every expert was once a beginner! 🌱';
  }
  
  Color get _gradeColor {
    if (_percentage >= 80) return Colors.green;
    if (_percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
                // Header with Mascot
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
                      const ElephantMascot(size: 80),
                      const SizedBox(height: 16),
                      Text(
                        'Quiz Complete!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _message,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Score Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
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
                      // Grade Display
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _gradeColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _gradeColor,
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _grade,
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _gradeColor,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Score Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildScoreItem(
                            context,
                            'Score',
                            '$score/$totalQuestions',
                            Icons.quiz,
                            theme.colorScheme.secondary,
                          ),
                          _buildScoreItem(
                            context,
                            'Percentage',
                            '${_percentage.round()}%',
                            Icons.percent,
                            theme.colorScheme.primary,
                          ),
                          _buildScoreItem(
                            context,
                            'Time',
                            '${timeInSeconds}s',
                            Icons.timer,
                            theme.colorScheme.tertiary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Performance Analysis
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Performance Analysis',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildAnalysisRow(
                        context,
                        'Correct Answers',
                        score,
                        totalQuestions,
                        Colors.green,
                      ),
                      _buildAnalysisRow(
                        context,
                        'Incorrect Answers',
                        totalQuestions - score,
                        totalQuestions,
                        Colors.red,
                      ),
                      _buildAnalysisRow(
                        context,
                        'Accuracy',
                        _percentage.round(),
                        100,
                        theme.colorScheme.primary,
                        isPercentage: true,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                Column(
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.go('/quiz-setup'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Take Another Quiz'),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    OutlinedButton.icon(
                      onPressed: () => context.go('/dashboard'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.home),
                      label: const Text('Back to Dashboard'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreItem(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisRow(BuildContext context, String label, int value, int total, Color color, {bool isPercentage = false}) {
    final theme = Theme.of(context);
    final percentage = isPercentage ? value.toDouble() : (value / total) * 100;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 50,
            child: Text(
              isPercentage ? '$value%' : '$value',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}