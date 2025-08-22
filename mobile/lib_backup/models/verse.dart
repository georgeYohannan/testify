class Verse {
  final String id;
  final String text;
  final String reference;

  Verse({
    required this.id,
    required this.text,
    required this.reference,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      reference: json['reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'reference': reference,
    };
  }
}