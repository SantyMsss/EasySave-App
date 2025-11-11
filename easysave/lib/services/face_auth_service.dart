import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../models/usuario.dart';

/// Servicio de autenticación con reconocimiento facial
class FaceAuthService {
  static final String baseUrl = 'https://postmundane-errol-askew.ngrok-free.dev/api/v1/auth';

  /// Comprime y optimiza la imagen para envío
  Future<String> _prepareImageBase64(File imageFile) async {
    try {
      // Leer los bytes originales
      final bytes = await imageFile.readAsBytes();
      print('[FACE AUTH] Imagen original: ${bytes.length} bytes');
      
      // Decodificar la imagen
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }
      
      print('[FACE AUTH] Dimensiones originales: ${image.width}x${image.height}');
      
      // Redimensionar si es muy grande (máximo 800px de ancho)
      img.Image resized = image;
      if (image.width > 800) {
        resized = img.copyResize(image, width: 800);
        print('[FACE AUTH] Imagen redimensionada a: ${resized.width}x${resized.height}');
      }
      
      // Comprimir a JPEG con calidad 85%
      final compressedBytes = img.encodeJpg(resized, quality: 85);
      print('[FACE AUTH] Imagen comprimida: ${compressedBytes.length} bytes');
      
      // Convertir a Base64
      final base64Image = base64Encode(compressedBytes);
      print('[FACE AUTH] Base64 generado: ${base64Image.length} caracteres');
      
      return base64Image;
    } catch (e) {
      print('[FACE AUTH] Error al preparar imagen: $e');
      rethrow;
    }
  }

  /// Registro de usuario con reconocimiento facial
  /// 
  /// Captura la imagen facial del usuario durante el registro
  /// y la envía al backend para su procesamiento
  Future<Map<String, dynamic>> registerWithFace({
    required String username,
    required String correo,
    required String password,
    required File imageFile,
    String rol = 'USER',
  }) async {
    try {
      print('[FACE AUTH] Iniciando registro facial para: $username');
      
      // Preparar y comprimir imagen
      final base64Image = await _prepareImageBase64(imageFile);
      
      print('[FACE AUTH] Enviando petición al backend...');
      final requestBody = {
        'username': username,
        'correo': correo,
        'password': password,
        'rol': rol,
        'faceImageBase64': 'data:image/jpeg;base64,$base64Image',
      };
      
      print('[FACE AUTH] Request body keys: ${requestBody.keys.join(", ")}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/register-face'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 45)); // Aumentado a 45 segundos
      
      print('[FACE AUTH] Status Code: ${response.statusCode}');
      print('[FACE AUTH] Response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[FACE AUTH] ✓ Registro facial exitoso');
        return data;
      } else {
        final error = jsonDecode(response.body);
        final errorMsg = error['message'] ?? error['error'] ?? 'Error en el registro facial';
        print('[FACE AUTH] ✗ Error del servidor: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('[FACE AUTH] ✗ Error en registro facial: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('El servidor tardó demasiado en responder. Verifica tu conexión.');
      }
      rethrow;
    }
  }

  /// Login de usuario con reconocimiento facial
  /// 
  /// Autentica al usuario mediante su rostro, sin necesidad de contraseña
  /// [username] es opcional - si se proporciona, solo verifica ese usuario (más rápido)
  Future<Map<String, dynamic>> loginWithFace({
    String? username,
    required File imageFile,
  }) async {
    try {
      print('[FACE AUTH] Iniciando login facial${username != null ? " para: $username" : ""}');
      
      // Convertir imagen a Base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      print('[FACE AUTH] Imagen convertida a Base64 (${bytes.length} bytes)');
      
      final requestBody = <String, dynamic>{
        'faceImageBase64': 'data:image/jpeg;base64,$base64Image',
      };
      
      // Agregar username si está disponible
      if (username != null && username.isNotEmpty) {
        requestBody['username'] = username;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/login-face'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30)); // Mayor timeout para imagen
      
      print('[FACE AUTH] Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Extraer data del objeto de respuesta
        final data = responseData['data'];
        
        print('[FACE AUTH] ✓ Login facial exitoso: ${data['username']}');
        return data;
      } else {
        final error = jsonDecode(response.body);
        final errorMsg = error['message'] ?? 'Error en la autenticación facial';
        print('[FACE AUTH] ✗ Error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('[FACE AUTH] ✗ Error en login facial: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('El servidor tardó demasiado en responder. Intenta con una imagen más pequeña.');
      }
      rethrow;
    }
  }

  /// Convertir respuesta del backend a objeto Usuario
  Usuario usuarioFromResponse(Map<String, dynamic> data) {
    return Usuario(
      id: data['id'],
      username: data['username'],
      correo: data['correo'],
      rol: data['rol'] ?? 'USER',
      password: '', // No se retorna la contraseña
    );
  }
}
