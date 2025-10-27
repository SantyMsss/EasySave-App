# ✅ Checklist de Verificación - Implementación JWT

## 🔍 Verificación Pre-Despliegue

### Backend Spring Boot

- [ ] El backend está corriendo en `http://localhost:8080`
- [ ] CORS está configurado correctamente
- [ ] Los endpoints `/api/v1/auth/register` y `/api/v1/auth/login` funcionan
- [ ] Los endpoints de usuario-service requieren autenticación JWT
- [ ] El token JWT tiene configurado el tiempo de expiración
- [ ] El secret del JWT está configurado en `application.properties`

**Probar manualmente con curl:**
```bash
# Registro
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test",
    "correo": "test@example.com",
    "password": "test123",
    "rol": "USER"
  }'

# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test",
    "password": "test123"
  }'

# Guardar el token recibido y probar endpoint protegido
curl -X GET http://localhost:8080/api/v1/usuario-service/usuarios/1 \
  -H "Authorization: Bearer TU_TOKEN_AQUI"
```

---

### Flutter App

#### Dependencias
- [ ] `flutter_secure_storage: ^9.0.0` instalado
- [ ] `http: ^1.1.0` instalado
- [ ] `shared_preferences: ^2.2.2` instalado (para compatibilidad)
- [ ] `intl: ^0.19.0` instalado

**Verificar:**
```bash
flutter pub get
flutter pub outdated
```

#### Archivos Creados
- [ ] `lib/services/auth_service.dart` existe
- [ ] `lib/services/auth_service_examples.dart` existe
- [ ] `JWT_IMPLEMENTATION.md` existe
- [ ] `CHANGES_SUMMARY.md` existe

#### Archivos Modificados
- [ ] `lib/config/app_config.dart` - URLs actualizadas
- [ ] `lib/models/usuario.dart` - password opcional
- [ ] `lib/services/auth_manager.dart` - usa flutter_secure_storage
- [ ] `lib/services/usuario_service.dart` - headers con JWT
- [ ] `lib/screens/login_screen.dart` - usa AuthService
- [ ] `lib/screens/registro_screen.dart` - usa AuthService

---

## 🧪 Tests Funcionales

### 1. Test de Registro
- [ ] Abrir la app
- [ ] Ir a "Regístrate"
- [ ] Ingresar datos válidos
- [ ] Click en "Registrarse"
- [ ] ✅ Debería mostrar "Registro exitoso" y navegar a HomeScreen
- [ ] ✅ El token debería estar guardado en secure storage

**Cómo verificar el token:**
```dart
// Agregar este código temporalmente en HomeScreen
final authService = AuthService();
final token = await authService.getToken();
print('Token guardado: $token');
```

### 2. Test de Login
- [ ] Cerrar sesión (si estás logueado)
- [ ] Ingresar username y password válidos
- [ ] Click en "Iniciar Sesión"
- [ ] ✅ Debería navegar a HomeScreen
- [ ] ✅ El token debería estar guardado

### 3. Test de Persistencia de Sesión
- [ ] Iniciar sesión
- [ ] Cerrar completamente la app (no solo minimizar)
- [ ] Volver a abrir la app
- [ ] ✅ Debería ir directamente a HomeScreen sin pedir login
- [ ] ✅ Los datos del usuario deberían estar cargados

### 4. Test de Peticiones Autenticadas
- [ ] Iniciar sesión
- [ ] Ir a la sección de Ingresos
- [ ] Agregar un nuevo ingreso
- [ ] ✅ Debería crearse correctamente
- [ ] Ir a la sección de Gastos
- [ ] Agregar un nuevo gasto
- [ ] ✅ Debería crearse correctamente
- [ ] Ver el resumen financiero
- [ ] ✅ Debería mostrar los totales correctos

### 5. Test de Error de Autenticación
**Opción A: Token inválido manual**
- [ ] Iniciar sesión
- [ ] Modificar manualmente el token en el código:
  ```dart
  await storage.write(key: 'jwt_token', value: 'token_invalido');
  ```
- [ ] Intentar agregar un ingreso
- [ ] ✅ Debería mostrar error "No autorizado"

**Opción B: Token expirado**
- [ ] Cambiar el tiempo de expiración del token en el backend a 1 minuto
- [ ] Iniciar sesión
- [ ] Esperar 2 minutos
- [ ] Intentar agregar un ingreso
- [ ] ✅ Debería mostrar error "No autorizado"

### 6. Test de Cerrar Sesión
- [ ] Iniciar sesión
- [ ] Ir a HomeScreen
- [ ] Click en botón de cerrar sesión (si existe)
- [ ] ✅ Debería limpiar el token y datos del usuario
- [ ] ✅ Debería navegar al LoginScreen

