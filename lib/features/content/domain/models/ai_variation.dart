class AIVariation {
  final String hook;
  final String body;
  final List<String> hashtags;
  final String fullText;

  const AIVariation({
    required this.hook,
    required this.body,
    required this.hashtags,
    required this.fullText,
  });

  factory AIVariation.fromJson(Map<String, dynamic> json) {
    return AIVariation(
      hook: json['hook'] as String? ?? '',
      body: json['body'] as String? ?? '',
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      fullText: json['fullText'] as String? ?? '',
    );
  }
}
