import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import 'auth_service.dart';

class UsuarioService {
  static const String baseUrl = 'http://localhost:8080/api/v1/usuario-service';
  final AuthService _authService = AuthService();

  // Headers con autenticación JWT
  Future<Map<String, String>> get _authHeaders async {
    return await _authService.getAuthHeaders();
  }

  Future<List<Usuario>> listarUsuarios() async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Usuario.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error del servidor (${response.statusCode})');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. El servidor no responde.');
    } on http.ClientException {
      throw Exception('No se puede conectar al servidor. Verifica que el backend esté corriendo en $baseUrl');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Buscar usuario por ID
  Future<Usuario> buscarUsuarioPorId(int id) async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Usuario.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        throw Exception('Error al buscar usuario: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar usuario
  Future<Usuario> actualizarUsuario(Usuario usuario) async {
    try {
      final headers = await _authHeaders;
      final response = await http.put(
        Uri.parse('$baseUrl/usuario'),
        headers: headers,
        body: json.encode(usuario.toJson()),
      );

      if (response.statusCode == 200) {
        return Usuario.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        throw Exception('Error al actualizar usuario: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener ingresos de un usuario
  Future<List<dynamic>> obtenerIngresos(int usuarioId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$usuarioId/ingresos'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener ingresos');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Obtener gastos de un usuario
  Future<List<dynamic>> obtenerGastos(int usuarioId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$usuarioId/gastos'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener gastos');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Agregar ingreso
  Future<Map<String, dynamic>> agregarIngreso(int usuarioId, Map<String, dynamic> ingreso) async {
    try {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/$usuarioId/ingresos'),
        headers: headers,
        body: json.encode(ingreso),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al agregar ingreso');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Agregar gasto
  Future<Map<String, dynamic>> agregarGasto(int usuarioId, Map<String, dynamic> gasto) async {
    try {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/$usuarioId/gastos'),
        headers: headers,
        body: json.encode(gasto),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al agregar gasto');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Eliminar ingreso
  Future<void> eliminarIngreso(int ingresoId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.delete(
        Uri.parse('$baseUrl/ingresos/$ingresoId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar ingreso');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Eliminar gasto
  Future<void> eliminarGasto(int gastoId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.delete(
        Uri.parse('$baseUrl/gastos/$gastoId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar gasto');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Obtener resumen financiero actualizado del usuario
  Future<Map<String, dynamic>> obtenerBalance(int usuarioId) async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$usuarioId/resumen-financiero'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener resumen financiero');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
