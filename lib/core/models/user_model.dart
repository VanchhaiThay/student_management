class UserModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? teacherId;
  final String? department;
  final String? role;

  const UserModel({
    this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.teacherId,
    this.department,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          json['userId']?.toString(),
      fullName: json['fullName'] as String? ??
          json['full_name'] as String? ??
          json['name'] as String? ??
          json['displayName'] as String? ??
          json['username'] as String?,
      email: json['email'] as String? ?? json['sub'] as String?,
      phoneNumber: json['phoneNumber'] as String? ??
          json['phone_number'] as String? ??
          json['phone'] as String?,
      teacherId: json['teacherId'] as String? ??
          json['teacher_id'] as String? ??
          json['idNumber'] as String? ??
          json['code'] as String?,
      department: json['department'] as String? ?? json['dept'] as String?,
      role: json['role'] as String? ?? json['roles']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'teacherId': teacherId,
      'department': department,
      'role': role,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? teacherId,
    String? department,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      teacherId: teacherId ?? this.teacherId,
      department: department ?? this.department,
      role: role ?? this.role,
    );
  }

  String get initials {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      final parts = fullName!.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
      }
    }
    if (email != null && email!.isNotEmpty) {
      return email!.substring(0, email!.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }

  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    if (email != null && email!.trim().isNotEmpty) {
      return email!.split('@').first;
    }
    return 'Teacher';
  }
}
