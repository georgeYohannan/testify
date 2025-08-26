class Question {
  final String id;
  final String book;
  final String question;
  final List<String> options;
  final String correctOption;

  Question({
    required this.id,
    required this.book,
    required this.question,
    required this.options,
    required this.correctOption,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      book: json['book'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOption: json['correct_option'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book,
      'question': question,
      'options': options,
      'correct_option': correctOption,
    };
  }
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
    required this.id,
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
    return {
      'id': id,
      'user_id': userId,
      'book': book,
      'score': score,
      'total_questions': totalQuestions,
      'time_in_seconds': timeInSeconds,
      'answers': answers,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

