/// EJEMPLO DE USO DEL AUTHSERVICE CON JWT
/// 
/// Este archivo muestra ejemplos prácticos de cómo usar el servicio
/// de autenticación JWT en diferentes escenarios.

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/auth_manager.dart';
import '../services/usuario_service.dart';
import '../models/usuario.dart';

// ============================================================================
// EJEMPLO 1: LOGIN COMPLETO
// ============================================================================
Future<void> ejemploLogin(BuildContext context) async {
  final authService = AuthService();
  final authManager = AuthManager();

  // Hacer login
  final result = await authService.login(
    username: 'juan',
    password: 'password123',
  );

  if (result['success']) {
    // Login exitoso
    final userData = result['data'];
    
    print('✅ Login exitoso!');
    print('Token: ${userData['token']}');
    print('Usuario ID: ${userData['id']}');
    print('Username: ${userData['username']}');
    print('Correo: ${userData['correo']}');
    print('Rol: ${userData['rol']}');

    // Crear objeto Usuario
    final usuario = Usuario(
      id: userData['id'],
      username: userData['username'],
      correo: userData['correo'],
      rol: userData['rol'],
    );

    // Guardar sesión
    await authManager.guardarSesion(usuario, userData['token']);

    // Navegar a home (ejemplo)
    // Navigator.pushReplacement(context, ...);
  } else {
    // Login fallido
    print('❌ Error: ${result['message']}');
    
    // Mostrar error al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// ============================================================================
// EJEMPLO 2: REGISTRO COMPLETO
// ============================================================================
Future<void> ejemploRegistro(BuildContext context) async {
  final authService = AuthService();
  final authManager = AuthManager();

  // Hacer registro
  final result = await authService.register(
    username: 'maria',
    correo: 'maria@example.com',
    password: 'password456',
    rol: 'USER', // Opcional, por defecto es 'USER'
  );

  if (result['success']) {
    // Registro exitoso
    final userData = result['data'];
    
    print('✅ Registro exitoso!');
    
    // Crear objeto Usuario
    final usuario = Usuario(
      id: userData['id'],
      username: userData['username'],
      correo: userData['correo'],
      rol: userData['rol'],
    );

    // Guardar sesión
    await authManager.guardarSesion(usuario, userData['token']);

    // Mostrar mensaje de bienvenida
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Bienvenido a EasySave!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navegar a home
    // Navigator.pushReplacement(context, ...);
  } else {
    // Registro fallido
    print('❌ Error: ${result['message']}');
  }
}

// ============================================================================
// EJEMPLO 3: HACER PETICIÓN AUTENTICADA (Método 1)
// ============================================================================
Future<void> ejemploPeticionConAuthService() async {
  final authService = AuthService();

  try {
    // Obtener lista de usuarios (endpoint protegido)
    final response = await authService.authenticatedRequest(
      url: 'http://localhost:8080/api/v1/usuario-service/usuarios',
      method: 'GET',
    );

    if (response.statusCode == 200) {
      print('✅ Usuarios obtenidos exitosamente');
      print(response.body);
    } else if (response.statusCode == 401) {
      print('❌ Token inválido o expirado');
      // Cerrar sesión y volver al login
    } else {
      print('❌ Error: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error de conexión: $e');
  }
}

// ============================================================================
// EJEMPLO 4: HACER PETICIÓN AUTENTICADA (Método 2 - Recomendado)
// ============================================================================
Future<void> ejemploPeticionConUsuarioService() async {
  final usuarioService = UsuarioService();

  try {
    // El UsuarioService ya incluye automáticamente el token en los headers
    final ingresos = await usuarioService.obtenerIngresos(1);
    
    print('✅ Ingresos obtenidos: ${ingresos.length}');
    for (var ingreso in ingresos) {
      print('- ${ingreso['nombreIngreso']}: \$${ingreso['valorIngreso']}');
    }
  } catch (e) {
    print('❌ Error: $e');
    
    if (e.toString().contains('No autorizado')) {
      // Token expirado, cerrar sesión
      final authService = AuthService();
      await authService.logout();
      // Navegar al login
    }
  }
}

// ============================================================================
// EJEMPLO 5: VERIFICAR SI ESTÁ AUTENTICADO
// ============================================================================
Future<void> ejemploVerificarAutenticacion() async {
  final authService = AuthService();
  final authManager = AuthManager();

  // Opción 1: Verificar si tiene token
  final isAuth = await authService.isAuthenticated();
  print('¿Está autenticado? $isAuth');

  // Opción 2: Verificar sesión completa
  final tieneSesion = await authManager.tieneSesionActiva();
  print('¿Tiene sesión activa? $tieneSesion');

  // Opción 3: Obtener usuario actual
  final usuario = await authManager.obtenerUsuarioActual();
  if (usuario != null) {
    print('Usuario actual: ${usuario.username}');
  } else {
    print('No hay usuario en sesión');
  }
}

// ============================================================================
// EJEMPLO 6: CERRAR SESIÓN
// ============================================================================
Future<void> ejemploCerrarSesion(BuildContext context) async {
  final authService = AuthService();

  // Cerrar sesión (elimina token y datos)
  await authService.logout();
  
  print('✅ Sesión cerrada');

  // Navegar al login
  // Navigator.pushAndRemoveUntil(
  //   context,
  //   MaterialPageRoute(builder: (context) => LoginScreen()),
  //   (route) => false,
  // );
}

// ============================================================================
// EJEMPLO 7: CREAR INGRESO CON AUTENTICACIÓN
// ============================================================================
Future<void> ejemploCrearIngreso() async {
  final usuarioService = UsuarioService();
  final authManager = AuthManager();

  try {
    // Obtener ID del usuario actual
    final usuarioId = await authManager.obtenerUsuarioId();
    
    if (usuarioId == null) {
      print('❌ No hay usuario en sesión');
      return;
    }

    // Crear ingreso
    final nuevoIngreso = {
      'nombreIngreso': 'Salario Mensual',
      'valorIngreso': 3000000.0,
      'estadoIngreso': 'fijo',
    };

    final ingresoCreado = await usuarioService.agregarIngreso(
      usuarioId,
      nuevoIngreso,
    );

    print('✅ Ingreso creado exitosamente!');
    print('ID: ${ingresoCreado['id']}');
    print('Nombre: ${ingresoCreado['nombreIngreso']}');
    print('Valor: \$${ingresoCreado['valorIngreso']}');
  } catch (e) {
    print('❌ Error al crear ingreso: $e');
  }
}

// ============================================================================
// EJEMPLO 8: OBTENER RESUMEN FINANCIERO
// ============================================================================
Future<void> ejemploResumenFinanciero() async {
  final usuarioService = UsuarioService();
  final authManager = AuthManager();

  try {
    final usuarioId = await authManager.obtenerUsuarioId();
    
    if (usuarioId == null) {
      print('❌ No hay usuario en sesión');
      return;
    }

    // Obtener resumen financiero (requiere autenticación)
    final resumen = await usuarioService.obtenerBalance(usuarioId);

    print('📊 RESUMEN FINANCIERO');
    print('━━━━━━━━━━━━━━━━━━━━━━');
    print('Total Ingresos: \$${resumen['totalIngresos']}');
    print('Total Gastos: \$${resumen['totalGastos']}');
    print('Balance: \$${resumen['balance']}');
    print('━━━━━━━━━━━━━━━━━━━━━━');
  } catch (e) {
    print('❌ Error: $e');
  }
}

// ============================================================================
// EJEMPLO 9: MANEJAR TOKEN EXPIRADO
// ============================================================================
Future<void> ejemploManejarTokenExpirado(BuildContext context) async {
  final usuarioService = UsuarioService();
  final authService = AuthService();

  try {
    // Intentar obtener datos
    final usuarios = await usuarioService.listarUsuarios();
    print('✅ Datos obtenidos: ${usuarios.length} usuarios');
  } catch (e) {
    final errorMsg = e.toString();
    
    // Verificar si es error de autenticación
    if (errorMsg.contains('No autorizado') || 
        errorMsg.contains('401') ||
        errorMsg.contains('Inicia sesión')) {
      
      print('🔒 Token expirado o inválido');
      
      // Cerrar sesión
      await authService.logout();
      
      // Mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu sesión ha expirado. Por favor inicia sesión nuevamente.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
      
      // Navegar al login
      // Navigator.pushAndRemoveUntil(...);
    } else {
      print('❌ Otro error: $errorMsg');
    }
  }
}

// ============================================================================
// EJEMPLO 10: OBTENER Y MOSTRAR TOKEN (Para debugging)
// ============================================================================
Future<void> ejemploMostrarToken() async {
  final authManager = AuthManager();

  final token = await authManager.obtenerToken();
  
  if (token != null) {
    print('🔑 Token JWT:');
    print(token);
    print('');
    print('Longitud: ${token.length} caracteres');
    print('Primeros 20 caracteres: ${token.substring(0, 20)}...');
  } else {
    print('❌ No hay token guardado');
  }
}
