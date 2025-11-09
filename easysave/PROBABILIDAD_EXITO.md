# Probabilidad de Éxito en Metas de Ahorro

## Descripción General

Esta funcionalidad calcula y muestra la **probabilidad de éxito** de una meta de ahorro basándose en la situación financiera actual del usuario. El objetivo es motivar al usuario mostrándole qué tan realista es su meta y ayudarlo a tomar decisiones informadas.

## Cómo Funciona

### Cálculo de Probabilidad (0-100%)

La probabilidad se calcula mediante **4 factores principales**:

#### 1. Capacidad de Pago Actual (40% del peso)
- **¿Puede pagar la cuota con su excedente mensual?**
- Compara: `excedente = ingresos - gastos` vs `cuota requerida`
- Si el excedente cubre la cuota completa → 40 puntos
- Si cubre parcialmente → puntos proporcionales

#### 2. Balance Disponible (30% del peso)
- **¿Tiene suficiente balance para cubrir varias cuotas?**
- Calcula: `cuotas que puede cubrir = balance / cuota`
- Si puede cubrir todas las cuotas pendientes → 30 puntos
- Si puede cubrir algunas → puntos proporcionales

#### 3. Progreso Actual (20% del peso)
- **A mayor progreso, mayor motivación**
- Basado en el porcentaje de avance de la meta
- Refleja el compromiso y disciplina del usuario

#### 4. Relación Ingresos/Gastos (10% del peso)
- **Salud financiera general**
- Ratio: `(ingresos - gastos) / ingresos`
- Indica la capacidad de ahorro sostenible

### Ajustes de Probabilidad

**Penalización por cuotas vencidas:**
- Cada cuota vencida reduce la probabilidad en 5 puntos
- Máximo de penalización: 15 puntos

## Niveles de Probabilidad

### 🟢 80-100%: Excelente - Meta muy alcanzable
- **Mensaje:** "¡Excelente! Tu meta es muy alcanzable"
- **Detalle:** Tu situación financiera te permite cumplir esta meta sin problemas
- **Color:** Verde
- **Recomendación:** Mantener la disciplina actual

### 🟢 60-79%: Buena - Meta alcanzable
- **Mensaje:** "¡Buena perspectiva! Meta alcanzable"
- **Detalle:** Con disciplina y constancia, lograrás tu objetivo
- **Color:** Verde claro
- **Recomendación:** Mantener control de gastos

### 🟡 40-59%: Media - Meta desafiante pero posible
- **Mensaje:** "Meta desafiante pero posible"
- **Detalle:** Necesitarás esfuerzo adicional
- **Color:** Naranja
- **Recomendación:** Reducir gastos innecesarios o buscar ingresos extra

### 🟠 20-39%: Baja - Meta difícil de alcanzar
- **Mensaje:** "Meta difícil de alcanzar"
- **Detalle:** Tu situación actual hace difícil cumplir esta meta
- **Color:** Naranja oscuro
- **Recomendación:** Considerar ajustar monto o plazo

### 🔴 0-19%: Muy baja - Meta poco realista
- **Mensaje:** "Meta poco realista actualmente"
- **Detalle:** Tus finanzas actuales no permiten cumplir esta meta
- **Color:** Rojo
- **Recomendación:** Replantear objetivos

## Interfaz Visual

### Componentes de la Tarjeta

1. **Barra de Progreso Animada**
   - Representación visual del porcentaje de probabilidad
   - Colores dinámicos según el nivel
   - Animación de 800ms al cargar

2. **Icono Emocional**
   - 😊 Muy satisfecho (80-100%)
   - 🙂 Satisfecho (60-79%)
   - 😐 Neutral (40-59%)
   - 🙁 Insatisfecho (20-39%)
   - 😟 Muy insatisfecho (0-19%)

3. **Mensaje Motivacional**
   - Título conciso
   - Detalle explicativo con recomendaciones

4. **Análisis Detallado**
   - Balance actual
   - Ingresos totales
   - Gastos totales
   - Cuota requerida

## Casos de Uso

### Ejemplo 1: Usuario con Buena Situación
```
Balance: $5,000
Ingresos: $3,000/mes
Gastos: $2,000/mes
Cuota: $500/mes
Cuotas pendientes: 6

Cálculo:
- Excedente ($1,000) > Cuota ($500) → 40 puntos
- Balance cubre 10 cuotas de 6 → 30 puntos
- Progreso 40% → 8 puntos
- Ratio salud (33%) → 3.3 puntos
Total: 81.3% → "¡Excelente!"
```

### Ejemplo 2: Usuario con Situación Ajustada
```
Balance: $500
Ingresos: $2,000/mes
Gastos: $1,800/mes
Cuota: $300/mes
Cuotas pendientes: 10

Cálculo:
- Excedente ($200) < Cuota ($300) → 26.7 puntos
- Balance cubre 1.6 cuotas de 10 → 4.8 puntos
- Progreso 30% → 6 puntos
- Ratio salud (10%) → 1 punto
Total: 38.5% → "Meta desafiante"
```

## Implementación Técnica

### Archivo Modificado
- `lib/screens/meta_ahorro_detalle_screen.dart`

### Métodos Clave

1. **`_calcularProbabilidadExito()`**
   - Recibe: MetaAhorro, Balance del usuario
   - Retorna: double (0-100) o null

2. **`_getMensajeProbabilidad()`**
   - Recibe: probabilidad (double)
   - Retorna: Map con mensaje, detalle, color e icono

3. **`_buildProbabilidadExitoCard()`**
   - Construye el widget visual de la tarjeta
   - Incluye barra animada y análisis detallado

### Dependencias
- `usuario_service.dart` - Para obtener balance
- `shared_preferences` - Para obtener ID del usuario
- `currency_formatter.dart` - Para formatear montos

## Ventajas de Esta Funcionalidad

1. **Motivación:** Feedback visual inmediato sobre viabilidad de la meta
2. **Realismo:** Ayuda a identificar metas poco realistas tempranamente
3. **Educación Financiera:** Muestra factores que afectan capacidad de ahorro
4. **Toma de Decisiones:** Datos concretos para ajustar metas
5. **Gamificación:** Elemento visual atractivo que incentiva mejor gestión

## Notas Importantes

- La probabilidad solo se muestra para metas **ACTIVAS**
- Requiere que el usuario tenga movimientos financieros registrados
- Se actualiza cada vez que se refresca el detalle de la meta
- El cálculo asume que los ingresos y gastos son mensuales
- Los pesos de los factores pueden ajustarse según necesidades

## Futuras Mejoras

1. Mostrar tendencia de probabilidad (aumentando/disminuyendo)
2. Comparar con probabilidad inicial de la meta
3. Sugerencias personalizadas de ajuste
4. Alertas cuando la probabilidad baje de cierto umbral
5. Historial de evolución de probabilidad
