class QuizHistory {
  final String id;
  final String userId;
  final String book;
  final String difficulty;
  final int score;
  final int totalQuestions;
  final Map<String, dynamic> answers;
  final DateTime completedAt;

  QuizHistory({
    required this.id,
    required this.userId,
    required this.book,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.answers,
    required this.completedAt,
  });

  factory QuizHistory.fromJson(Map<String, dynamic> json) {
    return QuizHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      book: json['book'] as String,
      difficulty: json['difficulty'] as String,
      score: json['score'] as int,
      totalQuestions: json['total_questions'] as int,
      answers: json['answers'] as Map<String, dynamic>,
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book': book,
      'difficulty': difficulty,
      'score': score,
      'total_questions': totalQuestions,
      'answers': answers,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  double get percentageScore {
    if (totalQuestions == 0) return 0.0;
    return (score / totalQuestions) * 100;
  }

  String get grade {
    if (percentageScore >= 90) return 'A+';
    if (percentageScore >= 80) return 'A';
    if (percentageScore >= 70) return 'B';
    if (percentageScore >= 60) return 'C';
    if (percentageScore >= 50) return 'D';
    return 'F';
  }

  String get performanceMessage {
    if (percentageScore >= 90) return 'Excellent! You really know your Bible!';
    if (percentageScore >= 80) return 'Great job! You have solid knowledge!';
    if (percentageScore >= 70) return 'Good work! Keep studying!';
    if (percentageScore >= 60) return 'Not bad! Room for improvement!';
    if (percentageScore >= 50) return 'Keep practicing! You\'ll get better!';
    return 'Don\'t give up! Study more and try again!';
  }

  QuizHistory copyWith({
    String? id,
    String? userId,
    String? book,
    String? difficulty,
    int? score,
    int? totalQuestions,
    Map<String, dynamic>? answers,
    DateTime? completedAt,
  }) {
    return QuizHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      book: book ?? this.book,
      difficulty: difficulty ?? this.difficulty,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      answers: answers ?? this.answers,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'QuizHistory(id: $id, userId: $userId, book: $book, difficulty: $difficulty, score: $score, totalQuestions: $totalQuestions, answers: $answers, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizHistory &&
        other.id == id &&
        other.userId == userId &&
        other.book == book &&
        other.difficulty == difficulty &&
        other.score == score &&
        other.totalQuestions == totalQuestions &&
        other.answers == answers &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        book.hashCode ^
        difficulty.hashCode ^
        score.hashCode ^
        totalQuestions.hashCode ^
        answers.hashCode ^
        completedAt.hashCode;
  }
}
