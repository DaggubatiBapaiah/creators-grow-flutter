enum SocialPlatform {
  instagram,
  facebook,
  youtube,
  tiktok,
  linkedin,
  x;

  String get displayName {
    switch (this) {
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.youtube:
        return 'YouTube';
      case SocialPlatform.tiktok:
        return 'TikTok';
      case SocialPlatform.linkedin:
        return 'LinkedIn';
      case SocialPlatform.x:
        return 'X';
    }
  }

  bool get isSupported {
    return this == SocialPlatform.instagram || this == SocialPlatform.tiktok;
  }
}