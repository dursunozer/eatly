class PolicyConfig {
  PolicyConfig._();

  // Sunucuda (backend) host edilen güncel KVKK/Gizlilik politikası URL'si
  static const String policyUrl =
      'https://www.resmigazete.gov.tr/eskiler/2016/04/20160407-8.pdf';

  // Politika versiyonu (backend ile senkron tutun)
  static const String policyVersion = '1.0.1';
}
