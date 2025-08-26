import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testify/services/quiz_service.dart';
import 'package:testify/widgets/elephant_mascot.dart';
import 'package:flutter/foundation.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  String? _selectedBook;
  String _selectedDifficulty = 'medium';
  bool _isLoading = true;
  bool _isLoadingBooks = true;
  List<String> _availableBooks = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAvailableBooks();
    // Temporarily disabled to fix loading issue
    // _testDatabaseConnection();
  }

  Future<void> _testDatabaseConnection() async {
    await QuizService.testDatabaseConnection();
  }

  Future<void> _loadAvailableBooks() async {
    try {
      if (kDebugMode) {
        print('🔄 Loading available books...');
      }
      
      setState(() {
        _isLoadingBooks = true;
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
          _isLoadingBooks = false;
        });
        
        // Auto-select first book if available
        if (books.isNotEmpty && _selectedBook == null) {
          setState(() {
            _selectedBook = books.first;
          });
          if (kDebugMode) {
            print('✓ Auto-selected first book: ${books.first}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('✗ Failed to load available books: $e');
      }
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load available books: $e';
          _isLoadingBooks = false;
        });
      }
    }
  }

  Future<void> _startQuiz() async {
    if (_selectedBook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a book'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Generate a simple quiz ID for navigation
      final quizId = '${_selectedBook}_${DateTime.now().millisecondsSinceEpoch}';
      
      if (mounted) {
        context.go('/quiz?id=$quizId&difficulty=$_selectedDifficulty');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error starting quiz: $e';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting quiz: $e'),
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
                // Header
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
                        'Quiz Setup',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose your quiz settings and get ready to test your knowledge!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Book Selection
                Text(
                  'Select Bible Book',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (_isLoadingBooks)
                  const Center(child: CircularProgressIndicator())
                else if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: 'Choose a book...',
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
                  ),
                
                const SizedBox(height: 24),
                
                // Difficulty Selection
                Text(
                  'Select Difficulty',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildDifficultyChip('easy', 'Easy', Icons.sentiment_satisfied),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDifficultyChip('medium', 'Medium', Icons.sentiment_neutral),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDifficultyChip('hard', 'Hard', Icons.sentiment_dissatisfied),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Start Quiz Button
                if (kDebugMode) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Debug Info:', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        Text('Selected Book: ${_selectedBook ?? "None"}'),
                        Text('Available Books: ${_availableBooks.length}'),
                        Text('Is Loading: $_isLoading'),
                        Text('Start Button Enabled: ${_selectedBook != null && !_isLoading}'),
                      ],
                    ),
                  ),
                ],
                
                FilledButton(
                  onPressed: _isLoading || _selectedBook == null ? null : _startQuiz,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Back Button
                OutlinedButton(
                  onPressed: () => context.go('/dashboard'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.outline,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}