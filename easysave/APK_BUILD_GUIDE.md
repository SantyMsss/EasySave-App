# 📱 Guía para Generar APK de EasySave

## Método Automático (Recomendado)

### Usando el Script PowerShell

1. Abre PowerShell en la carpeta del proyecto
2. Ejecuta el script:
   ```powershell
   .\build_apk.ps1
   ```

El script ejecutará automáticamente todos los pasos necesarios y abrirá la carpeta con el APK generado.

---

## Método Manual

Si prefieres hacerlo paso a paso, sigue estas instrucciones:

### Paso 1: Instalar Dependencias
```bash
flutter pub get
```

### Paso 2: Generar Iconos de la Aplicación
```bash
flutter pub run flutter_launcher_icons
```

### Paso 3: Limpiar Build Anterior (Opcional pero recomendado)
```bash
flutter clean
flutter pub get
```

### Paso 4: Compilar APK
```bash
flutter build apk --release
```

---

## 📂 Ubicación del APK

Una vez compilado, encontrarás el APK en:
```
build\app\outputs\flutter-apk\app-release.apk
```

---

## 📦 Características del APK Generado

✅ **Modo Release**: Optimizado para producción
✅ **Ícono Personalizado**: Logo de EasySave (logoes.png)
✅ **Nombre de App**: "EasySave"
✅ **Funcionalidad Completa**: Todas las features implementadas
✅ **Tamaño Optimizado**: APK comprimido y eficiente

---

## 🚀 Instalación en Dispositivo Android

### Opción 1: Transferencia Directa
1. Copia el archivo `app-release.apk` a tu dispositivo Android
2. Abre el archivo desde el administrador de archivos
3. Si es necesario, habilita "Instalar aplicaciones de origen desconocido"
4. Sigue las instrucciones en pantalla

### Opción 2: ADB (Dispositivo conectado por USB)
```bash
adb install build\app\outputs\flutter-apk\app-release.apk
```

---

## ⚙️ Configuración Actual del Proyecto

- **Nombre de Aplicación**: EasySave
- **Package Name**: com.example.easysave
- **Versión**: 1.0.0+1
- **Min SDK**: Flutter default
- **Target SDK**: Flutter default
- **Ícono**: assets/logoes.png

---

## 🔧 Solución de Problemas

### Error: "flutter_launcher_icons no encontrado"
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

### Error durante la compilación
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### APK muy grande
Para reducir el tamaño, puedes crear APKs separados por arquitectura:
```bash
flutter build apk --release --split-per-abi
```
Esto generará múltiples APKs más pequeños (arm64-v8a, armeabi-v7a, x86_64)

---

## 📝 Notas Importantes

1. **Permisos**: El APK incluye todos los permisos configurados en AndroidManifest.xml
2. **Backend URL**: Asegúrate de que la URL del backend esté configurada correctamente
3. **Certificado**: Este APK usa el certificado de debug. Para producción, debes firmarlo con tu propio keystore
4. **Actualizaciones**: Los usuarios deberán desinstalar e instalar manualmente cada nueva versión

---

## 🔐 Firma de Producción (Opcional)

Para distribuir en Google Play Store o firmado profesionalmente:

1. Genera un keystore:
```bash
keytool -genkey -v -keystore ~/easysave-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias easysave
```

2. Configura en `android/key.properties`

3. Actualiza `android/app/build.gradle.kts` con la configuración de firma

4. Compila con firma:
```bash
flutter build apk --release
```
