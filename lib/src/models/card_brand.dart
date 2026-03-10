enum CardBrand {
  amex('^3[47]', 15, 15, 'assets/brand_amex.png'),
  diners('^3(0[0-5]|6)', 14, 14, 'assets/brand_diners.png'),
  jcb('^35(2[89]|[3-8])', 16, 16, 'assets/brand_jcb.png'),
  visa('^4', 16, 16, 'assets/brand_visa.png'),
  mastercard('^5[1-5]', 16, 16, 'assets/brand_mastercard.png'),
  maestro('^(5018|5020|5038|6304|6759|676[1-3])', 12, 19,
      'assets/brand_maestro.png'),
  discover(
      '^(6011|622(12[6-9]|1[3-9][0-9]|[2-8][0-9]{2}|9[0-1][0-9]|92[0-5]|64[4-9])|65)',
      16,
      16,
      'assets/brand_discover.png'),
  unionpay('^(62|81)', 16, 19, 'assets/brand_unionpay.png');

  final String patternStr;
  final int minLength;
  final int maxLength;
  final String logoAssetPath;

  const CardBrand(
    this.patternStr,
    this.minLength,
    this.maxLength,
    this.logoAssetPath,
  );

  bool match(String? pan) {
    if (pan == null || pan.isEmpty) return false;
    // Remove spaces before matching
    final sanitizedPan = pan.replaceAll(RegExp(r'\s+'), '');
    // Construct regex to match the pattern at start, followed by optional digits to end
    final pattern = RegExp(patternStr + r'[0-9]*$');
    return pattern.hasMatch(sanitizedPan);
  }

  bool valid(String pan) {
    if (pan.isEmpty) return false;
    final sanitizedPan = pan.replaceAll(RegExp(r'\s+'), '');
    return match(sanitizedPan) &&
        minLength <= sanitizedPan.length &&
        sanitizedPan.length <= maxLength;
  }

  static CardBrand? getActiveBrand(String? pan) {
    if (pan == null || pan.isEmpty) return null;
    final sanitizedPan = pan.replaceAll(RegExp(r'\s+'), '');
    // Enums automatically provide a `.values` list!
    for (var brand in CardBrand.values) {
      if (brand.match(sanitizedPan)) {
        return brand;
      }
    }
    return null;
  }
}
