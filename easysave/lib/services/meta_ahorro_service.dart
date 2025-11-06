import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/meta_ahorro.dart';
import 'auth_service.dart';

class MetaAhorroService {
  static const String baseUrl = 'http://localhost:8080/api/v1/usuario-service';
  final AuthService _authService = AuthService();

  // Headers con autenticación JWT
  Future<Map<String, String>> get _authHeaders async {
    return await _authService.getAuthHeaders();
  }

  // 1. Crear Meta de Ahorro
  Future<MetaAhorro> crearMetaAhorro(
    int usuarioId,
    Map<String, dynamic> metaData,
  ) async {
    try {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/$usuarioId/metas-ahorro'),
        headers: headers,
        body: json.encode(metaData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return MetaAhorro.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Datos inválidos para crear la meta');
      } else {
        throw Exception('Error al crear meta de ahorro: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. El servidor no responde.');
    } on http.ClientException {
      throw Exception('No se puede conectar al servidor.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error: ${e.toString()}');
    }
  }

  // 2. Listar todas las metas de ahorro
  Future<List<MetaAhorro>> listarMetasAhorro(int usuarioId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$usuarioId/metas-ahorro'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => MetaAhorro.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener metas de ahorro: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado.');
    } on http.ClientException {
      throw Exception('No se puede conectar al servidor.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error: ${e.toString()}');
    }
  }

  // 3. Listar metas activas
  Future<List<MetaAhorro>> listarMetasActivas(int usuarioId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$usuarioId/metas-ahorro/activas'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => MetaAhorro.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener metas activas: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado.');
    } on http.ClientException {
      throw Exception('No se puede conectar al servidor.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error: ${e.toString()}');
    }
  }

  // 4. Obtener detalles de una meta
  Future<MetaAhorro> obtenerDetalleMeta(int metaId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/metas-ahorro/$metaId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return MetaAhorro.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        throw Exception('Meta de ahorro no encontrada');
      } else {
        throw Exception('Error al obtener detalle de meta: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado.');
    } on http.ClientException {
      throw Exception('No se puede conectar al servidor.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error: ${e.toString()}');
    }
  }

  // 5. Pagar cuota
  Future<Map<String, dynamic>> pagarCuota(int metaId, int cuotaId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('$baseUrl/metas-ahorro/$metaId/cuotas/$cuotaId/pagar'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'No se puede pagar la cuota');
      } else if (response.statusCode == 404) {
        throw Exception('Cuota no encontrada');
      } else {
        throw Exception('Error al pagar cuota: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado.');
    } on http.ClientException {
      throw Exception('No se puede conectar al servidor.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error: ${e.toString()}');
    }
  }

  // 6. Calcular sugerencia de ahorro
  Future<SugerenciaAhorro> calcularSugerenciaAhorro(
    int usuarioId, {
    double? porcentajeBalance,
    int? numeroCuotas,
    String? frecuencia,
  }) async {
    try {
      final headers = await _authHeaders;
      
      // Construir query parameters
      final queryParams = <String, String>{};
      if (porcentajeBalance != null) {
        queryParams['porcentajeBalance'] = porcentajeBalance.toString();
      }
      if (numeroCuotas != null) {
        queryParams['numeroCuotas'] = numeroCuotas.toString();
      }
      if (frecuencia != null) {
        queryParams['frecuencia'] = frecuencia;
      }

      final uri = Uri.parse('$baseUrl/usuarios/$usuarioId/sugerencia-ahorro')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return SugerenciaAhorro.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'No se puede calcular sugerencia');
      } else {
        throw Exception('Error al calcular sugerencia: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado.');
    } on http.ClientException {
      throw Exception('No se puede conectar al servidor.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error: ${e.toString()}');
    }
  }

  // 7. Cancelar meta
  Future<void> cancelarMeta(int metaId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.delete(
        Uri.parse('$baseUrl/metas-ahorro/$metaId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        throw Exception('Meta no encontrada');
      } else {
        throw Exception('Error al cancelar meta: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado.');
    } on http.ClientException {
      throw Exception('No se puede conectar al servidor.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error: ${e.toString()}');
    }
  }

  // 8. Actualizar cuotas vencidas
  Future<void> actualizarCuotasVencidas() async {
    try {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('$baseUrl/metas-ahorro/actualizar-vencidas'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al actualizar cuotas: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado.');
    } on http.ClientException {
      throw Exception('No se puede conectar al servidor.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error: ${e.toString()}');
    }
  }
}
