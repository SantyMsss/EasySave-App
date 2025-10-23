# EasySave - Frontend Flutter

Aplicación móvil/web para gestión de finanzas personales que consume APIs REST de un servicio de usuarios.

## Estructura del Proyecto

```
lib/
├── config/
│   └── app_config.dart          # Configuración de la aplicación
├── models/
│   └── usuario.dart             # Modelo de datos Usuario
├── screens/
│   ├── login_screen.dart        # Pantalla de inicio de sesión
│   ├── registro_screen.dart     # Pantalla de registro
│   └── home_screen.dart         # Pantalla principal
├── services/
│   ├── usuario_service.dart     # Servicio para consumir API
│   └── auth_manager.dart        # Gestor de autenticación
└── main.dart                    # Punto de entrada
```

## Características Implementadas

### 🔐 Autenticación
- **Login**: Inicio de sesión con validación de credenciales
- **Registro**: Creación de nueva cuenta de usuario
- **Persistencia de sesión**: Mantiene la sesión activa usando SharedPreferences
- **Cerrar sesión**: Opción para salir de la cuenta

### 👤 Gestión de Usuario
- Visualización de perfil completo
- Información de contacto (celular, correo)
- Dashboard financiero personalizado

### 💰 Dashboard Financiero
- Resumen de ingresos mensuales
- Resumen de gastos mensuales
- Cálculo automático de balance
- Indicador visual de porcentaje de gastos
- Alertas visuales según el nivel de gasto

## API Consumida

La aplicación consume los siguientes endpoints:

### Base URL
```
http://localhost:8080/api/v1/usuario-service
```

### Endpoints Utilizados

1. **Listar usuarios** (para login)
   - `GET /usuarios`
   - Usado para autenticación y validación

2. **Buscar usuario por ID**
   - `GET /usuarios/{id}`
   - Para obtener información actualizada

3. **Crear usuario** (registro)
   - `POST /usuario`
   - Body: `{ username, correoElectronico, password, celular, ingresos, gastos }`

4. **Actualizar usuario** (preparado para futuras funcionalidades)
   - `PUT /usuario`
   - Body: `{ id, username, correoElectronico, password, celular, ingresos, gastos }`

## Requisitos Previos

- Flutter SDK (>=3.10.0)
- Dart SDK
- API Backend ejecutándose en `http://localhost:8080`
- Android Studio / VS Code con extensiones de Flutter
- Emulador Android/iOS o navegador web

## Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <url-del-repositorio>
   cd easysave
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Verificar instalación**
   ```bash
   flutter doctor
   ```

## Configuración

### Backend API
Asegúrate de que tu API backend esté ejecutándose en:
```
http://localhost:8080/api/v1/usuario-service
```

Si necesitas cambiar la URL base, edita el archivo:
```dart
lib/services/usuario_service.dart
// Línea 6
static const String baseUrl = 'TU_URL_AQUI';
```

## Ejecución

### En Navegador Web (Chrome)
```bash
flutter run -d chrome
```

### En Emulador Android
```bash
flutter run -d android
```

### En Emulador iOS (solo macOS)
```bash
flutter run -d ios
```

### En todos los dispositivos disponibles
```bash
flutter run
```

## Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0                    # Cliente HTTP para consumir APIs
  shared_preferences: ^2.2.2      # Persistencia local de datos
  flutter_secure_storage: ^9.0.0  # Almacenamiento seguro
```

## Uso de la Aplicación

### 1. Registro de Usuario
1. Al abrir la app por primera vez, verás la pantalla de login
2. Toca "Regístrate" en la parte inferior
3. Completa todos los campos requeridos:
   - Usuario (mínimo 3 caracteres)
   - Correo electrónico válido
   - Celular (mínimo 10 dígitos)
   - Contraseña (mínimo 6 caracteres)
   - Confirmar contraseña
   - Ingresos mensuales
   - Gastos mensuales
4. Toca "Registrarse"
5. Serás redirigido automáticamente al dashboard

### 2. Inicio de Sesión
1. Ingresa tu usuario
2. Ingresa tu contraseña
3. Toca "Iniciar Sesión"
4. Si las credenciales son correctas, accederás al dashboard

### 3. Dashboard
- Visualiza tu balance mensual (ingresos - gastos)
- Revisa el porcentaje de gastos respecto a ingresos
- Consulta tu información de contacto
- Cierra sesión desde el botón en la barra superior

## Características de Seguridad

- ✅ Validación de formularios
- ✅ Contraseñas ocultas con opción de visualización
- ✅ Verificación de usuarios duplicados
- ✅ Manejo de errores del servidor
- ✅ Persistencia segura de sesión
- ✅ Timeouts de conexión configurados

## Validaciones Implementadas

### Registro
- Username: mínimo 3 caracteres, único
- Email: formato válido, único
- Celular: mínimo 10 dígitos
- Password: mínimo 6 caracteres
- Confirmación de password
- Ingresos y gastos: valores numéricos válidos

### Login
- Campos requeridos
- Validación de credenciales contra API

## Manejo de Errores

La aplicación maneja los siguientes escenarios:

- ❌ Error de conexión a internet
- ❌ Error 404: Usuario no encontrado
- ❌ Error 400: Datos inválidos
- ❌ Error 409: Usuario/correo ya existe
- ❌ Error 500: Error del servidor
- ❌ Timeout de conexión

Todos los errores se muestran mediante SnackBars informativos.

## Próximas Funcionalidades

- [ ] Editar perfil de usuario
- [ ] Agregar transacciones individuales
- [ ] Categorización de gastos
- [ ] Gráficos de gastos
- [ ] Exportar reportes
- [ ] Notificaciones de presupuesto
- [ ] Modo oscuro
- [ ] Recuperación de contraseña

## Troubleshooting

### Error: "Waiting for another flutter command to release the startup lock"
```bash
# Windows
del C:\Users\<USERNAME>\AppData\Local\Temp\flutter_tools_startup_lock

# macOS/Linux
rm /tmp/flutter_tools_startup_lock
```

### Error: "Connection refused" o "Failed to connect"
- Verifica que el backend esté ejecutándose
- Verifica la URL en `usuario_service.dart`
- Si usas emulador Android, usa `http://10.0.2.2:8080` en lugar de `localhost`

### Error: "CORS policy" (en web)
- Configura CORS en tu backend para permitir peticiones desde `localhost:PORT`

## Notas de Desarrollo

### Para Desarrollo Web
Si estás desarrollando para web y tienes problemas de CORS, puedes ejecutar Chrome con seguridad deshabilitada (solo para desarrollo):

```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### Hot Reload
Durante el desarrollo, puedes usar hot reload para ver cambios instantáneos:
- Presiona `r` en la terminal
- O guarda el archivo en tu IDE

### Build para Producción
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Web
flutter build web --release

# iOS (solo macOS)
flutter build ios --release
```

## Estructura de Datos

### Modelo Usuario
```dart
{
  id: int?,                    // Generado por el servidor
  username: String,            // Único, mínimo 3 caracteres
  correoElectronico: String,   // Único, formato email
  password: String,            // Mínimo 6 caracteres
  celular: String,             // Mínimo 10 dígitos
  ingresos: double,           // Valor decimal
  gastos: double              // Valor decimal
}
```

## Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto es parte de un trabajo académico.

## Contacto

Para preguntas o soporte, contacta al equipo de desarrollo.

---

**Desarrollado con ❤️ usando Flutter**
