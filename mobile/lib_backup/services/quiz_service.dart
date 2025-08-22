import 'dart:math';
import 'package:word__way/models/quiz.dart';
import 'package:word__way/models/verse.dart';
import 'package:word__way/supabase/supabase_config.dart';

class QuizService {
  static final Random _random = Random();

  // Sample data for immediate testing
  static final List<Question> _sampleQuestions = [
    // Genesis - Easy
    Question(
      id: '1',
      book: 'Genesis',
      difficulty: 'Easy',
      question: 'Who did God create first?',
      options: ['Adam', 'Eve', 'Noah', 'Abraham'],
      correctOption: 'Adam',
      verseReference: 'Genesis 2:7',
    ),
    Question(
      id: '2',
      book: 'Genesis',
      difficulty: 'Easy',
      question: 'How many days did it take God to create the world?',
      options: ['5', '6', '7', '8'],
      correctOption: '6',
      verseReference: 'Genesis 1:31',
    ),
    // Genesis - Medium
    Question(
      id: '3',
      book: 'Genesis',
      difficulty: 'Medium',
      question: 'What was the name of Abraham\'s wife?',
      options: ['Rachel', 'Leah', 'Sarah', 'Rebecca'],
      correctOption: 'Sarah',
      verseReference: 'Genesis 17:15',
    ),
    Question(
      id: '4',
      book: 'Genesis',
      difficulty: 'Medium',
      question: 'How many sons did Jacob have?',
      options: ['10', '11', '12', '13'],
      correctOption: '12',
      verseReference: 'Genesis 35:22',
    ),
    // Genesis - Hard
    Question(
      id: '5',
      book: 'Genesis',
      difficulty: 'Hard',
      question: 'What did Joseph\'s brothers sell him for?',
      options: ['20 pieces of silver', '30 pieces of silver', '20 shekels of silver', '30 shekels of silver'],
      correctOption: '20 shekels of silver',
      verseReference: 'Genesis 37:28',
    ),
    // Exodus - Easy
    Question(
      id: '6',
      book: 'Exodus',
      difficulty: 'Easy',
      question: 'Who led the Israelites out of Egypt?',
      options: ['Aaron', 'Moses', 'Joshua', 'David'],
      correctOption: 'Moses',
      verseReference: 'Exodus 3:10',
    ),
    Question(
      id: '7',
      book: 'Exodus',
      difficulty: 'Easy',
      question: 'How many commandments did God give Moses?',
      options: ['8', '10', '12', '15'],
      correctOption: '10',
      verseReference: 'Exodus 20:1-17',
    ),
    // Matthew - Easy
    Question(
      id: '8',
      book: 'Matthew',
      difficulty: 'Easy',
      question: 'Where was Jesus born?',
      options: ['Nazareth', 'Jerusalem', 'Bethlehem', 'Galilee'],
      correctOption: 'Bethlehem',
      verseReference: 'Matthew 2:1',
    ),
    Question(
      id: '9',
      book: 'Matthew',
      difficulty: 'Medium',
      question: 'How many disciples did Jesus choose?',
      options: ['10', '11', '12', '13'],
      correctOption: '12',
      verseReference: 'Matthew 10:1-4',
    ),
    // John - Easy
    Question(
      id: '10',
      book: 'John',
      difficulty: 'Easy',
      question: 'What is the most famous verse in the Bible?',
      options: ['John 3:16', 'John 1:1', 'John 14:6', 'John 8:32'],
      correctOption: 'John 3:16',
      verseReference: 'John 3:16',
    ),
  ];

  static final List<Verse> _sampleVerses = [
    Verse(id: '1', text: 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.', reference: 'John 3:16'),
    Verse(id: '2', text: 'Trust in the Lord with all your heart and lean not on your own understanding.', reference: 'Proverbs 3:5'),
    Verse(id: '3', text: 'I can do all this through him who gives me strength.', reference: 'Philippians 4:13'),
    Verse(id: '4', text: 'The Lord is my shepherd, I lack nothing.', reference: 'Psalm 23:1'),
    Verse(id: '5', text: 'Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.', reference: 'Joshua 1:9'),
    Verse(id: '6', text: 'And we know that in all things God works for the good of those who love him, who have been called according to his purpose.', reference: 'Romans 8:28'),
    Verse(id: '7', text: 'Cast all your anxiety on him because he cares for you.', reference: '1 Peter 5:7'),
    Verse(id: '8', text: 'In the beginning was the Word, and the Word was with God, and the Word was God.', reference: 'John 1:1'),
  ];

  static List<String> getAvailableBooks() {
    return ['Genesis', 'Exodus', 'Matthew', 'John'];
  }

  static Future<List<Question>> getQuestions({
    required String book,
    required String difficulty,
    int limit = 5,
  }) async {
    try {
      // Try to fetch from Supabase first
      final response = await SupabaseService.select(
        table: 'questions',
        filters: {
          'book': book,
          'difficulty': difficulty,
        },
        limit: limit,
      );

      if (response.isNotEmpty) {
        return response.map((json) => Question.fromJson(json)).toList();
      }
    } catch (e) {
      // If Supabase fails, use sample data
      print('Using sample questions: \$e');
    }

    // Fallback to sample data
    final filteredQuestions = _sampleQuestions
        .where((q) => q.book == book && q.difficulty == difficulty)
        .toList();
    
    filteredQuestions.shuffle(_random);
    return filteredQuestions.take(limit).toList();
  }

  static Future<Verse> getDailyVerse() async {
    try {
      // Try to fetch from Supabase first
      final response = await SupabaseService.select(
        table: 'verses',
        limit: 1,
      );

      if (response.isNotEmpty) {
        final randomIndex = _random.nextInt(response.length);
        return Verse.fromJson(response[randomIndex]);
      }
    } catch (e) {
      print('Using sample verse: \$e');
    }

    // Fallback to sample data
    final randomIndex = _random.nextInt(_sampleVerses.length);
    return _sampleVerses[randomIndex];
  }

  static Future<void> saveQuizResult(QuizResult result) async {
    try {
      await SupabaseService.insert(
        table: 'quiz_history',
        data: result.toJson(),
      );
    } catch (e) {
      print('Failed to save quiz result: \$e');
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
      print('Failed to fetch quiz history: \$e');
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

  static List<Verse> getEncouragementVerses(int score) {
    if (score >= 80) {
      return _sampleVerses.where((v) => 
          v.reference.contains('Philippians') || 
          v.reference.contains('Joshua')).toList();
    } else if (score >= 60) {
      return _sampleVerses.where((v) => 
          v.reference.contains('Romans') || 
          v.reference.contains('Proverbs')).toList();
    } else {
      return _sampleVerses.where((v) => 
          v.reference.contains('1 Peter') || 
          v.reference.contains('Psalm')).toList();
    }
  }
}