import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testify/services/quiz_service.dart';
import 'package:testify/widgets/elephant_mascot.dart';
import 'package:testify/widgets/liquid_glass_container.dart';
import 'package:testify/widgets/liquid_background.dart';
import 'package:testify/theme.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  String? _selectedBook;
  String _selectedDifficulty = 'medium';
  int _selectedQuestionCount = 10;
  bool _isLoading = false;
  bool _isLoadingQuestionCount = false;
  List<String> _availableBooks = [];
  String? _errorMessage;
  final Map<String, int> _bookQuestionCounts = {};
  bool _canStartQuiz = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableBooks();
  }

  Future<void> _loadAvailableBooks() async {
    try {
      if (kDebugMode) {
        print('🔄 Loading available books...');
      }
      
      setState(() {
        _errorMessage = null;
      });

      final books = await QuizService.getAvailableBooks();
      
      if (kDebugMode) {
        print('✓ Books loaded: ${books.length}');
        print('✓ Available books: ${books.take(10).join(', ')}${books.length > 10 ? '...' : ''}');
      }
      
      if (mounted) {
        setState(() {
          _availableBooks = books;
        });
        
        if (books.isNotEmpty && _selectedBook == null) {
          setState(() {
            _selectedBook = books.first;
          });
          if (kDebugMode) {
            print('✓ Auto-selected first book: ${books.first}');
          }
          _loadQuestionCountForBook(books.first);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('✗ Failed to load available books: $e');
      }
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load available books: $e';
        });
      }
    }
  }

  Future<void> _loadQuestionCountForBook(String book) async {
    try {
      setState(() {
        _isLoadingQuestionCount = true;
        _errorMessage = null;
      });

      final questionCount = await QuizService.getQuestionCountForBook(book);
      
      if (mounted) {
        setState(() {
          _bookQuestionCounts[book] = questionCount;
          _isLoadingQuestionCount = false;
          _canStartQuiz = questionCount > 0;
        });
        
        if (kDebugMode) {
          print('✓ Loaded $questionCount questions for $book');
          print('✓ Start button enabled: $_canStartQuiz');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('✗ Failed to load question count for $book: $e');
      }
      if (mounted) {
        setState(() {
          _bookQuestionCounts[book] = 0;
          _isLoadingQuestionCount = false;
          _canStartQuiz = false;
          _errorMessage = 'Failed to load question count for $book: $e';
        });
      }
    }
  }

  String _getNoQuestionsMessage(String book) {
    return 'Questions for $book are still in development. Please try again later or select a different book.';
  }

  Future<void> _startQuiz() async {
    if (_selectedBook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a book'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final quizId = '${_selectedBook}_${DateTime.now().millisecondsSinceEpoch}';
      
      if (mounted) {
        context.go('/quiz?id=$quizId&difficulty=$_selectedDifficulty&questions=$_selectedQuestionCount');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error starting quiz: $e';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting quiz: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Quiz Setup'),
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
                
                // Header Card
                LiquidGlassCard(
                  margin: const EdgeInsets.only(bottom: DesignTokens.xl),
                  child: Column(
                    children: [
                      const ElephantMascot(size: 80),
                      const SizedBox(height: DesignTokens.lg),
                      Text(
                        'Quiz Setup',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.sm),
                      Text(
                        'Choose your quiz settings and get ready to test your knowledge!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Book Selection Section
                _buildSectionHeader('Select Bible Book', Icons.book),
                const SizedBox(height: DesignTokens.md),
                
                if (_isLoadingQuestionCount)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (_errorMessage != null)
                  LiquidGlassContainer(
                    padding: const EdgeInsets.all(DesignTokens.md),
                    backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                    borderColor: theme.colorScheme.error.withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: DesignTokens.sm),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  LiquidGlassInput(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Choose a book...',
                        icon: Icon(Icons.arrow_drop_down),
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
                          _canStartQuiz = false;
                        });
                        if (value != null) {
                          _loadQuestionCountForBook(value);
                        }
                      },
                    ),
                  ),
                
                const SizedBox(height: DesignTokens.md),
                
                // Message for books with no questions
                if (_selectedBook != null && _bookQuestionCounts[_selectedBook] == 0) ...[
                  LiquidGlassContainer(
                    padding: const EdgeInsets.all(DesignTokens.md),
                    backgroundColor: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.1),
                    borderColor: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          color: theme.colorScheme.tertiary,
                          size: 20,
                        ),
                        const SizedBox(width: DesignTokens.sm),
                        Expanded(
                          child: Text(
                            _getNoQuestionsMessage(_selectedBook!),
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.md),
                ],
                
                const SizedBox(height: DesignTokens.xl),
                
                // Question Count Section
                _buildSectionHeader('Number of Questions', Icons.quiz),
                const SizedBox(height: DesignTokens.md),
                
                LiquidGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select how many questions you want in your quiz:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.lg),
                      Wrap(
                        spacing: DesignTokens.sm,
                        runSpacing: DesignTokens.sm,
                        children: [5, 10, 15, 20].map((count) {
                          final isSelected = _selectedQuestionCount == count;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedQuestionCount = count;
                              });
                            },
                            child: LiquidGlassContainer(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DesignTokens.lg,
                                vertical: DesignTokens.md,
                              ),
                              backgroundColor: isSelected 
                                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                                  : theme.colorScheme.surface.withValues(alpha: 0.1),
                              borderColor: isSelected 
                                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                                  : theme.colorScheme.outline.withValues(alpha: 0.3),
                              borderRadius: DesignTokens.radiusMd,
                              enableAnimation: true,
                              child: Text(
                                '$count',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected 
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: DesignTokens.xl),
                
                // Difficulty Section
                _buildSectionHeader('Select Difficulty', Icons.trending_up),
                const SizedBox(height: DesignTokens.md),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildDifficultyChip('easy', 'Easy', Icons.sentiment_satisfied),
                    ),
                    const SizedBox(width: DesignTokens.sm),
                    Expanded(
                      child: _buildDifficultyChip('medium', 'Medium', Icons.sentiment_neutral),
                    ),
                    const SizedBox(width: DesignTokens.sm),
                    Expanded(
                      child: _buildDifficultyChip('hard', 'Hard', Icons.sentiment_dissatisfied),
                    ),
                  ],
                ),
                
                const SizedBox(height: DesignTokens.xl),
                
                // Debug Info (only in debug mode)
                if (kDebugMode) ...[
                  LiquidGlassContainer(
                    padding: const EdgeInsets.all(DesignTokens.md),
                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    borderColor: Colors.orange.withValues(alpha: 0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debug Info:',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.xs),
                        Text('Selected Book: ${_selectedBook ?? "None"}'),
                        Text('Available Books: ${_availableBooks.length}'),
                        Text('Question Count: ${_bookQuestionCounts[_selectedBook] ?? 0}'),
                        Text('Is Loading Question Count: $_isLoadingQuestionCount'),
                        Text('Start Button Enabled: $_canStartQuiz'),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.lg),
                ],
                
                // Start Quiz Button
                LiquidGlassButton(
                  onPressed: _isLoading || _selectedBook == null || !_canStartQuiz 
                      ? null 
                      : _startQuiz,
                  width: double.infinity,
                  child: _isLoading || _isLoadingQuestionCount
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Start Quiz',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
                
                // Debug info for start button
                if (kDebugMode) ...[
                  const SizedBox(height: DesignTokens.md),
                  LiquidGlassContainer(
                    padding: const EdgeInsets.all(DesignTokens.md),
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    borderColor: Colors.red.withValues(alpha: 0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Button Debug:',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text('Selected Book: ${_selectedBook ?? "None"}'),
                        Text('Can Start Quiz: $_canStartQuiz'),
                        Text('Is Loading: $_isLoading'),
                        Text('Is Loading Question Count: $_isLoadingQuestionCount'),
                        Text('Button Enabled: ${!_isLoading && _selectedBook != null && _canStartQuiz}'),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: DesignTokens.md),
                
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

  Widget _buildDifficultyChip(String difficulty, String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _selectedDifficulty == difficulty;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      child: LiquidGlassContainer(
        padding: const EdgeInsets.symmetric(
          vertical: DesignTokens.md,
          horizontal: DesignTokens.sm,
        ),
        backgroundColor: isSelected 
            ? theme.colorScheme.secondary.withValues(alpha: 0.2)
            : theme.colorScheme.surface.withValues(alpha: 0.1),
        borderColor: isSelected 
            ? theme.colorScheme.secondary.withValues(alpha: 0.5)
            : theme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: DesignTokens.radiusMd,
        enableAnimation: true,
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: DesignTokens.sm),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}