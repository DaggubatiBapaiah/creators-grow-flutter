class BrandDeal {
  final String id;
  final String userId;
  final String brandName;
  final double dealValue;
  final String stage; // 'pitching', 'negotiating', 'signed', 'completed', 'paid'
  final String? contactPerson;
  final String? contactEmail;
  final String? notes;
  final String? associatedPostId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BrandDeal({
    required this.id,
    required this.userId,
    required this.brandName,
    required this.dealValue,
    required this.stage,
    this.contactPerson,
    this.contactEmail,
    this.notes,
    this.associatedPostId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BrandDeal.fromJson(Map<String, dynamic> json) {
    return BrandDeal(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      brandName: json['brand_name'] as String,
      dealValue: double.parse(json['deal_value'].toString()),
      stage: json['stage'] as String,
      contactPerson: json['contact_person'] as String?,
      contactEmail: json['contact_email'] as String?,
      notes: json['notes'] as String?,
      associatedPostId: json['associated_post_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'brand_name': brandName,
      'deal_value': dealValue,
      'stage': stage,
      'contact_person': contactPerson,
      'contact_email': contactEmail,
      'notes': notes,
      'associated_post_id': associatedPostId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BrandDeal copyWith({
    String? id,
    String? userId,
    String? brandName,
    double? dealValue,
    String? stage,
    String? contactPerson,
    String? contactEmail,
    String? notes,
    String? associatedPostId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BrandDeal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      brandName: brandName ?? this.brandName,
      dealValue: dealValue ?? this.dealValue,
      stage: stage ?? this.stage,
      contactPerson: contactPerson ?? this.contactPerson,
      contactEmail: contactEmail ?? this.contactEmail,
      notes: notes ?? this.notes,
      associatedPostId: associatedPostId ?? this.associatedPostId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}