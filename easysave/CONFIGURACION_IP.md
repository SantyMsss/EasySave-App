# 🌐 Configuración de IP para Dispositivos Móviles

## ⚠️ Problema Actual
Cuando ejecutas la app en un **dispositivo Android conectado por USB**, el dispositivo no puede conectarse a `localhost:8080` porque localhost se refiere al propio dispositivo, no a tu computadora.

## ✅ Solución Aplicada

### 1. **IP Local Detectada**
Tu IP local es: **192.168.1.9**

### 2. **Archivos Actualizados**
Se ha actualizado el archivo de configuración para usar tu IP local:

📁 **lib/config/app_config.dart**
```dart
static const String baseUrl = 'https://postmundane-errol-askew.ngrok-free.dev/api/v1/usuario-service';
static const String authBaseUrl = 'https://postmundane-errol-askew.ngrok-free.dev/api/v1/auth';
```

## 🔧 ¿Cómo Cambiar la IP si es Necesaria?

### Paso 1: Obtener tu IP actual
```powershell
ipconfig
```
Busca la línea **"Dirección IPv4"** en tu adaptador de red principal (generalmente empieza con 192.168.x.x)

### Paso 2: Actualizar app_config.dart
Abre `lib/config/app_config.dart` y cambia las URLs:
```dart
static const String baseUrl = 'http://TU_IP_AQUI:8080/api/v1/usuario-service';
static const String authBaseUrl = 'http://TU_IP_AQUI:8080/api/v1/auth';
```

### Paso 3: Hacer Hot Restart
Después de cambiar la IP, presiona **R** (mayúscula) en la terminal de Flutter para hacer un Hot Restart completo.

## 🚀 Iniciar Servicios Backend

### 1. **Spring Boot (Puerto 8080)**
```powershell
cd usuario-service
mvn spring-boot:run
```
O si tienes el JAR compilado:
```powershell
java -jar target/usuario-service.jar
```

### 2. **Python DeepFace Service (Puerto 5000)**
```powershell
cd face-recognition-service
.\venv\Scripts\Activate.ps1
python main.py
```

### 3. **Verificar Servicios**
```powershell
# Verificar Spring Boot
curl https://postmundane-errol-askew.ngrok-free.dev/api/v1/auth/test

# Verificar DeepFace
curl http://localhost:5000/health
```

## 📱 Configuración del Firewall

Si el dispositivo móvil no puede conectarse, asegúrate de que el **Firewall de Windows** permita conexiones en el puerto 8080:

1. Abre **Firewall de Windows Defender** → **Configuración Avanzada**
2. **Reglas de entrada** → **Nueva regla**
3. Tipo: **Puerto** → TCP → Puerto específico: **8080**
4. Acción: **Permitir la conexión**
5. Perfil: Marca **Dominio, Privado y Público**
6. Nombre: **Spring Boot - EasySave**

Repite el proceso para el puerto **5000** si es necesario.

## 🔍 Verificar Conectividad

### Desde tu computadora:
```powershell
# Verificar que Spring Boot escuche en todas las interfaces
netstat -an | findstr 8080
```

### Desde el dispositivo Android:
1. Abre un navegador web en el dispositivo
2. Navega a: `https://postmundane-errol-askew.ngrok-free.dev/api/v1/auth/test`
3. Deberías ver una respuesta del servidor

## ⚙️ Configuración de Spring Boot

Asegúrate de que tu `application.properties` o `application.yml` esté configurado para escuchar en todas las interfaces:

```properties
server.address=0.0.0.0
server.port=8080
```

## 🎯 Próximos Pasos

1. ✅ **IP actualizada en app_config.dart**
2. ⏳ **Iniciar servicios backend** (Spring Boot + DeepFace)
3. ⏳ **Ejecutar `flutter run` en el dispositivo**
4. ⏳ **Probar registro con reconocimiento facial**
5. ⏳ **Probar login con reconocimiento facial**

---

**Nota:** Si cambias de red WiFi o tu IP cambia, necesitarás repetir el proceso de actualización de la IP en `app_config.dart`.
