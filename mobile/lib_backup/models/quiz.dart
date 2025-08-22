class Question {
  final String id;
  final String book;
  final String difficulty;
  final String question;
  final List<String> options;
  final String correctOption;
  final String verseReference;

  Question({
    required this.id,
    required this.book,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctOption,
    required this.verseReference,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      book: json['book'] ?? '',
      difficulty: json['difficulty'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOption: json['correct_option'] ?? '',
      verseReference: json['verse_reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book,
      'difficulty': difficulty,
      'question': question,
      'options': options,
      'correct_option': correctOption,
      'verse_reference': verseReference,
    };
  }
}

class QuizResult {
  final String id;
  final String userId;
  final String book;
  final String difficulty;
  final int score;
  final Map<String, dynamic> answers;
  final DateTime createdAt;

  QuizResult({
    required this.id,
    required this.userId,
    required this.book,
    required this.difficulty,
    required this.score,
    required this.answers,
    required this.createdAt,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      book: json['book'] ?? '',
      difficulty: json['difficulty'] ?? '',
      score: json['score'] ?? 0,
      answers: Map<String, dynamic>.from(json['answers'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book': book,
      'difficulty': difficulty,
      'score': score,
      'answers': answers,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum Difficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  const Difficulty(this.displayName);
  final String displayName;
}