# 📝 Resumen de Implementación JWT en EasySave Flutter

## ✅ Archivos Creados

1. **`lib/services/auth_service.dart`**
   - Nuevo servicio para autenticación JWT
   - Métodos: `register()`, `login()`, `logout()`, `authenticatedRequest()`
   - Usa `flutter_secure_storage` para almacenar tokens de forma segura

2. **`lib/services/auth_service_examples.dart`**
   - 10 ejemplos completos de uso del AuthService
   - Casos de uso: login, registro, peticiones autenticadas, manejo de errores

3. **`JWT_IMPLEMENTATION.md`**
   - Documentación completa de la implementación
   - Diagrama de flujo de autenticación
   - Guía de migración del sistema anterior

## 🔄 Archivos Modificados

### 1. **`lib/config/app_config.dart`**
**Cambios:**
- ✅ Reorganización de URLs base
- ✅ Nueva constante `authUrl` para endpoints de autenticación
- ✅ Separación de `usuarioServiceUrl` y `baseUrl`

**Antes:**
```dart
static const String baseUrl = 'http://localhost:8080/api/v1/usuario-service';
```

**Ahora:**
```dart
static const String baseUrl = 'http://localhost:8080/api/v1';
static const String usuarioServiceUrl = '$baseUrl/usuario-service';
static const String authUrl = '$baseUrl/auth';
```

---

### 2. **`lib/models/usuario.dart`**
**Cambios:**
- ✅ Campo `password` ahora es opcional (`String?`)
- ✅ El `toJson()` solo incluye password si no es null

**Razón:** El backend JWT no devuelve el password en las respuestas

**Antes:**
```dart
final String password;
required this.password,
```

**Ahora:**
```dart
final String? password; // Opcional
this.password, // No required
```

---

### 3. **`lib/services/auth_manager.dart`**
**Cambios:**
- ✅ Migrado de `shared_preferences` a `flutter_secure_storage`
- ✅ Método `guardarSesion()` ahora requiere el token JWT
- ✅ Nuevo método `obtenerToken()`
- ✅ Nuevo método `obtenerUsuarioId()`

**Antes:**
```dart
Future<void> guardarSesion(Usuario usuario) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_keyUserId, usuario.id!);
  // ...
}
```

**Ahora:**
```dart
Future<void> guardarSesion(Usuario usuario, String token) async {
  await storage.write(key: _keyUserId, value: usuario.id.toString());
  await storage.write(key: _keyJwtToken, value: token);
  // ...
}
```

---

### 4. **`lib/services/usuario_service.dart`**
**Cambios:**
- ✅ Nuevo método privado `_getAuthHeaders()` que incluye el token JWT
- ✅ Todas las peticiones HTTP ahora usan headers autenticados
- ✅ Manejo de errores 401 (No autorizado)
- ✅ Métodos antiguos marcados como `@Deprecated`

**Agregado a cada petición:**
```dart
final headers = await _getAuthHeaders();
final response = await http.get(
  Uri.parse('$baseUrl/usuarios'),
  headers: headers, // ← Incluye Authorization: Bearer {token}
);

if (response.statusCode == 401) {
  throw Exception('No autorizado. Inicia sesión nuevamente.');
}
```

**Métodos deprecados:**
- `login()` → Usar `AuthService.login()`
- `existeUsername()` → Usar `AuthService.register()` que valida automáticamente
- `existeCorreo()` → Usar `AuthService.register()` que valida automáticamente

---

### 5. **`lib/screens/login_screen.dart`**
**Cambios:**
- ✅ Usa `AuthService` en lugar de `UsuarioService`
- ✅ Guarda el token JWT al iniciar sesión
- ✅ Maneja respuestas del formato `{success, data, message}`

**Antes:**
```dart
final usuario = await _usuarioService.login(username, password);
await _authManager.guardarSesion(usuario);
```

**Ahora:**
```dart
final result = await _authService.login(username: username, password: password);
if (result['success']) {
  final usuario = Usuario(
    id: result['data']['id'],
    username: result['data']['username'],
    correo: result['data']['correo'],
    rol: result['data']['rol'],
  );
  await _authManager.guardarSesion(usuario, result['data']['token']);
}
```

---

### 6. **`lib/screens/registro_screen.dart`**
**Cambios:**
- ✅ Usa `AuthService.register()` en lugar de `UsuarioService.crearUsuario()`
- ✅ Eliminadas las validaciones manuales de username/correo duplicados
- ✅ Guarda el token JWT al registrarse

