import 'package:flutter/material.dart';
import 'package:word__way/models/quiz.dart';
import 'package:word__way/services/quiz_service.dart';
import 'package:word__way/widgets/elephant_mascot.dart';
import 'package:word__way/screens/quiz_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  String? _selectedBook;
  Difficulty? _selectedDifficulty;
  bool _isLoading = false;

  final List<String> _availableBooks = QuizService.getAvailableBooks();

  Future<void> _startQuiz() async {
    if (_selectedBook == null || _selectedDifficulty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both book and difficulty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final questions = await QuizService.getQuestions(
        book: _selectedBook!,
        difficulty: _selectedDifficulty!.displayName,
        limit: 5,
      );

      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No questions available for $_selectedBook (${_selectedDifficulty!.displayName})'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              questions: questions,
              book: _selectedBook!,
              difficulty: _selectedDifficulty!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading quiz: \$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Setup'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Mascot
            const ElephantMascot(
              state: ElephantState.neutral,
              size: 100,
              message: 'Choose your challenge! 📚',
            ),
            
            const SizedBox(height: 40),
            
            // Book Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Select Bible Book',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedBook,
                      decoration: InputDecoration(
                        hintText: 'Choose a book',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: _availableBooks.map((book) {
                        return DropdownMenuItem(
                          value: book,
                          child: Text(book),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBook = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Difficulty Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Select Difficulty',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: Difficulty.values.map((difficulty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: RadioListTile<Difficulty>(
                              title: Text(difficulty.displayName),
                              subtitle: Text(_getDifficultyDescription(difficulty)),
                              value: difficulty,
                              groupValue: _selectedDifficulty,
                              onChanged: (value) {
                                setState(() {
                                  _selectedDifficulty = value;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              tileColor: _selectedDifficulty == difficulty
                                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Start Quiz Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _startQuiz,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isLoading ? 'Loading...' : 'Begin Quiz'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDifficultyDescription(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Basic Bible stories and well-known verses';
      case Difficulty.medium:
        return 'More detailed knowledge and specific references';
      case Difficulty.hard:
        return 'Advanced knowledge and specific details';
    }
  }
}