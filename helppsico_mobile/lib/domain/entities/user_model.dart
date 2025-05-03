class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      };
}