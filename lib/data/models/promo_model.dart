import 'package:flutter/material.dart';

class PromoModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final int colorValue;
  final String? imageUrl;
  final DateTime validUntil;
  final bool isActive;

  const PromoModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.colorValue,
    this.imageUrl,
    required this.validUntil,
    required this.isActive,
  });

  Color get color => Color(colorValue);

  PromoModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    int? colorValue,
    String? imageUrl,
    DateTime? validUntil,
    bool? isActive,
  }) {
    return PromoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      imageUrl: imageUrl ?? this.imageUrl,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'colorValue': colorValue,
      'imageUrl': imageUrl,
      'validUntil': validUntil.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      colorValue: json['colorValue'] as int,
      imageUrl: json['imageUrl'] as String?,
      validUntil: DateTime.parse(json['validUntil'] as String),
      isActive: json['isActive'] as bool,
    );
  }
}
