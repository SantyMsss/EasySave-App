# 🔧 Documentación Técnica - Módulo de Metas de Ahorro

## 📦 Estructura de Archivos

```
easysave/
├── lib/
│   ├── models/
│   │   └── meta_ahorro.dart          # Modelos de datos
│   ├── services/
│   │   └── meta_ahorro_service.dart  # Servicio HTTP
│   └── screens/
│       ├── metas_ahorro_screen.dart          # Pantalla principal
│       ├── meta_ahorro_detalle_screen.dart   # Pantalla de detalle
│       └── home_screen.dart                  # (Modificado)
├── METAS_AHORRO_GUIDE.md             # Guía de usuario
└── METAS_AHORRO_TECH.md              # Este archivo
```

---

## 🗂️ Modelos de Datos

### `CuotaAhorro`
Representa una cuota individual de pago.

```dart
class CuotaAhorro {
  final int? id;
  final int numeroCuota;         // Número secuencial (1, 2, 3...)
  final double montoCuota;       // Valor a pagar
  final String fechaProgramada;  // Fecha objetivo (YYYY-MM-DD)
  final String? fechaPago;       // Fecha real de pago (nullable)
  final String estado;           // PENDIENTE | PAGADA | VENCIDA
}
```

**Métodos:**
- `fromJson(Map<String, dynamic>)`: Deserialización
- `toJson()`: Serialización

### `MetaAhorro`
Representa una meta de ahorro completa.

```dart
class MetaAhorro {
  final int? id;
  final String nombreMeta;
  final double montoObjetivo;
  final double montoAhorrado;
  final double? montoFaltante;         // Calculado en backend
  final double? progresoPorcentaje;    // Calculado en backend
  final int numeroCuotas;
  final double valorCuota;             // Calculado automáticamente
  final String frecuenciaCuota;        // SEMANAL | QUINCENAL | MENSUAL
  final String fechaInicio;
  final String fechaFinEstimada;
  final String estado;                 // ACTIVA | COMPLETADA | CANCELADA
  final double? porcentajeBalance;
  final int? cuotasPagadas;            // Calculado en backend
  final int? cuotasPendientes;         // Calculado en backend
  final List<CuotaAhorro>? proximasCuotas;
}
```

**Características:**
- Campos opcionales para flexibilidad
- Conversión automática de tipos numéricos
- Manejo seguro de listas nulas

### `SugerenciaAhorro`
Respuesta del endpoint de sugerencias.

```dart
class SugerenciaAhorro {
  final String mensaje;
  final MetaAhorro sugerencia;
  final String? nota;
}
```

---

## 🌐 Servicio HTTP

### `MetaAhorroService`

**Configuración:**
```dart
static const String baseUrl = 'http://localhost:8080/api/v1/usuario-service';
```

**Autenticación:**
Usa `AuthService` para obtener headers JWT automáticamente:
```dart
Future<Map<String, String>> get _authHeaders async {
  return await _authService.getAuthHeaders();
}
```

### Métodos Implementados

#### 1. `crearMetaAhorro(int usuarioId, Map<String, dynamic> metaData)`
```dart
POST /usuarios/{usuarioId}/metas-ahorro
```
**Request Body:**
```json
{
  "nombreMeta": "Vacaciones 2026",
  "montoObjetivo": 2000000.0,
  "numeroCuotas": 10,
  "frecuenciaCuota": "MENSUAL",
  "porcentajeBalance": 25.0  // Opcional
}
```
**Returns:** `MetaAhorro`

#### 2. `listarMetasAhorro(int usuarioId)`
```dart
GET /usuarios/{usuarioId}/metas-ahorro
```
**Returns:** `List<MetaAhorro>`

#### 3. `listarMetasActivas(int usuarioId)`
```dart
GET /usuarios/{usuarioId}/metas-ahorro/activas
```
**Returns:** `List<MetaAhorro>` (solo ACTIVAS)

#### 4. `obtenerDetalleMeta(int metaId)`
```dart
GET /metas-ahorro/{metaId}
```
**Returns:** `MetaAhorro` (con cuotas completas)

#### 5. `pagarCuota(int metaId, int cuotaId)`
```dart
POST /metas-ahorro/{metaId}/cuotas/{cuotaId}/pagar
```
**Returns:** `Map<String, dynamic>` con mensaje y estado actualizado

#### 6. `calcularSugerenciaAhorro(int usuarioId, {params})`
```dart
GET /usuarios/{usuarioId}/sugerencia-ahorro?porcentajeBalance=25&numeroCuotas=12&frecuencia=MENSUAL
```
**Parámetros opcionales:**
- `porcentajeBalance`: double (default 20)
- `numeroCuotas`: int (default 12)
- `frecuencia`: String (default MENSUAL)

