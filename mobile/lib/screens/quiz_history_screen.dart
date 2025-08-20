import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz_history.dart';

class QuizHistoryScreen extends StatelessWidget {
  const QuizHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.quizHistory.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No quiz history yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Complete your first quiz to see your results here!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizProvider.quizHistory.length,
            itemBuilder: (context, index) {
              final history = quizProvider.quizHistory[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getScoreColor(history.score, history.totalQuestions),
                    child: Text(
                      '${((history.score / history.totalQuestions) * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    history.book,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${history.score}/${history.totalQuestions} correct • ${history.completedAt.toString().split(' ')[0]}',
                  ),
                  trailing: Icon(
                    _getScoreIcon(history.score, history.totalQuestions),
                    color: _getScoreColor(history.score, history.totalQuestions),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getScoreColor(int score, int total) {
    final percentage = score / total;
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.6) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(int score, int total) {
    final percentage = score / total;
    if (percentage >= 0.8) return Icons.emoji_events;
    if (percentage >= 0.6) return Icons.thumb_up;
    return Icons.thumb_down;
  }
}
