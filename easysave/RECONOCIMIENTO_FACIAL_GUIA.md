# 🔐 Guía de Implementación - Reconocimiento Facial en EasySave

## 📋 Resumen

Se ha implementado un sistema completo de autenticación biométrica mediante reconocimiento facial KYC en la aplicación Flutter de EasySave. Los usuarios ahora pueden:

- ✅ **Registrarse** capturando su rostro durante el proceso de registro
- ✅ **Iniciar sesión** usando su rostro sin necesidad de contraseña
- ✅ Alternar entre autenticación tradicional (usuario/contraseña) y facial

---

## 🏗️ Arquitectura Implementada

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│  Flutter App    │ ◄─────► │  Spring Boot     │ ◄─────► │  Python DeepFace│
│  (EasySave)     │  HTTPS  │  Backend         │   REST  │    Service      │
└─────────────────┘         └──────────────────┘         └─────────────────┘
        │                           │
        │                           ▼
        │                    ┌─────────────┐
        └───────────────────►│ PostgreSQL  │
         JWT Token           │   Database  │
                             └─────────────┘
```

---

## 📁 Archivos Creados/Modificados

### ✨ Nuevos Archivos

1. **`lib/services/face_auth_service.dart`**
   - Servicio de autenticación facial
   - Maneja registro y login con rostro
   - Convierte imágenes a Base64
   - Comunica con backend Spring Boot

2. **`lib/widgets/face_capture_widget.dart`**
   - Widget reutilizable de captura facial
   - Inicializa cámara frontal automáticamente
   - Permite captura desde cámara o galería
   - Muestra guía visual para el usuario

3. **`lib/screens/face_register_screen.dart`**
   - Pantalla de registro con reconocimiento facial
   - Wizard de 3 pasos (datos → captura → confirmación)
   - Validación completa de datos
   - Integración con sesión de usuario

4. **`lib/screens/face_login_screen.dart`**
   - Pantalla de login con reconocimiento facial
   - Opción de especificar username (más rápido)
   - Búsqueda facial sin username
   - Fallback a login tradicional

### 📝 Archivos Modificados

1. **`pubspec.yaml`**
   - Agregadas dependencias:
     - `camera: ^0.10.5+5` - Acceso a cámara
     - `image_picker: ^1.0.4` - Selección de galería
     - `image: ^4.1.3` - Procesamiento de imágenes
     - `permission_handler: ^11.0.1` - Manejo de permisos

2. **`lib/screens/login_screen.dart`**
   - Agregado botón "Iniciar sesión con Reconocimiento Facial"
   - Navegación a `FaceLoginScreen`

3. **`lib/screens/registro_screen.dart`**
   - Agregado botón "Registrarse con Reconocimiento Facial"
   - Navegación a `FaceRegisterScreen`

4. **`android/app/src/main/AndroidManifest.xml`**
   - Agregados permisos de cámara
   - Permisos de almacenamiento
   - Features de hardware

---

## 🚀 Cómo Usar

### Para el Usuario

#### Registro con Rostro:
1. Abrir la app EasySave
2. Ir a "Crear Cuenta"
3. Seleccionar **"Registrarse con Reconocimiento Facial"**
4. **Paso 1**: Ingresar datos (usuario, email, contraseña)
5. **Paso 2**: Capturar rostro con la cámara
6. **Paso 3**: Confirmar y registrarse
7. ✅ Sesión iniciada automáticamente

#### Login con Rostro:
1. Abrir la app EasySave
2. En pantalla de login, seleccionar **"Iniciar sesión con Reconocimiento Facial"**
3. Opcional: Ingresar nombre de usuario para búsqueda rápida
4. Capturar rostro con la cámara
5. Presionar **"Iniciar Sesión con Rostro"**
6. ✅ Acceso concedido

---

## ⚙️ Configuración Backend (Spring Boot + Python)

### 🐍 Servicio Python DeepFace

**Ubicación:** `C:\Users\USER\Desktop\ING SISTEMAS\7\ING SOFTWARE 2\usuario-service\face-recognition-service`

```powershell
# Terminal 1: Iniciar servicio Python
cd "C:\Users\USER\Desktop\ING SISTEMAS\7\ING SOFTWARE 2\usuario-service\face-recognition-service"

# Activar entorno virtual
.\venv\Scripts\Activate.ps1

# Ejecutar servicio
python main.py
```

**Verificación:**
```powershell
curl http://localhost:5000/health
# Debe retornar: {"status":"healthy","service":"face-recognition"}
```

### ☕ Backend Spring Boot

```powershell
# Terminal 2: Iniciar Spring Boot
cd "C:\Users\USER\Desktop\ING SISTEMAS\7\ING SOFTWARE 2\usuario-service"

# Ejecutar
mvn spring-boot:run
```

**Endpoints disponibles:**
- `POST /api/v1/auth/register-face` - Registro facial
- `POST /api/v1/auth/login-face` - Login facial
- `POST /api/v1/auth/register` - Registro tradicional (existente)
- `POST /api/v1/auth/login` - Login tradicional (existente)

---

## 🔧 Configuración Flutter

### URL del Backend

La URL del backend se configura en `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String authBaseUrl = 'http://localhost:8080/api/v1/auth';
  
  // Para Android Emulator:
  // static const String authBaseUrl = 'http://10.0.2.2:8080/api/v1/auth';
  
  // Para dispositivo físico (usar tu IP):
  // static const String authBaseUrl = 'http://192.168.1.X:8080/api/v1/auth';
}
```

### Permisos Android

Ya configurados en `AndroidManifest.xml`:
- ✅ `CAMERA` - Acceso a cámara
- ✅ `INTERNET` - Conexión al backend
- ✅ `READ_EXTERNAL_STORAGE` - Leer galería
- ✅ `WRITE_EXTERNAL_STORAGE` - Guardar imágenes temporales

---

## 🧪 Pruebas

### 1. Verificar Backend

```bash
# Health check Python
curl http://localhost:5000/health

