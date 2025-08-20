class Question {
  final String id;
  final String book;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String? verseReference;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.book,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.verseReference,
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      book: json['book'] as String,
      questionText: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctOptionIndex: json['correct_option'] as int,
      verseReference: json['verse_reference'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book,
      'question': questionText,
      'options': options,
      'correct_option': correctOptionIndex,
      'verse_reference': verseReference,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool isCorrect(String selectedOption) {
    final selectedIndex = options.indexOf(selectedOption);
    return selectedIndex == correctOptionIndex;
  }

  String get correctOption {
    return options[correctOptionIndex];
  }

  Question copyWith({
    String? id,
    String? book,
    String? questionText,
    List<String>? options,
    int? correctOptionIndex,
    String? verseReference,
    DateTime? createdAt,
  }) {
    return Question(
      id: id ?? this.id,
      book: book ?? this.book,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      verseReference: verseReference ?? this.verseReference,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Question(id: $id, book: $book, questionText: $questionText, options: $options, correctOptionIndex: $correctOptionIndex, verseReference: $verseReference)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question &&
        other.id == id &&
        other.book == book &&
        other.questionText == questionText &&
        other.options == options &&
        other.correctOptionIndex == correctOptionIndex &&
        other.verseReference == verseReference;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        book.hashCode ^
        questionText.hashCode ^
        options.hashCode ^
        correctOptionIndex.hashCode ^
        verseReference.hashCode;
  }
}
