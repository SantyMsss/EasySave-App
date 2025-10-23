import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import 'dart:convert';

class AuthManager {
  static const String _keyUserId = 'user_id';
  static const String _keyUserData = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Guardar sesión del usuario
  Future<void> guardarSesion(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, usuario.id!);
    await prefs.setString(_keyUserData, json.encode(usuario.toJson()));
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // Obtener usuario actual
  Future<Usuario?> obtenerUsuarioActual() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    
    if (!isLoggedIn) return null;

    final userData = prefs.getString(_keyUserData);
    if (userData != null) {
      return Usuario.fromJson(json.decode(userData));
    }
    return null;
  }

  // Verificar si hay sesión activa
  Future<bool> tieneSesionActiva() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserData);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // Actualizar datos del usuario en la sesión
  Future<void> actualizarSesion(Usuario usuario) async {
    await guardarSesion(usuario);
  }
}
