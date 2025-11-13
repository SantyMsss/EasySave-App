# ✏️ Funcionalidad de Edición de Ingresos y Gastos

## 📋 Resumen de Cambios

Se ha implementado la funcionalidad completa para **editar** ingresos y gastos en la aplicación EasySave Flutter.

---

## 🔄 Archivos Modificados

### 1. **`lib/services/usuario_service.dart`**

#### Métodos Agregados:

**`actualizarIngreso()`**
```dart
Future<Map<String, dynamic>> actualizarIngreso(int ingresoId, Map<String, dynamic> ingreso)
```
- **Endpoint:** `PUT /api/v1/usuario-service/ingresos/{id}`
- **Parámetros:**
  - `ingresoId`: ID del ingreso a actualizar
  - `ingreso`: Objeto con `nombreIngreso`, `valorIngreso`, `estadoIngreso`
- **Autenticación:** Incluye token JWT automáticamente
- **Retorna:** El ingreso actualizado

**`actualizarGasto()`**
```dart
Future<Map<String, dynamic>> actualizarGasto(int gastoId, Map<String, dynamic> gasto)
```
- **Endpoint:** `PUT /api/v1/usuario-service/gastos/{id}`
- **Parámetros:**
  - `gastoId`: ID del gasto a actualizar
  - `gasto`: Objeto con `nombreGasto`, `valorGasto`, `estadoGasto`
- **Autenticación:** Incluye token JWT automáticamente
- **Retorna:** El gasto actualizado

---

### 2. **`lib/screens/ingresos_screen.dart`**

#### Método Agregado:

**`_mostrarDialogoEditar(Ingreso ingreso)`**
- Abre un diálogo modal con los datos actuales del ingreso
- Permite modificar:
  - ✏️ Nombre del ingreso
  - 💰 Valor (solo números)
  - 🏷️ Tipo (Fijo o Variable)
- Pre-rellena los campos con los valores actuales
- Valida que los campos no estén vacíos
- Muestra mensaje de éxito/error después de actualizar

#### Cambios en la UI:

**Antes:**
```
[Valor] [🗑️ Eliminar]
```

**Ahora:**
```
[Valor] [✏️ Editar] [🗑️ Eliminar]
```

- Se agregó el botón de **Editar** (ícono de lápiz azul)
- Botones con tooltips: "Editar" y "Eliminar"
- Espaciado mejorado entre botones

---

### 3. **`lib/screens/gastos_screen.dart`**

#### Método Agregado:

**`_mostrarDialogoEditar(Gasto gasto)`**
- Abre un diálogo modal con los datos actuales del gasto
- Permite modificar:
  - ✏️ Nombre del gasto
  - 💰 Valor (solo números)
  - 🏷️ Tipo (Fijo o Variable)
- Pre-rellena los campos con los valores actuales
- Valida que los campos no estén vacíos
- Muestra mensaje de éxito/error después de actualizar

#### Cambios en la UI:

**Antes:**
```
[Valor] [🗑️ Eliminar]
```

**Ahora:**
```
[Valor] [✏️ Editar] [🗑️ Eliminar]
```

- Se agregó el botón de **Editar** (ícono de lápiz azul)
- Botones con tooltips: "Editar" y "Eliminar"
- Espaciado mejorado entre botones

---

## 🎯 Funcionalidades Implementadas

### ✅ Editar Ingreso

1. Usuario hace clic en el botón **✏️ Editar** de un ingreso
2. Se abre un diálogo con los datos actuales:
   - Nombre del ingreso
   - Valor actual
   - Tipo (Fijo/Variable)
3. Usuario modifica los campos deseados
4. Hace clic en **"Guardar"**
5. Se envía la petición `PUT` al backend con JWT
6. Se actualiza la lista de ingresos
7. Se muestra mensaje de confirmación

### ✅ Editar Gasto

1. Usuario hace clic en el botón **✏️ Editar** de un gasto
2. Se abre un diálogo con los datos actuales:
   - Nombre del gasto
   - Valor actual
   - Tipo (Fijo/Variable)
3. Usuario modifica los campos deseados
4. Hace clic en **"Guardar"**
5. Se envía la petición `PUT` al backend con JWT
6. Se actualiza la lista de gastos
7. Se muestra mensaje de confirmación

---

## 🔐 Seguridad

- ✅ Todas las peticiones de actualización incluyen el **token JWT**
- ✅ Si el token ha expirado, se muestra mensaje de error
- ✅ Validación de campos antes de enviar al servidor
- ✅ Manejo de errores con mensajes descriptivos

---

## 🎨 Diseño de la UI

### Diálogo de Edición

```
┌─────────────────────────────────┐
│  Editar Ingreso/Gasto           │
├─────────────────────────────────┤
│  ┌─────────────────────────┐   │
│  │ Nombre del Ingreso      │   │
│  │ [Salario Mensual]       │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ Valor                   │   │
│  │ $ [3000000]             │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ Tipo                    │   │
│  │ [Fijo ▼]                │   │
│  └─────────────────────────┘   │
│                                 │
│     [Cancelar]  [Guardar]      │
└─────────────────────────────────┘
```

