# 🎯 Preview de Metas de Ahorro en Home Screen

## 📝 Cambios Implementados

Se ha agregado una **tarjeta de preview** de metas de ahorro activas en la pantalla principal (Home Screen) para que los usuarios puedan ver rápidamente el estado de sus metas sin necesidad de navegar a la pantalla completa.

---

## ✨ Características del Preview

### 🎨 Diseño Visual
- **Card elevado** con bordes redondeados
- **Header** con ícono de bandera y título "Tus Metas de Ahorro"
- **Botón "Ver todas"** para navegar a la pantalla completa
- **Hasta 3 metas activas** mostradas en el preview

### 📊 Información Mostrada por Meta
Cada meta en el preview muestra:
- ✅ **Nombre de la meta**
- 📈 **Porcentaje de progreso** (badge azul)
- 💰 **Monto ahorrado** vs **Monto objetivo**
- 📊 **Barra de progreso visual** (linear progress indicator)
- 📅 **Cuotas pagadas/total** y **frecuencia de pago**
- 💵 **Valor de cada cuota**

### 🎯 Estados del Preview

#### 1️⃣ Cargando
- Muestra un **CircularProgressIndicator** mientras carga las metas

#### 2️⃣ Sin Metas Activas
- Ícono de ahorro gris
- Mensaje: "No tienes metas activas"
- Botón "Crear Meta" para navegar directamente

#### 3️⃣ Con Metas Activas
- Lista de hasta 3 metas con toda la información
- Si hay más de 3 metas, muestra botón "Ver todas las metas"

---

## 🔄 Navegación

### Desde el Preview:
1. **Clic en una meta individual** → Navega a detalle de esa meta
2. **Botón "Ver todas"** (arriba derecha) → Navega a lista completa
3. **Botón "Ver todas las metas"** (abajo) → Navega a lista completa (cuando hay 3+ metas)
4. **Botón "Crear Meta"** → Navega a pantalla de metas (cuando no hay metas)

### Actualización Automática:
- Al volver de cualquier navegación, **se recargan las metas** automáticamente

---

## 🎨 Paleta de Colores

- **Fondo de meta**: `Colors.blue[50]` (azul claro)
- **Borde**: `Colors.blue[200]` (azul suave)
- **Badge de progreso**: `Colors.blue[100]` / `Colors.blue[900]`
- **Barra de progreso**: `Colors.blue[600]`
- **Monto ahorrado**: `Colors.green[700]` (verde)
- **Texto secundario**: `Colors.grey[600]`

---

## 🧩 Componentes Técnicos

### State Variables Agregadas:
```dart
List<MetaAhorro> _metasActivas = [];
bool _isLoadingMetas = false;
final _metaAhorroService = MetaAhorroService();
```

### Métodos Agregados:

#### `_cargarMetasActivas()`
```dart
Future<void> _cargarMetasActivas() async
```
- Carga las metas activas del usuario
- Limita a las primeras 3 metas
- Manejo silencioso de errores (no muestra SnackBar)

#### `_getIconByFrecuencia(String frecuencia)`
```dart
IconData _getIconByFrecuencia(String frecuencia)
```
- Retorna el ícono apropiado según la frecuencia
- SEMANAL → `Icons.calendar_view_week`
- QUINCENAL → `Icons.calendar_view_month`
- MENSUAL → `Icons.calendar_month`

---

## 📍 Ubicación en la Pantalla

El preview se encuentra:
1. **Después** de las tarjetas de Ingresos/Gastos
2. **Antes** de la sección de Gráficos Estadísticos

```
Home Screen Layout:
├── Tarjeta de Bienvenida
├── Tarjeta de Balance (clickeable)
├── Row: Tarjetas de Ingresos y Gastos
├── 🆕 PREVIEW DE METAS DE AHORRO ← AQUÍ
└── Sección de Gráficos Estadísticos
```

---

## 🎯 Interactividad

### Clickeable:
- ✅ Cada meta individual (lleva al detalle)
- ✅ Botón "Ver todas" (header)
- ✅ Botón "Crear Meta" (cuando no hay metas)
- ✅ Botón "Ver todas las metas" (footer)

### Ripple Effect:
- Cada meta tiene `InkWell` con `borderRadius` para efecto visual al tocar

---

## 📱 Responsive

- El preview se adapta al ancho de la pantalla
- Las metas usan `Expanded` y `overflow: TextOverflow.ellipsis` para nombres largos
- Layout flexible que se ajusta a diferentes tamaños

---

## 🔍 Ejemplo de Vista

### Con 2 Metas Activas:
```
┌─────────────────────────────────────┐
│ 🚩 Tus Metas de Ahorro    Ver todas│
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Vacaciones 2026         65%     │ │
│ │ $ 1,300,000 de $ 2,000,000     │ │
│ │ ████████████░░░░░░░░░░          │ │
│ │ 📅 6/10 cuotas • $200,000/mes  │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Laptop Nueva            40%     │ │
│ │ $ 600,000 de $ 1,500,000       │ │
│ │ ██████░░░░░░░░░░░░░░░░          │ │
│ │ 📅 2/6 cuotas • $250,000/quin  │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Sin Metas:
```
┌─────────────────────────────────────┐
│ 🚩 Tus Metas de Ahorro    Ver todas│
├─────────────────────────────────────┤
│           💰                         │
│   No tienes metas activas           │
│                                      │
│     [➕ Crear Meta]                 │
└─────────────────────────────────────┘
```

---

## ✅ Ventajas del Preview

1. **Visibilidad inmediata** de las metas sin navegación extra
2. **Motivación constante** al ver el progreso en la pantalla principal
3. **Acceso rápido** con un solo tap a los detalles
4. **Información condensada** pero completa
5. **Diseño coherente** con el resto de la app
6. **No invasivo**: Solo aparece si hay metas o están cargando

---

## 🚀 Uso

### Primera Vez (Sin Metas):
1. Usuario ve el preview vacío
2. Hace clic en "Crear Meta"
3. Crea su primera meta
4. Al volver, el preview muestra la meta

### Con Metas Activas:
1. Usuario ve sus 3 metas principales
2. Puede hacer clic en cualquiera para ver detalle
3. Puede hacer clic en "Ver todas" para ver todas sus metas
4. El progreso se actualiza cada vez que vuelve a Home

---

## 🎓 Lecciones Técnicas

### Conditional Rendering:
```dart
if (_metasActivas.isNotEmpty || _isLoadingMetas)
  Card(...) // Solo muestra si hay metas o está cargando
```

### Navigation with Callback:
```dart
Navigator.push(...).then((_) => _cargarMetasActivas());
// Recarga metas al volver
```

### Limited List:
```dart
_metasActivas = metas.take(3).toList();
// Solo las primeras 3
```

---

## 📊 Métricas de UX

- **Menos navegación**: Usuario ve metas sin salir de Home
- **Mayor engagement**: Vista constante del progreso
- **Mejor feedback**: Actualización inmediata al volver
- **Acceso rápido**: 1 tap a detalle vs 2 taps antes

---

**¡El preview está listo para motivar a tus usuarios a ahorrar! 💰✨**
