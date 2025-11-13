# 🚀 Inicio Rápido - Reconocimiento Facial

## 1️⃣ Iniciar Servicio Python (Terminal 1)

```powershell
cd "C:\Users\USER\Desktop\ING SISTEMAS\7\ING SOFTWARE 2\usuario-service\face-recognition-service"
.\venv\Scripts\Activate.ps1
python main.py
```

**Salida esperada:**
```
INFO:     Uvicorn running on http://0.0.0.0:5000
```

---

## 2️⃣ Iniciar Spring Boot (Terminal 2)

```powershell
cd "C:\Users\USER\Desktop\ING SISTEMAS\7\ING SOFTWARE 2\usuario-service"
mvn spring-boot:run
```

**Salida esperada:**
```
Started CelularServiceApplication in X.XXX seconds
```

---

## 3️⃣ Ejecutar Flutter App (Terminal 3)

```powershell
cd "C:\Users\USER\Desktop\ING SISTEMAS\7\ING SOFTWARE 2\EasySave-App\easysave"
flutter run
```

---

## 🧪 Probar Funcionalidad

### Opción A: Registro con Rostro
1. Abrir app
2. Click en "Crear Cuenta"
3. Click en **"Registrarse con Reconocimiento Facial"** (botón con ícono de rostro)
4. Seguir wizard de 3 pasos
5. ✅ Acceso automático

### Opción B: Login con Rostro
1. Si ya tienes cuenta con reconocimiento facial configurado
2. En pantalla de login, click en **"Iniciar sesión con Reconocimiento Facial"**
3. Capturar rostro
4. ✅ Acceso concedido

---

## 📋 Checklist Pre-Ejecución

- [ ] Python ejecutándose en puerto 5000
- [ ] Spring Boot ejecutándose en puerto 8080
- [ ] PostgreSQL activo
- [ ] Flutter conectado a backend correcto
- [ ] Permisos de cámara otorgados (Android)

---

## 🐛 Verificación Rápida

```powershell
# Terminal 4: Verificar servicios
curl http://localhost:5000/health
curl https://easysave-usuario-service-production.up.railway.app/api/v1/auth/test
```

Si ambos responden, ¡todo listo! 🎉

---

## 📸 Consejos para Captura

✅ **SÍ:**
- Buena iluminación frontal
- Rostro completo visible
- Vista frontal directa
- Fondo uniforme

❌ **NO:**
- Lentes oscuros
- Máscaras
- Poca luz
- Ángulos extremos

---

**Documentación completa:** Ver `RECONOCIMIENTO_FACIAL_GUIA.md`
