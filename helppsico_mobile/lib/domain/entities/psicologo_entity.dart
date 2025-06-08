class Psicologo {
  final String id;
  final String nome;
  final String? crp;
  final String? cpf;
  final String? email;
  final String? telefone;
  final DateTime? dataNascimento;
  final String? senha;
  final String? genero;
  final EnderecoAtendimento? enderecoAtendimento;
  final String? biografia;
  final String? fotoUrl;
  final String? statusPsicologo;
  final double? valorSessao;
  final int? tempoSessao;

  Psicologo({
    required this.id,
    required this.nome,
    this.crp,
    this.cpf,
    this.email,
    this.telefone,
    this.dataNascimento,
    this.senha,
    this.genero,
    this.enderecoAtendimento,
    this.biografia,
    this.fotoUrl,
    this.statusPsicologo,
    this.valorSessao,
    this.tempoSessao,
  });

  factory Psicologo.fromJson(Map<String, dynamic> json) {
    return Psicologo(
      id: json['id'] as String,
      nome: json['nome'] as String,
      crp: json['crp'] as String?,
      cpf: json['cpf'] as String?,
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      dataNascimento: json['dataNascimento'] != null
          ? DateTime.tryParse(json['dataNascimento'] as String)
          : null,
      senha: json['senha'] as String?,
      genero: json['genero'] as String?,
      enderecoAtendimento: json['enderecoAtendimento'] != null
          ? EnderecoAtendimento.fromJson(
              json['enderecoAtendimento'] as Map<String, dynamic>)
          : null,
      biografia: json['biografia'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
      statusPsicologo: json['statusPsicologo'] as String?,
      valorSessao: json['valorSessao'] != null
          ? (json['valorSessao'] as num).toDouble()
          : null,
      tempoSessao: json['tempoSessao'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        if (crp != null) 'crp': crp,
        if (cpf != null) 'cpf': cpf,
        if (email != null) 'email': email,
        if (telefone != null) 'telefone': telefone,
        if (dataNascimento != null)
          'dataNascimento': dataNascimento!.toIso8601String(),
        if (senha != null) 'senha': senha,
        if (genero != null) 'genero': genero,
        if (enderecoAtendimento != null)
          'enderecoAtendimento': enderecoAtendimento!.toJson(),
        if (biografia != null) 'biografia': biografia,
        if (fotoUrl != null) 'fotoUrl': fotoUrl,
        if (statusPsicologo != null) 'statusPsicologo': statusPsicologo,
        if (valorSessao != null) 'valorSessao': valorSessao,
        if (tempoSessao != null) 'tempoSessao': tempoSessao,
      };
}

class EnderecoAtendimento {
  final String id;
  final String? rua;
  final int? numero;
  final String? cep;
  final String? cidade;
  final String? estado;

  EnderecoAtendimento({
    required this.id,
    this.rua,
    this.numero,
    this.cep,
    this.cidade,
    this.estado,
  });

  factory EnderecoAtendimento.fromJson(Map<String, dynamic> json) {
    return EnderecoAtendimento(
      id: json['id'] as String,
      rua: json['rua'] as String?,
      numero: json['numero'] as int?,
      cep: json['cep'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (rua != null) 'rua': rua,
        if (numero != null) 'numero': numero,
        if (cep != null) 'cep': cep,
        if (cidade != null) 'cidade': cidade,
        if (estado != null) 'estado': estado,
      };
}
