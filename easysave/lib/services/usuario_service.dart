import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../config/app_config.dart';
import 'auth_manager.dart';

class UsuarioService {
  static const String baseUrl = AppConfig.usuarioServiceUrl;
  
  final _authManager = AuthManager();

  /// Obtiene los headers con el token JWT para peticiones autenticadas
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authManager.obtenerToken();
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Usuario>> listarUsuarios() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Usuario.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Inicia sesión nuevamente.');
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

  // 2. Buscar usuario por ID
  Future<Usuario> buscarUsuarioPorId(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Usuario.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        throw Exception('Error al buscar usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Usuario> crearUsuario(Usuario usuario) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/usuario'),
        headers: headers,
        body: json.encode(usuario.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Usuario.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Inicia sesión nuevamente.');
      } else if (response.statusCode == 400) {
        throw Exception('Datos inválidos. Verifica la información ingresada.');
      } else if (response.statusCode == 409) {
        throw Exception('El usuario o correo ya existe.');
      } else {
        throw Exception('Error al crear usuario: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión: $e');
    }
  }

  // 4. Actualizar usuario
  Future<Usuario> actualizarUsuario(Usuario usuario) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/usuario'),
        headers: headers,
        body: json.encode(usuario.toJson()),
      );

      if (response.statusCode == 200) {
        return Usuario.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Inicia sesión nuevamente.');
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

  // Método auxiliar para login (busca por username y valida password)
  // DEPRECADO: Usar AuthService.login() en su lugar
  @Deprecated('Usar AuthService.login() para autenticación JWT')
  Future<Usuario> login(String username, String password) async {
    try {
      // Obtener todos los usuarios
      final usuarios = await listarUsuarios();
      
      // Buscar el usuario por username
      final usuario = usuarios.firstWhere(
        (u) => u.username == username,
        orElse: () => throw Exception('Usuario no encontrado'),
      );

      // Validar password
      if (usuario.password == password) {
        return usuario;
      } else {
        throw Exception('Contraseña incorrecta');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error en el login: $e');
    }
  }

  // Método auxiliar para verificar si un username ya existe
  @Deprecated('Usar AuthService.register() para registro con JWT')
  Future<bool> existeUsername(String username) async {
    try {
      final usuarios = await listarUsuarios();
      return usuarios.any((u) => u.username == username);
    } catch (e) {
      return false;
    }
  }

  @Deprecated('Usar AuthService.register() para registro con JWT')
  Future<bool> existeCorreo(String correo) async {
    try {
      final usuarios = await listarUsuarios();
      return usuarios.any((u) => u.correo == correo);
    } catch (e) {
      return false;
    }
  }

  // Obtener ingresos de un usuario
  Future<List<dynamic>> obtenerIngresos(int usuarioId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$usuarioId/ingresos'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Inicia sesión nuevamente.');
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
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$usuarioId/gastos'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Inicia sesión nuevamente.');
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
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/$usuarioId/ingresos'),
        headers: headers,
        body: json.encode(ingreso),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Inicia sesión nuevamente.');
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
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/$usuarioId/gastos'),
        headers: headers,
        body: json.encode(gasto),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Inicia sesión nuevamente.');
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
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/ingresos/$ingresoId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        throw Exception('No autorizado. Inicia sesión nuevamente.');
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
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/gastos/$gastoId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        throw Exception('No autorizado. Inicia sesión nuevamente.');
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
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$usuarioId/resumen-financiero'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener resumen financiero');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
