import 'dart:io';
import 'package:flutter/material.dart';
import '../services/face_auth_service.dart';
import '../services/auth_manager.dart';
import '../widgets/face_capture_widget.dart';
import 'home_screen.dart';

/// Pantalla de login con reconocimiento facial
/// 
/// Permite al usuario autenticarse mediante su rostro,
/// sin necesidad de contraseña
class FaceLoginScreen extends StatefulWidget {
  const FaceLoginScreen({Key? key}) : super(key: key);
  
  @override
  State<FaceLoginScreen> createState() => _FaceLoginScreenState();
}

class _FaceLoginScreenState extends State<FaceLoginScreen> {
  final _usernameController = TextEditingController();
  final FaceAuthService _faceAuthService = FaceAuthService();
  final AuthManager _authManager = AuthManager();
  
  File? _capturedImage;
  bool _isLoading = false;
  bool _showUsernameField = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Facial'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono y título
              Icon(
                Icons.face,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Autenticación Facial',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Inicia sesión usando tu rostro',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // Opción de usar username
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Especificar usuario',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Más rápido si conoces tu nombre de usuario',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _showUsernameField,
                  onChanged: (value) {
                    setState(() {
                      _showUsernameField = value;
                      if (!value) {
                        _usernameController.clear();
                      }
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Campo de username (opcional)
              if (_showUsernameField)
                Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de usuario',
                        hintText: 'Opcional - deja vacío para buscar por rostro',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: _usernameController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _usernameController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              
              // Información
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _showUsernameField && _usernameController.text.isEmpty
                            ? 'Puedes ingresar tu usuario para una autenticación más rápida'
                            : _showUsernameField
                                ? 'Solo verificaremos tu rostro contra el usuario especificado'
                                : 'Buscaremos tu rostro entre todos los usuarios registrados',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Captura facial
              Container(
                height: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _capturedImage == null
                    ? FaceCaptureWidget(
                        onImageCaptured: (image) {
                          setState(() {
                            _capturedImage = image;
                          });
                        },
                        instructionText: 'Captura tu rostro para iniciar sesión',
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [
                            Image.file(
                              _capturedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            
                            // Overlay con información
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Botón para tomar otra foto
                            Positioned(
                              top: 16,
                              right: 16,
                              child: FloatingActionButton.small(
                                heroTag: 'retake',
                                onPressed: () {
                                  setState(() {
                                    _capturedImage = null;
                                  });
                                },
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.refresh,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            
                            // Botones de acción
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                children: [
                                  const Text(
                                    'Imagen capturada ✓',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _login,
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.login),
                                    label: Text(
                                      _isLoading
                                          ? 'Verificando...'
                                          : 'Iniciar Sesión con Rostro',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      minimumSize: const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              
              const SizedBox(height: 20),
              
              // Divider
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'o',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Botón para login tradicional
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Usar contraseña tradicional'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _login() async {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, captura tu rostro primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final username = _showUsernameField && _usernameController.text.isNotEmpty
          ? _usernameController.text.trim()
          : null;
      
      print('[FACE LOGIN] Iniciando login${username != null ? " para: $username" : " sin usuario especificado"}');
      
      // Login con reconocimiento facial
      final result = await _faceAuthService.loginWithFace(
        username: username,
        imageFile: _capturedImage!,
      );
      
      // Convertir a Usuario y guardar sesión
      final usuario = _faceAuthService.usuarioFromResponse(result);
      await _authManager.guardarSesion(usuario);
      
      if (mounted) {
        // Mostrar mensaje de bienvenida
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('¡Bienvenido ${usuario.username}! 👋'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navegar al home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(usuario: usuario),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _capturedImage = null;
                });
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
