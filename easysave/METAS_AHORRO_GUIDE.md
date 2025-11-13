# 💰 Guía de Uso - Módulo de Metas de Ahorro

## 📱 Interfaz de Usuario Implementada

### 1. **Acceso al Módulo**
Desde la pantalla principal (`HomeScreen`), haz clic en la **tarjeta de Balance Mensual** que ahora incluye:
- Un ícono de ahorro (💰)
- Texto indicativo: "Tap para ver tus metas de ahorro"
- Flecha de navegación (→)

### 2. **Pantalla Principal de Metas** (`MetasAhorroScreen`)

#### Características:
- **Filtros de visualización:**
  - 📋 **Todas**: Muestra todas las metas
  - ✅ **Activas**: Solo metas en progreso
  - ✓ **Completadas**: Metas alcanzadas

- **Tarjetas de Metas:**
  Cada tarjeta muestra:
  - 🎯 Nombre de la meta
  - 📊 Barra de progreso visual
  - 💵 Monto ahorrado vs. objetivo
  - 📅 Información de cuotas (frecuencia, número)
  - 🏷️ Estado (ACTIVA, COMPLETADA, CANCELADA)
  - 💰 Valor de cuota según frecuencia

- **Acciones disponibles:**
  - ➕ Crear nueva meta (botón flotante)
  - 👁️ Ver detalle de meta (clic en tarjeta)
  - ❌ Cancelar meta activa

### 3. **Crear Nueva Meta de Ahorro**

Al presionar el botón "Nueva Meta", se abre un diálogo con:

**Campos requeridos:**
- 📝 **Nombre de la Meta**: Ej: "Vacaciones 2026"
- 💰 **Monto Objetivo**: Cantidad a ahorrar
- 📊 **Número de Cuotas**: Cantidad de pagos
- 🔄 **Frecuencia de Pago**: 
  - Semanal
  - Quincenal
  - Mensual

**Botones:**
- **Ver Sugerencia**: Calcula automáticamente una meta basada en tu balance (25% del balance disponible)
- **Crear**: Crea la meta con los datos ingresados
- **Cancelar**: Cierra el diálogo

### 4. **Pantalla de Detalle de Meta** (`MetaAhorroDetalleScreen`)

Muestra información completa:

#### Sección de Progreso:
- 🎯 Gráfico circular con porcentaje de avance
- 💚 Monto ahorrado actual
- 🎯 Monto objetivo
- 🟠 Monto faltante por ahorrar

#### Información General:
- 💵 Valor de cuota
- 🔢 Número total de cuotas
- 📅 Frecuencia de pago
- 📆 Fecha de inicio
- 📆 Fecha estimada de finalización
- ✅ Cuotas pagadas
- ⏳ Cuotas pendientes

#### Lista de Cuotas:
Cada cuota muestra:
- 🔢 Número de cuota
- 💰 Monto a pagar
- 📅 Fecha programada
- ✅ Fecha de pago (si ya se pagó)
- 🏷️ Estado:
  - 🟠 **PENDIENTE**: Aún no se ha pagado
  - ✅ **PAGADA**: Ya fue pagada
  - 🔴 **VENCIDA**: Pasó su fecha y no se pagó

**Acción de Pago:**
- Clic en una cuota pendiente o vencida para pagarla
- Confirmación antes de registrar el pago
- Actualización automática del progreso

### 5. **Sugerencia Inteligente de Ahorro**

La funcionalidad calcula automáticamente:
- 📊 25% del balance disponible (Ingresos - Gastos)
- 📅 12 cuotas mensuales por defecto
- 💵 Valor de cada cuota
- 📆 Proyección de fechas

**Ejemplo:**
```
Balance: $2,250,000
Sugerencia (25%): $562,500
12 cuotas mensuales: $46,875 c/u
```

---

## 🎨 Características Visuales

### Colores por Estado:
- 🔵 **ACTIVA**: Azul
- 🟢 **COMPLETADA**: Verde
- 🔴 **CANCELADA**: Rojo

