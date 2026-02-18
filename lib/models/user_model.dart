class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'employee' or 'company' (mapped from backend 'type')
  final String? profilePhoto; // mapped from 'avatar'
  final String? phone; // mapped from 'phoneNumber'
  final Map<String, dynamic>? additionalInfo;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profilePhoto,
    this.phone,
    this.additionalInfo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Backend uses '_id' and 'type' ('entreprise' or 'employee')
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final type = json['type'] ?? 'employee';
    // Map 'entreprise' to 'company' for consistency
    final role = type == 'entreprise' ? 'company' : 'employee';
    
    return User(
      id: id,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: role,
      profilePhoto: json['avatar'] ?? json['profilePhoto'],
      phone: json['phoneNumber'] ?? json['phone'],
      additionalInfo: {
        'address': json['address'],
        'city': json['city'],
        'country': json['country'],
        'postalCode': json['postalCode'],
        'cinOrPassport': json['cinOrPassport'],
        'identityPic': json['identityPic'],
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'type': role == 'company' ? 'entreprise' : 'employee', // Backend expects 'entreprise' or 'employee'
      'avatar': profilePhoto,
      'phoneNumber': phone,
      'address': additionalInfo?['address'],
      'city': additionalInfo?['city'],
      'country': additionalInfo?['country'],
      'postalCode': additionalInfo?['postalCode'],
    };
  }
}


