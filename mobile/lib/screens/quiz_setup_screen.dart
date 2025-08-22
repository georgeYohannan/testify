import 'package:flutter/material.dart';
import 'package:testify/services/quiz_service.dart';
import 'package:testify/widgets/elephant_mascot.dart';
import 'package:testify/screens/quiz_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  String? _selectedBook;
  bool _isLoading = false;
  bool _isLoadingBooks = true;
  List<String> _availableBooks = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAvailableBooks();
  }

  Future<void> _loadAvailableBooks() async {
    try {
      setState(() {
        _isLoadingBooks = true;
        _errorMessage = null;
      });

      final books = await QuizService.getAvailableBooks();
      
      if (mounted) {
        setState(() {
          _availableBooks = books;
          _isLoadingBooks = false;
        });
      }
    } catch (e) {
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
      final questions = await QuizService.getQuestions(
        book: _selectedBook!,
        limit: 5,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              questions: questions,
              book: _selectedBook!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading quiz: $e';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading quiz: $e'),
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
              size: 120,
              state: ElephantState.encouraging,
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              'Choose Your Quiz',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Select a Bible book to start your quiz',
                          style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            ),
            
            const SizedBox(height: 32),
            
            // Book Selection
            if (_isLoadingBooks)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              _buildErrorWidget()
            else
              _buildBookSelection(),
            
            const Spacer(),
            
            // Start Quiz Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_selectedBook != null && !_isLoading)
                    ? _startQuiz
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                    : const Text(
                        'Start Quiz',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadAvailableBooks,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Book',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableBooks.map((book) {
            final isSelected = _selectedBook == book;
            return ChoiceChip(
              label: Text(book),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedBook = selected ? book : null;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}