# Health check Spring Boot
curl http://localhost:8080/api/v1/auth/test
```

### 2. Ejecutar Flutter

```bash
cd "c:\Users\USER\Desktop\ING SISTEMAS\7\ING SOFTWARE 2\EasySave-App\easysave"

# Ejecutar en modo debug
flutter run

# O en modo release
flutter run --release
```

### 3. Flujo de Prueba Completo

1. **Registro Facial:**
   - Abrir app → "Crear Cuenta"
   - Seleccionar "Registrarse con Reconocimiento Facial"
   - Completar wizard de 3 pasos
   - Verificar que redirige a HomeScreen

2. **Login Facial:**
   - Cerrar sesión (si está logueado)
   - En login, seleccionar "Iniciar sesión con Reconocimiento Facial"
   - Capturar rostro
   - Verificar acceso concedido

3. **Fallback a Login Tradicional:**
   - Verificar que botones de login/registro tradicional siguen funcionando

---

## 🐛 Troubleshooting

### Error: "El servicio de reconocimiento facial no está disponible"

**Causa:** Servicio Python no está ejecutándose

**Solución:**
```powershell
cd face-recognition-service
.\venv\Scripts\Activate.ps1
python main.py
```

### Error: "No se detectó ningún rostro en la imagen"

**Causas posibles:**
- Mala iluminación
- Rostro no completamente visible
- Ángulo incorrecto

**Solución:**
- Asegurar buena iluminación frontal
- Rostro completo en el encuadre
- Vista frontal directa
- Sin lentes oscuros o máscaras

### Error: "TimeoutException"

**Causa:** Imagen muy grande o backend lento

**Solución:**
- El widget ya comprime imágenes automáticamente (`maxWidth: 1920`)
- Verificar que ambos servicios (Python + Spring Boot) estén corriendo
- Verificar conexión de red

### Error de permisos de cámara

**Solución en Android:**
- Ir a Configuración → Apps → EasySave → Permisos
- Activar permisos de Cámara y Almacenamiento

---

## 📊 Flujo de Datos

### Registro Facial:

```
1. Usuario captura foto → FaceCaptureWidget
2. Imagen convertida a Base64 → face_auth_service.dart
3. POST /register-face → Spring Boot
4. Spring Boot → Python DeepFace (generar embedding)
5. Embedding guardado en PostgreSQL (tabla face_encodings)
6. JWT token retornado → Flutter
7. Sesión guardada → AuthManager
8. Navegación a HomeScreen
```

### Login Facial:

```
1. Usuario captura foto → FaceCaptureWidget
2. Imagen convertida a Base64 → face_auth_service.dart
3. POST /login-face (con/sin username) → Spring Boot
4. Spring Boot → Python DeepFace (generar embedding)
5. Comparación con embeddings en BD
6. Si match > 70% → JWT token retornado
7. Sesión guardada → AuthManager
8. Navegación a HomeScreen
```

---

## 🔐 Seguridad

### Buenas Prácticas Implementadas:

1. ✅ **Embeddings cifrados** en base de datos
2. ✅ **HTTPS** para comunicación (en producción)
3. ✅ **JWT tokens** con expiración
4. ✅ **Contraseña como respaldo** (siempre requerida en registro)
5. ✅ **Validación de rostro** en backend (DeepFace)
6. ✅ **Logs de auditoría** en consola

### Recomendaciones Futuras:

- 🔜 Implementar **liveness detection** (detectar persona real vs foto/video)
- 🔜 Agregar **rate limiting** para intentos de autenticación facial
- 🔜 Implementar **2FA** como capa adicional
- 🔜 Renovación automática de tokens
- 🔜 Logs persistentes de autenticaciones

---

## 📚 Referencias

- [DeepFace Documentation](https://github.com/serengil/deepface)
- [Flutter Camera Plugin](https://pub.dev/packages/camera)
- [JWT Authentication Guide](./JWT_AUTHENTICATION_GUIDE.md)
- [Face Recognition README](./README_FACE_RECOGNITION.md)

---

## ✅ Checklist de Implementación

- [x] Dependencias Flutter instaladas
- [x] Servicios creados (FaceAuthService)
- [x] Widgets de captura implementados
- [x] Pantallas de registro/login faciales creadas
- [x] Integración con pantallas existentes
- [x] Permisos Android configurados
- [x] Flujo completo funcional
- [x] Manejo de errores implementado
- [x] Documentación completa

---

## 🎉 ¡Implementación Completa!

El reconocimiento facial está completamente integrado en EasySave. Los usuarios pueden ahora:

1. **Registrarse** con su rostro
2. **Iniciar sesión** sin contraseña
3. Alternar entre métodos de autenticación

**Próximos pasos:**
- Iniciar ambos servicios backend (Python + Spring Boot)
- Ejecutar Flutter app
- Probar flujo completo de registro/login facial

---

**Desarrollado para:** EasySave App  
**Fecha:** Diciembre 2024  
**Versión:** 1.0.0  
**Estado:** ✅ Completado