**Returns:** `SugerenciaAhorro`

#### 7. `cancelarMeta(int metaId)`
```dart
DELETE /metas-ahorro/{metaId}
```
**Returns:** `void`

#### 8. `actualizarCuotasVencidas()`
```dart
POST /metas-ahorro/actualizar-vencidas
```
**Returns:** `void`

### Manejo de Errores

Todos los métodos implementan:
```dart
try {
  // Lógica
} on TimeoutException {
  throw Exception('Tiempo de espera agotado.');
} on http.ClientException {
  throw Exception('No se puede conectar al servidor.');
} catch (e) {
  if (e is Exception) rethrow;
  throw Exception('Error: ${e.toString()}');
}
```

**Códigos HTTP manejados:**
- `200/201`: Éxito
- `400`: Bad Request (muestra mensaje del backend)
- `401`: No autorizado (sesión expirada)
- `404`: No encontrado
- `500+`: Error del servidor

---

## 🖼️ Pantallas

### `MetasAhorroScreen`

**State Management:**
```dart
class _MetasAhorroScreenState extends State<MetasAhorroScreen> {
  final _metaAhorroService = MetaAhorroService();
  List<MetaAhorro> _metas = [];
  bool _isLoading = true;
  int _filtroEstado = 0; // 0: Todas, 1: Activas, 2: Completadas
}
```

**Widgets principales:**

1. **SegmentedButton** para filtros:
```dart
SegmentedButton<int>(
  segments: [
    ButtonSegment(value: 0, label: Text('Todas')),
    ButtonSegment(value: 1, label: Text('Activas')),
    ButtonSegment(value: 2, label: Text('Completadas')),
  ],
  selected: {_filtroEstado},
  onSelectionChanged: (newSelection) => _cargarMetas(),
)
```

2. **Card** personalizado para cada meta:
- Header con ícono y estado
- Barra de progreso lineal
- Información financiera
- Botones de acción condicionales

3. **FloatingActionButton** para crear meta

**Diálogos:**

- `_mostrarDialogoCrearMeta()`: Form con validación
- `_mostrarSugerencia()`: Muestra cálculo automático
- `_confirmarCancelar()`: Confirmación de cancelación

### `MetaAhorroDetalleScreen`

**State Management:**
```dart
class _MetaAhorroDetalleScreenState extends State<MetaAhorroDetalleScreen> {
  final _metaAhorroService = MetaAhorroService();
  MetaAhorro? _meta;
  bool _isLoading = true;
}
```

**Widgets principales:**

1. **Gráfico Circular de Progreso:**
```dart
Stack(
  alignment: Alignment.center,
  children: [
    SizedBox(
      width: 150, height: 150,
      child: CircularProgressIndicator(
        value: progreso / 100,
        strokeWidth: 12,
      ),
    ),
    Column(children: [
      Text('${progreso.toStringAsFixed(1)}%'),
      Text(_meta.estado),
    ]),
  ],
)
```

2. **Lista de Cuotas:**
```dart
ListView.separated(
  itemCount: cuotas.length,
  separatorBuilder: (context, index) => const Divider(),
  itemBuilder: (context, index) {
    final cuota = cuotas[index];
    return ListTile(
      leading: CircleAvatar(/* estado icon */),
      title: Text('Cuota #${cuota.numeroCuota}'),
      subtitle: Text(/* fechas */),
      trailing: Column(/* monto y badge */),
      onTap: () => _pagarCuota(cuota),
    );
  },
)
```

3. **Mensajes Motivacionales:**
- Activa: Gradient azul/morado con trofeo
- Completada: Verde con celebración

**RefreshIndicator:**
Pull-to-refresh implementado para actualizar datos

---

## 🎨 Utilidades de UI

### Colores por Estado

```dart
Color _getColorByEstado(String estado) {
  switch (estado) {
    case 'ACTIVA': return Colors.blue;
    case 'COMPLETADA': return Colors.green;
    case 'CANCELADA': return Colors.red;
    default: return Colors.grey;
  }
}
```

### Iconos por Frecuencia

```dart
IconData _getIconByFrecuencia(String frecuencia) {
  switch (frecuencia) {
    case 'SEMANAL': return Icons.calendar_view_week;
    case 'QUINCENAL': return Icons.calendar_view_month;
    case 'MENSUAL': return Icons.calendar_month;
    default: return Icons.calendar_today;
  }
}
```

### Formateador de Moneda

Usa `CurrencyFormatter.format()` del proyecto:
```dart
CurrencyFormatter.format(2000000.0) // "$ 2,000,000"
```

---

## 🔄 Flujo de Datos

