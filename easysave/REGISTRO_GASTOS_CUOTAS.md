# 💳 Registro Automático de Gastos al Pagar Cuotas

## 📋 Descripción

Se ha implementado el registro automático de gastos cuando el usuario paga una cuota de ahorro programada. Cada pago de cuota se registra automáticamente en el sistema de gastos del usuario.

## ✅ Implementación Completada

### Características:

1. **Registro Automático en AMBOS lugares**:
   - ✅ **Desde el diálogo de notificaciones** (HomeScreen): Cuando aparece la notificación automática
   - ✅ **Desde la pantalla de detalle de meta**: Cuando pagas manualmente desde la lista de cuotas
   - Al pagar una cuota, se crea automáticamente un gasto
   - El usuario no necesita hacer nada adicional
   - Proceso transparente y automático

2. **Formato del Gasto**:
   ```
   Nombre: "Ahorro: {Nombre Meta} (Cuota #{Número})"
   Valor: {Monto de la cuota}
   Tipo: "fijo"
   ```

3. **Ejemplo**:
   ```json
   {
     "nombreGasto": "Ahorro: Vacaciones 2026 (Cuota #4)",
     "valorGasto": 375000.0,
     "estadoGasto": "fijo"
   }
   ```

4. **Feedback Visual**:
   - ✅ Si el gasto se registra exitosamente: Mensaje verde con "✓ Registrado como gasto"
   - ⚠️ Si falla el registro: Mensaje naranja con el error específico
   - El pago de la cuota siempre se procesa, incluso si falla el registro del gasto

## 🔄 Flujo Completo

```
Usuario hace click en "Pagar" en el diálogo
    ↓
Se muestra "Procesando pago..."
    ↓
1. Backend procesa el pago de la cuota ✓
    ↓
2. Se registra automáticamente como gasto ✓
    ↓
3. Se cierra el diálogo de progreso
    ↓
4. Se muestra mensaje de confirmación
    ↓
El usuario ve el resultado y el estado del registro
```

## 🧪 Cómo Verificar que Funciona

### Opción A: Desde el Diálogo de Notificaciones

#### Paso 1: Crear una Meta de Ahorro con Cuota para Hoy
1. Abre la app y ve a "Metas de Ahorro"
2. Crea una nueva meta con:
   - Nombre: "Prueba Gasto"
   - Monto: $500.000
   - Cuotas: 5
   - Frecuencia: Mensual
3. Asegúrate de que la primera cuota esté programada para hoy

#### Paso 2: Esperar la Notificación
1. Ve al HomeScreen
2. Debería aparecer automáticamente un diálogo de notificación
3. El diálogo muestra:
   - Meta: Prueba Gasto
   - Cuota #: 1
   - Monto: $100.000
   - Fecha: Hoy

#### Paso 3: Pagar la Cuota
1. Haz click en "Pagar ahora"
2. Se muestra un indicador de progreso
3. Observa el mensaje de confirmación con el estado del registro del gasto

### Opción B: Desde la Pantalla de Detalle de Meta

#### Paso 1: Navegar a una Meta
1. Abre la app y ve a "Metas de Ahorro"
2. Selecciona cualquier meta activa que tenga cuotas pendientes
3. Verás la lista de cuotas programadas

#### Paso 2: Pagar una Cuota
1. Haz click en cualquier cuota con estado "PENDIENTE" o "VENCIDA"
2. Aparecerá un diálogo de confirmación que indica:
   - "Este pago se registrará automáticamente como gasto"
3. Haz click en "Pagar"
4. Se muestra un indicador de progreso "Procesando pago..."

#### Paso 3: Ver Confirmación
1. Observa el mensaje de confirmación:
   - **Verde**: "¡Pago exitoso! ✓ Registrado como gasto"
   - **Naranja**: "¡Pago exitoso! ⚠ No se pudo registrar como gasto: [error]"
2. La pantalla se actualiza automáticamente

### Paso 4 (Para ambas opciones): Verificar el Gasto Registrado
1. Ve a la pantalla de "Mis Gastos"
2. **Refresca la lista** (botón de actualizar en la barra superior)
3. Deberías ver un nuevo gasto:
   - Nombre: "Ahorro: Prueba Gasto (Cuota #1)"
   - Valor: $100.000
   - Tipo: Fijo

### Paso 5: Verificar en el PDF
1. Desde "Mis Gastos", genera un informe PDF
2. En la sección "Gastos Fijos" deberías ver el pago de la cuota
3. Se suma al total de gastos

## 📊 Logs en Consola

Durante el proceso, se imprimen logs útiles para debugging:

```
✅ Pago de cuota registrado como gasto: Ahorro: Prueba Gasto (Cuota #1)
📊 Respuesta del servidor: {id: 123, nombreGasto: Ahorro: Prueba Gasto (Cuota #1), ...}
```

O en caso de error:

```
⚠️ Error al registrar gasto de cuota: Sesión expirada. Por favor inicia sesión nuevamente.
```

## 🔧 Detalles Técnicos

### Archivos Modificados:

