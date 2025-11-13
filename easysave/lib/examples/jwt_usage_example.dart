import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';

/// Ejemplo de uso de JWT Authentication en EasySave
/// 
/// Este archivo muestra cómo usar el servicio de autenticación JWT
/// para registro, login y consumo de APIs protegidas.
class JwtUsageExample {
  final AuthService authService = AuthService();
  final UsuarioService usuarioService = UsuarioService();

  /// EJEMPLO 1: Registro de nuevo usuario
  Future<void> ejemploRegistro() async {
    try {
      final usuario = await authService.register(
        username: 'juan_perez',
        correo: 'juan@example.com',
        password: 'password123',
        rol: 'USER',
      );

      print('✅ Usuario registrado exitosamente');
      print('ID: ${usuario.id}');
      print('Username: ${usuario.username}');
      print('Correo: ${usuario.correo}');
      print('Rol: ${usuario.rol}');
      
      // El token JWT ya está guardado automáticamente
    } catch (e) {
      print('❌ Error en registro: $e');
    }
  }

  /// EJEMPLO 2: Login de usuario existente
  Future<void> ejemploLogin() async {
    try {
      final usuario = await authService.login(
        username: 'juan_perez',
        password: 'password123',
      );

      print('✅ Login exitoso');
      print('ID: ${usuario.id}');
      print('Username: ${usuario.username}');
      
      // El token JWT ya está guardado automáticamente
    } catch (e) {
      print('❌ Error en login: $e');
    }
  }

  /// EJEMPLO 3: Verificar autenticación
  Future<void> ejemploVerificarAuth() async {
    final isAuthenticated = await authService.isAuthenticated();
    
    if (isAuthenticated) {
      print('✅ Usuario autenticado');
      
      // Obtener el token guardado
      final token = await authService.getToken();
      print('Token JWT: ${token?.substring(0, 20)}...');
      
      // Obtener el ID del usuario
      final userId = await authService.getUserId();
      print('User ID: $userId');
    } else {
      print('❌ No hay sesión activa');
    }
  }

