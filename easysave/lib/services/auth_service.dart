import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

/// Servicio de autenticación JWT para consumir el backend de Spring Boot
class AuthService {
  static const String authUrl = '${AppConfig.baseUrl}/auth';
  
  final storage = const FlutterSecureStorage();

  // Headers comunes para las peticiones
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  /// Registra un nuevo usuario y retorna un token JWT
  /// 
  /// Retorna un Map con:
  /// - 'success': true si el registro fue exitoso, false en caso contrario
  /// - 'data': información del usuario y token (si success es true)
  /// - 'message': mensaje de error (si success es false)
  Future<Map<String, dynamic>> register({
    required String username,
    required String correo,
    required String password,
    String rol = 'USER',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/register'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'correo': correo,
          'password': password,
          'rol': rol,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        await saveUserData(data);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false, 
          'message': error['message'] ?? 'Error en el registro'
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': 'Error de conexión: ${e.toString()}'
      };
    }
  }

  /// Autentica un usuario existente y retorna un token JWT
  /// 
  /// Retorna un Map con:
  /// - 'success': true si el login fue exitoso, false en caso contrario
  /// - 'data': información del usuario y token (si success es true)
  /// - 'message': mensaje de error (si success es false)
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/login'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        await saveUserData(data);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false, 
          'message': error['message'] ?? 'Credenciales inválidas'
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': 'Error de conexión: ${e.toString()}'
      };
    }
  }

  /// Guarda el token JWT en el almacenamiento seguro
  Future<void> saveToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  /// Guarda los datos del usuario en el almacenamiento seguro
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await storage.write(key: 'user_id', value: userData['id'].toString());
    await storage.write(key: 'username', value: userData['username']);
    await storage.write(key: 'correo', value: userData['correo']);
    await storage.write(key: 'rol', value: userData['rol']);
  }

  /// Obtiene el token JWT del almacenamiento seguro
  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  /// Obtiene los datos del usuario guardados
  Future<Map<String, String?>> getUserData() async {
    final id = await storage.read(key: 'user_id');
    final username = await storage.read(key: 'username');
    final correo = await storage.read(key: 'correo');
    final rol = await storage.read(key: 'rol');
    
    return {
      'id': id,
      'username': username,
      'correo': correo,
      'rol': rol,
    };
  }

  /// Elimina el token y datos del usuario (logout)
  Future<void> logout() async {
    await storage.delete(key: 'jwt_token');
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'username');
    await storage.delete(key: 'correo');
    await storage.delete(key: 'rol');
  }

  /// Verifica si el usuario está autenticado (tiene un token válido)
  Future<bool> isAuthenticated() async {
    String? token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Hace una petición HTTP autenticada con el token JWT
  /// 
  /// [url] URL completa del endpoint
  /// [method] Método HTTP (GET, POST, PUT, DELETE)
  /// [body] Cuerpo de la petición (para POST y PUT)
  Future<http.Response> authenticatedRequest({
    required String url,
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    String? token = await getToken();
    
    if (token == null) {
      throw Exception('No hay token de autenticación. Inicia sesión primero.');
    }
    
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    switch (method.toUpperCase()) {
      case 'POST':
        return await http.post(
          Uri.parse(url),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return await http.put(
          Uri.parse(url),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return await http.delete(Uri.parse(url), headers: headers);
      default:
        return await http.get(Uri.parse(url), headers: headers);
    }
  }

  /// Verifica que el token JWT sea válido haciendo una petición de test
  Future<bool> testAuthentication() async {
    try {
      final response = await authenticatedRequest(
        url: '$authUrl/test',
        method: 'GET',
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
