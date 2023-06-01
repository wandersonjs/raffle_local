class RaffleDetails {
  late String premiumDescription = "";
  late double premiumValue = 0.0;
  late double quotaValue = 0.0;
  late int max = 50;

  RaffleDetails();

  RaffleDetails.fromJson(Map<String, dynamic> json) {
    try {
      premiumDescription = json['premium_description'] ?? "";
      premiumValue = json['premium_value'] ?? 0.0;
      quotaValue = json['quota_value'] ?? 0.0;
      max = json['max'] ?? 0;
    } catch (e) {
      premiumDescription = "";
      premiumValue = 0.0;
      quotaValue = 0.0;
      max = 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'premium_description': premiumDescription,
      'premium_value': premiumValue,
      'quota_value': quotaValue,
      'max': max
    };
  }
}
