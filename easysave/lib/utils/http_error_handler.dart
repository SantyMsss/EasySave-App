import 'package:flutter/material.dart';
import '../services/auth_manager.dart';
import '../screens/login_screen.dart';

class HttpErrorHandler {
  static final AuthManager _authManager = AuthManager();

  /// Maneja errores HTTP y redirecciona si es necesario
  static Future<void> handleError(
    BuildContext context,
    Exception error, {
    bool showSnackbar = true,
  }) async {
    final errorMessage = error.toString().replaceAll('Exception: ', '');

    // Si es error 401 (no autorizado), cerrar sesión y volver al login
    if (errorMessage.contains('401') || 
        errorMessage.contains('Sesión expirada') ||
        errorMessage.contains('Unauthorized')) {
      await _authManager.cerrarSesion();
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tu sesión ha expirado. Por favor inicia sesión nuevamente.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Mostrar error genérico
    if (showSnackbar && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Verifica si un error es de autenticación
  static bool isAuthError(Exception error) {
    final errorMessage = error.toString().replaceAll('Exception: ', '');
    return errorMessage.contains('401') || 
           errorMessage.contains('Sesión expirada') ||
           errorMessage.contains('Unauthorized');
  }
}
