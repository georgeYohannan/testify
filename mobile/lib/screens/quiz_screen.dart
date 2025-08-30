import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testify/models/quiz.dart';
import 'package:testify/services/quiz_service.dart';
import 'package:flutter/foundation.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  final String difficulty;
  final int questionCount; // Add question count parameter

  const QuizScreen({
    super.key,
    required this.quizId,
    required this.difficulty,
    required this.questionCount, // Make it required
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  final Map<String, String> _answers = {};
  String? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  int _score = 0;
  int _startTime = 0;
  bool _isLoading = true;
  String? _errorMessage;
  
  late AnimationController _progressController;
  late AnimationController _feedbackController;

  // Questions will be loaded from database
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _initializeAnimations();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Extract book name from quiz ID
      final book = widget.quizId.split('_')[0];
      
      // Fetch questions from database with random selection for books with many questions
      final questions = await QuizService.getQuestions(
        book: book,
        limit: widget.questionCount,
      );

      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
        
        if (kDebugMode) {
          print('📚 Loaded ${questions.length} questions for $book');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load questions: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController.animateTo(
      (_currentQuestionIndex + 1) / (_questions.isNotEmpty ? _questions.length : 1),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _selectAnswer(String answer) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null || _hasAnswered) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    _isCorrect = _selectedAnswer == currentQuestion.correctOption;

    if (_isCorrect) {
      _score++;
    }

    setState(() {
      _hasAnswered = true;
      _answers[currentQuestion.id] = _selectedAnswer!;
    });

    _feedbackController.forward().then((_) {
      _feedbackController.reverse();
    });

    // Wait a moment to show feedback, then move to next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
        _isCorrect = false;
      });

      _progressController.animateTo(
        (_currentQuestionIndex + 1) / _questions.length,
      );
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final timeInSeconds = (endTime - _startTime) ~/ 1000;
    
    context.go('/results?score=$_score&total=${_questions.length}&time=$timeInSeconds');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Quiz...'),
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
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading questions...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load quiz',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loadQuestions,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('No Questions'),
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No questions available',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'There are no questions available for this book.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => context.go('/quiz-setup'),
                  child: const Text('Choose Different Book'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz - ${currentQuestion.book}'),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                ),
                
                const SizedBox(height: 16),
                
                // Question Counter
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Question
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
                      Text(
                        currentQuestion.question,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Answer Options
                      ...currentQuestion.options.map((option) {
                        final isSelected = _selectedAnswer == option;
                        final isCorrect = option == currentQuestion.correctOption;
                        final showFeedback = _hasAnswered;
                        
                        Color? backgroundColor;
                        Color? textColor;
                        
                        if (showFeedback) {
                          if (isCorrect) {
                            backgroundColor = Colors.green;
                            textColor = Colors.white;
                          } else if (isSelected && !isCorrect) {
                            backgroundColor = Colors.red;
                            textColor = Colors.white;
                          } else {
                            backgroundColor = theme.colorScheme.surface;
                            textColor = theme.colorScheme.onSurface;
                          }
                        } else {
                          backgroundColor = isSelected 
                              ? theme.colorScheme.secondary 
                              : theme.colorScheme.surface;
                          textColor = isSelected 
                              ? theme.colorScheme.onSecondary 
                              : theme.colorScheme.onSurface;
                        }
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: showFeedback ? null : () => _selectAnswer(option),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  option,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Submit Button
                if (!_hasAnswered) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectedAnswer == null ? null : _submitAnswer,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Submit Answer',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Feedback
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCorrect 
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isCorrect ? Colors.green : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isCorrect ? Icons.check_circle : Icons.cancel,
                          color: _isCorrect ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isCorrect ? 'Correct!' : 'Incorrect',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
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