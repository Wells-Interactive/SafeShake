class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final bool enabled;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.enabled = true,
  });

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    bool? enabled,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phoneNumber': phoneNumber,
    'enabled': enabled,
  };

  factory EmergencyContact.fromMap(String id, Map<String, dynamic> map) {
    return EmergencyContact(
      id: id,
      name: map['name'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      enabled: map['enabled'] as bool? ?? true,
    );
  }
}
