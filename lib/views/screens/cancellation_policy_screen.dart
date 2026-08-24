import 'package:flutter/material.dart';

import '../widgets/legal_document_scaffold.dart';

class CancellationPolicyScreen extends StatelessWidget {
  const CancellationPolicyScreen({super.key});

  static const _intro = <LegalBlock>[
    LegalParagraph(
      'This Cancellation Policy applies to orders placed through the **Veggiicart** website and mobile application.',
    ),
  ];

  static const _closing = <LegalBlock>[
    LegalParagraph(
      'Veggiicart reserves the right to update this Cancellation Policy from time to time. Any revised policy will be published on the website or mobile application.',
    ),
  ];

  static const _sections = <LegalSection>[
    LegalSection(
      title: '1. Customer Order Cancellation',
      blocks: [
        LegalParagraph(
          'Customers may request cancellation of an order **before the order has been processed, procured, packed, or dispatched**.',
        ),
        LegalParagraph(
          'Once the order has entered processing or dispatch, cancellation may not be possible.',
        ),
      ],
    ),
    LegalSection(
      title: '2. How to Request Cancellation',
      blocks: [
        LegalParagraph(
          'To request cancellation, customers may contact Veggiicart through:',
        ),
        LegalParagraph(
          '**Email:** Veggiicart@gmail.com\n**Phone:** 8099999086',
        ),
        LegalParagraph('The customer should provide:'),
        LegalBullets([
          'Order ID',
          'Registered mobile number',
          'Customer or business name',
          'Reason for cancellation',
        ]),
      ],
    ),
    LegalSection(
      title: '3. Cancellation of Bulk Orders',
      blocks: [
        LegalParagraph(
          'Veggiicart primarily deals with bulk orders.',
        ),
        LegalParagraph(
          'For large-volume, special, or specifically procured orders, cancellation may not be accepted once procurement has started.',
        ),
        LegalParagraph(
          'If Veggiicart has already incurred procurement, transportation, loading, packing, or handling costs, such charges may be deducted from any refundable amount, where applicable.',
        ),
      ],
    ),
    LegalSection(
      title: '4. Cancellation After Dispatch',
      blocks: [
        LegalParagraph(
          'Once an order has been dispatched for delivery, the customer may not be eligible to cancel the order.',
        ),
        LegalParagraph(
          'If the customer refuses a dispatched order without a valid reason, Veggiicart may:',
        ),
        LegalBullets([
          'Recover transportation charges',
          'Recover handling or procurement costs',
          'Restrict Cash on Delivery facility',
          'Suspend the account in case of repeated order refusals',
        ]),
      ],
    ),
    LegalSection(
      title: '5. Cancellation by Veggiicart',
      blocks: [
        LegalParagraph(
          'Veggiicart reserves the right to cancel an order due to reasons including:',
        ),
        LegalBullets([
          'Product unavailability',
          'Quality concerns',
          'Incorrect pricing',
          'Incorrect customer details',
          'Delivery location not being serviceable',
          'Verification issues',
          'Suspected fraudulent activity',
          'Operational or logistical difficulties',
          'Government restrictions',
          'Force majeure circumstances',
          'Other reasons beyond Veggiicart\'s reasonable control',
        ]),
        LegalParagraph(
          'Where possible, the customer will be informed about the cancellation.',
        ),
      ],
    ),
    LegalSection(
      title: '6. Cash on Delivery Orders',
      blocks: [
        LegalParagraph(
          'For Cash on Delivery orders, no refund will be required if the order is successfully cancelled before payment is collected.',
        ),
        LegalParagraph(
          'If any advance amount has been collected for a bulk or special order, refund eligibility will depend on the status of procurement and processing.',
        ),
      ],
    ),
    LegalSection(
      title: '7. Refund on Cancelled Orders',
      blocks: [
        LegalParagraph(
          'If an eligible prepaid or advance-paid order is cancelled, the approved refund may be processed through:',
        ),
        LegalBullets([
          'Original payment method',
          'Bank transfer',
          'Customer credit',
          'Adjustment against a future order',
          'Any other mutually agreed method',
        ]),
        LegalParagraph(
          'Applicable procurement, handling, transportation, or payment processing charges may be deducted where the cancellation occurs after such costs have already been incurred.',
        ),
      ],
    ),
    LegalSection(
      title: '8. Modification Instead of Cancellation',
      blocks: [
        LegalParagraph(
          'Where possible, customers may request changes to:',
        ),
        LegalBullets([
          'Product quantity',
          'Delivery address',
          'Delivery date',
          'Selected products',
        ]),
        LegalParagraph(
          'Such modifications are subject to availability and order processing status.',
        ),
      ],
    ),
    LegalSection(
      title: '9. Repeated Cancellations',
      blocks: [
        LegalParagraph(
          'Veggiicart reserves the right to restrict or suspend accounts that repeatedly:',
        ),
        LegalBullets([
          'Place and cancel orders',
          'Refuse confirmed deliveries',
          'Provide incorrect addresses',
          'Misuse Cash on Delivery services',
        ]),
      ],
    ),
    LegalSection(
      title: '10. Contact Us',
      blocks: [
        LegalParagraph(
          'For cancellation requests or related assistance, contact:',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScaffold(
      title: 'Cancellation Policy',
      lastUpdated: 'August 2026',
      intro: _intro,
      sections: _sections,
      closing: _closing,
    );
  }
}
