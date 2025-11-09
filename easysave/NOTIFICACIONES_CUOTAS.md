# 🔔 Sistema de Notificaciones para Cuotas de Ahorro Programadas

## 📋 Descripción General

Se ha implementado un sistema inteligente de notificaciones que alerta al usuario cuando tiene cuotas de ahorro programadas para el día actual, permitiéndole pagarlas con un solo click.

## 🎯 Características Implementadas

### 1. Servicio de Notificaciones (`lib/services/notificacion_cuota_service.dart`)

#### Funcionalidades Principales:

**Verificación Automática**:
- ✅ Revisa cuotas pendientes cada 6 horas
- ✅ Verificación inmediata al iniciar la aplicación
- ✅ Filtra solo las cuotas programadas para el día actual
- ✅ Solo muestra cuotas en estado "PENDIENTE"

**Notificación Inteligente**:
- ✅ Diálogo modal con información completa de la cuota
- ✅ Diseño atractivo con iconos y colores
- ✅ Información detallada: meta, cuota #, monto, fecha
- ✅ Opciones claras: "Más tarde" o "Pagar ahora"

**Procesamiento de Pago**:
- ✅ Integración directa con el backend
- ✅ Registro automático del pago como gasto
- ✅ Indicador de progreso durante el pago
- ✅ Confirmación visual de pago exitoso
- ✅ Manejo robusto de errores
- ✅ Verificación automática de más cuotas después del pago

### 2. Integración en HomeScreen

**Ciclo de Vida**:
```dart
initState()  → Inicializa el servicio de notificaciones
dispose()    → Detiene el timer para evitar memory leaks
```

**Características**:
- ✅ Se activa automáticamente al entrar al home
- ✅ Se detiene al salir de la pantalla
- ✅ Acceso al usuario actual
- ✅ Contexto de navegación disponible

## 📱 Flujo de Usuario

### 1. Usuario Entra a la Aplicación
```
HomeScreen carga
    ↓
Servicio de notificaciones se inicializa
    ↓
Verificación inmediata de cuotas pendientes
```

### 2. Cuota Pendiente Detectada
```
Se encuentra cuota para hoy
    ↓
Aparece diálogo de notificación
    ↓
Usuario ve: Meta, Cuota #, Monto, Fecha
```

### 3. Usuario Decide Pagar
```
Click en "Pagar ahora"
    ↓
Mostrar indicador de progreso
    ↓
Llamada al backend (pagarCuota)
    ↓
Actualización en base de datos
    ↓
Registrar pago como gasto automáticamente
    ↓
Mensaje de confirmación
    ↓
Verificar más cuotas pendientes
```

### 4. Usuario Pospone
```
Click en "Más tarde"
    ↓
Diálogo se cierra
    ↓
Próxima verificación en 6 horas
```

## 🎨 Diseño del Diálogo

### Elementos Visuales:

**Icono Principal**: 
- 🔔 `Icons.notifications_active`
- Color naranja para llamar la atención

**Título**: 
- 💰 "Recordatorio de Ahorro"
- Negrita para destacar

**Tarjeta de Información** (fondo azul claro):
- 🏁 Icono de meta + Nombre de la meta
- **Línea divisoria**
- 🔢 Número de cuota
- 💵 Monto a pagar (formato $X.XXX)
- 📅 Fecha programada (dd/MM/yyyy)

**Botones de Acción**:
- "Más tarde" → TextButton (gris, discreto)
- "Pagar ahora" → ElevatedButton (verde, prominente) con ícono ✓

## 🔄 Ciclo de Verificación

```
Inicio de Aplicación
    ↓
Verificación Inmediata ────────┐
    ↓                          │
Timer de 6 horas               │
    ↓                          │
Verificación Automática ───────┘
    ↓
Repetir cada 6 horas
```

## 💾 Dependencias Agregadas

```yaml
dependencies:
  flutter_local_notifications: ^17.2.3  # Sistema de notificaciones
  timezone: ^0.9.4                       # Manejo de zonas horarias
```

## 🔧 Configuración Técnica

### Inicialización en HomeScreen:

```dart
final _notificacionService = NotificacionCuotaService();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _notificacionService.inicializar(context, usuario: widget.usuario);
  });
}

@override
void dispose() {
  _notificacionService.detener();
  super.dispose();
}
```

### Clase CuotaPendiente:

```dart
class CuotaPendiente {
  final MetaAhorro meta;
  final CuotaAhorro cuota;
  final Usuario usuario;
}
```

## 🌐 Integración con Backend

### Endpoints Utilizados:

