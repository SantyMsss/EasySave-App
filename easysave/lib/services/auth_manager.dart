import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario.dart';
import 'auth_service.dart';
import 'dart:convert';

/// Administrador de sesión y autenticación del usuario
/// Maneja el almacenamiento seguro de tokens JWT y datos del usuario
class AuthManager {
  static const String _keyUserId = 'user_id';
  static const String _keyUserData = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  
  final AuthService _authService = AuthService();

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

  // Verificar si hay sesión activa (con validación de token JWT)
  Future<bool> tieneSesionActiva() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    
    if (!isLoggedIn) return false;
    
    // Verificar si el token JWT es válido
    final tokenValido = await _authService.isAuthenticated();
    
    if (!tokenValido) {
      // Si el token no es válido, cerrar sesión
      await cerrarSesion();
      return false;
    }
    
    return true;
  }

  // Cerrar sesión (elimina datos locales y token JWT)
  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserData);
    await prefs.setBool(_keyIsLoggedIn, false);
    
    // Eliminar token JWT
    await _authService.logout();
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
