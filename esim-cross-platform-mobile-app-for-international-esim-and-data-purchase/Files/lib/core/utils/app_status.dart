// ignore_for_file: constant_identifier_names

class AppStatus {
  static const String ENABLE = '1';
  static const String DISABLE = "0";

  static const String YES = "1";
  static const String NO = "0";

  static const String VERIFIED = "1";
  static const String UNVERIFIED = "0";

  static const String PAYMENT_INITIATE = "0";
  static const String PAYMENT_SUCCESS = "1";
  static const String PAYMENT_PENDING = "2";
  static const String PAYMENT_REJECT = "3";

  static const String TICKET_OPEN = "0";
  static const String TICKET_ANSWER = "1";
  static const String TICKET_REPLY = "2";
  static const String TICKET_CLOSE = "3";

  static const String PRIORITY_LOW = "1";
  static const String PRIORITY_MEDIUM = "2";
  static const String PRIORITY_HIGH = "3";

  static const String USER_ACTIVE = "1";
  static const String USER_BAN = "0";

  static const String KYC_UNVERIFIED = "0";
  static const String KYC_PENDING = "2";
  static const String KYC_VERIFIED = "1";

  static const String GOOGLE_PAY = "5001";

  static const String CUR_BOTH = "1";
  static const String CUR_TEXT = "2";
  static const String CUR_SYM = "3";

  static const String CRYPTO_CURRENCY = "1";
  static const String FIAT_CURRENCY = "2";

  static const String BUY_SIDE_ORDER = "1";
  static const String SELL_SIDE_ORDER = "2";

  static const String BUY_SIDE_TRADE = "1";
  static const String SELL_SIDE_TRADE = "2";

  static const String ORDER_TYPE_LIMIT = "1";
  static const String ORDER_TYPE_MARKET = "2";
  static const String ORDER_TYPE_STOP_LIMIT = "3";

  static const String ORDER_OPEN = "0";
  static const String ORDER_COMPLETED = "1";
  static const String ORDER_PENDING = "2";
  static const String ORDER_CANCELED = "9";

  static const String WALLET_TYPE_SPOT = "1";
  static const String WALLET_TYPE_FUNDING = "2";

  static const String P2P_AD_PENDING = "0";
  static const String P2P_AD_COMPLETED = "1";
  static const String P2P_AD_REJECT = "9";

  static const String P2P_AD_PRICE_TYPE_FIXED = "1";
  static const String P2P_AD_PRICE_TYPE_MARGIN = "2";

  static const String P2P_AD_TYPE_BUY = "1";
  static const String P2P_AD_TYPE_SELL = "2";

  static const String P2P_TRADE_SIDE_BUY = "1";
  static const String P2P_TRADE_SIDE_SELL = "2";

  static const String P2P_TRADE_PENDING = "0";
  static const String P2P_TRADE_COMPLETED = "1";
  static const String P2P_TRADE_PAID = "2";
  static const String P2P_TRADE_REPORTED = "4";
  static const String P2P_TRADE_CANCELED = "9";

  static const String P2P_TRADE_FEEDBACK_POSITIVE = "1";
  static const String P2P_TRADE_FEEDBACK_NEGATIVE = "0";

  static const String BINARY_TRADE_PENDING = "0";
  static const String BINARY_TRADE_WIN = "1";
  static const String BINARY_TRADE_LOSE = "2";
  static const String BINARY_TRADE_REFUND = "3";

  static const String SPOT_TRADE = "1";
  static const String BINARY_TRADE = "2";
  static const String BOTH_TRADE = "3";
}
