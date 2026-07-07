import 'package:intl/intl.dart';

final NumberFormat currencyIdr = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0, // IDR typically does not display decimal cents
);
