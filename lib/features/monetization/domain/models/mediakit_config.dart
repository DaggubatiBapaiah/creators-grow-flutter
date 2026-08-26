class RateItem {
  final String service;
  final double rate;

  const RateItem({required this.service, required this.rate});

  factory RateItem.fromJson(Map<String, dynamic> json) {
    return RateItem(
      service: json['service'] as String? ?? '',
      rate: double.parse((json['rate'] ?? 0).toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'service': service,
    'rate': rate,
  };
}

class MediaKitConfig {
  final String id;
  final String userId;
  final String? customBio;
  final String? contactEmail;
  final bool showInstagram;
  final bool showTiktok;
  final List<RateItem> rates;
  final int viewsCount;

  const MediaKitConfig({
    required this.id,
    required this.userId,
    this.customBio,
    this.contactEmail,
    this.showInstagram = true,
    this.showTiktok = true,
    this.rates = const [],
    this.viewsCount = 0,
  });

  factory MediaKitConfig.fromJson(Map<String, dynamic> json) {
    final ratesRaw = json['rates'] as List<dynamic>? ?? [];
    return MediaKitConfig(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      customBio: json['custom_bio'] as String?,
      contactEmail: json['contact_email'] as String?,
      showInstagram: json['show_instagram'] as bool? ?? true,
      showTiktok: json['show_tiktok'] as bool? ?? true,
      rates: ratesRaw.map((e) => RateItem.fromJson(e as Map<String, dynamic>)).toList(),
      viewsCount: json['views_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'custom_bio': customBio,
      'contact_email': contactEmail,
      'show_instagram': showInstagram,
      'show_tiktok': showTiktok,
      'rates': rates.map((e) => e.toJson()).toList(),
      'views_count': viewsCount,
    };
  }

  MediaKitConfig copyWith({
    String? id,
    String? userId,
    String? customBio,
    String? contactEmail,
    bool? showInstagram,
    bool? showTiktok,
    List<RateItem>? rates,
    int? viewsCount,
  }) {
    return MediaKitConfig(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customBio: customBio ?? this.customBio,
      contactEmail: contactEmail ?? this.contactEmail,
      showInstagram: showInstagram ?? this.showInstagram,
      showTiktok: showTiktok ?? this.showTiktok,
      rates: rates ?? this.rates,
      viewsCount: viewsCount ?? this.viewsCount,
    );
  }
}