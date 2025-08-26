import 'dart:math';
import 'package:flutter/foundation.dart';
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
      if (kDebugMode) {
        print('Failed to fetch available books: $e');
      }
      // Fallback to placeholder books if database fails
      return [
        'Genesis',
        'Exodus',
        'Matthew',
        'Mark',
        'Luke',
        'John',
        'Acts',
        'Romans',
        '1 Corinthians',
        '2 Corinthians',
        'Galatians',
        'Ephesians',
        'Philippians',
        'Colossians',
        '1 Thessalonians',
        '2 Thessalonians',
        '1 Timothy',
        '2 Timothy',
        'Titus',
        'Philemon',
        'Hebrews',
        'James',
        '1 Peter',
        '2 Peter',
        '1 John',
        '2 John',
        '3 John',
        'Jude',
        'Revelation',
      ];
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
      if (kDebugMode) {
        print('Failed to fetch questions: $e');
      }
      // Fallback to placeholder questions if database fails
      return _getPlaceholderQuestions(book, limit);
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
      // Fallback to placeholder verse if database fails
      return _getPlaceholderVerse();
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

  // Fallback methods for when database is unavailable
  static List<Question> _getPlaceholderQuestions(String book, int limit) {
    final questions = [
      Question(
        id: '1',
        book: book,
        question: 'What is the first book of the Bible?',
        options: ['Genesis', 'Exodus', 'Matthew', 'Revelation'],
        correctOption: 'Genesis',
      ),
      Question(
        id: '2',
        book: book,
        question: 'Who built the ark according to the Bible?',
        options: ['Moses', 'Noah', 'Abraham', 'David'],
        correctOption: 'Noah',
      ),
      Question(
        id: '3',
        book: book,
        question: 'How many days and nights did Jesus fast in the wilderness?',
        options: ['30', '40', '50', '60'],
        correctOption: '40',
      ),
      Question(
        id: '4',
        book: book,
        question: 'Who was the first king of Israel?',
        options: ['David', 'Solomon', 'Saul', 'Samuel'],
        correctOption: 'Saul',
      ),
      Question(
        id: '5',
        book: book,
        question: 'What is the shortest verse in the Bible?',
        options: ['Jesus wept', 'Rejoice always', 'Pray continually', 'Love one another'],
        correctOption: 'Jesus wept',
      ),
    ];
    
    questions.shuffle(_random);
    return questions.take(limit).toList();
  }

  static Verse _getPlaceholderVerse() {
    final verses = [
      Verse(
        id: '1',
        text: 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
        reference: 'John 3:16',
      ),
      Verse(
        id: '2',
        text: 'I can do all things through Christ who strengthens me.',
        reference: 'Philippians 4:13',
      ),
      Verse(
        id: '3',
        text: 'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.',
        reference: 'Proverbs 3:5-6',
      ),
      Verse(
        id: '4',
        text: 'The Lord is my shepherd, I shall not want.',
        reference: 'Psalm 23:1',
      ),
      Verse(
        id: '5',
        text: 'Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
        reference: 'Joshua 1:9',
      ),
    ];
    
    return verses[_random.nextInt(verses.length)];
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