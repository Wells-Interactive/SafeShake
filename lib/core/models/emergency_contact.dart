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

  Map<String, dynamic> toMap() => {
    'name': name,
    'phoneNumber': phoneNumber,
    'enabled': enabled,
  };
}
