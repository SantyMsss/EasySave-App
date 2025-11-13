# Guía de Pruebas - API EasySave

## Pruebas con cURL

### 1. Crear un usuario de prueba

```bash
curl -X POST https://easysave-usuario-service-production.up.railway.app/api/v1/usuario-service/usuario \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "correoElectronico": "test@email.com",
    "password": "123456",
    "celular": "3001234567",
    "ingresos": 5000000.0,
    "gastos": 2500000.0
  }'
```

### 2. Listar todos los usuarios

```bash
curl -X GET https://easysave-usuario-service-production.up.railway.app/api/v1/usuario-service/usuarios
```

### 3. Buscar usuario por ID

```bash
curl -X GET https://easysave-usuario-service-production.up.railway.app/api/v1/usuario-service/usuarios/1
```

### 4. Actualizar usuario

```bash
curl -X PUT https://easysave-usuario-service-production.up.railway.app/api/v1/usuario-service/usuario \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "username": "testuser",
    "correoElectronico": "test@email.com",
    "password": "123456",
    "celular": "3001234567",
    "ingresos": 6000000.0,
    "gastos": 3000000.0
  }'
```

## Casos de Prueba para la Aplicación

### Caso 1: Registro Exitoso
1. Abre la aplicación
2. Click en "Regístrate"
3. Completa los campos:
   - Usuario: `juanperez`
   - Correo: `juan@email.com`
   - Celular: `3101234567`
   - Password: `123456`
   - Confirmar: `123456`
   - Ingresos: `4000000`
   - Gastos: `2000000`
4. Click en "Registrarse"
5. **Resultado esperado**: Dashboard con balance de $2,000,000

### Caso 2: Login Exitoso
1. Abre la aplicación
2. Ingresa usuario: `juanperez`
3. Ingresa password: `123456`
4. Click en "Iniciar Sesión"
5. **Resultado esperado**: Acceso al dashboard

### Caso 3: Login con credenciales incorrectas
1. Abre la aplicación
2. Ingresa usuario: `userincorrecto`
3. Ingresa password: `wrongpass`
4. Click en "Iniciar Sesión"
5. **Resultado esperado**: Mensaje de error "Usuario no encontrado"

### Caso 4: Registro con username duplicado
1. Registra un usuario con username `testuser`
2. Intenta registrar otro usuario con el mismo username
3. **Resultado esperado**: Error "El nombre de usuario ya está en uso"

### Caso 5: Validación de formularios
1. Intenta registrarte sin completar campos
2. **Resultado esperado**: Mensajes de validación en campos vacíos

### Caso 6: Persistencia de sesión
1. Inicia sesión
2. Cierra la aplicación
3. Abre la aplicación nuevamente
4. **Resultado esperado**: Dashboard sin necesidad de login

### Caso 7: Cerrar sesión
1. Estando en el dashboard, click en el botón de logout
2. Confirma el cierre de sesión
3. **Resultado esperado**: Retorno a pantalla de login

### Caso 8: Cálculo de balance
Registra usuarios con diferentes valores de ingresos y gastos:

| Ingresos | Gastos  | Balance Esperado | Color Indicador |
|----------|---------|------------------|-----------------|
| 5000000  | 2000000 | 3000000          | Verde          |
| 5000000  | 4000000 | 1000000          | Naranja        |
| 5000000  | 5500000 | -500000          | Rojo           |

## Pruebas de Conexión

### Verificar que el backend está corriendo
```bash
curl https://easysave-usuario-service-production.up.railway.app/api/v1/usuario-service/usuarios
```

Si recibes una respuesta JSON, el backend está funcionando.

### Solución de problemas comunes

#### Error CORS en Web
Si aparece error de CORS al ejecutar en navegador, agrega esta configuración en tu backend:

```java
@Configuration
public class CorsConfig {
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")
                    .allowedOrigins("*")
                    .allowedMethods("GET", "POST", "PUT", "DELETE")
                    .allowedHeaders("*");
            }
        };
    }
}
```

#### Error de conexión en emulador Android
Si usas emulador Android, cambia `localhost` por `10.0.2.2`:

```dart
// En usuario_service.dart
static const String baseUrl = 'http://10.0.2.2:8080/api/v1/usuario-service';
```

## Datos de Prueba

### Usuario 1: Admin
```json
{
  "username": "admin",
  "correoElectronico": "admin@easysave.com",
  "password": "admin123",
  "celular": "3001111111",
  "ingresos": 10000000.0,
  "gastos": 4000000.0
}
```

### Usuario 2: Usuario Regular
```json
{
  "username": "usuario1",
  "correoElectronico": "usuario1@email.com",
  "password": "user123",
  "celular": "3002222222",
  "ingresos": 3500000.0,
  "gastos": 2800000.0
}
```

### Usuario 3: Usuario con gastos altos
```json
{
  "username": "gastador",
  "correoElectronico": "gastador@email.com",
  "password": "gasta123",
  "celular": "3003333333",
  "ingresos": 4000000.0,
  "gastos": 4500000.0
}
```

## Checklist de Funcionalidades

- [ ] Registro de nuevo usuario
- [ ] Validación de campos en registro
- [ ] Login con credenciales correctas
- [ ] Manejo de error en login con credenciales incorrectas
- [ ] Navegación a dashboard después de login
- [ ] Visualización de información del usuario
- [ ] Cálculo correcto de balance
- [ ] Indicador visual de porcentaje de gastos
- [ ] Colores correctos según nivel de gastos
- [ ] Cerrar sesión funciona correctamente
- [ ] Persistencia de sesión al reabrir app
- [ ] Splash screen muestra correctamente
- [ ] Validación de username duplicado
- [ ] Validación de correo duplicado
- [ ] Formato de moneda correcto en dashboard
- [ ] Responsive design en diferentes tamaños de pantalla

## Capturas Esperadas

### Pantalla de Login
- Logo de EasySave
- Campos de usuario y contraseña
- Botón de iniciar sesión
- Enlace a registro

### Pantalla de Registro
- Campos del formulario completos
- Validaciones visibles
- Botón de registro

### Dashboard
- Tarjeta de bienvenida con avatar
- Tarjeta de balance mensual con indicador
- Tarjetas separadas de ingresos y gastos
- Información de contacto
- Botón de cerrar sesión

## Métricas de Rendimiento

### Tiempos esperados
- Login: < 2 segundos
- Registro: < 3 segundos
- Carga de dashboard: < 1 segundo
- Navegación entre pantallas: < 500ms

### Manejo de memoria
- App en segundo plano: < 100MB
- App en primer plano: < 150MB

## Reporte de Bugs

Si encuentras un bug, documenta:
1. Pasos para reproducir
2. Resultado esperado
3. Resultado actual
4. Capturas de pantalla
5. Logs de consola
6. Dispositivo/navegador usado

---

**Última actualización**: 22 de octubre de 2025
