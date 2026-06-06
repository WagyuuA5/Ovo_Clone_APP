class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String avatarUrl;
  final double ovoBalance;
  final int ovoPoints;
  final String pin;
  final bool isVerified;
  final DateTime? lastLogin;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.avatarUrl,
    required this.ovoBalance,
    required this.ovoPoints,
    required this.pin,
    required this.isVerified,
    this.lastLogin,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    double? ovoBalance,
    int? ovoPoints,
    String? pin,
    bool? isVerified,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ovoBalance: ovoBalance ?? this.ovoBalance,
      ovoPoints: ovoPoints ?? this.ovoPoints,
      pin: pin ?? this.pin,
      isVerified: isVerified ?? this.isVerified,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatarUrl': avatarUrl,
      'ovoBalance': ovoBalance,
      'ovoPoints': ovoPoints,
      'pin': pin,
      'isVerified': isVerified,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
      ovoBalance: (json['ovoBalance'] as num).toDouble(),
      ovoPoints: json['ovoPoints'] as int,
      pin: json['pin'] as String,
      isVerified: json['isVerified'] as bool,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, phone: $phone, email: $email, '
        'ovoBalance: $ovoBalance, ovoPoints: $ovoPoints, isVerified: $isVerified, '
        'lastLogin: $lastLogin)';
  }
}
