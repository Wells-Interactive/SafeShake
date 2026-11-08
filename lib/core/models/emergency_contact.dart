class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final bool enabled;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email = '',
    this.enabled = true,
  });

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    bool? enabled,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'enabled': enabled,
      };

  factory EmergencyContact.fromMap(String id, Map<String, dynamic> map) {
    return EmergencyContact(
      id: id,
      name: map['name'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      email: map['email'] as String? ?? '',
      enabled: map['enabled'] as bool? ?? true,
    );
  }
}
