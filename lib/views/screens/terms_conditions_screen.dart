import 'package:flutter/material.dart';

import '../widgets/legal_document_scaffold.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const _intro = <LegalBlock>[
    LegalParagraph(
      'Welcome to **Veggiicart**. These Terms & Conditions govern your use of the Veggiicart website, mobile application, products, ordering services, and related features.',
    ),
    LegalParagraph(
      'By registering, browsing, placing an order, or using Veggiicart, you agree to these Terms & Conditions.',
    ),
  ];

  static const _closing = <LegalBlock>[
    LegalParagraph(
      'By registering, placing an order, or continuing to use Veggiicart, you confirm that you have read, understood, and agreed to these Terms & Conditions.',
    ),
  ];

  static const _sections = <LegalSection>[
    LegalSection(
      title: '1. About Veggiicart',
      blocks: [
        LegalParagraph(
          'Veggiicart is a **B2B bulk grocery and fresh produce ordering platform** designed for retailers, supermarkets, hotels, restaurants, caterers, hostels, institutions, resellers, and other commercial buyers.',
        ),
        LegalParagraph(
          'Products and delivery services are available only in locations and pincodes currently serviced by Veggiicart.',
        ),
      ],
    ),
    LegalSection(
      title: '2. User Eligibility',
      blocks: [
        LegalParagraph('To register and place orders on Veggiicart:'),
        LegalBullets([
          'The user must be at least 18 years of age.',
          'The user must be legally capable of entering into a contract.',
          'The account must be used for genuine business or commercial purposes.',
          'All information provided during registration must be true, accurate, and complete.',
        ]),
        LegalParagraph(
          'Veggiicart reserves the right to approve, reject, suspend, or deactivate any account if the information provided is incorrect, incomplete, unverifiable, misleading, or suspected to be fraudulent.',
        ),
      ],
    ),
    LegalSection(
      title: '3. Business Registration & Verification',
      blocks: [
        LegalParagraph(
          'Users may be required to provide business and identity details, including:',
        ),
        LegalBullets([
          'Business or Shop Name',
          'Business Type',
          'Owner or Authorized Person Name',
          'Mobile Number',
          'Email Address',
          'Business Address',
          'PAN',
          'Aadhaar or other valid identity proof',
          'GST Certificate, where applicable',
          'FSSAI Certificate, where applicable',
          'Shop Registration Certificate',
          'MSME/Udyam Registration',
          'Trade Licence',
          'Business or Shop Photograph',
          'Visiting Card',
          'Other supporting documents, where required',
        ]),
        LegalParagraph(
          'Some documents may be optional depending on the nature of the business.',
        ),
        LegalParagraph(
          'Submission of documents does not automatically guarantee approval of an account. Veggiicart may verify the details before approving registration or processing orders.',
        ),
      ],
    ),
    LegalSection(
      title: '4. Account Responsibility',
      blocks: [
        LegalParagraph(
          'Users are responsible for maintaining the confidentiality of their login credentials.',
        ),
        LegalParagraph(
          'Any activity performed through a registered account may be treated as activity performed by the account holder.',
        ),
        LegalParagraph(
          'Users should immediately inform Veggiicart if they suspect unauthorized access or misuse of their account.',
        ),
      ],
    ),
    LegalSection(
      title: '5. Product Information',
      blocks: [
        LegalParagraph(
          'Veggiicart makes reasonable efforts to display accurate information relating to:',
        ),
        LegalBullets([
          'Product name',
          'Category',
          'Brand',
          'Weight',
          'Quantity',
          'Price',
          'Description',
          'Images',
          'Availability',
        ]),
        LegalParagraph(
          'However, images are for representation purposes only. Actual product packaging, colour, size, batch, label, shape, or appearance may differ.',
        ),
        LegalParagraph(
          'For fresh fruits and vegetables, natural variations in colour, size, shape, texture, ripeness, and appearance are normal and shall not automatically be treated as defects.',
        ),
      ],
    ),
    LegalSection(
      title: '6. Product Availability',
      blocks: [
        LegalParagraph(
          'All products displayed on Veggiicart are subject to availability.',
        ),
        LegalParagraph(
          'If a product becomes unavailable after an order is placed, Veggiicart may:',
        ),
        LegalBullets([
          'Inform the customer,',
          'Suggest an alternative product,',
          'Modify the quantity with customer approval, or',
          'Cancel the unavailable item or order.',
        ]),
      ],
    ),
    LegalSection(
      title: '7. Pricing',
      blocks: [
        LegalParagraph('Product prices may change based on:'),
        LegalBullets([
          'Market conditions',
          'Seasonal fluctuations',
          'Supplier pricing',
          'Product availability',
          'Quantity',
          'Location',
          'Transportation costs',
          'Applicable taxes',
        ]),
        LegalParagraph(
          'The price applicable when the order is confirmed will normally be considered the final price, except in cases of obvious technical or pricing errors.',
        ),
        LegalParagraph(
          'Applicable GST, delivery charges, handling charges, or other charges, if any, will be displayed or communicated to the customer.',
        ),
      ],
    ),
    LegalSection(
      title: '8. Minimum Order Quantity',
      blocks: [
        LegalParagraph(
          'Veggiicart is primarily a bulk-ordering platform.',
        ),
        LegalParagraph(
          'The **minimum order quantity is generally 20 kg**, unless a different minimum quantity is displayed for a particular product, category, customer, or location.',
        ),
        LegalParagraph(
          'Veggiicart reserves the right to change minimum order requirements from time to time.',
        ),
      ],
    ),
    LegalSection(
      title: '9. Order Placement',
      blocks: [
        LegalParagraph(
          'Customers are responsible for reviewing all product, quantity, address, and order details before confirming an order.',
        ),
        LegalParagraph(
          'Placing an order does not automatically mean that the order has been accepted.',
        ),
        LegalParagraph(
          'An order will be considered accepted only after confirmation by Veggiicart.',
        ),
        LegalParagraph(
          'Veggiicart may contact the customer for verification or clarification before processing or dispatching an order.',
        ),
      ],
    ),
    LegalSection(
      title: '10. Order Cancellation by Veggiicart',
      blocks: [
        LegalParagraph(
          'Veggiicart reserves the right to cancel, reject, or partially fulfil an order due to:',
        ),
        LegalBullets([
          'Product unavailability',
          'Incorrect pricing',
          'Incorrect customer information',
          'Delivery location restrictions',
          'Verification issues',
          'Quantity limitations',
          'Suspected fraudulent activity',
          'Quality concerns',
          'Logistical difficulties',
          'Technical errors',
          'Circumstances beyond reasonable control',
        ]),
        LegalParagraph(
          'Where possible, the customer will be informed about the cancellation or modification.',
        ),
      ],
    ),
    LegalSection(
      title: '11. Payment',
      blocks: [
        LegalParagraph(
          'Veggiicart currently supports **Cash on Delivery (COD)** or such other payment options as may be made available on the platform.',
        ),
        LegalParagraph('For COD orders:'),
        LegalBullets([
          'Full payment must be made at the time of delivery.',
          'Customers must arrange payment before accepting the order.',
          'Veggiicart may restrict COD facilities for customers with repeated failed deliveries, refused orders, or payment-related issues.',
        ]),
        LegalParagraph(
          'For certain bulk or special orders, Veggiicart may request an advance payment before processing the order.',
        ),
      ],
    ),
    LegalSection(
      title: '12. Delivery',
      blocks: [
        LegalParagraph(
          'Delivery availability is determined by the customer\'s pincode and the serviceability of the delivery location.',
        ),
        LegalParagraph('Customers must provide:'),
        LegalBullets([
          'Correct delivery address',
          'Correct pincode',
          'Active mobile number',
          'Accurate delivery instructions',
        ]),
        LegalParagraph(
          'Estimated delivery times are indicative and may vary due to:',
        ),
        LegalBullets([
          'Traffic',
          'Weather',
          'Product availability',
          'Market conditions',
          'Vehicle issues',
          'Government restrictions',
          'Public holidays',
          'High order volumes',
          'Other circumstances beyond Veggiicart\'s reasonable control',
        ]),
        LegalParagraph(
          'Veggiicart does not guarantee delivery at an exact time unless specifically confirmed.',
        ),
      ],
    ),
    LegalSection(
      title: '13. Receiving and Checking the Order',
      blocks: [
        LegalParagraph(
          'The customer or an authorized representative should be available at the delivery location to receive the order.',
        ),
        LegalParagraph(
          'Customers are advised to inspect the order at the time of delivery and verify:',
        ),
        LegalBullets([
          'Quantity',
          'Packaging',
          'Product condition',
          'Missing items',
          'Incorrect items',
          'Visible damage',
        ]),
        LegalParagraph(
          'Any visible discrepancy should be reported immediately or within the applicable reporting period.',
        ),
        LegalParagraph(
          'Veggiicart may request photographs, videos, invoices, or other supporting evidence when reviewing a complaint.',
        ),
      ],
    ),
    LegalSection(
      title: '14. Fresh and Perishable Products',
      blocks: [
        LegalParagraph(
          'Fruits, vegetables, and other fresh products are naturally perishable.',
        ),
        LegalParagraph(
          'Customers should inspect such products immediately after delivery and store them under appropriate conditions.',
        ),
        LegalParagraph(
          'Veggiicart will not be responsible for deterioration caused by:',
        ),
        LegalBullets([
          'Improper storage',
          'Delayed use',
          'Mishandling after delivery',
          'Incorrect temperature',
          'Contamination after delivery',
          'Customer negligence',
        ]),
      ],
    ),
    LegalSection(
      title: '15. Returns & Replacements',
      blocks: [
        LegalParagraph(
          'A return or replacement request may be considered where:',
        ),
        LegalBullets([
          'The wrong product was delivered.',
          'The delivered quantity is materially different from the confirmed order.',
          'The product was visibly damaged during delivery.',
          'A fresh product was spoiled or unusable at the time of delivery.',
          'There was a genuine fulfilment error attributable to Veggiicart.',
        ]),
        LegalParagraph(
          'Customers must report the issue within the period specified in the applicable **Return & Refund Policy**.',
        ),
        LegalParagraph(
          'Veggiicart reserves the right to inspect and verify the complaint before approving a return, replacement, refund, or adjustment.',
        ),
      ],
    ),
    LegalSection(
      title: '16. Customer Order Cancellation',
      blocks: [
        LegalParagraph(
          'Customers may request cancellation before the order has been processed, procured, packed, or dispatched.',
        ),
        LegalParagraph(
          'Once an order has been packed, specially procured, or dispatched, cancellation may not be permitted.',
        ),
        LegalParagraph(
          'Special, customized, or large bulk orders may not be eligible for cancellation after confirmation.',
        ),
        LegalParagraph(
          'Veggiicart reserves the right to determine cancellation eligibility based on the status of the order.',
        ),
      ],
    ),
    LegalSection(
      title: '17. Refunds',
      blocks: [
        LegalParagraph(
          'Since many Veggiicart orders may be Cash on Delivery, refunds generally apply only where payment has already been collected.',
        ),
        LegalParagraph(
          'Where a refund is approved, it may be processed through:',
        ),
        LegalBullets([
          'Bank transfer',
          'Original payment method, where applicable',
          'Credit adjustment',
          'Adjustment against a future order',
          'Any other mutually agreed method',
        ]),
        LegalParagraph(
          'Refund processing times may vary depending on banks or third-party payment providers.',
        ),
      ],
    ),
    LegalSection(
      title: '18. Refusal of Delivery',
      blocks: [
        LegalParagraph(
          'If a customer refuses a confirmed order without a valid reason after dispatch, Veggiicart may recover applicable:',
        ),
        LegalBullets([
          'Transportation charges',
          'Handling charges',
          'Procurement costs',
          'Cancellation costs',
        ]),
        LegalParagraph(
          'Repeated refusal of orders may result in account suspension or restriction of Cash on Delivery facilities.',
        ),
      ],
    ),
    LegalSection(
      title: '19. Invoice',
      blocks: [
        LegalParagraph(
          'Veggiicart may provide invoices electronically or physically.',
        ),
        LegalParagraph(
          'Customers requiring GST invoices are responsible for providing accurate GST and business information.',
        ),
        LegalParagraph(
          'Veggiicart shall not be responsible for errors in invoices resulting from incorrect details supplied by the customer.',
        ),
      ],
    ),
    LegalSection(
      title: '20. User Conduct',
      blocks: [
        LegalParagraph('Users must not use Veggiicart for:'),
        LegalBullets([
          'Fraudulent transactions',
          'Illegal activities',
          'False registrations',
          'Submission of fake documents',
          'Unauthorized access to other accounts',
          'Attempting to interfere with the website, application, server, or database',
          'Uploading malicious software',
          'Manipulating prices, offers, or promotions',
          'Misusing Veggiicart content or services',
        ]),
        LegalParagraph(
          'Violation of these conditions may result in account suspension or termination.',
        ),
      ],
    ),
    LegalSection(
      title: '21. Intellectual Property',
      blocks: [
        LegalParagraph(
          'All Veggiicart-owned content, including its:',
        ),
        LegalBullets([
          'Brand name',
          'Logo',
          'Website design',
          'Application design',
          'Graphics',
          'Text',
          'Software',
          'Database structure',
          'Original images and content',
        ]),
        LegalParagraph(
          'may be protected under applicable intellectual property laws.',
        ),
        LegalParagraph(
          'Users may not copy, reproduce, modify, distribute, sell, or commercially exploit Veggiicart\'s intellectual property without prior written permission.',
        ),
      ],
    ),
    LegalSection(
      title: '22. Third-Party Brands',
      blocks: [
        LegalParagraph(
          'Product names, trademarks, logos, images, or descriptions belonging to manufacturers, suppliers, or other third parties remain the property of their respective owners.',
        ),
        LegalParagraph(
          'Veggiicart does not claim ownership of third-party trademarks.',
        ),
      ],
    ),
    LegalSection(
      title: '23. Limitation of Liability',
      blocks: [
        LegalParagraph(
          'To the maximum extent permitted by applicable law, Veggiicart shall not be responsible for indirect, incidental, special, or consequential losses arising from use of the platform or products.',
        ),
        LegalParagraph(
          'Veggiicart shall also not be responsible for loss or damage caused by:',
        ),
        LegalBullets([
          'Incorrect information provided by customers',
          'Improper storage after delivery',
          'Misuse of products',
          'Delays beyond Veggiicart\'s reasonable control',
          'Internet or network failures',
          'Unauthorized access caused by a user\'s failure to secure login credentials',
          'Natural variations in fresh produce',
        ]),
        LegalParagraph(
          'Nothing in these Terms shall exclude any liability that cannot legally be excluded under applicable law.',
        ),
      ],
    ),
    LegalSection(
      title: '24. Platform Availability',
      blocks: [
        LegalParagraph(
          'Veggiicart aims to maintain continuous availability of its website and application, but uninterrupted service cannot be guaranteed.',
        ),
        LegalParagraph(
          'Temporary interruption may occur due to:',
        ),
        LegalBullets([
          'Maintenance',
          'Software updates',
          'Server issues',
          'Network failures',
          'Security concerns',
          'Technical problems',
          'Events outside Veggiicart\'s reasonable control',
        ]),
      ],
    ),
    LegalSection(
      title: '25. Privacy',
      blocks: [
        LegalParagraph(
          'Personal and business information provided by customers will be handled in accordance with Veggiicart\'s **Privacy Policy**.',
        ),
        LegalParagraph(
          'By using the platform, customers agree to the collection and processing of their information in accordance with the applicable Privacy Policy.',
        ),
      ],
    ),
    LegalSection(
      title: '26. Communication',
      blocks: [
        LegalParagraph(
          'By registering with Veggiicart, customers agree to receive communications regarding:',
        ),
        LegalBullets([
          'Registration',
          'Account verification',
          'Orders',
          'Delivery',
          'Customer support',
          'Service updates',
          'Offers and promotions',
          'Business-related notifications',
        ]),
        LegalParagraph('Communication may take place through:'),
        LegalBullets([
          'Phone calls',
          'SMS',
          'WhatsApp',
          'Email',
          'Push notifications',
          'Other permitted communication channels',
        ]),
        LegalParagraph(
          'Customers may opt out of promotional communications where applicable.',
        ),
      ],
    ),
    LegalSection(
      title: '27. Account Suspension or Termination',
      blocks: [
        LegalParagraph(
          'Veggiicart may suspend, restrict, or terminate an account for:',
        ),
        LegalBullets([
          'Violation of these Terms',
          'Fraudulent activity',
          'Submission of false documents',
          'Misuse of the platform',
          'Repeated refusal of confirmed orders',
          'Non-payment of outstanding dues',
          'Security risks',
          'Illegal activities',
        ]),
        LegalParagraph(
          'Termination shall not affect any outstanding financial or legal obligations.',
        ),
      ],
    ),
    LegalSection(
      title: '28. Force Majeure',
      blocks: [
        LegalParagraph(
          'Veggiicart shall not be responsible for delays or failure to perform obligations caused by circumstances beyond its reasonable control, including:',
        ),
        LegalBullets([
          'Natural disasters',
          'Floods',
          'Fires',
          'Strikes',
          'Riots',
          'Pandemics',
          'Government restrictions',
          'Transportation disruptions',
          'Internet failures',
          'Other force majeure events',
        ]),
      ],
    ),
    LegalSection(
      title: '29. Changes to Terms & Conditions',
      blocks: [
        LegalParagraph(
          'Veggiicart reserves the right to update or modify these Terms & Conditions from time to time.',
        ),
        LegalParagraph(
          'Updated Terms will be published on the website or application.',
        ),
        LegalParagraph(
          'Continued use of Veggiicart after publication of revised Terms shall constitute acceptance of those changes.',
        ),
      ],
    ),
    LegalSection(
      title: '30. Governing Law',
      blocks: [
        LegalParagraph(
          'These Terms & Conditions shall be governed by the **laws of India**.',
        ),
        LegalParagraph(
          'Any disputes arising from the use of Veggiicart shall be subject to the jurisdiction of the competent courts applicable to Veggiicart\'s registered place of business, unless otherwise required by law.',
        ),
      ],
    ),
    LegalSection(
      title: '31. Contact Us',
      blocks: [
        LegalParagraph(
          'For questions, order-related issues, complaints, cancellations, returns, refunds, or other assistance, please contact:',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScaffold(
      title: 'Terms & Conditions',
      lastUpdated: 'August 2026',
      intro: _intro,
      sections: _sections,
      closing: _closing,
    );
  }
}
