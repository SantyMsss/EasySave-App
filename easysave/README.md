# 💰 EasySave - Aplicación de Gestión Financiera Personal

Una aplicación Flutter completa para la gestión de finanzas personales con funcionalidades de seguimiento de ingresos, gastos y **metas de ahorro programado**.

## 🌟 Características Principales

### 📊 Gestión Financiera
- ✅ **Registro de Ingresos**: Administra tus entradas de dinero (fijos/variables)
- ✅ **Control de Gastos**: Monitorea tus egresos (fijos/variables)
- ✅ **Balance en Tiempo Real**: Visualiza tu situación financiera actual
- ✅ **Gráficos Estadísticos**: Visualización de datos con gráficos interactivos

### 💎 Metas de Ahorro (NUEVO)
- 🎯 **Crear Metas de Ahorro**: Define objetivos financieros con cuotas programadas
- 💡 **Sugerencias Inteligentes**: Cálculo automático basado en tu balance disponible
- 📅 **Cuotas Programadas**: Sistema de pago por cuotas (semanal, quincenal, mensual)
- 📈 **Seguimiento de Progreso**: Visualiza tu avance con gráficos circulares y lineales
- ✅ **Gestión de Cuotas**: Paga cuotas individuales y monitorea tu avance
- 🏆 **Estados de Meta**: ACTIVA, COMPLETADA, CANCELADA

### 🔐 Autenticación
- 🔑 **Login/Registro**: Sistema de autenticación con JWT
- 👤 **Gestión de Usuarios**: Perfil de usuario personalizado
- 🛡️ **Sesión Persistente**: Mantén tu sesión activa de forma segura

## 📱 Capturas de Pantalla

*(Agregar capturas de pantalla aquí)*

## 🚀 Inicio Rápido

### Prerequisitos
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Backend EasySave corriendo en `https://easysave-usuario-service-production.up.railway.app`

### Instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd EasySave-App/easysave
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar la aplicación**
```bash
flutter run
```

## 🏗️ Estructura del Proyecto

```
easysave/
├── lib/
│   ├── models/
│   │   ├── usuario.dart          # Modelos de Usuario, Ingreso, Gasto
│   │   └── meta_ahorro.dart      # Modelos de MetaAhorro, CuotaAhorro
│   ├── services/
│   │   ├── auth_service.dart     # Servicio de autenticación
│   │   ├── auth_manager.dart     # Gestión de sesión
│   │   ├── usuario_service.dart  # Servicios de usuario
│   │   └── meta_ahorro_service.dart  # Servicios de metas de ahorro
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── registro_screen.dart
│   │   ├── home_screen.dart
│   │   ├── ingresos_screen.dart
│   │   ├── gastos_screen.dart
│   │   ├── metas_ahorro_screen.dart         # Lista de metas
│   │   └── meta_ahorro_detalle_screen.dart  # Detalle de meta
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   └── http_error_handler.dart
│   ├── config/
│   │   └── app_config.dart
│   └── main.dart
├── android/
├── ios/
├── web/
├── test/
├── pubspec.yaml
├── README.md                        # Este archivo
├── METAS_AHORRO_GUIDE.md           # Guía de usuario
├── METAS_AHORRO_TECH.md            # Documentación técnica
└── IMPLEMENTATION_SUMMARY.md       # Resumen de implementación
```

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # Cliente HTTP
  fl_chart: ^0.66.0         # Gráficos y visualizaciones
  shared_preferences: ^2.2.2  # Almacenamiento local
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## 🔌 API Backend

La aplicación se conecta a un backend Spring Boot en:
```
https://easysave-usuario-service-production.up.railway.app/api/v1/
```

### Endpoints Principales

#### Autenticación
- `POST /auth/login` - Iniciar sesión
- `POST /auth/register` - Registrar usuario

#### Usuario
- `GET /usuario-service/usuarios/{id}` - Obtener usuario
- `GET /usuario-service/usuarios/{id}/resumen-financiero` - Balance

#### Ingresos/Gastos
- `GET /usuario-service/usuarios/{id}/ingresos` - Listar ingresos
- `POST /usuario-service/usuarios/{id}/ingresos` - Agregar ingreso
- `DELETE /usuario-service/ingresos/{id}` - Eliminar ingreso
- `GET /usuario-service/usuarios/{id}/gastos` - Listar gastos
- `POST /usuario-service/usuarios/{id}/gastos` - Agregar gasto
- `DELETE /usuario-service/gastos/{id}` - Eliminar gasto

