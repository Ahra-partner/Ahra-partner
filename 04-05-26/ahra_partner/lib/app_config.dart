class AppConfig {
  static const bool isPartnerApp =
      bool.fromEnvironment('PARTNER_APP', defaultValue: true);
}