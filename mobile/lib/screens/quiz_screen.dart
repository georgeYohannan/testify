import 'package:flutter/material.dart';
import 'package:word__way/models/quiz.dart';
import 'package:word__way/widgets/elephant_mascot.dart';
import 'package:word__way/screens/results_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  final String book;
  final Difficulty difficulty;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.book,
    required this.difficulty,
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
  
  late AnimationController _progressController;
  late AnimationController _feedbackController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticInOut,
    ));

    _progressController.animateTo(
      (_currentQuestionIndex + 1) / widget.questions.length,
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

    final currentQuestion = widget.questions[_currentQuestionIndex];
    _isCorrect = _selectedAnswer == currentQuestion.correctOption;

    setState(() {
      _hasAnswered = true;
      _answers[currentQuestion.id] = _selectedAnswer!;
    });

    _feedbackController.forward().then((_) {
      _feedbackController.reverse();
    });

    // Auto advance after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
        _isCorrect = false;
      });

      _progressController.animateTo(
        (_currentQuestionIndex + 1) / widget.questions.length,
      );
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          questions: widget.questions,
          answers: _answers,
          book: widget.book,
          difficulty: widget.difficulty,
        ),
      ),
    );
  }

  ElephantState _getElephantState() {
    if (!_hasAnswered) return ElephantState.neutral;
    return _isCorrect ? ElephantState.correct : ElephantState.incorrect;
  }

  String? _getElephantMessage() {
    if (!_hasAnswered) return null;
    
    if (_isCorrect) {
      final messages = [
        'Excellent! 🎉',
        'You got it! ⭐',
        'Amazing! 👏',
        'Well done! 🌟',
        'Perfect! 🎯',
      ];
      return messages[_currentQuestionIndex % messages.length];
    } else {
      final messages = [
        'Keep trying! 💪',
        "You'll get the next one! 🙂",
        "Don't give up! 💙",
        'Learn and grow! 📚',
        'Stay positive! ✨',
      ];
      return messages[_currentQuestionIndex % messages.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQuestion = widget.questions[_currentQuestionIndex];
    
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Quiz'),
            content: const Text('Are you sure you want to exit? Your progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.book} Quiz'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1}',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '${_currentQuestionIndex + 1}/${widget.questions.length}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Mascot
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: ElephantMascot(
                    state: _getElephantState(),
                    size: 80,
                    message: _getElephantMessage(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Question and Options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Question
                    Card(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              currentQuestion.question,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentQuestion.verseReference,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Answer Options
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentQuestion.options.length,
                        itemBuilder: (context, index) {
                          final option = currentQuestion.options[index];
                          final isSelected = _selectedAnswer == option;
                          final isCorrect = option == currentQuestion.correctOption;
                          
                          Color? cardColor;
                          Color? borderColor;
                          
                          if (_hasAnswered) {
                            if (isCorrect) {
                              cardColor = theme.colorScheme.tertiary.withValues(alpha: 0.1);
                              borderColor = theme.colorScheme.tertiary;
                            } else if (isSelected && !isCorrect) {
                              cardColor = theme.colorScheme.error.withValues(alpha: 0.1);
                              borderColor = theme.colorScheme.error;
                            }
                          } else if (isSelected) {
                            cardColor = theme.colorScheme.primary.withValues(alpha: 0.1);
                            borderColor = theme.colorScheme.primary;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => _selectAnswer(option),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor ?? theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: borderColor ?? 
                                        theme.colorScheme.outline.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: borderColor?.withValues(alpha: 0.2),
                                        border: Border.all(
                                          color: borderColor ?? 
                                              theme.colorScheme.outline.withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              Icons.circle,
                                              size: 12,
                                              color: borderColor,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: isSelected 
                                              ? FontWeight.w600 
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (_hasAnswered && isCorrect)
                                      Icon(
                                        Icons.check_circle,
                                        color: theme.colorScheme.tertiary,
                                      )
                                    else if (_hasAnswered && isSelected && !isCorrect)
                                      Icon(
                                        Icons.cancel,
                                        color: theme.colorScheme.error,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Submit/Next Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _selectedAnswer != null && !_hasAnswered
                            ? _submitAnswer
                            : _hasAnswered 
                                ? _nextQuestion
                                : null,
                        icon: Icon(
                          _hasAnswered ? Icons.arrow_forward : Icons.check,
                        ),
                        label: Text(
                          _hasAnswered
                              ? (_currentQuestionIndex == widget.questions.length - 1
                                  ? 'View Results'
                                  : 'Next Question')
                              : 'Submit Answer',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}