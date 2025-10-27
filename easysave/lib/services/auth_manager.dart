import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario.dart';
import 'dart:convert';

/// Administrador de sesión y autenticación del usuario
/// Maneja el almacenamiento seguro de tokens JWT y datos del usuario
class AuthManager {
  static const String _keyUserId = 'user_id';
  static const String _keyUserData = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyJwtToken = 'jwt_token';

  final storage = const FlutterSecureStorage();

  /// Guarda la sesión del usuario con token JWT
  Future<void> guardarSesion(Usuario usuario, String token) async {
    await storage.write(key: _keyUserId, value: usuario.id.toString());
    await storage.write(key: _keyUserData, value: json.encode(usuario.toJson()));
    await storage.write(key: _keyIsLoggedIn, value: 'true');
    await storage.write(key: _keyJwtToken, value: token);
  }

  /// Obtiene el usuario actual de la sesión
  Future<Usuario?> obtenerUsuarioActual() async {
    final isLoggedIn = await storage.read(key: _keyIsLoggedIn);
    
    if (isLoggedIn != 'true') return null;

    final userData = await storage.read(key: _keyUserData);
    if (userData != null) {
      return Usuario.fromJson(json.decode(userData));
    }
    return null;
  }

  /// Obtiene el token JWT de la sesión actual
  Future<String?> obtenerToken() async {
    return await storage.read(key: _keyJwtToken);
  }

  /// Verifica si hay una sesión activa
  Future<bool> tieneSesionActiva() async {
    final isLoggedIn = await storage.read(key: _keyIsLoggedIn);
    final token = await storage.read(key: _keyJwtToken);
    return isLoggedIn == 'true' && token != null && token.isNotEmpty;
  }

  /// Cierra la sesión y elimina todos los datos almacenados
  Future<void> cerrarSesion() async {
    await storage.delete(key: _keyUserId);
    await storage.delete(key: _keyUserData);
    await storage.delete(key: _keyIsLoggedIn);
    await storage.delete(key: _keyJwtToken);
  }

  /// Actualiza los datos del usuario en la sesión (mantiene el token)
  Future<void> actualizarSesion(Usuario usuario) async {
    final token = await obtenerToken();
    if (token != null) {
      await guardarSesion(usuario, token);
    }
  }

  /// Obtiene el ID del usuario actual
  Future<int?> obtenerUsuarioId() async {
    final userIdStr = await storage.read(key: _keyUserId);
    if (userIdStr != null) {
      return int.tryParse(userIdStr);
    }
    return null;
  }
}
