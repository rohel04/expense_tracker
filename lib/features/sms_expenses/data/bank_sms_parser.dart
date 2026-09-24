import 'package:expense_tracker/features/sms_expenses/data/sms_transaction.dart';
import 'package:intl/intl.dart';

/// Parses bank debit/credit SMS such as:
/// "Dear Customer, Your A/C XX1234 has been debited with NPR 1,250.00 on
/// 24-Sep-2026 at XYZ Store."
///
/// Matching is keyword based rather than one regex per bank, so most
/// "debited/credited ... NPR <amount>" formats work. Add bank-specific
/// wording to the keyword patterns below.
class BankSmsParser {
  static final _debit =
      RegExp(r'\b(debited|withdrawn)\b', caseSensitive: false);
  static final _credit =
      RegExp(r'\b(credited|deposited)\b', caseSensitive: false);

  /// Messages that mention a transaction but did not move money.
  static final _ignore = RegExp(
    r'\b(will be|to be|failed|declined|unsuccessful|reversed|otp|one time password)\b',
    caseSensitive: false,
  );

  static final _balance = RegExp(
    r'\b(av|avl|avail|available|ledger|closing)\.?\s*bal[a-z]*\.?\s*:?\s*(?:is\s*)?(?:NPR|Rs)?\.?\s*[\d,]+(?:\.\d+)?',
    caseSensitive: false,
  );
  static final _amount = RegExp(
    r'(?:NPR|Rs)\.?\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );
  // 24-Sep-2026
  static final _namedMonthDate = RegExp(r'\b(\d{1,2})-([A-Za-z]{3})-(\d{4})\b');
  // 2026-09-23 (Citizens)
  static final _isoDate = RegExp(r'\b(\d{4})-(\d{2})-(\d{2})\b');
  // 07/09/2026, day first (NMB)
  static final _slashDate = RegExp(r'\b(\d{1,2})/(\d{1,2})/(\d{4})\b');

  // "A/C XX1234", "A/C 0#11", or a bare masked number like "###9041".
  static final _account = RegExp(
    r'\bA/?C\.?\s*(?:no\.?\s*)?([X*#\d]+)|([X*#]{2,}\d{3,})',
    caseSensitive: false,
  );

  // Where the money went: "at XYZ Store.", "Remarks: ... . Support",
  // or "(CPS-SALARY OF APRIL)".
  static final _merchantAt = RegExp(r'\bat\s+([^.]+)', caseSensitive: false);
  static final _remarks =
      RegExp(r'\bRemarks:\s*(.+?)(?:\.\s*Support\b|$)', caseSensitive: false);
  static final _parenthesised = RegExp(r'\(([^)]+)\)');

  static final _storageFormat = DateFormat('yyyy-MM-dd');
  static final _smsDateFormat = DateFormat('dd-MMM-yyyy', 'en_US');

  /// Returns null unless [body] is a completed debit/credit message that
  /// names both an account number and an amount.
  /// [receivedAt] is used as the date when the SMS text has none.
  static SmsTransaction? parse({
    required String id,
    required String address,
    required String body,
    required DateTime receivedAt,
  }) {
    // Balance figures would be mistaken for the amount or merchant.
    final text =
        body.replaceAll(_balance, '').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (_ignore.hasMatch(text)) return null;

    final debit = _debit.firstMatch(text);
    final credit = _credit.firstMatch(text);
    if (debit == null && credit == null) return null;
    final type = credit == null || (debit != null && debit.start < credit.start)
        ? SmsTransactionType.debit
        : SmsTransactionType.credit;

    final amountMatch = _amount.firstMatch(text);
    if (amountMatch == null) return null;
    final amount = double.tryParse(amountMatch[1]!.replaceAll(',', ''));
    if (amount == null || amount <= 0) return null;

    final accountMatch = _account.firstMatch(text);
    final account = accountMatch?[1] ?? accountMatch?[2];
    if (account == null) return null;

    return SmsTransaction(
      id: id,
      type: type,
      amount: amount,
      date: _storageFormat.format(_parseDate(text) ?? receivedAt),
      merchant: _parseMerchant(text) ??
          (type == SmsTransactionType.debit ? 'Bank debit' : 'Bank credit'),
      account: account,
      bank: bankName(address),
    );
  }

  static const _knownSenders = {
    'CTZNS': 'Citizens Bank',
    'CTZN': 'Citizens Bank',
    'NMB': 'NMB Bank',
  };

  /// Bank name from the SMS sender id, e.g. "CTZNS_Alert" -> "Citizens Bank".
  /// Unknown senders keep their id without the "_Alert" suffix; add them to
  /// [_knownSenders] for a nicer name.
  static String bankName(String address) {
    final sender = address
        .replaceFirst(RegExp(r'[_\-\s]*alert$', caseSensitive: false), '')
        .trim();
    return _knownSenders[sender.toUpperCase()] ??
        (sender.isEmpty ? address : sender);
  }

  static String? _parseMerchant(String text) {
    final at = _merchantAt.firstMatch(text)?[1]?.trim();
    if (at != null && at.isNotEmpty) return at;

    final remarks = _remarks.firstMatch(text)?[1]?.trim();
    if (remarks != null && remarks.isNotEmpty) return _describeRemarks(remarks);

    return _parenthesised.firstMatch(text)?[1]?.trim();
  }

  /// Turns bank remark codes such as "POS/459521x9831/60106574/158367/DARAZ"
  /// or "MB/9860939360/ESEWA,124077721" into a short readable title.
  static String _describeRemarks(String remarks) {
    final code = remarks.split('/').first.toUpperCase();
    switch (code) {
      case 'ATM':
        return 'ATM withdrawal';
      case 'POS':
        return 'Card payment - ${remarks.split('/').last.trim()}';
      case 'MB':
        return remarks.toUpperCase().contains('ESEWA')
            ? 'Mobile banking - eSewa'
            : 'Mobile banking';
    }
    return remarks.length > 40 ? '${remarks.substring(0, 40)}...' : remarks;
  }

  static DateTime? _parseDate(String text) {
    final named = _namedMonthDate.firstMatch(text);
    if (named != null) {
      // intl expects "Sep", banks often send "SEP".
      final month =
          named[2]![0].toUpperCase() + named[2]!.substring(1).toLowerCase();
      try {
        return _smsDateFormat
            .parseStrict('${named[1]!.padLeft(2, '0')}-$month-${named[3]}');
      } on FormatException {
        return null;
      }
    }

    final iso = _isoDate.firstMatch(text);
    if (iso != null) {
      return _validDate(
          int.parse(iso[1]!), int.parse(iso[2]!), int.parse(iso[3]!));
    }

    final slash = _slashDate.firstMatch(text);
    if (slash != null) {
      return _validDate(
          int.parse(slash[3]!), int.parse(slash[2]!), int.parse(slash[1]!));
    }
    return null;
  }

  /// DateTime silently rolls 31/02 over to March, so reject such dates.
  static DateTime? _validDate(int year, int month, int day) {
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day
        ? date
        : null;
  }
}
