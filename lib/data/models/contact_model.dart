class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String avatarInitial;
  final bool isFavorite;
  final DateTime? lastTransactionDate;

  const ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.avatarInitial,
    required this.isFavorite,
    this.lastTransactionDate,
  });

  ContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatarInitial,
    bool? isFavorite,
    DateTime? lastTransactionDate,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarInitial: avatarInitial ?? this.avatarInitial,
      isFavorite: isFavorite ?? this.isFavorite,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatarInitial': avatarInitial,
      'isFavorite': isFavorite,
      'lastTransactionDate': lastTransactionDate?.toIso8601String(),
    };
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      avatarInitial: json['avatarInitial'] as String,
      isFavorite: json['isFavorite'] as bool,
      lastTransactionDate: json['lastTransactionDate'] != null
          ? DateTime.parse(json['lastTransactionDate'] as String)
          : null,
    );
  }
}