#### Metas de Ahorro (NUEVO)
- `POST /usuario-service/usuarios/{id}/metas-ahorro` - Crear meta
- `GET /usuario-service/usuarios/{id}/metas-ahorro` - Listar metas
- `GET /usuario-service/usuarios/{id}/metas-ahorro/activas` - Metas activas
- `GET /usuario-service/metas-ahorro/{id}` - Detalle de meta
- `POST /usuario-service/metas-ahorro/{metaId}/cuotas/{cuotaId}/pagar` - Pagar cuota
- `GET /usuario-service/usuarios/{id}/sugerencia-ahorro` - Calcular sugerencia
- `DELETE /usuario-service/metas-ahorro/{id}` - Cancelar meta

## 🎯 Flujo de Usuario

### 1. Autenticación
1. Registrarse o iniciar sesión
2. Sistema guarda JWT token localmente

### 2. Dashboard Principal
- Ver balance mensual (Ingresos - Gastos)
- Visualizar gráficos estadísticos
- Acceder rápidamente a Ingresos, Gastos o Metas

### 3. Gestión de Ingresos/Gastos
- Agregar nuevos items (fijos o variables)
- Ver lista completa
- Eliminar items
- Ver total acumulado

### 4. Metas de Ahorro
1. **Acceder**: Clic en tarjeta de Balance
2. **Crear Meta**: 
   - Definir nombre y monto
   - Establecer cuotas y frecuencia
   - Ver sugerencia automática
3. **Seguimiento**:
   - Ver progreso en tiempo real
   - Revisar cuotas programadas
   - Pagar cuotas individuales
4. **Completar**: 
   - Meta se completa al pagar todas las cuotas
   - Mensaje de felicitaciones

## 🎨 Paleta de Colores

### Estados de Meta
- 🔵 **Activa**: Blue (#2196F3)
- 🟢 **Completada**: Green (#4CAF50)
- 🔴 **Cancelada**: Red (#F44336)

### Estados de Cuota
- 🟠 **Pendiente**: Orange (#FF9800)
- ✅ **Pagada**: Green (#4CAF50)
- 🔴 **Vencida**: Red (#F44336)

### General
- Ingresos: Green tones
- Gastos: Red tones
- Balance positivo: Green
- Balance negativo: Red

## 🧪 Testing

### Ejecutar tests
```bash
flutter test
```

### Casos de prueba recomendados
- Creación de meta con balance positivo
- Pago completo de todas las cuotas
- Filtrado de metas (Todas/Activas/Completadas)
- Sugerencia automática de ahorro
- Cancelación de meta

## 🔧 Configuración

### Cambiar URL del Backend
Editar en cada servicio:
```dart
// lib/services/meta_ahorro_service.dart
static const String baseUrl = 'http://TU_IP:8080/api/v1/usuario-service';
```

### Habilitar CORS en Backend
Ver archivo `CORS_SETUP.md` en el proyecto backend

## 📚 Documentación Adicional

- **[METAS_AHORRO_GUIDE.md](METAS_AHORRO_GUIDE.md)**: Guía completa de usuario
- **[METAS_AHORRO_TECH.md](METAS_AHORRO_TECH.md)**: Documentación técnica detallada
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)**: Resumen de implementación
- **[ARCHITECTURE.md](ARCHITECTURE.md)**: Arquitectura del proyecto
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)**: Guía de testing

## 🐛 Solución de Problemas

### Error: "No se puede conectar al servidor"
- Verificar que el backend esté corriendo
- Comprobar la URL en los servicios
- Revisar configuración de CORS

### Error: "Sesión expirada"
- Cerrar sesión y volver a iniciar
- JWT token puede haber expirado

### Progreso no se actualiza
- Hacer pull-to-refresh
- Navegar atrás y volver a entrar

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add: AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto es para fines educativos.

## 👥 Autores

- **Equipo EasySave** - Ingeniería de Software 2

## 🙏 Agradecimientos

- Flutter Team
- Material Design
- FL Chart Library
- Spring Boot Team

---

## 🆕 Changelog

### v1.1.0 (Noviembre 2025)
- ✨ **NUEVO**: Módulo completo de Metas de Ahorro
- ✨ Sugerencias inteligentes de ahorro
- ✨ Sistema de cuotas programadas
- ✨ Gráficos de progreso circular y lineal
- ✨ Filtros de metas (Todas/Activas/Completadas)
- 🐛 Mejoras en navegación
- 📚 Documentación completa agregada

### v1.0.0
- 🎉 Release inicial
- ✅ Autenticación con JWT
- ✅ Gestión de Ingresos y Gastos
- ✅ Dashboard con gráficos
- ✅ Balance en tiempo real

---

**¿Preguntas?** Consulta la documentación o crea un issue.

**¡Comienza a ahorrar de forma inteligente con EasySave! 💰✨**
