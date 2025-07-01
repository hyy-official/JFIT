import 'package:flutter/services.dart';

/// TextInputFormatter that allows only numbers with up to [decimalRange] decimal
/// places. If [decimalRange] is 0, it behaves like an integer-only formatter.
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange = 1})
      : assert(decimalRange >= 0, 'Decimal range must be non-negative');

  /// Maximum number of digits allowed after the decimal point.
  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Always allow empty string (so the user can clear the field).
    if (text.isEmpty) {
      return newValue;
    }

    // Build regex dynamically based on [decimalRange].
    final String decimalPattern = decimalRange > 0
        ? r'(\.\d{0,' + decimalRange.toString() + r'})?'
        : '';

    final regex = RegExp(r'^\d*' + decimalPattern + r'\$');

    if (regex.hasMatch(text)) {
      return newValue;
    }
    // If the new input doesn't match the pattern, keep the old value.
    return oldValue;
  }
} 