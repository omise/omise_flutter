import 'package:flutter/material.dart';
import 'package:omise_flutter/src/enums/enums.dart';

class Translations {
  /// A test locale that can be set during utility unit testing since mocking context delegates in hard.
  /// In actual widget tests the actual context must be used.
  static Locale? testLocale;
  static const Map<OmiseLocale, Map<String, String>> translations = {
    OmiseLocale.en: {
      "cardNumber": "Card Number",
      "name": "Name",
      "nameOptional": "Name (optional)",
      "expiryDate": "Expiry Date",
      "cvv": "CVV",
      "address": "Address",
      "city": "City",
      "state": "State",
      "postalCode": "Postal Code",
      "mobileBanking": "Mobile Banking",
      "installments": "Installments",
      "unsupportedPaymentMethod": "Unsupported Payment Method",
      "card": "Credit/Debit Card",
      "promptpay": "PromptPay",
      "mobileBankingBay": "Krungsri (KMA)",
      "mobileBankingBbl": "Bangkok Bank",
      "mobileBankingKbank": "KBank (K PLUS)",
      "mobileBankingKtb": "Krungthai NEXT",
      "mobileBankingOcbc": "OCBC Digital",
      "mobileBankingScb": "SCB (SCB Easy)",
      "installmentBbl": "Bangkok Bank",
      "installmentWlbBbl": "Bangkok Bank",
      "installmentMbb": "Maybank",
      "installmentWlbMbb": "Maybank",
      "installmentKbank": "Kasikorn",
      "installmentWlbKbank": "Kasikorn",
      "installmentBay": "Krungsri",
      "installmentWlbBay": "Krungsri",
      "installmentFirstChoice": "Krungsri First Choice",
      "installmentWlbFirstChoice": "Krungsri First Choice",
      "installmentKtc": "KTC",
      "installmentWlbKtc": "KTC",
      "installmentScb": "Siam Commercial Bank",
      "installmentWlbScb": "Siam Commercial Bank",
      "installmentTtb": "TMBThanachart Bank",
      "installmentWlbTtb": "TMBThanachart Bank",
      "installmentUob": "United Overseas Bank",
      "installmentWlbUob": "United Overseas Bank",
      "alipay": "Alipay Online",
      "alipayCn": "Alipay",
      "alipayHk": "AlipayHK",
      "paynow": "PayNow",
      "dana": "DANA",
      "gcash": "GCash",
      "kakaopay": "Kakao Pay",
      "touchNGo": "Touch 'n Go",
      "rabbitLinepay": "Rabbit LINE Pay",
      "boost": "Boost",
      "shopeePay": "ShopeePay",
      "shopeePayJumpapp": "ShopeePay",
      "duitnowQr": "DuitNow QR",
      "mayBankQr": "Maybank QRPay",
      "grabpay": "Grab",
      "paypay": "PayPay",
      "wechatPay": "WeChat Pay",
      "truemoney": "TrueMoney",
      "truemoneyJumpapp": "TrueMoney",
      "fpx": "FPX",
      "duitnowObw": "DuitNow Online Banking/Wallets",
      "googlePay": "Google Pay",
      "atome": "Atome",
      "fpxInfoText":
          "(Optional) Please input your email to receive transaction confirmation from FPX",
      "trueMoneyWalletInfoText":
          "Please input the mobile number connected to your TrueMoney Wallet account",
      "atomeInfoText":
          "Please input below information to complete the charge creation with Atome",
      "phone": "Phone",
      "invalidPhoneNumber": "Phone number is invalid",
      "next": "Next",
      "grabpayFooter": "(GrabPay and PayLater)",
      "alipayPartnerFooter": "(Alipay+™ Partner)",
      "installmentsAmountLowerThanMonthlyLimit":
          "Amount is lower than the monthly minimum payment amount",
      "months": "months",
      "secureCheckout": "Secure Checkout",
      "selectPaymentMethod": "Select a payment method",
      "noPaymentMethods": "No payment methods available to display",
      "nameOnCard": "Name on card",
      "hintExpiry": "MM/YY",
      "securityCode": "Security code",
      "countryRegion": "Country or region",
      "pay": "Pay",
      "email": "Email",
      "emailOptional": "Email (optional)",
      "cardNumberRequired": "Card number is required",
      "invalidCardNumber": "Invalid card number",
      "isRequired": "is required",
      "expiryDateRequired": "Expiry date is required",
      "expiryFormat": "MM/YY format",
      "cvvRequired": "CVV is required",
      "onlyDigits": "Only digits are allowed",
      "cvvDigits": "CVV must be 3 or 4 digits",
      "invalidEmail": "Email is invalid",
      "shippingAddress": "Shipping address",
      "street": "Street",
      "countryCode": "Country Code",
      "billingAddressOptional": "Billing address (optional)",
      "sameBillingAndShipping": "My billing and shipping address are the same",
      "invalidCountryCode":
          "Address cannot be empty or country code is invalid",
    },
    OmiseLocale.th: {
      "cardNumber": "หมายเลขบัตร",
      "name": "ชื่อ",
      "nameOptional": "ชื่อ (ไม่จำเป็น)",
      "expiryDate": "วันหมดอายุ",
      "cvv": "รหัส CVV",
      "address": "ที่อยู่",
      "city": "เมือง",
      "state": "รัฐ/จังหวัด",
      "postalCode": "รหัสไปรษณีย์",
      "mobileBanking": "โมบายแบงก์กิ้ง",
      "installments": "ผ่อนชำระ",
      "unsupportedPaymentMethod": "วิธีการชำระเงินที่ไม่รองรับ",
      "card": "บัตรเครดิต/เดบิต",
      "promptpay": "พร้อมเพย์",
      "mobileBankingBay": "กรุงศรี (KMA)",
      "mobileBankingBbl": "ธนาคารกรุงเทพ",
      "mobileBankingKbank": "กสิกรไทย (K PLUS)",
      "mobileBankingKtb": "กรุงไทย (Krungthai NEXT)",
      "mobileBankingOcbc": "OCBC Digital",
      "mobileBankingScb": "ไทยพาณิชย์ (SCB Easy)",
      "installmentBbl": "ธนาคารกรุงเทพ",
      "installmentWlbBbl": "ธนาคารกรุงเทพ",
      "installmentMbb": "เมย์แบงก์",
      "installmentWlbMbb": "เมย์แบงก์",
      "installmentKbank": "ธนาคารกสิกรไทย",
      "installmentWlbKbank": "ธนาคารกสิกรไทย",
      "installmentBay": "ธนาคารกรุงศรี",
      "installmentWlbBay": "ธนาคารกรุงศรี",
      "installmentFirstChoice": "กรุงศรีเฟิร์สช้อยส์",
      "installmentWlbFirstChoice": "กรุงศรีเฟิร์สช้อยส์",
      "installmentKtc": "เคทีซี",
      "installmentWlbKtc": "เคทีซี",
      "installmentScb": "ธนาคารไทยพาณิชย์",
      "installmentWlbScb": "ธนาคารไทยพาณิชย์",
      "installmentTtb": "ธนาคารทีเอ็มบีธนชาต",
      "installmentWlbTtb": "ธนาคารทีเอ็มบีธนชาต",
      "installmentUob": "ธนาคารยูโอบี",
      "installmentWlbUob": "ธนาคารยูโอบี",
      "alipay": "อาลีเพย์ (ออนไลน์)",
      "alipayCn": "อาลีเพย์",
      "alipayHk": "อาลีเพย์ฮ่องกง",
      "paynow": "เพย์นาว",
      "dana": "ดานา",
      "gcash": "จีแคช",
      "kakaopay": "กาเกาเพย์",
      "touchNGo": "ทัชแอนด์โก",
      "rabbitLinepay": "Rabbit LINE Pay",
      "boost": "Boost",
      "shopeePay": "ShopeePay",
      "shopeePayJumpapp": "ShopeePay",
      "duitnowQr": "DuitNow QR",
      "mayBankQr": "Maybank QRPay",
      "grabpay": "Grab",
      "paypay": "PayPay",
      "wechatPay": "WeChat Pay",
      "truemoney": "ทรูมันนี่",
      "truemoneyJumpapp": "ทรูมันนี่",
      "fpx": "FPX",
      "duitnowObw": "DuitNow Online Banking/Wallets",
      "googlePay": "Google Pay",
      "atome": "Atome",
      "fpxInfoText":
          "กรุณากรอกอีเมลเพื่อรับการยืนยันการรับชำระจากเอฟพีเอ็กซ์ (ถ้ามี)",
      "trueMoneyWalletInfoText":
          "กรุณากรอกหมายเลขโทรศัพท์ที่ผูกกับบัญชีทรูมันนี่วอลเล็ท",
      "atomeInfoText": "กรุณากรอกข้อมูลที่จำเป็นเพื่อยืนยันการรับชำระจาก Atome",
      "phone": "โทร.",
      "invalidPhoneNumber": "หมายเลขโทรศัพท์ไม่ถูกต้อง",
      "next": "ถัดไป",
      "grabpayFooter": "(GrabPay and PayLater)",
      "alipayPartnerFooter": "(อาลีเพย์พลัส)",
      "installmentsAmountLowerThanMonthlyLimit":
          "ยอดชำระต่อเดือนต่ำกว่าจำนวนขั้นต่ำที่ธนาคารกำหนด",
      "months": "เดือน",
      "secureCheckout": "ชำระเงินอย่างปลอดภัย",
      "selectPaymentMethod": "เลือกวิธีการชำระเงิน",
      "noPaymentMethods": "ยังไม่มีวิธีการชำระเงิน",
      "nameOnCard": "ชื่อบนบัตร",
      "hintExpiry": "เดือน/ปี (MM/YY)",
      "securityCode": "รหัสความปลอดภัย",
      "countryRegion": "ประเทศหรือภูมิภาค",
      "pay": "ชำระเงิน",
      "email": "อีเมล์",
      "emailOptional": "อีเมล (ไม่จำเป็น)",
      "cardNumberRequired": "จำเป็นต้องกรอกหมายเลขบัตร",
      "invalidCardNumber": "หมายเลขบัตรไม่ถูกต้อง",
      "isRequired": "จำเป็นต้องกรอก",
      "expiryDateRequired": "จำเป็นต้องกรอกวันหมดอายุ",
      "expiryFormat": "รูปแบบเดือน/ปี (MM/YY)",
      "cvvRequired": "จำเป็นต้องกรอกรหัส CVV",
      "onlyDigits": "สามารถกรอกได้เฉพาะตัวเลขเท่านั้น",
      "cvvDigits": "รหัส CVV ต้องมี 3 หรือ 4 หลัก",
      "invalidEmail": "อีเมล์ไม่ถูกต้อง",
      "shippingAddress": "ที่อยู่ในการจัดส่ง",
      "street": "ที่อยู่",
      "countryCode": "รหัสประเทศ",
      "billingAddressOptional": "Billing address (optional)",
      "sameBillingAndShipping":
          "ใช้ที่อยู่เดียวกันสำหรับจัดส่งสินค้าและใบแจ้งหนี้",
      "invalidCountryCode": "กรุณากรอกข้อมูลที่อยู่ให้ถูกต้อง",
    },
    OmiseLocale.ja: {
      "cardNumber": "カード番号",
      "name": "氏名",
      "nameOptional": "Name (optional)",
      "expiryDate": "有効期限",
      "cvv": "CVV",
      "address": "住所",
      "city": "市区町村",
      "state": "都道府県",
      "postalCode": "郵便番号",
      "mobileBanking": "モバイルバンキング",
      "installments": "分割払い",
      "unsupportedPaymentMethod": "未対応の決済方法",
      "card": "クレジットカード／デビットカード",
      "promptpay": "PromptPay",
      "mobileBankingBay": "クルンシィ (KMA)",
      "mobileBankingBbl": "バンコック銀行",
      "mobileBankingKbank": "KBANK (K PLUS)",
      "mobileBankingKtb": "Krungthai NEXT",
      "mobileBankingOcbc": "OCBC Digital",
      "mobileBankingScb": "SCB (SCB Easy)",
      "installmentBbl": "バンコク銀行",
      "installmentWlbBbl": "バンコク銀行",
      "installmentMbb": "メイバンク",
      "installmentWlbMbb": "メイバンク",
      "installmentKbank": "カシコン",
      "installmentWlbKbank": "カシコン",
      "installmentBay": ">クルンシィ<",
      "installmentWlbBay": ">クルンシィ<",
      "installmentFirstChoice": "クルンシィ・ファーストチョイス",
      "installmentWlbFirstChoice": "クルンシィ・ファーストチョイス",
      "installmentKtc": "クルンタイカード",
      "installmentWlbKtc": "クルンタイカード",
      "installmentScb": "サイアム・コマーシャル銀行",
      "installmentWlbScb": "サイアム・コマーシャル銀行",
      "installmentTtb": "TMBタナチャート銀行",
      "installmentWlbTtb": "TMBタナチャート銀行",
      "installmentUob": "ユナイテッド・オーバーシーズ銀行",
      "installmentWlbUob": "ユナイテッド・オーバーシーズ銀行",
      "alipay": ">アリペイオンライン",
      "alipayCn": "アリペイ",
      "alipayHk": "アリペイ香港",
      "paynow": "PayNow",
      "dana": "ダナ",
      "gcash": "ジーキャッシュ",
      "kakaopay": "カカオペイ",
      "touchNGo": "タッチンゴー",
      "rabbitLinepay": "Rabbit LINE Pay",
      "boost": "Boost",
      "shopeePay": "ShopeePay",
      "shopeePayJumpapp": "ShopeePay",
      "duitnowQr": "DuitNow QR",
      "mayBankQr": "Maybank QRPay",
      "grabpay": "Grab",
      "paypay": "PayPay",
      "wechatPay": "WeChat Pay",
      "truemoney": "TrueMoney",
      "truemoneyJumpapp": "TrueMoney",
      "fpx": "FPX",
      "duitnowObw": "DuitNow Online Banking/Wallets",
      "googlePay": "Google Pay",
      "atome": "Atome",
      "fpxInfoText": "(任意) メールアドレスを入力し、FPXからの取引確認メールを受信します",
      "trueMoneyWalletInfoText": "TrueMoney ウォレットアカウントに登録されている携帯電話番号を入力してください",
      "atomeInfoText":
          "Please input below information to complete the charge creation with Atome",
      "phone": "電話",
      "invalidPhoneNumber": "電話番号が無効です",
      "next": "次",
      "grabpayFooter": "(GrabPay and PayLater)",
      "alipayPartnerFooter": "(アリペイプラス)",
      "installmentsAmountLowerThanMonthlyLimit": "月々のお支払いが銀行の最低金額以下",
      "secureCheckout": "セキュアチェックアウト",
      "months": "ヶ月",
      "selectPaymentMethod": "決済方法を選択する",
      "noPaymentMethods": "表示可能な決済方法がありません",
      "nameOnCard": "カードの名義人の氏名",
      "hintExpiry": "月/年",
      "securityCode": "セキュリティコード",
      "countryRegion": "国または地域",
      "pay": "支払う",
      "email": "メール",
      "emailOptional": "Email (optional)",
      "cardNumberRequired": "カード番号は必須です",
      "invalidCardNumber": "無効なカード番号です",
      "isRequired": "は必須です",
      "expiryDateRequired": "有効期限は必須です",
      "expiryFormat": "月/年 形式です",
      "cvvRequired": "CVVは必須です",
      "onlyDigits": "数字のみをご入力ください",
      "cvvDigits": "CVVは3桁または4桁の数字です",
      "invalidEmail": "メールが無効です",
      "shippingAddress": "Shipping address",
      "street": "Street",
      "countryCode": "Country Code",
      "billingAddressOptional": "Billing address (optional)",
      "sameBillingAndShipping": "My billing and shipping address are the same",
      "invalidCountryCode":
          "Address cannot be empty or country code is invalid",
    },
  };
  static OmiseLocale detectLocale(OmiseLocale? locale, BuildContext context) {
    final currentLocale = testLocale ?? Localizations.localeOf(context);
    return locale ?? OmiseLocaleFromLocaleExtension.fromString(currentLocale);
  }

  static String get(String key, OmiseLocale? locale, BuildContext context) {
    return translations[detectLocale(locale, context)]?[key] ?? 'N/A';
  }
}
