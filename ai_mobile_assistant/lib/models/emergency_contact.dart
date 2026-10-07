import 'dart:convert';

/// Model representing an emergency contact.
class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }

  static List<EmergencyContact> fromJsonList(String jsonString) {
    if (jsonString.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String toJsonList(List<EmergencyContact> contacts) {
    return json.encode(contacts.map((c) => c.toJson()).toList());
  }
}
