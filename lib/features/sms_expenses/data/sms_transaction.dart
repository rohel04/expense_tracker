enum SmsTransactionType { debit, credit }

enum SmsTransactionStatus { pending, imported, ignored }

class SmsTransaction {
  final String id;
  final SmsTransactionType type;
  final double amount;
  final String date;
  final String merchant;
  final String? account;
  final String bank;
  final SmsTransactionStatus status;

  const SmsTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.merchant,
    required this.bank,
    this.account,
    this.status = SmsTransactionStatus.pending,
  });

  SmsTransaction withStatus(SmsTransactionStatus status) => SmsTransaction(
        id: id,
        type: type,
        amount: amount,
        date: date,
        merchant: merchant,
        bank: bank,
        account: account,
        status: status,
      );
}
