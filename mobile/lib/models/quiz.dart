import 'dart:convert';
import 'package:flutter/foundation.dart';

class Question {
  final String id;
  final String book;
  final String question;
  final List<String> options;
  final int correctOptionIndex; // Changed from String to int to match database

  Question({
    required this.id,
    required this.book,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    try {
      // Debug logging
      if (kDebugMode) {
        print('🔍 Parsing question: ${json['question']}');
        print('🔍 Options type: ${json['options'].runtimeType}');
        print('🔍 Options value: ${json['options']}');
        print('🔍 Correct option type: ${json['correct_option'].runtimeType}');
        print('🔍 Correct option value: ${json['correct_option']}');
      }

      // Handle options field - ensure it's a List<String>
      List<String> optionsList;
      if (json['options'] is List) {
        optionsList = List<String>.from(json['options'] ?? []);
      } else if (json['options'] is String) {
        // If options is a string, try to parse it as JSON
        try {
          final parsed = jsonDecode(json['options'] as String);
          if (parsed is List) {
            optionsList = List<String>.from(parsed);
          } else {
            optionsList = [];
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Failed to parse options string: $e');
          }
          optionsList = [];
        }
      } else {
        if (kDebugMode) {
          print('⚠️ Unexpected options type: ${json['options'].runtimeType}');
        }
        optionsList = [];
      }

      // Handle correct_option field - ensure it's an integer
      int correctOptionIndex;
      if (json['correct_option'] is int) {
        correctOptionIndex = json['correct_option'] as int;
      } else if (json['correct_option'] is String) {
        correctOptionIndex = int.tryParse(json['correct_option'] as String) ?? 0;
      } else {
        correctOptionIndex = 0;
      }

      return Question(
        id: json['id']?.toString() ?? '',
        book: json['book']?.toString() ?? '',
        question: json['question']?.toString() ?? '',
        options: optionsList,
        correctOptionIndex: correctOptionIndex,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing question: $e');
        print('❌ JSON data: $json');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book,
      'question': question,
      'options': options,
      'correct_option': correctOptionIndex,
    };
  }

  // Helper method to get the correct answer text
  String get correctOption => options.isNotEmpty && correctOptionIndex < options.length 
      ? options[correctOptionIndex] 
      : '';
}

class QuizResult {
  final String id;
  final String userId;
  final String book;
  final int score;
  final int totalQuestions;
  final int timeInSeconds;
  final Map<String, dynamic> answers;
  final DateTime createdAt;

  QuizResult({
    this.id = '', // Make ID optional with default empty string
    required this.userId,
    required this.book,
    required this.score,
    required this.totalQuestions,
    required this.timeInSeconds,
    required this.answers,
    required this.createdAt,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      book: json['book'] ?? '',
      score: json['score'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      timeInSeconds: json['time_in_seconds'] ?? 0,
      answers: Map<String, dynamic>.from(json['answers'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'user_id': userId,
      'book': book,
      'score': score,
      'total_questions': totalQuestions,
      'time_in_seconds': timeInSeconds,
      'answers': answers,
      'created_at': createdAt.toIso8601String(),
    };
    
    // Only include ID if it's not empty (let database generate UUID if empty)
    if (id.isNotEmpty) {
      data['id'] = id;
    }
    
    return data;
  }
}