#### 1. Pagar Cuota:
```
POST /api/v1/usuario-service/metas-ahorro/{metaId}/cuotas/{cuotaId}/pagar
```

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
```

**Respuesta Exitosa (200):**
```json
{
  "message": "Cuota pagada exitosamente",
  "cuota": {
    "id": 123,
    "numeroCuota": 3,
    "montoCuota": 100000,
    "fechaPago": "2025-11-09",
    "estado": "PAGADA"
  }
}
```

#### 2. Registrar Gasto (Automático):
```
POST /api/v1/usuario-service/usuarios/{usuarioId}/gastos
```

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
```

**Body:**
```json
{
  "nombreGasto": "Ahorro: Vacaciones 2026 (Cuota #3)",
  "valorGasto": 100000.0,
  "estadoGasto": "fijo"
}
```

**Respuesta Exitosa (200/201):**
```json
{
  "id": 456,
  "nombreGasto": "Ahorro: Vacaciones 2026 (Cuota #3)",
  "valorGasto": 100000.0,
  "estadoGasto": "fijo"
}
```

## ⚡ Optimizaciones Implementadas

1. **Verificación de Contexto**:
   - Valida que el BuildContext esté montado antes de mostrar diálogos
   - Previene errores de navegación después de dispose

2. **Manejo de Memoria**:
   - Timer se cancela en dispose()
   - Previene memory leaks
   - Limpia referencias al contexto

3. **Verificación Condicional**:
   - Solo verifica si hay usuario autenticado
   - Solo procesa metas activas
   - Solo muestra cuotas del día actual

4. **Experiencia de Usuario**:
   - Feedback visual inmediato
   - Mensajes de error claros
   - Prevención de doble procesamiento

## 🎯 Casos de Uso

### Caso 1: Usuario con una cuota hoy
```
Usuario abre app → Aparece notificación → Paga cuota → ✓ Éxito
```

### Caso 2: Usuario con múltiples cuotas hoy
```
Usuario paga primera cuota → Aparece segunda notificación → Decide después
```

### Caso 3: Usuario sin cuotas pendientes
```
Usuario abre app → No hay notificaciones → Uso normal de la app
```

### Caso 4: Error al pagar
```
Usuario intenta pagar → Error de conexión → Mensaje de error → Puede reintentar
```

## 📊 Información Mostrada al Usuario

