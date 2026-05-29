class PriceUtils {
  static const Map<String, String> _digitToChar = {
    '1': 'L',
    '2': 'A',
    '3': 'H',
    '4': 'O',
    '5': 'R',
    '6': 'C',
    '7': 'I',
    '8': 'T',
    '9': 'Y',
    '0': 'B',
  };

  static const Map<String, String> _charToDigit = {
    'L': '1',
    'A': '2',
    'H': '3',
    'O': '4',
    'R': '5',
    'C': '6',
    'I': '7',
    'T': '8',
    'Y': '9',
    'B': '0',
  };

  /// Encodes a numeric cost price into an alphabet-based string.
  /// Example: 1250 -> LARB, 1.5 -> L.R
  static String encode(double price) {
    // Convert to string and handle potential .0 for integers
    String priceStr = price.toString();
    if (priceStr.endsWith('.0')) {
      priceStr = price.toInt().toString();
    }

    StringBuffer encoded = StringBuffer();

    for (int i = 0; i < priceStr.length; i++) {
      String char = priceStr[i];
      if (char == '.') {
        encoded.write('.');
      } else {
        encoded.write(_digitToChar[char] ?? char);
      }
    }

    return encoded.toString();
  }

  /// Decodes an alphabet-based string back into a numeric cost price.
  /// Example: LARB -> 1250, L.R -> 1.5
  static double decode(String encoded) {
    StringBuffer decoded = StringBuffer();

    for (int i = 0; i < encoded.length; i++) {
      String char = encoded[i].toUpperCase();
      if (char == '.') {
        decoded.write('.');
      } else {
        decoded.write(_charToDigit[char] ?? '');
      }
    }

    return double.tryParse(decoded.toString()) ?? 0.0;
  }

  /// Calculates the selling price based on cost price and markup.
  static double calculateSellingPrice(double costPrice, double markup) {
    return costPrice * markup;
  }
}
