import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:testify/models/quiz.dart';
import 'package:testify/models/verse.dart';
import 'package:testify/supabase/supabase_config.dart';

class QuizService {
  static final Random _random = Random();

  static Future<List<String>> getAvailableBooks() async {
    // Return a static list of Bible books in order - no need to query database for this
    if (kDebugMode) {
      print('📚 Returning Bible book list in canonical order');
    }
    
    // Bible books in canonical order
    return [
      // Old Testament (39 books)
      'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
      'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
      '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles',
      'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
      'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah',
      'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel',
      'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum',
      'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi',
      // New Testament (27 books)
      'Matthew', 'Mark', 'Luke', 'John', 'Acts',
      'Romans', '1 Corinthians', '2 Corinthians', 'Galatians',
      'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians',
      '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus',
      'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter',
      '1 John', '2 John', '3 John', 'Jude', 'Revelation'
    ];
  }

  static Future<int> getQuestionCountForBook(String book) async {
    try {
      final response = await SupabaseService.select(
        table: 'questions',
        filters: {
          'book': book,
        },
        columns: 'id', // Only count IDs for performance
      );
      
      return response.length;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get question count for $book: $e');
      }
      return 0;
    }
  }

  static Future<List<Question>> getQuestions({
    required String book,
    int limit = 5,
  }) async {
    try {
      // First, get all questions for the book to determine total count
      final allQuestionsResponse = await SupabaseService.select(
        table: 'questions',
        filters: {
          'book': book,
        },
      );

      if (allQuestionsResponse.isEmpty) {
        throw Exception('No questions available for $book');
      }

      final allQuestions = <Question>[];
      
      // Parse questions with error handling for individual items
      for (final json in allQuestionsResponse) {
        try {
          final question = Question.fromJson(json);
          if (question.options.isNotEmpty) {
            allQuestions.add(question);
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Skipping malformed question for $book: $e');
          }
          // Continue with other questions
        }
      }

      if (allQuestions.isEmpty) {
        throw Exception('No valid questions available for $book');
      }

      final totalQuestions = allQuestions.length;

      if (kDebugMode) {
        print('📚 Found $totalQuestions valid questions for $book');
      }

      // If we have more questions than the limit, randomly select questions
      if (totalQuestions > limit) {
        // Shuffle all questions and take the first 'limit' questions
        allQuestions.shuffle(_random);
        final selectedQuestions = allQuestions.take(limit).toList();
        
        if (kDebugMode) {
          print('🎲 Randomly selected $limit questions from $totalQuestions available');
        }
        
        return selectedQuestions;
      } else {
        // If we have fewer or equal questions to the limit, return all available
        if (kDebugMode) {
          print('📖 Returning all $totalQuestions questions (less than limit of $limit)');
        }
        return allQuestions;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch questions: $e');
      }
      // No fallback questions - only use Supabase data
      rethrow;
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
      if (kDebugMode) {
        print('Failed to fetch daily verse: $e');
      }
      // No fallback verses - only use Supabase data
      rethrow;
    }
  }

  static Future<void> saveQuizResult(QuizResult result) async {
    try {
      await SupabaseService.insert(
        table: 'quiz_history',
        data: result.toJson(),
      );
      if (kDebugMode) {
        print('Quiz result saved to database: ${result.toJson()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save quiz result to database: $e');
        print('Quiz result saved locally: ${result.toJson()}');
      }
      // Could implement local storage fallback here
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
      if (kDebugMode) {
        print('Failed to fetch quiz history from database: $e');
      }
      // Return empty list if database fails
      return [];
    }
  }



  // Test method to verify database connection
  static Future<void> testDatabaseConnection() async {
    try {
      if (kDebugMode) {
        print('Testing database connection...');
      }
      
      // Test 1: Check if we can connect to the database
      try {
        await SupabaseService.select(
          table: 'questions',
          limit: 1,
        );
        if (kDebugMode) {
          print('✓ Database connection successful');
          print('✓ Questions table accessible');
        }
      } catch (e) {
        if (kDebugMode) {
          print('✗ Database connection failed: $e');
        }
        return;
      }
      
      // Test 2: Check total questions count
      try {
        final allQuestions = await SupabaseService.select(
          table: 'questions',
          limit: 1000, // Get a large number to see total
        );
        
        if (kDebugMode) {
          print('✓ Total questions in database: ${allQuestions.length}');
          if (allQuestions.isNotEmpty) {
            print('✓ Sample question structure: ${allQuestions.first.keys.toList()}');
            print('✓ Sample question data: ${allQuestions.first}');
          } else {
            print('⚠ No questions found in database');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('✗ Failed to count questions: $e');
        }
      }
      
      // Test 3: Check available books
      try {
        final allBooks = await SupabaseService.select(
          table: 'questions',
          columns: 'book',
        );
        
        if (kDebugMode) {
          final uniqueBooks = allBooks.map((q) => q['book']).where((b) => b != null).toSet().toList();
          print('✓ Available books: $uniqueBooks');
        }
      } catch (e) {
        if (kDebugMode) {
          print('✗ Failed to get books: $e');
        }
      }
      
      // Test 4: Try to get questions for a specific book
      try {
        final genesisQuestions = await SupabaseService.select(
          table: 'questions',
          filters: {'book': 'Genesis'},
          limit: 5,
        );
        
        if (kDebugMode) {
          print('✓ Genesis questions found: ${genesisQuestions.length}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('✗ Failed to get Genesis questions: $e');
        }
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('✗ Database connection test failed: $e');
      }
    }
  }
}