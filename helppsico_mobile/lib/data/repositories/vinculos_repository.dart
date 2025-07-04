import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/data/datasource/vinculos_datasource.dart';
import 'package:helppsico_mobile/domain/entities/vinculo_model.dart';

class VinculosRepository {
  final VinculosDataSource _dataSource;

  VinculosRepository({
    VinculosDataSource? dataSource,
    IGenericHttp? http,
    SecureStorageService? secureStorage,
    AuthService? authService,
  }) : _dataSource = dataSource ?? 
       VinculosDataSource(
         http ?? GenericHttp(),
         storage: secureStorage ?? GetIt.instance.get<SecureStorageService>(),
         authService: authService ?? AuthService(),
       );


  Future<VinculoModel?> getVinculoPaciente() async {
    try {
      final response = await _dataSource.getVinculoByPacienteId();
      
      if (response.statusCode == 200 && response.body != null) {

        final responseData = response.body;
        if (responseData == null || !responseData.containsKey('dado')) {
          return null;
        }
        
        final vinculoDto = responseData['dado'];
        return _adaptVinculoDtoToModel(vinculoDto);
      }
      return null;
    } catch (e) {
      print('Erro ao obter vínculo: $e');
      return null;
    }
  }


  Future<VinculoModel?> solicitarVinculo(String psicologoId) async {
    try {
      final response = await _dataSource.solicitarVinculo(psicologoId);
      
      if ((response.statusCode == 200 || response.statusCode == 201) && response.body != null) {
   
        final responseData = response.body;
        if (responseData == null || !responseData.containsKey('dado')) {
          return null;
        }
        
        final vinculoDto = responseData['dado'];
        return _adaptVinculoDtoToModel(vinculoDto);
      }
      return null;
    } catch (e) {
      print('Erro ao solicitar vínculo: $e');
      throw Exception('Não foi possível solicitar o vínculo: $e');
    }
  }


  Future<bool> cancelarVinculo(String vinculoId) async {
    try {
      final response = await _dataSource.cancelarVinculo(vinculoId);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Erro ao cancelar vínculo: $e');
      throw Exception('Não foi possível cancelar o vínculo: $e');
    }
  }


  VinculoModel _adaptVinculoDtoToModel(Map<String, dynamic> vinculoDto) {

    final psicologo = vinculoDto['psicologo'] ?? {};
    final paciente = vinculoDto['paciente'] ?? {};
    
    return VinculoModel(
      id: vinculoDto['id']?.toString() ?? '',
      pacienteId: paciente['id']?.toString() ?? '',
      pacienteNome: paciente['nome'] ?? '',
      psicologoId: psicologo['id']?.toString() ?? '',
      psicologoNome: psicologo['nome'] ?? '',
      psicologoCrp: psicologo['crp'] ?? '',
      valorConsulta: psicologo['valorConsulta'] != null ? 
          double.tryParse(psicologo['valorConsulta'].toString()) ?? 0.0 : 0.0,
      fotoUrl: psicologo['fotoUrl'] ?? '',
      status: vinculoDto['status'] ?? 'PENDENTE',
    );
  }
}