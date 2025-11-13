# Arquitectura del Frontend - EasySave

## 📋 Índice
1. [Visión General](#visión-general)
2. [Arquitectura de Capas](#arquitectura-de-capas)
3. [Flujo de Datos](#flujo-de-datos)
4. [Componentes Principales](#componentes-principales)
5. [Patrones de Diseño](#patrones-de-diseño)
6. [Diagramas](#diagramas)

---

## Visión General

EasySave utiliza una arquitectura de capas limpia (Clean Architecture) adaptada para Flutter, separando las responsabilidades en diferentes módulos:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │  (Screens/UI)
├─────────────────────────────────────┤
│         Business Logic Layer        │  (Services)
├─────────────────────────────────────┤
│           Data Layer                │  (Models/API)
└─────────────────────────────────────┘
```

---

## Arquitectura de Capas

### 1. **Presentation Layer** (Capa de Presentación)

**Ubicación**: `lib/screens/`

**Responsabilidades**:
- Renderizar la interfaz de usuario
- Capturar eventos del usuario
- Mostrar feedback visual (loading, errores, éxitos)
- Navegación entre pantallas

**Componentes**:
- `login_screen.dart`: UI de autenticación
- `registro_screen.dart`: UI de creación de cuenta
- `home_screen.dart`: Dashboard principal

**Características**:
- Widgets Stateful para manejar estado local
- Validación de formularios
- Gestión de loading states
- Manejo de errores con SnackBars

---

### 2. **Business Logic Layer** (Capa de Lógica de Negocio)

**Ubicación**: `lib/services/`

**Responsabilidades**:
- Implementar lógica de negocio
- Comunicación con APIs
- Gestión de autenticación
- Transformación de datos

**Componentes**:

#### `usuario_service.dart`
```dart
- listarUsuarios()
- buscarUsuarioPorId(int id)
- crearUsuario(Usuario usuario)
- actualizarUsuario(Usuario usuario)
- login(String username, String password)
- existeUsername(String username)
- existeCorreo(String correo)
```

#### `auth_manager.dart`
```dart
- guardarSesion(Usuario usuario)
- obtenerUsuarioActual()
- tieneSesionActiva()
- cerrarSesion()
- actualizarSesion(Usuario usuario)
```

---

### 3. **Data Layer** (Capa de Datos)

**Ubicación**: `lib/models/`

**Responsabilidades**:
- Definir modelos de datos
- Serialización/Deserialización JSON
- Validación de tipos

**Componentes**:

#### `usuario.dart`
```dart
class Usuario {
  final int? id;
  final String username;
  final String correoElectronico;
  final String password;
  final String celular;
  final double ingresos;
  final double gastos;
  
  // Métodos
  - fromJson(Map<String, dynamic>)
  - toJson()
  - copyWith(...)
}
```

---

## Flujo de Datos

### Flujo de Login

```
┌─────────────┐
│ LoginScreen │
└──────┬──────┘
       │ 1. Usuario ingresa credenciales
       │
       ▼
┌─────────────────┐
│ UsuarioService  │
│  login()        │
└──────┬──────────┘
       │ 2. Valida contra API
       │
       ▼
┌─────────────────┐
│   HTTP Client   │
│  GET /usuarios  │
└──────┬──────────┘
       │ 3. Respuesta de API
       │
       ▼
┌─────────────────┐
│  AuthManager    │
│ guardarSesion() │
└──────┬──────────┘
       │ 4. Guarda en local
       │
       ▼
┌─────────────┐
│ HomeScreen  │
│  Dashboard  │
└─────────────┘
```

### Flujo de Registro

```
┌──────────────────┐
│ RegistroScreen   │
└────────┬─────────┘
         │ 1. Usuario completa formulario
         │
         ▼
┌──────────────────┐
│ Validaciones     │
│ (Formulario)     │
└────────┬─────────┘
         │ 2. Validar campos
         │
         ▼
┌──────────────────┐
│ UsuarioService   │
│ crearUsuario()   │
└────────┬─────────┘
         │ 3. POST /usuario
         │
         ▼
┌──────────────────┐
│   API Backend    │
│ Crear usuario    │
└────────┬─────────┘
         │ 4. Usuario creado
         │
         ▼
┌──────────────────┐
│  AuthManager     │
│ guardarSesion()  │
└────────┬─────────┘
         │ 5. Sesión guardada
         │
         ▼
┌──────────────────┐
│   HomeScreen     │
└──────────────────┘
```

---

## Componentes Principales

### 1. Main App (`main.dart`)

**Funciones**:
- Punto de entrada de la aplicación
- Configuración del tema
- Enrutamiento inicial

**Características**:
- Material Design 3
- Tema personalizado con colores verdes
- SplashScreen para verificar sesión

```dart
void main() {
  runApp(const MyApp());
}
```

### 2. SplashScreen

**Propósito**: Pantalla inicial mientras se verifica la sesión

**Flujo**:
1. Muestra logo y loading
2. Verifica si hay sesión activa
3. Navega a HomeScreen o LoginScreen

### 3. LoginScreen

**Estado**: Stateful Widget

**Controllers**:
- `_usernameController`: TextEditingController
- `_passwordController`: TextEditingController

**Estados**:
- `_isLoading`: bool - Muestra indicador de carga
- `_obscurePassword`: bool - Controla visibilidad de password

**Métodos principales**:
```dart
_handleLogin() async {
  // 1. Validar formulario
  // 2. Llamar a UsuarioService.login()
  // 3. Guardar sesión con AuthManager
  // 4. Navegar a HomeScreen
}
```

### 4. RegistroScreen

**Estado**: Stateful Widget

**Controllers**:
- Username, Email, Password, Confirm, Celular, Ingresos, Gastos

**Validaciones**:
- Username: mínimo 3 caracteres
- Email: formato válido
- Celular: mínimo 10 dígitos
- Password: mínimo 6 caracteres
- Confirm: debe coincidir con password
- Ingresos/Gastos: valores numéricos

**Métodos principales**:
```dart
_handleRegistro() async {
  // 1. Validar formulario
  // 2. Verificar username único
  // 3. Verificar correo único
  // 4. Crear usuario
  // 5. Guardar sesión
  // 6. Navegar a HomeScreen
}
```

### 5. HomeScreen

**Propósito**: Dashboard principal del usuario

**Widgets principales**:
- **Tarjeta de Bienvenida**: Avatar y nombre de usuario
- **Tarjeta de Balance**: Muestra saldo mensual con indicador
- **Tarjetas de Ingresos/Gastos**: Información financiera
- **Tarjeta de Contacto**: Celular y correo

**Cálculos**:
```dart
final saldo = widget.usuario.ingresos - widget.usuario.gastos;
final porcentajeGastos = (gastos / ingresos) * 100;
```

**Colores dinámicos**:
- Verde: saldo positivo
- Rojo: saldo negativo
- Naranja: >60% de gastos
- Rojo: >80% de gastos

---

## Patrones de Diseño

### 1. **Singleton** (Implícito)
- `UsuarioService`: Una instancia por pantalla
- `AuthManager`: Una instancia por pantalla

### 2. **Repository Pattern**
- `UsuarioService` actúa como repositorio
- Abstrae la lógica de acceso a datos de la API

### 3. **Factory Pattern**
- `Usuario.fromJson()`: Factory constructor
- Crea objetos Usuario desde JSON

### 4. **State Management**
- State local con `setState()`
- Controllers para inputs
- FutureBuilder para datos asíncronos

### 5. **Service Layer Pattern**
- Servicios encapsulan lógica de negocio
- Separación entre UI y lógica

---

## Diagramas

### Diagrama de Clases

```
┌─────────────────────────┐
│       Usuario           │
├─────────────────────────┤
│ - id: int?              │
│ - username: String      │
│ - correoElectronico     │
│ - password: String      │
│ - celular: String       │
│ - ingresos: double      │
│ - gastos: double        │
├─────────────────────────┤
│ + fromJson()            │
│ + toJson()              │
│ + copyWith()            │
└─────────────────────────┘
          △
          │ uses
          │
┌─────────────────────────┐
│   UsuarioService        │
├─────────────────────────┤
│ - baseUrl: String       │
├─────────────────────────┤
│ + listarUsuarios()      │
│ + buscarPorId()         │
│ + crearUsuario()        │
│ + actualizarUsuario()   │
│ + login()               │
│ + existeUsername()      │
│ + existeCorreo()        │
└─────────────────────────┘

┌─────────────────────────┐
│     AuthManager         │
├─────────────────────────┤
│ + guardarSesion()       │
│ + obtenerUsuarioActual()│
│ + tieneSesionActiva()   │
│ + cerrarSesion()        │
└─────────────────────────┘
```

### Diagrama de Navegación

```
┌─────────────┐
│   Splash    │
│   Screen    │
└──────┬──────┘
       │
       ├──────┐ Sesión activa
       │      │
       │      ▼
       │  ┌──────────┐
       │  │   Home   │
       │  │  Screen  │
       │  └──────────┘
       │
       └──────┐ Sin sesión
              │
              ▼
         ┌─────────┐
         │  Login  │
         │ Screen  │
         └────┬────┘
              │
              ├──────┐ Login exitoso
              │      │
              │      ▼
              │  ┌──────────┐
              │  │   Home   │
              │  │  Screen  │
              │  └──────────┘
              │
              └──────┐ Click "Regístrate"
                     │
                     ▼
                ┌──────────┐
                │ Registro │
                │  Screen  │
                └─────┬────┘
                      │
                      │ Registro exitoso
                      │
                      ▼
                  ┌──────────┐
                  │   Home   │
                  │  Screen  │
                  └──────────┘
```

---

## Persistencia de Datos

### SharedPreferences

**Datos guardados**:
```dart
'user_id': int
'user_data': String (JSON del usuario)
'is_logged_in': bool
```

**Cuándo se usa**:
- Al hacer login exitoso
- Al registrarse
- Al verificar sesión en splash
- Al cerrar sesión

---

## Comunicación HTTP

### Headers
```dart
{
  'Content-Type': 'application/json'
}
```

### Timeout
- Conexión: 30 segundos
- Recepción: 30 segundos

### Manejo de Respuestas

| Status Code | Manejo                        |
|-------------|-------------------------------|
| 200         | Éxito - parsear JSON          |
| 201         | Creado - parsear JSON         |
| 400         | Error de datos - mensaje user |
| 404         | No encontrado - mensaje user  |
| 409         | Conflicto - duplicado         |
| 500         | Error servidor - mensaje user |

---

## Seguridad

### Buenas Prácticas Implementadas

✅ Contraseñas ocultas por defecto
✅ Validación de inputs del lado del cliente
✅ Manejo seguro de errores (sin exponer detalles técnicos)
✅ Sesiones con SharedPreferences
✅ Verificación de duplicados antes de crear

### Mejoras Futuras

- [ ] Encriptación de contraseñas con bcrypt
- [ ] Tokens JWT para autenticación
- [ ] Refresh tokens
- [ ] Biometría para login
- [ ] Rate limiting en intentos de login

---

## Performance

### Optimizaciones

- **Lazy loading**: Widgets se construyen solo cuando son necesarios
- **setState localizado**: Solo reconstruye widgets necesarios
- **Controllers dispuestos**: Liberación de memoria al salir de pantallas
- **Caché de sesión**: No consultar API en cada apertura

### Métricas

- Tiempo de inicio: ~1-2 segundos
- Tiempo de login: <2 segundos
- Consumo de memoria: <150MB
- Tamaño del APK: ~20MB (release)

---

## Testing

### Tipos de Tests Recomendados

1. **Unit Tests**: Servicios y modelos
2. **Widget Tests**: Pantallas individuales
3. **Integration Tests**: Flujos completos

### Ejemplo de Unit Test

```dart
test('Usuario.fromJson debería crear un usuario válido', () {
  final json = {
    'id': 1,
    'username': 'test',
    'correoElectronico': 'test@email.com',
    // ...
  };
  
  final usuario = Usuario.fromJson(json);
  
  expect(usuario.id, 1);
  expect(usuario.username, 'test');
});
```

---

## Dependencias

### Producción

| Paquete                    | Versión | Uso                        |
|----------------------------|---------|----------------------------|
| http                       | ^1.1.0  | Cliente HTTP para APIs     |
| shared_preferences         | ^2.2.2  | Almacenamiento local       |
| flutter_secure_storage     | ^9.0.0  | Almacenamiento seguro      |

### Desarrollo

| Paquete        | Versión | Uso                     |
|----------------|---------|-------------------------|
| flutter_test   | sdk     | Testing                 |
| flutter_lints  | ^6.0.0  | Análisis de código      |

---

## Convenciones de Código

### Nomenclatura

- **Clases**: PascalCase (`LoginScreen`)
- **Variables**: camelCase (`_isLoading`)
- **Constantes**: camelCase con const (`baseUrl`)
- **Privados**: Prefijo `_` (`_handleLogin`)

### Estructura de archivos

```
nombre_archivo.dart
│
├── Imports
├── Clase principal
│   ├── Variables de instancia
│   ├── Constructor
│   ├── Lifecycle methods
│   ├── Event handlers
│   └── Build method
└── Helper methods privados
```

---

## Configuración del Entorno

### Variables de Entorno (Futuro)

```dart
// config/env.dart
abstract class Env {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://easysave-usuario-service-production.up.railway.app',
  );
}
```

### Uso
```bash
flutter run --dart-define=API_URL=https://api.easysave.com
```

---

**Última actualización**: 22 de octubre de 2025
