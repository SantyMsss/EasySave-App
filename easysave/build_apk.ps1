# Script para generar APK de EasySave
# Este script ejecuta todos los pasos necesarios para crear el APK

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Generador de APK - EasySave App" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Obtener dependencias
Write-Host "[1/4] Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al obtener dependencias" -ForegroundColor Red
    exit 1
}
Write-Host "Dependencias obtenidas correctamente" -ForegroundColor Green
Write-Host ""

# Paso 2: Generar iconos de la aplicación
Write-Host "[2/4] Generando iconos de la aplicación..." -ForegroundColor Yellow
flutter pub run flutter_launcher_icons
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al generar iconos" -ForegroundColor Red
    exit 1
}
Write-Host "Iconos generados correctamente" -ForegroundColor Green
Write-Host ""

# Paso 3: Limpiar build anterior
Write-Host "[3/4] Limpiando builds anteriores..." -ForegroundColor Yellow
flutter clean
flutter pub get
Write-Host "Limpieza completada" -ForegroundColor Green
Write-Host ""

# Paso 4: Compilar APK
Write-Host "[4/4] Compilando APK en modo release..." -ForegroundColor Yellow
Write-Host "Este proceso puede tardar varios minutos..." -ForegroundColor Yellow
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al compilar APK" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "  APK GENERADO EXITOSAMENTE" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Ubicación del APK:" -ForegroundColor Cyan
Write-Host "build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
Write-Host ""
Write-Host "Puedes instalar este APK en cualquier dispositivo Android" -ForegroundColor Yellow
Write-Host ""

# Abrir la carpeta del APK
$apkPath = ".\build\app\outputs\flutter-apk"
if (Test-Path $apkPath) {
    Write-Host "Abriendo carpeta del APK..." -ForegroundColor Cyan
    explorer.exe $apkPath
}