### Iconos por Frecuencia:
- 📅 **SEMANAL**: Calendario semanal
- 📆 **QUINCENAL**: Calendario mensual
- 🗓️ **MENSUAL**: Calendario completo

### Indicadores de Progreso:
- Barra lineal en lista de metas
- Gráfico circular en detalle
- Porcentajes con decimales

---

## 🔄 Flujo de Usuario Completo

### Caso de Uso: Crear Meta para Vacaciones

1. **Inicio**: Usuario ve su balance de $2,250,000
2. **Navegación**: Clic en tarjeta de Balance
3. **Nueva Meta**: Presiona botón "Nueva Meta"
4. **Ver Sugerencia**: Presiona "Ver Sugerencia"
   - Sistema calcula: $562,500 (25%)
   - 12 cuotas de $46,875
5. **Personalizar**: Usuario modifica:
   - Nombre: "Vacaciones Caribe 2026"
   - Monto: $2,000,000
   - Cuotas: 10
   - Frecuencia: MENSUAL
6. **Crear**: Sistema genera:
   - 10 cuotas de $200,000
   - Fechas automáticas cada mes
   - Meta en estado ACTIVA
7. **Seguimiento**: Usuario ve:
   - Progreso: 0%
   - Primera cuota pendiente
8. **Pagar Cuota**: 
   - Clic en cuota #1
   - Confirmar pago
   - Progreso actualizado: 10%
9. **Repetir**: Pagar cuotas mensualmente
10. **Completar**: Al pagar cuota #10:
    - Estado cambia a COMPLETADA
    - Mensaje de felicitaciones

---

## 🛠️ Archivos Creados

### Modelos:
```
lib/models/meta_ahorro.dart
```
- Clases: `MetaAhorro`, `CuotaAhorro`, `SugerenciaAhorro`

### Servicios:
```
lib/services/meta_ahorro_service.dart
```
- Integración completa con API REST
- 8 endpoints implementados

### Pantallas:
```
lib/screens/metas_ahorro_screen.dart
lib/screens/meta_ahorro_detalle_screen.dart
```

### Modificaciones:
```
lib/screens/home_screen.dart
```
- Importación de `MetasAhorroScreen`
- Tarjeta de balance clickeable
- Navegación implementada

---

## 📡 Endpoints Utilizados

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/usuarios/{id}/metas-ahorro` | POST | Crear meta |
| `/usuarios/{id}/metas-ahorro` | GET | Listar todas |
| `/usuarios/{id}/metas-ahorro/activas` | GET | Listar activas |
| `/metas-ahorro/{id}` | GET | Ver detalle |
| `/metas-ahorro/{metaId}/cuotas/{cuotaId}/pagar` | POST | Pagar cuota |
| `/usuarios/{id}/sugerencia-ahorro` | GET | Calcular sugerencia |
| `/metas-ahorro/{id}` | DELETE | Cancelar meta |
| `/metas-ahorro/actualizar-vencidas` | POST | Actualizar vencidas |

---

## ✨ Funcionalidades Destacadas

✅ **Navegación fluida** desde pantalla principal  
✅ **Sugerencias inteligentes** basadas en balance  
✅ **Cálculos automáticos** de cuotas y fechas  
✅ **Visualización clara** con gráficos y colores  
✅ **Gestión completa** del ciclo de vida de metas  
✅ **Pago de cuotas** con confirmación  
✅ **Actualización en tiempo real** del progreso  
✅ **Mensajes motivacionales** según estado  
✅ **Filtros intuitivos** para organizar metas  
✅ **Diseño responsive** y atractivo  

---

## 🔮 Mejoras Futuras Sugeridas

- 📊 Gráficos de tendencia de ahorro
- 🔔 Notificaciones de cuotas próximas
- 📸 Imágenes para cada meta
- 🎯 Metas compartidas entre usuarios
- 💡 Tips de ahorro personalizados
- 📈 Estadísticas históricas
- 🏆 Sistema de logros y recompensas

---

**¡Disfruta ahorrando con EasySave! 💰✨**
