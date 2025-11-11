/// Configuración de constantes para la aplicación
class AppConfig {
  // URL base del API - Usa la IP local para conectar desde dispositivos móviles
  // Cambia 192.168.1.9 por tu IP local si es diferente (usa 'ipconfig' en Windows)
  static final String baseUrl = 'https://postmundane-errol-askew.ngrok-free.dev/api/v1/usuario-service';
  static final String authBaseUrl = 'https://postmundane-errol-askew.ngrok-free.dev/api/v1/auth';
  
  // Endpoints
  static const String usuariosEndpoint = '/usuarios';
  static const String usuarioEndpoint = '/usuario';
  
  // Configuración de la app
  static const String appName = 'EasySave';
  static const String appVersion = '1.0.0';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Mensajes de error comunes
  static const String errorConexion = 'Error de conexión. Verifica tu internet.';
  static const String errorServidor = 'Error en el servidor. Intenta más tarde.';
  static const String errorDatosInvalidos = 'Los datos ingresados no son válidos.';
}
