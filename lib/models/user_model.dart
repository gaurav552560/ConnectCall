class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool isOnline;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isOnline,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'isOnline': isOnline,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isOnline: map['isOnline'] ?? false,
      createdAt: map['createdAt']?.toDate(),
    );
  }
}