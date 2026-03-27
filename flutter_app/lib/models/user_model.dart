import 'package:freezed_annotation/freezed_annotation.dart';

/// Model de usuário do app
class UserModel {
  final String id;
  final String email;
  final String name;
  final int age;
  final String? bio;
  final List<String> photos; // URLs das fotos
  final String? avatarUrl; // Foto principal
  
  // Localização
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;
  
  // Origem brasileira
  final String brazilianCity; // De onde é no Brasil
  final String brazilianState;
  
  // Preferências
  final String gender; // 'male', 'female', 'other'
  final String interestedIn; // 'male', 'female', 'both'
  final int minAge;
  final int maxAge;
  final int maxDistance; // Em km
  
  // Verificação
  final bool isVerified; // Badge verificado
  final bool isPhoneVerified;
  final bool isDocumentVerified;
  
  // Créditos
  final int credits;
  
  // Metadata
  final DateTime createdAt;
  final DateTime? lastActive;
  
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    this.bio,
    required this.photos,
    this.avatarUrl,
    required this.city,
    required this.state,
    required this.country,
    this.latitude,
    this.longitude,
    required this.brazilianCity,
    required this.brazilianState,
    required this.gender,
    required this.interestedIn,
    this.minAge = 18,
    this.maxAge = 50,
    this.maxDistance = 50,
    this.isVerified = false,
    this.isPhoneVerified = false,
    this.isDocumentVerified = false,
    this.credits = 0,
    required this.createdAt,
    this.lastActive,
  });
  
  // From JSON (Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      bio: json['bio'] as String?,
      photos: List<String>.from(json['photos'] ?? []),
      avatarUrl: json['avatar_url'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      brazilianCity: json['brazilian_city'] as String,
      brazilianState: json['brazilian_state'] as String,
      gender: json['gender'] as String,
      interestedIn: json['interested_in'] as String,
      minAge: json['min_age'] as int? ?? 18,
      maxAge: json['max_age'] as int? ?? 50,
      maxDistance: json['max_distance'] as int? ?? 50,
      isVerified: json['is_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      isDocumentVerified: json['is_document_verified'] as bool? ?? false,
      credits: json['credits'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActive: json['last_active'] != null 
        ? DateTime.parse(json['last_active'] as String)
        : null,
    );
  }
  
  // To JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'bio': bio,
      'photos': photos,
      'avatar_url': avatarUrl,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'brazilian_city': brazilianCity,
      'brazilian_state': brazilianState,
      'gender': gender,
      'interested_in': interestedIn,
      'min_age': minAge,
      'max_age': maxAge,
      'max_distance': maxDistance,
      'is_verified': isVerified,
      'is_phone_verified': isPhoneVerified,
      'is_document_verified': isDocumentVerified,
      'credits': credits,
      'created_at': createdAt.toIso8601String(),
      'last_active': lastActive?.toIso8601String(),
    };
  }
  
  // CopyWith
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    int? age,
    String? bio,
    List<String>? photos,
    String? avatarUrl,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    String? brazilianCity,
    String? brazilianState,
    String? gender,
    String? interestedIn,
    int? minAge,
    int? maxAge,
    int? maxDistance,
    bool? isVerified,
    bool? isPhoneVerified,
    bool? isDocumentVerified,
    int? credits,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      brazilianCity: brazilianCity ?? this.brazilianCity,
      brazilianState: brazilianState ?? this.brazilianState,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      maxDistance: maxDistance ?? this.maxDistance,
      isVerified: isVerified ?? this.isVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isDocumentVerified: isDocumentVerified ?? this.isDocumentVerified,
      credits: credits ?? this.credits,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