### Lista de Ingresos/Gastos

```
┌─────────────────────────────────────────┐
│ 🟢 Salario Mensual                      │
│    FIJO                                 │
│                   $ 3.000.000 ✏️ 🗑️     │
└─────────────────────────────────────────┘
```

**Colores:**
- ✏️ Botón Editar: Azul
- 🗑️ Botón Eliminar: Rojo

---

## 🧪 Cómo Probar

### Editar un Ingreso:

1. Ejecutar la app y hacer login
2. Ir a la sección **"Mis Ingresos"**
3. Hacer clic en el botón **✏️** de cualquier ingreso
4. Modificar el nombre, valor o tipo
5. Hacer clic en **"Guardar"**
6. ✅ Verificar que se actualice correctamente
7. ✅ Verificar que se muestre el mensaje de éxito

### Editar un Gasto:

1. Ir a la sección **"Mis Gastos"**
2. Hacer clic en el botón **✏️** de cualquier gasto
3. Modificar el nombre, valor o tipo
4. Hacer clic en **"Guardar"**
5. ✅ Verificar que se actualice correctamente
6. ✅ Verificar que se muestre el mensaje de éxito

### Probar Validaciones:

1. Hacer clic en **✏️ Editar**
2. Borrar el nombre o el valor
3. Intentar guardar
4. ✅ No debería permitir guardar (validación de campos vacíos)

### Probar Cancelar:

1. Hacer clic en **✏️ Editar**
2. Modificar algunos campos
3. Hacer clic en **"Cancelar"**
4. ✅ No debería guardar los cambios

---

## 🔗 Endpoints Utilizados

### Backend Spring Boot

**Actualizar Ingreso:**
```http
PUT https://easysave-usuario-service-production.up.railway.app/api/v1/usuario-service/ingresos/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "nombreIngreso": "Salario Actualizado",
  "valorIngreso": 3500000,
  "estadoIngreso": "fijo"
}
```

**Actualizar Gasto:**
```http
PUT https://easysave-usuario-service-production.up.railway.app/api/v1/usuario-service/gastos/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "nombreGasto": "Arriendo Actualizado",
  "valorGasto": 850000,
  "estadoGasto": "fijo"
}
```

---

## 📱 Flujo de Actualización

```
Usuario → Click Editar → Diálogo
    ↓
Modificar Datos
    ↓
Click Guardar
    ↓
Validar Campos
    ↓
usuario_service.actualizarIngreso/Gasto()
    ↓
Headers con JWT Token
    ↓
PUT /api/v1/usuario-service/ingresos/{id}
    ↓
Backend valida token
    ↓
Backend actualiza en BD
    ↓
Response 200 OK con datos actualizados
    ↓
Recargar lista (_cargarIngresos/_cargarGastos)
    ↓
Mostrar SnackBar de éxito ✅
```

---

## ⚠️ Manejo de Errores

### Errores Posibles:

1. **Token Expirado (401)**
   - Mensaje: "Sesión expirada. Por favor inicia sesión nuevamente."

2. **Ingreso/Gasto No Encontrado (404)**
   - Mensaje: "Error al actualizar: Ingreso/Gasto no encontrado"

3. **Error de Conexión**
   - Mensaje: "Error: No se puede conectar al servidor"

4. **Campos Vacíos**
   - Validación en el cliente (no permite guardar)

---

## 💡 Características Adicionales

- ✅ **Pre-relleno de Datos:** Los campos se rellenan automáticamente con los valores actuales
- ✅ **Validación en Tiempo Real:** No permite guardar si hay campos vacíos
- ✅ **Feedback Visual:** Mensajes de éxito/error con colores (verde/rojo)
- ✅ **Formato de Moneda:** El valor se muestra sin decimales en el campo de edición
- ✅ **Dropdown Dinámico:** El tipo (Fijo/Variable) se actualiza en tiempo real
- ✅ **Tooltips:** Descripciones al pasar sobre los botones
- ✅ **Recarga Automática:** La lista se actualiza automáticamente después de editar

---

## 🎉 Resultado Final

Ahora los usuarios pueden:

1. ✅ Ver sus ingresos y gastos
2. ✅ Agregar nuevos ingresos y gastos
3. ✅ **Editar ingresos y gastos existentes** ⭐ NUEVO
4. ✅ Eliminar ingresos y gastos
5. ✅ Ver el total calculado automáticamente

---

## 🚀 Mejoras Futuras (Opcional)

- [ ] Historial de cambios (auditoría)
- [ ] Confirmación antes de guardar cambios importantes
- [ ] Edición rápida (inline editing)
- [ ] Deshacer última edición
- [ ] Búsqueda y filtros antes de editar
- [ ] Edición masiva (seleccionar múltiples items)

---

¡Listo! La funcionalidad de edición está completamente implementada. 🎊
