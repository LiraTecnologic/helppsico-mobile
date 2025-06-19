import 'psicologo_entity.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? cpf;
  final String? telefone;
  final String? dataNascimento;
  final String? endereco;
  final Psicologo? psicologo;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.cpf,
    this.telefone,
    this.dataNascimento,
    this.endereco,
    this.psicologo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: '', 
      role: json['role'] ?? 'PACIENTE',
      cpf: json['cpf'],
      telefone: json['telefone'],
      dataNascimento: json['dataNascimento'],
      endereco: json['endereco'],
      psicologo: json['psicologo'] != null
          ? Psicologo.fromJson(json['psicologo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        if (cpf != null) 'cpf': cpf,
        if (telefone != null) 'telefone': telefone,
        if (dataNascimento != null) 'dataNascimento': dataNascimento,
        if (endereco != null) 'endereco': endereco,
        if (psicologo != null) 'psicologo': psicologo!.toJson(),
      };
}