  /// EJEMPLO 4: Consumir API protegida - Obtener resumen financiero
  Future<void> ejemploObtenerResumen(BuildContext context) async {
    try {
      // Obtener el ID del usuario actual
      final userId = await authService.getUserId();
      
      if (userId == null) {
        throw Exception('No hay sesión activa');
      }

      // Llamar a API protegida (incluye automáticamente el token JWT)
      final resumen = await usuarioService.obtenerBalance(userId);
      
      print('✅ Resumen financiero obtenido');
      print('Total Ingresos: ${resumen['totalIngresos']}');
      print('Total Gastos: ${resumen['totalGastos']}');
      print('Balance: ${resumen['balance']}');
    } catch (e) {
      print('❌ Error: $e');
      
      // Si el error es de autenticación (401), el token expiró
      if (e.toString().contains('Sesión expirada')) {
        // Redirigir al login
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }
  }

  /// EJEMPLO 5: Agregar ingreso (API protegida)
  Future<void> ejemploAgregarIngreso() async {
    try {
      final userId = await authService.getUserId();
      
      if (userId == null) {
        throw Exception('No hay sesión activa');
      }

      final nuevoIngreso = {
        'nombreIngreso': 'Salario Enero',
        'valorIngreso': 3000.0,
        'estadoIngreso': 'Recibido',
      };

      final ingreso = await usuarioService.agregarIngreso(userId, nuevoIngreso);
      
      print('✅ Ingreso agregado exitosamente');
      print('ID: ${ingreso['id']}');
      print('Nombre: ${ingreso['nombreIngreso']}');
    } catch (e) {
      print('❌ Error al agregar ingreso: $e');
    }
  }

  /// EJEMPLO 6: Agregar gasto (API protegida)
  Future<void> ejemploAgregarGasto() async {
    try {
      final userId = await authService.getUserId();
      
      if (userId == null) {
        throw Exception('No hay sesión activa');
      }

      final nuevoGasto = {
        'nombreGasto': 'Supermercado',
        'valorGasto': 150.0,
        'estadoGasto': 'Pagado',
      };

      final gasto = await usuarioService.agregarGasto(userId, nuevoGasto);
      
      print('✅ Gasto agregado exitosamente');
      print('ID: ${gasto['id']}');
      print('Nombre: ${gasto['nombreGasto']}');
    } catch (e) {
      print('❌ Error al agregar gasto: $e');
    }
  }

  /// EJEMPLO 7: Logout
  Future<void> ejemploLogout() async {
    try {
      await authService.logout();
      print('✅ Sesión cerrada exitosamente');
      print('Token JWT eliminado');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
    }
  }

  /// EJEMPLO 8: Petición autenticada manual (método avanzado)
  Future<void> ejemploPeticionManual() async {
    try {
      final response = await authService.authenticatedRequest(
        url: 'https://easysave-usuario-service-production.up.railway.app/api/v1/usuario-service/usuarios',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        print('✅ Petición exitosa');
        print('Response: ${response.body}');
      } else {
        print('❌ Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en petición: $e');
    }
  }

  /// EJEMPLO 9: Flujo completo de autenticación
  Future<void> flujoCompletoAuth(BuildContext context) async {
    try {
      // 1. Registrar usuario
      print('📝 Paso 1: Registrando usuario...');
      final usuario = await authService.register(
        username: 'maria_garcia',
        correo: 'maria@example.com',
        password: 'secure123',
      );
      print('✅ Usuario registrado: ${usuario.username}');

      // 2. Verificar que está autenticado
      print('\n🔐 Paso 2: Verificando autenticación...');
      final isAuth = await authService.isAuthenticated();
      print('✅ Autenticado: $isAuth');

      // 3. Obtener resumen financiero
      print('\n💰 Paso 3: Obteniendo resumen financiero...');
      final resumen = await usuarioService.obtenerBalance(usuario.id!);
      print('✅ Balance: ${resumen['balance']}');

      // 4. Agregar un ingreso
      print('\n➕ Paso 4: Agregando ingreso...');
      await usuarioService.agregarIngreso(usuario.id!, {
        'nombreIngreso': 'Freelance',
        'valorIngreso': 500.0,
        'estadoIngreso': 'Recibido',
      });
      print('✅ Ingreso agregado');

      // 5. Cerrar sesión
      print('\n👋 Paso 5: Cerrando sesión...');
      await authService.logout();
      print('✅ Sesión cerrada');

      // 6. Intentar login
      print('\n🔑 Paso 6: Iniciando sesión nuevamente...');
      await authService.login(
        username: 'maria_garcia',
        password: 'secure123',
      );
      print('✅ Login exitoso');

      print('\n🎉 ¡Flujo completo ejecutado exitosamente!');
    } catch (e) {
      print('❌ Error en flujo: $e');
    }
  }
}

// Widget de ejemplo para usar en la UI
class JwtExampleWidget extends StatelessWidget {
  const JwtExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final example = JwtUsageExample();

    return Scaffold(
      appBar: AppBar(title: const Text('JWT Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => example.ejemploRegistro(),
            child: const Text('1. Ejemplo Registro'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => example.ejemploLogin(),
            child: const Text('2. Ejemplo Login'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => example.ejemploVerificarAuth(),
            child: const Text('3. Verificar Autenticación'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => example.ejemploObtenerResumen(context),
            child: const Text('4. Obtener Resumen'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => example.ejemploAgregarIngreso(),
            child: const Text('5. Agregar Ingreso'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => example.ejemploAgregarGasto(),
            child: const Text('6. Agregar Gasto'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => example.ejemploLogout(),
            child: const Text('7. Logout'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => example.flujoCompletoAuth(context),
            child: const Text('9. Flujo Completo'),
          ),
        ],
      ),
    );
  }
}