#### 1. `lib/services/notificacion_cuota_service.dart`
- **Método**: `_procesarPagoCuota()`
- **Funcionalidad**: Paga cuota y registra gasto automáticamente desde notificaciones
- **Flujo**:
  1. Muestra diálogo de progreso
  2. Llama a `pagarCuota()` del backend
  3. Llama a `agregarGasto()` del backend
  4. Muestra mensaje de éxito con estado del registro

#### 2. `lib/screens/meta_ahorro_detalle_screen.dart` (NUEVO)
- **Método**: `_pagarCuota()`
- **Funcionalidad**: Paga cuota y registra gasto automáticamente desde pantalla de detalle
- **Mejoras agregadas**:
  - Mensaje informativo en el diálogo: "Este pago se registrará automáticamente como gasto"
  - Indicador de progreso durante el procesamiento
  - Logs detallados en consola
  - Feedback visual mejorado con estado del registro

### Código en `notificacion_cuota_service.dart`:

```dart
// Registrar el pago como un gasto
bool gastoRegistrado = false;
String errorGasto = '';
try {
  final nombreGasto = 'Ahorro: ${cuotaPendiente.meta.nombreMeta} (Cuota #${cuotaPendiente.cuota.numeroCuota})';
  final resultado = await _usuarioService.agregarGasto(
    cuotaPendiente.usuario.id!,
    {
      'nombreGasto': nombreGasto,
      'valorGasto': cuotaPendiente.cuota.montoCuota,
      'estadoGasto': 'fijo',
    },
  );
  gastoRegistrado = true;
} catch (e) {
  errorGasto = e.toString().replaceAll('Exception: ', '');
}
```

### Endpoints del Backend Utilizados:

1. **Pagar Cuota**:
   ```
   POST /api/v1/usuario-service/metas-ahorro/{metaId}/cuotas/{cuotaId}/pagar
   ```

2. **Registrar Gasto**:
   ```
   POST /api/v1/usuario-service/usuarios/{usuarioId}/gastos
   ```

## 🛠️ Solución de Problemas

### Problema: "No se ve el gasto en la lista"
**Solución**: 
- Presiona el botón de actualizar (🔄) en la pantalla de Gastos
- El servicio registra el gasto pero la UI no se actualiza automáticamente

### Problema: "El mensaje dice que no se pudo registrar como gasto"
**Causas posibles**:
1. **Token JWT expirado**: Cierra sesión e inicia sesión nuevamente
2. **Backend no disponible**: Verifica que el servidor esté corriendo en `localhost:8080`
3. **Error de red**: Verifica tu conexión a internet

**Solución**:
- Lee el mensaje de error específico en el SnackBar
- Revisa los logs en consola para más detalles
- Puedes agregar el gasto manualmente desde la pantalla de Gastos

### Problema: "La cuota se pagó pero no apareció el gasto"
**Nota importante**:
- El sistema prioriza el pago de la cuota sobre el registro del gasto
- Si el registro del gasto falla, la cuota ya fue pagada exitosamente
- Puedes verificar en la meta que la cuota cambió a "PAGADA"
- Si es necesario, agrega el gasto manualmente

## ✨ Ventajas del Sistema

1. **Automatización**: No necesitas recordar registrar el gasto
2. **Precisión**: El monto es exacto, sin errores de digitación
3. **Trazabilidad**: Puedes ver cuánto has destinado a cada meta de ahorro
4. **Reportes Completos**: Los informes PDF incluyen estos gastos
5. **Balance Real**: Tu balance financiero refleja realmente tus ahorros
6. **Gastos Categorizados**: Se marcan como "fijos" para análisis

## 📈 Impacto en la Aplicación

### HomeScreen:
- El balance incluye estos gastos
- Se actualiza el disponible para ahorrar

### GastosScreen:
- Los pagos de cuotas aparecen en la lista
- Se pueden editar o eliminar si es necesario
- Se suman al total de gastos

### Informes PDF:
- Aparecen en la sección "Gastos Fijos"
- Se incluyen en el total de gastos
- Afectan el balance mostrado

### MetasAhorroScreen:
- El progreso de la meta se actualiza
- La cuota cambia a estado "PAGADA"
- Se actualiza el monto ahorrado

## 🎯 Casos de Uso

### Caso 1: Usuario paga cuota regularmente
```
Usuario recibe notificación → Paga cuota → 
Gasto se registra automáticamente → 
Ve el impacto en su balance
```

### Caso 2: Usuario quiere ver cuánto destina a ahorros
```
Usuario va a Gastos → 
Filtra por "Ahorro:" en el buscador → 
Ve todos los pagos de cuotas realizados
```

### Caso 3: Usuario genera reporte mensual
```
Usuario genera PDF de ingresos/gastos → 
El informe incluye todos los pagos de cuotas → 
Ve el balance considerando sus ahorros
```

## 📝 Notas Finales

- ✅ **Implementación completa y funcional**
- ✅ **Manejo robusto de errores**
- ✅ **Feedback claro al usuario**
- ✅ **Logs detallados para debugging**
- ✅ **No interrumpe el flujo principal**
- ✅ **Compatible con todos los features existentes**

---

**Fecha de Implementación**: 9 de noviembre de 2025  
**Versión**: 1.1.0  
**Estado**: ✅ Implementado y Documentado  
**Autor**: Sistema de Notificaciones EasySave
