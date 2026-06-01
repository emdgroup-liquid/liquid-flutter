enum PaymentStatus { paid, due, sent }

class HomePayment {
  const HomePayment(this.reference, this.amount, this.status);

  final String reference;
  final double amount;
  final PaymentStatus status;
}

const homePayments = [
  HomePayment('REF-1390', 100, PaymentStatus.paid),
  HomePayment('REF-1230', 200, PaymentStatus.due),
  HomePayment('REF-1231', 300, PaymentStatus.sent),
  HomePayment('REF-1232', 400, PaymentStatus.paid),
  HomePayment('REF-1233', 500, PaymentStatus.due),
  HomePayment('REF-1234', 600, PaymentStatus.sent),
  HomePayment('REF-1235', 700, PaymentStatus.paid),
  HomePayment('REF-1236', 800, PaymentStatus.due),
  HomePayment('REF-1237', 900, PaymentStatus.sent),
];
