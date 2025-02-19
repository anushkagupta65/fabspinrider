class PickupDrop {
  final String pickupAddress;
  final String deliverAddress;
  final String storecode;
  final String status; // New field added
  final String type;
  final String pickupDate;
  final String pickupTime;
  final String id;
  final String customerName;
  final String customerMobile;

  PickupDrop({
    required this.pickupAddress,
    required this.deliverAddress,
    required this.storecode,
    required this.status,
    required this.type,
    required this.pickupDate,
    required this.pickupTime,
    required this.id,
    required this.customerName,
    required this.customerMobile,
  });

  factory PickupDrop.fromJson(Map<String, dynamic> json) {
    return PickupDrop(
      pickupAddress: json['pickup_address'] ?? '',
      deliverAddress: json['deliver_address'] ?? '',
      storecode: json['storecode']?.toString() ?? '',
      status: json['status'] ?? '', // Mapping the new `status` field
      type: json['type'] ?? '',
      pickupDate: json['pickup_date'] ?? '',
      pickupTime: json['pickup_time'] ?? '',
      id: json['id']?.toString() ?? '', // Convert `id` to String if it's an int
      customerName: json['customer_name'] ?? '',
      customerMobile: json['customer_mobile']?.toString() ?? '', // Convert `customer_mobile` to String if it's an int
    );
  }
}
