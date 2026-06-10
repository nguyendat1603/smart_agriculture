class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String farmLocation;
  final String avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.farmLocation,
    required this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? 'User',
      farmLocation: json['farm_location'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'farm_location': farmLocation,
      'avatar_url': avatarUrl,
    };
  }

  UserModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? farmLocation,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      email: email,
      role: role,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      farmLocation: farmLocation ?? this.farmLocation,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