```
Usuario interactúa → Widget
                      ↓
                setState(() => _isLoading = true)
                      ↓
                MetaAhorroService
                      ↓
                HTTP Request + JWT
                      ↓
                Backend API
                      ↓
                JSON Response
                      ↓
                Model.fromJson()
                      ↓
                setState(() { _data = parsed, _isLoading = false })
                      ↓
                Widget rebuild → UI actualizada
```

---

## 🛡️ Validaciones

### Crear Meta:
```dart
if (nombreController.text.isEmpty || 
    montoController.text.isEmpty ||
    cuotasController.text.isEmpty) {
  ScaffoldMessenger.showSnackBar(/* error */);
  return;
}
```

### Pagar Cuota:
```dart
if (cuota.estado != 'PENDIENTE' && cuota.estado != 'VENCIDA') {
  ScaffoldMessenger.showSnackBar(/* ya pagada */);
  return;
}
```

---

## 🧪 Testing Recomendado

### Unit Tests
```dart
test('CuotaAhorro fromJson debe parsear correctamente', () {
  final json = {
    'id': 1,
    'numeroCuota': 1,
    'montoCuota': 200000.0,
    'fechaProgramada': '2025-11-05',
    'estado': 'PENDIENTE',
  };
  
  final cuota = CuotaAhorro.fromJson(json);
  
  expect(cuota.id, 1);
  expect(cuota.numeroCuota, 1);
  expect(cuota.estado, 'PENDIENTE');
});
```

### Widget Tests
```dart
testWidgets('MetasAhorroScreen muestra mensaje cuando no hay metas', 
  (WidgetTester tester) async {
    await tester.pumpWidget(/* widget */);
    expect(find.text('No tienes metas de ahorro'), findsOneWidget);
  }
);
```

### Integration Tests
```dart
testWidgets('Crear meta y verificar en lista', (WidgetTester tester) async {
  // 1. Tap en botón Nueva Meta
  // 2. Llenar formulario
  // 3. Tap en Crear
  // 4. Verificar que aparece en lista
});
```

---

## 📊 Métricas de Performance

**Optimizaciones implementadas:**
- ✅ Carga lazy de detalles (solo al entrar a detalle)
- ✅ setState mínimo (solo datos necesarios)
- ✅ ListView.builder para listas grandes
- ✅ Timeouts en requests HTTP (10 segundos)
- ✅ Pull-to-refresh en lugar de auto-reload

**Tiempos esperados:**
- Listar metas: < 500ms
- Crear meta: < 1s
- Pagar cuota: < 800ms
- Calcular sugerencia: < 600ms

---

## 🔐 Seguridad

**Implementado:**
- ✅ JWT en todos los requests
- ✅ Validación de sesión (401 redirect)
- ✅ Sanitización de inputs (FilteringTextInputFormatter)
- ✅ Confirmaciones para acciones destructivas

**No implementado (backend):**
- Validación de propiedad (usuario solo ve sus metas)
- Rate limiting
- Validación de montos negativos

---

## 🐛 Troubleshooting

### Error: "No se puede conectar al servidor"
**Causa:** Backend no está corriendo
**Solución:** Iniciar backend en `localhost:8080`

### Error: "Sesión expirada"
**Causa:** JWT caducado
**Solución:** Hacer logout y login nuevamente

### Error: "Meta no encontrada" (404)
**Causa:** ID de meta inválido o eliminado
**Solución:** Refrescar lista de metas

### Progress no actualiza después de pagar
**Causa:** Cache local no actualizado
**Solución:** Pull-to-refresh o navegar atrás y re-entrar

---

## 🚀 Próximas Mejoras Técnicas

1. **State Management Mejorado:**
   - Implementar Provider/Riverpod
   - Caché de datos con Hive/Shared Preferences
   
2. **Offline First:**
   - Sincronización cuando hay conexión
   - Queue de pagos pendientes
   
3. **Animaciones:**
   - Hero transitions entre screens
   - Animación de progreso circular
   
4. **Accesibilidad:**
   - Semantics para screen readers
   - Contraste de colores AA/AAA
   
5. **i18n:**
   - Soporte multi-idioma
   - Formato de fechas localizadas

---

## 📚 Dependencias Utilizadas

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # HTTP requests
  fl_chart: ^0.66.0         # Gráficos (ya en proyecto)
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.3           # Para mocking en tests
```

---

## 👥 Contribución

Para agregar nuevas funcionalidades:

1. Crear branch: `feature/metas-ahorro-{feature}`
2. Seguir estructura de archivos existente
3. Documentar nuevos endpoints en este archivo
4. Agregar tests correspondientes
5. Update `METAS_AHORRO_GUIDE.md` con UI changes

---

**Desarrollado para EasySave App - Flutter 3.x**
