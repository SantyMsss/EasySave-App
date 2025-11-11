import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

/// Widget para captura de imagen facial
/// 
/// Permite al usuario capturar una foto usando la cámara frontal
/// o seleccionar una imagen desde la galería
class FaceCaptureWidget extends StatefulWidget {
  final Function(File) onImageCaptured;
  final String instructionText;
  
  const FaceCaptureWidget({
    Key? key,
    required this.onImageCaptured,
    this.instructionText = 'Centra tu rostro en el recuadro',
  }) : super(key: key);
  
  @override
  State<FaceCaptureWidget> createState() => _FaceCaptureWidgetState();
}

class _FaceCaptureWidgetState extends State<FaceCaptureWidget> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _initCamera();
  }
  
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras!.isEmpty) {
        print('[FACE CAPTURE] No se encontraron cámaras');
        return;
      }
      
      // Buscar cámara frontal
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      
      print('[FACE CAPTURE] Inicializando cámara: ${frontCamera.name}');
      
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        print('[FACE CAPTURE] Cámara inicializada correctamente');
      }
    } catch (e) {
      print('[FACE CAPTURE] Error al inicializar cámara: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al inicializar la cámara: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) {
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      print('[FACE CAPTURE] Capturando imagen...');
      final image = await _controller!.takePicture();
      print('[FACE CAPTURE] ✓ Imagen capturada: ${image.path}');
      widget.onImageCaptured(File(image.path));
    } catch (e) {
      print('[FACE CAPTURE] ✗ Error al capturar imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al capturar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      print('[FACE CAPTURE] Abriendo galería...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (image != null) {
        print('[FACE CAPTURE] ✓ Imagen seleccionada: ${image.path}');
        widget.onImageCaptured(File(image.path));
      } else {
        print('[FACE CAPTURE] Usuario canceló selección');
      }
    } catch (e) {
      print('[FACE CAPTURE] ✗ Error al seleccionar imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Inicializando cámara...'),
            const SizedBox(height: 24),
            // Botón de galería como alternativa
            OutlinedButton.icon(
              onPressed: _pickImageFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Seleccionar de Galería'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // Vista previa de la cámara
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CameraPreview(_controller!),
              ),
              
              // Overlay con guía facial
              Center(
                child: Container(
                  width: 250,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.7),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
              
              // Indicador de procesamiento
              if (_isProcessing)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Instrucciones
        Text(
          widget.instructionText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '• Buena iluminación\n• Rostro completo visible\n• Sin accesorios que cubran el rostro',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Botones
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Botón galería
            FloatingActionButton(
              heroTag: 'gallery',
              onPressed: _isProcessing ? null : _pickImageFromGallery,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.photo_library,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            // Botón capturar
            FloatingActionButton.large(
              heroTag: 'capture',
              onPressed: _isProcessing ? null : _takePicture,
              child: Icon(
                _isProcessing ? Icons.hourglass_empty : Icons.camera_alt,
                size: 36,
              ),
            ),
            
            // Botón cambiar cámara (si hay múltiples)
            if (_cameras != null && _cameras!.length > 1)
              FloatingActionButton(
                heroTag: 'switch',
                onPressed: _isProcessing ? null : _switchCamera,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.switch_camera,
                  color: Theme.of(context).primaryColor,
                ),
              )
            else
              // Espaciador para mantener el diseño
              const SizedBox(width: 56),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
  
  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1 || _isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final currentLens = _controller!.description.lensDirection;
      final newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection != currentLens,
        orElse: () => _cameras!.first,
      );
      
      await _controller?.dispose();
      
      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('[FACE CAPTURE] Error al cambiar cámara: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
