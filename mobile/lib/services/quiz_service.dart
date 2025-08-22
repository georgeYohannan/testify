import 'dart:math';
import 'package:testify/models/quiz.dart';
import 'package:testify/models/verse.dart';
import 'package:testify/supabase/supabase_config.dart';

class QuizService {
  static final Random _random = Random();

  static Future<List<String>> getAvailableBooks() async {
    try {
      final response = await SupabaseService.select(
        table: 'questions',
        columns: 'book',
      );
      
      // Extract unique book names
      final books = response
          .map((json) => json['book'] as String)
          .toSet()
          .toList();
      
      return books..sort();
    } catch (e) {
      print('Failed to fetch available books: $e');
      return [];
    }
  }

  static Future<List<Question>> getQuestions({
    required String book,
    int limit = 5,
  }) async {
    try {
      final response = await SupabaseService.select(
        table: 'questions',
        filters: {
          'book': book,
        },
        limit: limit,
      );

      if (response.isEmpty) {
        throw Exception('No questions available for $book');
      }

      final questions = response.map((json) => Question.fromJson(json)).toList();
      questions.shuffle(_random);
      return questions.take(limit).toList();
    } catch (e) {
      print('Failed to fetch questions: $e');
      rethrow; // Re-throw to let UI handle the error
    }
  }

  static Future<Verse> getDailyVerse() async {
    try {
      final response = await SupabaseService.select(
        table: 'verses',
        limit: 100, // Get more verses for better randomization
      );

      if (response.isEmpty) {
        throw Exception('No verses available');
      }

      final randomIndex = _random.nextInt(response.length);
      return Verse.fromJson(response[randomIndex]);
    } catch (e) {
      print('Failed to fetch daily verse: $e');
      rethrow; // Re-throw to let UI handle the error
    }
  }

  static Future<void> saveQuizResult(QuizResult result) async {
    try {
      await SupabaseService.insert(
        table: 'quiz_history',
        data: result.toJson(),
      );
    } catch (e) {
      print('Failed to save quiz result: $e');
      rethrow;
    }
  }

  static Future<List<QuizResult>> getQuizHistory(String userId) async {
    try {
      final response = await SupabaseService.select(
        table: 'quiz_history',
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
      );

      return response.map((json) => QuizResult.fromJson(json)).toList();
    } catch (e) {
      print('Failed to fetch quiz history: $e');
      return [];
    }
  }

  static int calculateScore(List<Question> questions, Map<String, String> answers) {
    int correct = 0;
    for (final question in questions) {
      if (answers[question.id] == question.correctOption) {
        correct++;
      }
    }
    return (correct / questions.length * 100).round();
  }

  static Future<List<Verse>> getEncouragementVerses(int score) async {
    try {
      final response = await SupabaseService.select(
        table: 'verses',
        limit: 50,
      );

      if (response.isEmpty) {
        return [];
      }

      final verses = response.map((json) => Verse.fromJson(json)).toList();
      verses.shuffle(_random);

      if (score >= 80) {
        // Return encouraging verses for high scores
        return verses.take(2).toList();
      } else if (score >= 60) {
        // Return motivational verses for medium scores
        return verses.take(2).toList();
      } else {
        // Return comforting verses for lower scores
        return verses.take(2).toList();
      }
    } catch (e) {
      print('Failed to fetch encouragement verses: $e');
      return [];
    }
  }
}