### En el Diálogo:
- ✅ Nombre de la meta de ahorro
- ✅ Número de cuota (Ej: Cuota #3)
- ✅ Monto exacto a pagar
- ✅ Fecha programada original
- ✅ Estado visual con iconos

### En el SnackBar de Confirmación:
- ✅ "¡Pago exitoso!"
- ✅ Cuota pagada y meta asociada
- ✅ Botón para ver detalle de la meta

## 🛠️ Manejo de Errores

### Errores Capturados:

1. **Error de Conexión**:
```
"No se puede conectar al servidor"
```

2. **Sesión Expirada**:
```
"Sesión expirada. Por favor inicia sesión nuevamente"
```

3. **Error del Backend**:
```
"Error al procesar el pago: [mensaje del backend]"
```

4. **Timeout**:
```
"Tiempo de espera agotado. El servidor no responde"
```

## 🔐 Seguridad

- ✅ JWT token incluido en todas las peticiones
- ✅ Validación de usuario autenticado
- ✅ Verificación de propiedad de la meta
- ✅ Transacciones atómicas en el backend

## 📈 Mejoras Futuras Sugeridas

1. **Notificaciones Push**:
   - Firebase Cloud Messaging
   - Notificaciones incluso con app cerrada
   - Notificaciones programadas anticipadas (1 día antes)

2. **Personalización**:
   - Hora preferida para notificaciones
   - Frecuencia de verificación configurable
   - Activar/desactivar notificaciones por meta

3. **Historial**:
   - Ver notificaciones pasadas
   - Estadísticas de pagos a tiempo
   - Recordatorios de cuotas vencidas

4. **Integraciones**:
   - Calendario del sistema
   - Recordatorios del SO
   - Widget de cuotas pendientes

5. **Analytics**:
   - Tasa de respuesta a notificaciones
   - Tiempo promedio de respuesta
   - Cuotas más frecuentemente pospuestas

## 🎨 Capturas de Funcionalidad

### Diálogo de Notificación:
```
┌────────────────────────────────┐
│  🔔                            │
│  💰 Recordatorio de Ahorro     │
│                                │
│  Hoy tienes programado...      │
│                                │
│  ┌──────────────────────────┐ │
│  │ 🏁 Vacaciones 2026       │ │
│  │ ─────────────────────    │ │
│  │ 🔢 Cuota #: 3            │ │
│  │ 💵 Monto: $100.000       │ │
│  │ 📅 Fecha: 09/11/2025     │ │
│  └──────────────────────────┘ │
│                                │
│  ¿Deseas realizar el pago?     │
│                                │
│  [Más tarde]  [✓ Pagar ahora]  │
└────────────────────────────────┘
```

## 🚀 Activación

La funcionalidad se activa automáticamente cuando:
1. ✅ Usuario inicia sesión
2. ✅ Navega al HomeScreen
3. ✅ Tiene metas de ahorro activas
4. ✅ Hay cuotas programadas para hoy

## 📝 Notas de Implementación

- **Timer**: Se usa `Timer.periodic` para verificaciones recurrentes
- **Context Safety**: Se verifica `mounted` antes de usar BuildContext
- **Memory Management**: Timer se cancela en dispose()
- **User Experience**: Verificación inmediata + verificaciones periódicas
- **Error Handling**: Try-catch completo con mensajes descriptivos
- **Registro Automático**: Cada pago de cuota se registra como gasto automáticamente

## 💳 Registro Automático de Gastos

### Características del Registro:

**Formato del Nombre**:
```
Ahorro: {Nombre de la Meta} (Cuota #{Número})
```
Ejemplo: `"Ahorro: Vacaciones 2026 (Cuota #3)"`

**Tipo de Gasto**:
- Se registra como **"fijo"** porque las cuotas programadas son gastos recurrentes
- Esto permite al usuario ver el impacto real de sus ahorros en sus finanzas

**Valor del Gasto**:
- Se registra exactamente el `montoCuota` de la cuota pagada
- Mantiene precisión decimal sin redondeos

### Flujo de Registro:

```
Pago exitoso de cuota
    ↓
Llamar a usuarioService.agregarGasto()
    ↓
Backend registra en tabla de gastos
    ↓
Gasto asociado al usuario
    ↓
Visible en pantalla de Gastos
    ↓
Incluido en reportes PDF
    ↓
Suma al total de gastos del usuario
```

### Manejo de Errores:

Si el registro del gasto falla:
- ✅ El pago de la cuota YA fue procesado (no se revierte)
- ✅ Se registra un log en consola para debugging
- ✅ No se muestra error al usuario (para no confundirlo)
- ✅ El usuario puede agregar el gasto manualmente si lo desea

Razón: La integridad del pago de la cuota es más importante que el registro del gasto. El gasto es una característica adicional de conveniencia.

### Ventajas del Registro Automático:

1. **Visibilidad Financiera**:
   - El usuario ve cuánto dinero destina a ahorros
   - Puede comparar gastos vs ahorros fácilmente

2. **Reportes Completos**:
   - Los informes PDF incluyen los pagos de cuotas
   - Balance financiero más preciso

3. **Historial Detallado**:
   - Cada pago de cuota queda registrado con fecha
   - Fácil de rastrear y auditar

4. **Sin Esfuerzo Adicional**:
   - El usuario no necesita registrar manualmente
   - Un solo click hace todo el proceso

5. **Gastos Fijos Identificables**:
   - Se marcan como "fijo" para análisis
   - Fácil de categorizar y planificar

### Ejemplo de Gasto Registrado:

```dart
{
  "id": 456,
  "nombreGasto": "Ahorro: Vacaciones 2026 (Cuota #3)",
  "valorGasto": 100000.0,
  "estadoGasto": "fijo"
}
```

### Integración con Otras Pantallas:

**GastosScreen**:
- Los pagos de cuotas aparecen en la lista de gastos
- Se pueden editar o eliminar como cualquier otro gasto
- Se incluyen en el total de gastos

**PDFService**:
- Los pagos de cuotas aparecen en informes financieros
- Se categorizan como gastos fijos
- Se suman al total de gastos del período

**HomeScreen**:
- El balance incluye estos gastos
- Se reflejan en el cálculo de disponibilidad de ahorro

## 🎉 Beneficios para el Usuario

1. **Nunca olvida un pago**: Recordatorios automáticos
2. **Pago rápido**: Un solo click para pagar
3. **Registro automático**: El pago se registra como gasto sin esfuerzo adicional
4. **Historial completo**: Todos los pagos de cuotas quedan en el registro de gastos
5. **Información clara**: Todo lo necesario en un vistazo
6. **Flexibilidad**: Puede posponer si lo necesita
7. **Confirmación visual**: Sabe inmediatamente si el pago fue exitoso
8. **Trazabilidad**: Puede ver el impacto de sus ahorros en sus finanzas generales

---

**Fecha de Implementación**: 9 de noviembre de 2025  
**Versión**: 1.0.0  
**Estado**: ✅ Implementado y funcional  
**Plataformas**: Android, iOS, Web, Windows, macOS, Linux
