/// Approved B2B business type catalogue (12 options).
class BusinessTypeOption {
  const BusinessTypeOption({required this.id, required this.label});

  final String id;
  final String label;
}

class BusinessTypes {
  BusinessTypes._();

  static const List<BusinessTypeOption> all = [
    BusinessTypeOption(id: 'retail_shop', label: 'Retail Shop'),
    BusinessTypeOption(id: 'kirana_store', label: 'Kirana Store'),
    BusinessTypeOption(id: 'supermarket', label: 'Supermarket'),
    BusinessTypeOption(id: 'hotel', label: 'Hotel'),
    BusinessTypeOption(id: 'restaurant', label: 'Restaurant'),
    BusinessTypeOption(id: 'catering_service', label: 'Catering Service'),
    BusinessTypeOption(id: 'hostel', label: 'Hostel'),
    BusinessTypeOption(id: 'hospital', label: 'Hospital'),
    BusinessTypeOption(id: 'corporate_pantry', label: 'Corporate Pantry'),
    BusinessTypeOption(id: 'juice_shop', label: 'Juice Shop'),
    BusinessTypeOption(id: 'vendor_reseller', label: 'Vendor/Reseller'),
    BusinessTypeOption(id: 'other', label: 'Other'),
  ];

  static const String defaultId = 'retail_shop';
  static const String otherId = 'other';

  static bool isOther(String? id) => id == otherId;

  static BusinessTypeOption byId(String? id) {
    return all.firstWhere(
      (e) => e.id == id,
      orElse: () => all.firstWhere(
        (e) => e.label == id,
        orElse: () => all.first,
      ),
    );
  }

  static List<String> get labels => all.map((e) => e.label).toList();
}

/// Indian states / UTs for registration address.
class IndianStates {
  IndianStates._();

  static const List<String> all = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];
}
