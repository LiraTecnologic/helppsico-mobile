import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/psicologo_entity.dart';

void main() {
  group('Psicologo Tests', () {
    late Map<String, dynamic> validPsicologoJson;
    late Map<String, dynamic> psicologoJsonWithEndereco;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.parse('1980-05-15');
      
      validPsicologoJson = {
        'id': 'psi123',
        'nome': 'Dr. João Silva',
        'crp': '12345',
        'cpf': '12345678901',
        'email': 'joao@email.com',
        'telefone': '11999999999',
        'dataNascimento': '1980-05-15',
        'senha': 'password123',
        'genero': 'M',
        'biografia': 'Psicólogo especialista em terapia cognitiva',
        'fotoUrl': 'https://example.com/foto.jpg',
        'statusPsicologo': 'ATIVO',
        'valorSessao': 150.0,
        'tempoSessao': 60,
      };

      psicologoJsonWithEndereco = {
        ...validPsicologoJson,
        'enderecoAtendimento': {
          'id': 'end123',
          'rua': 'Rua A',
          'numero': '123',
          'bairro': 'Centro',
          'cidade': 'São Paulo',
          'estado': 'SP',
          'cep': '01234567',
        },
      };
    });

    test('should create Psicologo instance with required fields only', () {
      final psicologo = Psicologo(
        id: 'psi123',
        nome: 'Dr. João Silva',
      );

      expect(psicologo.id, 'psi123');
      expect(psicologo.nome, 'Dr. João Silva');
      expect(psicologo.crp, isNull);
      expect(psicologo.cpf, isNull);
      expect(psicologo.email, isNull);
      expect(psicologo.telefone, isNull);
      expect(psicologo.dataNascimento, isNull);
      expect(psicologo.senha, isNull);
      expect(psicologo.genero, isNull);
      expect(psicologo.enderecoAtendimento, isNull);
      expect(psicologo.biografia, isNull);
      expect(psicologo.fotoUrl, isNull);
      expect(psicologo.statusPsicologo, isNull);
      expect(psicologo.valorSessao, isNull);
      expect(psicologo.tempoSessao, isNull);
    });

    test('should create Psicologo instance with all fields', () {
      final endereco = EnderecoAtendimento(
        id: 'end123',
        rua: 'Rua A',
        numero: 123,
        
        cidade: 'São Paulo',
        estado: 'SP',
        cep: '01234567',
      );

      final psicologo = Psicologo(
        id: 'psi123',
        nome: 'Dr. João Silva',
        crp: '12345',
        cpf: '12345678901',
        email: 'joao@email.com',
        telefone: '11999999999',
        dataNascimento: testDate,
        senha: 'password123',
        genero: 'M',
        enderecoAtendimento: endereco,
        biografia: 'Psicólogo especialista em terapia cognitiva',
        fotoUrl: 'https://example.com/foto.jpg',
        statusPsicologo: 'ATIVO',
        valorSessao: 150.0,
        tempoSessao: 60,
      );

      expect(psicologo.id, 'psi123');
      expect(psicologo.nome, 'Dr. João Silva');
      expect(psicologo.crp, '12345');
      expect(psicologo.cpf, '12345678901');
      expect(psicologo.email, 'joao@email.com');
      expect(psicologo.telefone, '11999999999');
      expect(psicologo.dataNascimento, testDate);
      expect(psicologo.senha, 'password123');
      expect(psicologo.genero, 'M');
      expect(psicologo.enderecoAtendimento, endereco);
      expect(psicologo.biografia, 'Psicólogo especialista em terapia cognitiva');
      expect(psicologo.fotoUrl, 'https://example.com/foto.jpg');
      expect(psicologo.statusPsicologo, 'ATIVO');
      expect(psicologo.valorSessao, 150.0);
      expect(psicologo.tempoSessao, 60);
    });

    test('should create Psicologo from valid JSON', () {
      final psicologo = Psicologo.fromJson(validPsicologoJson);

      expect(psicologo.id, 'psi123');
      expect(psicologo.nome, 'Dr. João Silva');
      expect(psicologo.crp, '12345');
      expect(psicologo.cpf, '12345678901');
      expect(psicologo.email, 'joao@email.com');
      expect(psicologo.telefone, '11999999999');
      expect(psicologo.dataNascimento, testDate);
      expect(psicologo.senha, 'password123');
      expect(psicologo.genero, 'M');
      expect(psicologo.biografia, 'Psicólogo especialista em terapia cognitiva');
      expect(psicologo.fotoUrl, 'https://example.com/foto.jpg');
      expect(psicologo.statusPsicologo, 'ATIVO');
      expect(psicologo.valorSessao, 150.0);
      expect(psicologo.tempoSessao, 60);
      expect(psicologo.enderecoAtendimento, isNull);
    });

    test('should create Psicologo from JSON with endereco', () {
      final psicologo = Psicologo.fromJson(psicologoJsonWithEndereco);

      expect(psicologo.id, 'psi123');
      expect(psicologo.nome, 'Dr. João Silva');
      expect(psicologo.enderecoAtendimento, isNotNull);
      expect(psicologo.enderecoAtendimento!.id, 'end123');
      expect(psicologo.enderecoAtendimento!.rua, 'Rua A');
      expect(psicologo.enderecoAtendimento!.numero, '123');
   
      expect(psicologo.enderecoAtendimento!.cidade, 'São Paulo');
      expect(psicologo.enderecoAtendimento!.estado, 'SP');
      expect(psicologo.enderecoAtendimento!.cep, '01234567');
    });

    test('should handle invalid date in JSON', () {
      final jsonWithInvalidDate = {
        ...validPsicologoJson,
        'dataNascimento': 'invalid-date',
      };

      final psicologo = Psicologo.fromJson(jsonWithInvalidDate);
      expect(psicologo.dataNascimento, isNull);
    });

    test('should handle null date in JSON', () {
      final jsonWithNullDate = {
        ...validPsicologoJson,
        'dataNascimento': null,
      };

      final psicologo = Psicologo.fromJson(jsonWithNullDate);
      expect(psicologo.dataNascimento, isNull);
    });

    test('should convert Psicologo to JSON correctly', () {
      final psicologo = Psicologo(
        id: 'psi123',
        nome: 'Dr. João Silva',
        crp: '12345',
        cpf: '12345678901',
        email: 'joao@email.com',
        telefone: '11999999999',
        dataNascimento: testDate,
        senha: 'password123',
        genero: 'M',
        biografia: 'Psicólogo especialista em terapia cognitiva',
        fotoUrl: 'https://example.com/foto.jpg',
        statusPsicologo: 'ATIVO',
        valorSessao: 150.0,
        tempoSessao: 60,
      );

      final json = psicologo.toJson();

      expect(json['id'], 'psi123');
      expect(json['nome'], 'Dr. João Silva');
      expect(json['crp'], '12345');
      expect(json['cpf'], '12345678901');
      expect(json['email'], 'joao@email.com');
      expect(json['telefone'], '11999999999');
      expect(json['dataNascimento'], testDate.toIso8601String());
      expect(json['senha'], 'password123');
      expect(json['genero'], 'M');
      expect(json['biografia'], 'Psicólogo especialista em terapia cognitiva');
      expect(json['fotoUrl'], 'https://example.com/foto.jpg');
      expect(json['statusPsicologo'], 'ATIVO');
      expect(json['valorSessao'], 150.0);
      expect(json['tempoSessao'], 60);
    });

    test('should convert Psicologo to JSON without optional fields', () {
      final psicologo = Psicologo(
        id: 'psi123',
        nome: 'Dr. João Silva',
      );

      final json = psicologo.toJson();

      expect(json['id'], 'psi123');
      expect(json['nome'], 'Dr. João Silva');
      expect(json.containsKey('crp'), false);
      expect(json.containsKey('cpf'), false);
      expect(json.containsKey('email'), false);
      expect(json.containsKey('telefone'), false);
      expect(json.containsKey('dataNascimento'), false);
      expect(json.containsKey('senha'), false);
      expect(json.containsKey('genero'), false);
      expect(json.containsKey('enderecoAtendimento'), false);
      expect(json.containsKey('biografia'), false);
      expect(json.containsKey('fotoUrl'), false);
      expect(json.containsKey('statusPsicologo'), false);
      expect(json.containsKey('valorSessao'), false);
      expect(json.containsKey('tempoSessao'), false);
    });
  });

  group('EnderecoAtendimento Tests', () {
    late Map<String, dynamic> validEnderecoJson;

    setUp(() {
      validEnderecoJson = {
        'id': 'end123',
        'rua': 'Rua A',
        'numero': '123',
        'bairro': 'Centro',
        'cidade': 'São Paulo',
        'estado': 'SP',
        'cep': '01234567',
      };
    });

    test('should create EnderecoAtendimento instance', () {
      final endereco = EnderecoAtendimento(
        id: 'end123',
        rua: 'Rua A',
        numero: 123,
     
        cidade: 'São Paulo',
        estado: 'SP',
        cep: '01234567',
      );

      expect(endereco.id, 'end123');
      expect(endereco.rua, 'Rua A');
      expect(endereco.numero, '123');

      expect(endereco.cidade, 'São Paulo');
      expect(endereco.estado, 'SP');
      expect(endereco.cep, '01234567');
    });

    test('should create EnderecoAtendimento from JSON', () {
      final endereco = EnderecoAtendimento.fromJson(validEnderecoJson);

      expect(endereco.id, 'end123');
      expect(endereco.rua, 'Rua A');
      expect(endereco.numero, '123');
    
      expect(endereco.cidade, 'São Paulo');
      expect(endereco.estado, 'SP');
      expect(endereco.cep, '01234567');
    });

    test('should convert EnderecoAtendimento to JSON', () {
      final endereco = EnderecoAtendimento(
        id: 'end123',
        rua: 'Rua A',
        numero:123,
      
        cidade: 'São Paulo',
        estado: 'SP',
        cep: '01234567',
      );

      final json = endereco.toJson();

      expect(json['id'], 'end123');
      expect(json['rua'], 'Rua A');
      expect(json['numero'], '123');
      expect(json['bairro'], 'Centro');
      expect(json['cidade'], 'São Paulo');
      expect(json['estado'], 'SP');
      expect(json['cep'], '01234567');
    });
  });
}