**Antes:**
```dart
final existeUsername = await _usuarioService.existeUsername(username);
if (existeUsername) throw Exception('Usuario ya existe');

final usuario = await _usuarioService.crearUsuario(nuevoUsuario);
await _authManager.guardarSesion(usuario);
```

**Ahora:**
```dart
final result = await _authService.register(
  username: username,
  correo: correo,
  password: password,
);
if (result['success']) {
  final usuario = Usuario(...);
  await _authManager.guardarSesion(usuario, result['data']['token']);
}
```

---

## 🔐 Flujo de Autenticación

### Login:
```
Usuario → LoginScreen → AuthService.login() 
  ↓
Backend Spring Boot (/api/v1/auth/login)
  ↓
Respuesta: {token, id, username, correo, rol}
  ↓
AuthManager.guardarSesion(usuario, token)
  ↓
flutter_secure_storage guarda:
  - jwt_token
  - user_id
  - username
  - correo
  - rol
  - user_data (JSON)
  - is_logged_in
  ↓
Navegación a HomeScreen
```

### Peticiones Protegidas:
```
UsuarioService.obtenerIngresos(usuarioId)
  ↓
_getAuthHeaders() → Obtiene token del AuthManager
  ↓
Headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6...'
}
  ↓
http.get(url, headers: headers)
  ↓
Backend valida el token JWT
  ↓
Si válido → Retorna datos (200)
Si inválido → Retorna 401 Unauthorized
```

---

## 🧪 Cómo Probar

1. **Iniciar el backend:**
   ```bash
   cd backend-spring-boot
   mvn spring-boot:run
   ```

2. **Verificar que el backend esté corriendo:**
   - Abrir en navegador: `http://localhost:8080/api/v1/auth/test`
   - Debería retornar error 401 (es normal, requiere token)

3. **Ejecutar la app Flutter:**
   ```bash
   cd easysave
   flutter pub get
   flutter run
   ```

4. **Probar Registro:**
   - Crear un nuevo usuario
   - Verificar que se redirija a HomeScreen
   - Cerrar y volver a abrir la app
   - Debería mantener la sesión

5. **Probar Login:**
   - Cerrar sesión desde la app
   - Iniciar sesión con el usuario creado
   - Verificar que funcione correctamente

6. **Probar Peticiones Autenticadas:**
   - Agregar un ingreso
   - Agregar un gasto
   - Ver el resumen financiero
   - Todas estas operaciones usan el token JWT automáticamente

---

## ⚠️ Notas Importantes

1. **CORS en el Backend**
   - Asegúrate de que el backend tenga CORS configurado correctamente
   - Debe permitir `http://localhost` y el origen de tu app Flutter

2. **URL del Backend**
   - Para emulador Android: `http://10.0.2.2:8080`
   - Para iOS Simulator: `http://localhost:8080`
   - Para dispositivo físico: `http://TU_IP_LOCAL:8080`

3. **Expiración del Token**
   - Por defecto: 24 horas
   - Cuando expira, mostrar error 401 y cerrar sesión

4. **Seguridad**
   - Los tokens se almacenan en `flutter_secure_storage` (cifrado)
   - Nunca almacenar el password en texto plano
   - El password solo se envía durante login/registro

---

## 📚 Próximos Pasos Recomendados

1. ✅ **Implementado:** Autenticación JWT básica
2. ⏳ **Pendiente:** Refresh Token (renovar tokens sin login)
3. ⏳ **Pendiente:** Interceptor HTTP global
4. ⏳ **Pendiente:** Biometría para login rápido
5. ⏳ **Pendiente:** Indicador de tiempo de expiración

---

## 🐛 Troubleshooting

### Error: "No se puede conectar al servidor"
- Verifica que el backend esté corriendo
- Verifica la URL en `app_config.dart`
- Usa `10.0.2.2` para emulador Android

### Error: "No autorizado" después de login
- Verifica que el token se esté guardando correctamente
- Revisa los logs del backend
- Verifica que el secret del JWT sea el mismo

### Error: "Las contraseñas no coinciden"
- El backend JWT no devuelve el password
- El modelo Usuario ahora tiene `password` opcional
- Esto es normal y esperado

---

## 📞 Soporte

Si tienes algún problema:
1. Revisa `JWT_IMPLEMENTATION.md`
2. Revisa los ejemplos en `auth_service_examples.dart`
3. Verifica los logs de la consola de Flutter
4. Verifica los logs del backend de Spring Boot

¡Listo! 🚀
