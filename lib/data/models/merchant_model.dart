class MerchantModel {
  final String id;
  final String name;
  final String category;
  final String? logoUrl;
  final String description;
  final double? minPayment;

  const MerchantModel({
    required this.id,
    required this.name,
    required this.category,
    this.logoUrl,
    required this.description,
    this.minPayment,
  });

  MerchantModel copyWith({
    String? id,
    String? name,
    String? category,
    String? logoUrl,
    String? description,
    double? minPayment,
  }) {
    return MerchantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      minPayment: minPayment ?? this.minPayment,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'logoUrl': logoUrl,
      'description': description,
      'minPayment': minPayment,
    };
  }

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String,
      minPayment: json['minPayment'] != null
          ? (json['minPayment'] as num).toDouble()
          : null,
    );
  }
}