### 7. Test de Credenciales Incorrectas
**Login:**
- [ ] Intentar login con username inexistente
- [ ] ✅ Debería mostrar "Usuario no encontrado" o "Credenciales inválidas"
- [ ] Intentar login con password incorrecta
- [ ] ✅ Debería mostrar "Credenciales inválidas"

**Registro:**
- [ ] Intentar registrar un username ya existente
- [ ] ✅ Debería mostrar "El username ya está en uso"
- [ ] Intentar registrar un correo ya existente
- [ ] ✅ Debería mostrar "El correo ya está registrado"

---

## 🔒 Verificación de Seguridad

### Almacenamiento
- [ ] El token JWT se guarda en `flutter_secure_storage` (cifrado)
- [ ] El password NO se almacena después del login
- [ ] Los datos sensibles NO están en logs de producción

**Verificar:**
```dart
// NO debería aparecer el password en ningún print() o log
// Revisar todos los archivos .dart
```

### Headers HTTP
- [ ] Todas las peticiones a endpoints protegidos incluyen `Authorization: Bearer {token}`
- [ ] El token NO se envía en la URL
- [ ] El token NO se envía en el body (solo en headers)

**Verificar en usuario_service.dart:**
```dart
// Todas las peticiones deberían tener:
final headers = await _getAuthHeaders();
// Y ese método incluye: 'Authorization': 'Bearer $token'
```

---

## 🌐 Configuración de Red

### Emulador Android
- [ ] Usar `http://10.0.2.2:8080` en lugar de `localhost`
- [ ] Verificar en `lib/config/app_config.dart`

### iOS Simulator
- [ ] Usar `http://localhost:8080`
- [ ] Verificar en `lib/config/app_config.dart`

### Dispositivo Físico
- [ ] Encontrar la IP de tu máquina:
  ```bash
  # Windows
  ipconfig
  # Mac/Linux
  ifconfig
  ```
- [ ] Usar `http://TU_IP:8080` (ej: `http://192.168.1.100:8080`)
- [ ] Backend debe permitir conexiones desde esa IP
- [ ] Verificar firewall del sistema

---

## 📱 Pruebas en Diferentes Plataformas

### Android
- [ ] Emulador Android funciona
- [ ] Dispositivo físico Android funciona
- [ ] No hay errores de permisos de red

### iOS
- [ ] Simulator iOS funciona
- [ ] Dispositivo físico iOS funciona
- [ ] Configurado `NSAppTransportSecurity` si usas HTTP

### Web (opcional)
- [ ] CORS configurado en el backend
- [ ] La app web funciona correctamente

---

## 📊 Monitoreo y Logs

### Logs de Flutter
- [ ] Revisar logs durante login
- [ ] Revisar logs durante registro
- [ ] Revisar logs de peticiones HTTP
- [ ] No hay errores en la consola

**Activar logs detallados:**
```bash
flutter run --verbose
```

### Logs del Backend
- [ ] Ver logs de Spring Boot durante autenticación
- [ ] Verificar que se genere el token correctamente
- [ ] Verificar que se valide el token en cada petición

---

## ✅ Checklist Final

- [ ] ✅ Todas las pruebas funcionales pasaron
- [ ] ✅ No hay errores de compilación
- [ ] ✅ No hay warnings importantes
- [ ] ✅ La persistencia de sesión funciona
- [ ] ✅ El manejo de errores es adecuado
- [ ] ✅ La UX es fluida (sin delays innecesarios)
- [ ] ✅ Los tokens se guardan de forma segura
- [ ] ✅ La documentación está completa

---

## 🎯 Mejoras Futuras (Opcional)

- [ ] Implementar Refresh Token
- [ ] Agregar biometría para login rápido
- [ ] Implementar interceptor HTTP global
- [ ] Agregar indicador de tiempo de expiración del token
- [ ] Implementar logout en todas las pantallas
- [ ] Agregar pruebas unitarias
- [ ] Agregar pruebas de integración

---

## 📝 Notas

**Fecha de implementación:** _______________________

**Versión de la app:** 1.0.0

**Versión del backend:** _______________________

**Observaciones:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## ✨ ¡Felicitaciones!

Si todos los checks están marcados, tu implementación de JWT está completa y lista para usar. 🚀

**Próximos pasos:**
1. Hacer commit de los cambios
2. Probar en diferentes dispositivos
3. Considerar implementar las mejoras futuras
4. Mantener la documentación actualizada

¡Excelente trabajo! 💪
