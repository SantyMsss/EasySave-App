# Configuración CORS para EasySave Backend

## ⚠️ Importante para desarrollo web

Si estás ejecutando la aplicación Flutter en un navegador web (Chrome, Firefox, etc.), necesitas configurar CORS en tu backend para permitir peticiones desde `localhost`.

## Problema

Cuando intentas hacer peticiones desde `http://localhost:PORT` (Flutter web) a `https://easysave-usuario-service-production.up.railway.app` (API), el navegador bloquea las peticiones por política de seguridad CORS.

## Solución: Configurar CORS en Spring Boot

### Opción 1: Configuración Global (Recomendado)

Crea una clase de configuración en tu proyecto Spring Boot:

**Ubicación**: `src/main/java/com/easysave/config/CorsConfig.java`

```java
package com.easysave.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig implements WebMvcConfigurer {
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("*")  // Para desarrollo, permite todos los orígenes
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(false)
                .maxAge(3600);
    }
}
```

### Opción 2: Usando anotaciones en Controladores

Puedes agregar `@CrossOrigin` a tu controlador:

```java
package com.easysave.controller;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/usuario-service")
@CrossOrigin(origins = "*")  // Permite todos los orígenes
public class UsuarioController {
    // ... tus endpoints
}
```

### Opción 3: Configuración específica para producción

Para un entorno de producción, es mejor especificar los orígenes permitidos:

```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins(
                    "http://localhost:3000",      // Flutter web dev
                    "https://easysave-usuario-service-production.up.railway.app",      // Backend
                    "https://tu-dominio.com"      // Producción
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }
}
```

### Opción 4: Usando application.properties

Si prefieres configurar CORS en `application.properties`:

```properties
# application.properties
spring.web.cors.allowed-origins=*
spring.web.cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
spring.web.cors.allowed-headers=*
spring.web.cors.max-age=3600
```

## Verificación

### 1. Reinicia tu servidor Spring Boot

Después de agregar la configuración CORS, reinicia el servidor:

```bash
./mvnw spring-boot:run
# o
./gradlew bootRun
```

### 2. Verifica con cURL

Prueba que CORS está configurado correctamente:

```bash
curl -H "Origin: http://localhost:3000" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -X OPTIONS \
     --verbose \
     https://easysave-usuario-service-production.up.railway.app/api/v1/usuario-service/usuarios
```

Deberías ver headers como:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
```

### 3. Verifica en el navegador

1. Abre DevTools en Chrome (F12)
2. Ve a la pestaña "Console"
3. Ejecuta tu aplicación Flutter
4. Si no ves errores de CORS, está funcionando correctamente

## Errores Comunes de CORS

### Error 1: "No 'Access-Control-Allow-Origin' header is present"

**Causa**: CORS no está configurado en el backend

**Solución**: Agrega la configuración CORS mencionada arriba

### Error 2: "The value of the 'Access-Control-Allow-Origin' header... must not be the wildcard '*' when credentials flag is true"

**Causa**: Estás usando `allowCredentials(true)` con `allowedOrigins("*")`

**Solución**: 
```java
.allowedOrigins("http://localhost:3000")  // Específico
.allowCredentials(true)
```

### Error 3: "Request method 'POST' is not supported"

**Causa**: No se agregó el método en `allowedMethods`

**Solución**:
```java
.allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
```

## Configuración para diferentes entornos

### Development

```java
@Profile("dev")
@Configuration
public class DevCorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("*")
                .allowedMethods("*")
                .allowedHeaders("*");
    }
}
```

### Production

```java
@Profile("prod")
@Configuration
public class ProdCorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("https://tu-dominio.com")
                .allowedMethods("GET", "POST", "PUT", "DELETE")
                .allowedHeaders("Content-Type", "Authorization")
                .allowCredentials(true)
                .maxAge(3600);
    }
}
```

## Alternativa: Ejecutar Flutter sin CORS

Si no puedes modificar el backend, puedes ejecutar Chrome sin seguridad CORS (solo para desarrollo):

### Windows
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=C:\temp\chrome-dev"
```

### macOS/Linux
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=/tmp/chrome-dev"
```

⚠️ **ADVERTENCIA**: Esto es SOLO para desarrollo. Nunca uses esto en producción.

## Para emulador Android

Si estás usando un emulador Android, necesitas cambiar `localhost` a `10.0.2.2`:

**En `usuario_service.dart`**:
```dart
// Para Android emulator
static const String baseUrl = 'http://10.0.2.2:8080/api/v1/usuario-service';

// Para web o dispositivo físico
static const String baseUrl = 'https://easysave-usuario-service-production.up.railway.app/api/v1/usuario-service';
```

O mejor aún, usa una variable de entorno:

```dart
class ApiConfig {
  static const bool isAndroidEmulator = bool.fromEnvironment('ANDROID_EMULATOR', defaultValue: false);
  
  static String get baseUrl {
    if (isAndroidEmulator) {
      return 'http://10.0.2.2:8080/api/v1/usuario-service';
    }
    return 'https://easysave-usuario-service-production.up.railway.app/api/v1/usuario-service';
  }
}
```

## Checklist de verificación CORS

- [ ] Configuración CORS agregada en backend
- [ ] Servidor backend reiniciado
- [ ] Métodos HTTP necesarios permitidos (GET, POST, PUT, DELETE)
- [ ] Headers permitidos configurados
- [ ] Orígenes correctos en producción
- [ ] Prueba con cURL exitosa
- [ ] Prueba desde navegador exitosa
- [ ] No hay errores de CORS en DevTools

## Recursos Adicionales

- [Spring Boot CORS Documentation](https://spring.io/guides/gs/rest-service-cors/)
- [MDN Web Docs - CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Flutter Web - Network Configuration](https://docs.flutter.dev/platform-integration/web/faq)

---

**Última actualización**: 22 de octubre de 2025
