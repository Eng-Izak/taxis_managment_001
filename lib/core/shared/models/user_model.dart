class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String phone;
  final String role;
  final DateTime? lastSyncTime;
  final bool isEmailVerified;
  final bool autoSyncEnabled;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.phone = '',
    this.role = 'مدير الأسطول والمحفظة',
    this.lastSyncTime,
    this.isEmailVerified = true,
    this.autoSyncEnabled = true,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phone,
    String? role,
    DateTime? lastSyncTime,
    bool? isEmailVerified,
    bool? autoSyncEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'role': role,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'autoSyncEnabled': autoSyncEnabled,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'مدير الأسطول والمحفظة',
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.tryParse(json['lastSyncTime'] as String)
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? true,
      autoSyncEnabled: json['autoSyncEnabled'] as bool? ?? true,
    );
  }
}
