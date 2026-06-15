import 'package:flutter/material.dart';
import 'package:liquid/home/payment_data.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomePaymentsCard extends StatelessWidget {
  const HomePaymentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LdCard(
      child: LdAutoSpace(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LdText.h('Payments', lineHeight: 1),
                  LdMute(child: LdText.ls('Manage your payments')),
                ],
              ),
              Spacer(),
              LdButton(trailing: Icon(LucideIcons.arrowDown), onPressed: () {}, child: Text('Export')),
            ],
          ),
          LdTable<HomePayment>(
            columns: [
              LdCol(title: 'Status'),
              LdCol(title: 'Date', weight: 2),
              LdCol(title: 'Amount', weight: 2),
            ],
            rowCount: homePayments.length,
            rows: homePayments,
            buildRow: (row) {
              return [
                Align(
                  alignment: Alignment.centerLeft,
                  child: switch (row.status) {
                    PaymentStatus.paid => LdTag(child: Text('Paid')),
                    PaymentStatus.due => LdTag.error(child: Text('Due')),
                    PaymentStatus.sent => LdTag.success(child: Text('Sent')),
                  },
                ),
                Text(row.reference),
                Text(row.amount.toString()),
              ];
            },
          ),
        ],
      ),
    );
  }
}
