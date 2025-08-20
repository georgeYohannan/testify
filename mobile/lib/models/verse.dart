class Verse {
  final String id;
  final String text;
  final String reference;
  final DateTime createdAt;
  final DateTime updatedAt;

  Verse({
    required this.id,
    required this.text,
    required this.reference,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] as String,
      text: json['text'] as String,
      reference: json['reference'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'reference': reference,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Verse copyWith({
    String? id,
    String? text,
    String? reference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Verse(
      id: id ?? this.id,
      text: text ?? this.text,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Verse(id: $id, text: $text, reference: $reference, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Verse &&
        other.id == id &&
        other.text == text &&
        other.reference == reference &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        reference.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
