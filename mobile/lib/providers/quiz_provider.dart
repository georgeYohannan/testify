import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question.dart';
import '../models/quiz_history.dart';

class QuizProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Question> _questions = [];
  List<Question> _currentQuizQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<Map<String, dynamic>> _userAnswers = [];
  List<QuizHistory> _quizHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedBook;

  // Getters
  List<Question> get questions => _questions;
  List<Question> get currentQuizQuestions => _currentQuizQuestions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  List<Map<String, dynamic>> get userAnswers => _userAnswers;
  List<QuizHistory> get quizHistory => _quizHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedBook => _selectedBook;
  
  int get totalQuestions => _currentQuizQuestions.length;
  bool get isQuizComplete => _currentQuestionIndex >= _currentQuizQuestions.length;
  Question? get currentQuestion => _currentQuestionIndex < _currentQuizQuestions.length 
      ? _currentQuizQuestions[_currentQuestionIndex] 
      : null;

  // Quiz setup
  void setQuizSettings({String? book}) {
    _selectedBook = book;
    notifyListeners();
  }

  Future<bool> loadQuestions({String? book}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      String query = '';
      if (book != null && book.isNotEmpty) {
        query = 'book.eq.$book';
      }

      final response = await _supabase
          .from('questions')
          .select()
          .eq('book', book ?? '')
          .order('created_at', ascending: false);

      if (response != null) {
        _questions = (response as List)
            .map((json) => Question.fromJson(json))
            .toList();
        
        // Shuffle questions for variety
        _questions.shuffle();
        
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to load questions: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startQuiz({int questionCount = 10}) {
    if (_questions.isEmpty) return;
    
    // Take first N questions or all if less than N
    _currentQuizQuestions = _questions.take(questionCount).toList();
    _currentQuestionIndex = 0;
    _score = 0;
    _userAnswers = [];
    notifyListeners();
  }

  void answerQuestion(String selectedOption) {
    if (_currentQuestionIndex >= _currentQuizQuestions.length) return;
    
    final question = _currentQuizQuestions[_currentQuestionIndex];
    final isCorrect = question.isCorrect(selectedOption);
    
    if (isCorrect) {
      _score++;
    }
    
    _userAnswers.add({
      'question_id': question.id,
      'selected_option': selectedOption,
      'correct_option': question.correctOption,
      'is_correct': isCorrect,
      'question_text': question.questionText,
    });
    
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuizQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _userAnswers = [];
    _currentQuizQuestions = [];
    notifyListeners();
  }

  Future<bool> saveQuizHistory() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null || _selectedBook == null) {
        return false;
      }

      final quizHistory = {
        'user_id': user.id,
        'book': _selectedBook,
        'score': _score,
        'total_questions': _currentQuizQuestions.length,
        'answers': _userAnswers,
      };

      await _supabase
          .from('quiz_history')
          .insert(quizHistory);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to save quiz history: $e';
      return false;
    }
  }

  Future<List<QuizHistory>> loadQuizHistory() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('quiz_history')
          .select()
          .eq('user_id', user.id)
          .order('completed_at', ascending: false);

      if (response != null) {
        _quizHistory = (response as List)
            .map((json) => QuizHistory.fromJson(json))
            .toList();
        notifyListeners();
        return _quizHistory;
      }
      return [];
    } catch (e) {
      _errorMessage = 'Failed to load quiz history: $e';
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Quiz statistics
  Map<String, int> get bookStats {
    final Map<String, int> stats = {};
    for (final question in _questions) {
      stats[question.book] = (stats[question.book] ?? 0) + 1;
    }
    return stats;
  }
}
