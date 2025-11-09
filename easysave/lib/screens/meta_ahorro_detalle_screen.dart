import 'package:flutter/material.dart';
import '../models/meta_ahorro.dart';
import '../services/meta_ahorro_service.dart';
import '../services/usuario_service.dart';
import '../utils/currency_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MetaAhorroDetalleScreen extends StatefulWidget {
  final int metaId;

  const MetaAhorroDetalleScreen({super.key, required this.metaId});

  @override
  State<MetaAhorroDetalleScreen> createState() => _MetaAhorroDetalleScreenState();
}

class _MetaAhorroDetalleScreenState extends State<MetaAhorroDetalleScreen> {
  final _metaAhorroService = MetaAhorroService();
  final _usuarioService = UsuarioService();
  MetaAhorro? _meta;
  bool _isLoading = true;
  Map<String, dynamic>? _balance;
  double? _probabilidadExito;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    setState(() => _isLoading = true);
    try {
      final meta = await _metaAhorroService.obtenerDetalleMeta(widget.metaId);
      
      // Obtener el balance del usuario
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('usuario_id');
      
      Map<String, dynamic>? balance;
      if (usuarioId != null) {
        try {
          balance = await _usuarioService.obtenerBalance(usuarioId);
        } catch (e) {
          print('[META_DETALLE] Error obteniendo balance: $e');
        }
      }

      setState(() {
        _meta = meta;
        _balance = balance;
        _probabilidadExito = _calcularProbabilidadExito(meta, balance);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Calcula la probabilidad de éxito de la meta basada en el balance del usuario
  double? _calcularProbabilidadExito(MetaAhorro meta, Map<String, dynamic>? balance) {
    if (balance == null || meta.estado != 'ACTIVA') return null;

    try {
      // Obtener datos del balance
      final balanceActual = (balance['balance'] ?? 0).toDouble();
      final ingresosPromedio = (balance['totalIngresos'] ?? 0).toDouble();
      final gastosPromedio = (balance['totalGastos'] ?? 0).toDouble();
      
      // Calcular excedente mensual (asumiendo que el balance es mensual)
      final excedenteMensual = ingresosPromedio - gastosPromedio;
      
      // Obtener información de la meta
      final cuotaRequerida = meta.valorCuota;
      final cuotasPendientes = meta.cuotasPendientes ?? meta.numeroCuotas;

      // Factores de probabilidad (0-100)
      double probabilidad = 0;

      // Factor 1: Capacidad de pago actual (40% del peso)
      // ¿Puede pagar la cuota con su excedente?
      if (excedenteMensual >= cuotaRequerida) {
        probabilidad += 40;
      } else if (excedenteMensual > 0) {
        // Proporcional a cuánto puede cubrir
        probabilidad += 40 * (excedenteMensual / cuotaRequerida);
      }

      // Factor 2: Balance disponible (30% del peso)
      // ¿Tiene suficiente balance para cubrir varias cuotas?
      final cuotasQuePuedeCubrir = balanceActual / cuotaRequerida;
      if (cuotasQuePuedeCubrir >= cuotasPendientes) {
        probabilidad += 30;
      } else if (cuotasQuePuedeCubrir > 0) {
        probabilidad += 30 * (cuotasQuePuedeCubrir / cuotasPendientes);
      }

      // Factor 3: Progreso actual (20% del peso)
      // A mayor progreso, mayor motivación y probabilidad
      final progresoActual = meta.progresoPorcentaje ?? 
          (meta.montoObjetivo > 0 
              ? (meta.montoAhorrado / meta.montoObjetivo * 100).clamp(0, 100)
              : 0.0);
      probabilidad += 20 * (progresoActual / 100);

      // Factor 4: Relación ingresos/gastos (10% del peso)
      // Si gasta menos de lo que gana, mejor probabilidad
      if (ingresosPromedio > 0) {
        final ratioSalud = (ingresosPromedio - gastosPromedio) / ingresosPromedio;
        if (ratioSalud > 0) {
          probabilidad += 10 * ratioSalud.clamp(0, 1);
        }
      }

      // Ajustes finales
      // Si ya tiene cuotas vencidas, reducir probabilidad
      final cuotasVencidas = (meta.proximasCuotas ?? [])
          .where((c) => c.estado == 'VENCIDA')
          .length;
      if (cuotasVencidas > 0) {
        probabilidad -= (cuotasVencidas * 5).clamp(0, 15);
      }

      // Limitar entre 0 y 100
      return probabilidad.clamp(0, 100);
    } catch (e) {
      print('[META_DETALLE] Error calculando probabilidad: $e');
      return null;
    }
  }

  // Obtiene el mensaje motivacional basado en la probabilidad
  Map<String, dynamic> _getMensajeProbabilidad(double probabilidad) {
    if (probabilidad >= 80) {
      return {
        'mensaje': '¡Excelente! Tu meta es muy alcanzable',
        'detalle': 'Tu situación financiera te permite cumplir esta meta sin problemas. ¡Sigue así!',
        'color': Colors.green,
        'icono': Icons.sentiment_very_satisfied,
      };
    } else if (probabilidad >= 60) {
      return {
        'mensaje': '¡Buena perspectiva! Meta alcanzable',
        'detalle': 'Con disciplina y constancia, lograrás tu objetivo. Mantén el control de tus gastos.',
        'color': Colors.lightGreen,
        'icono': Icons.sentiment_satisfied,
      };
    } else if (probabilidad >= 40) {
      return {
        'mensaje': 'Meta desafiante pero posible',
        'detalle': 'Necesitarás esfuerzo adicional. Considera reducir gastos innecesarios o buscar ingresos extra.',
        'color': Colors.orange,
        'icono': Icons.sentiment_neutral,
      };
    } else if (probabilidad >= 20) {
      return {
        'mensaje': 'Meta difícil de alcanzar',
        'detalle': 'Tu situación actual hace difícil cumplir esta meta. Considera ajustar el monto o plazo.',
        'color': Colors.deepOrange,
        'icono': Icons.sentiment_dissatisfied,
      };
    } else {
      return {
        'mensaje': 'Meta poco realista actualmente',
        'detalle': 'Tus finanzas actuales no permiten cumplir esta meta. Te recomendamos replantear los objetivos.',
        'color': Colors.red,
        'icono': Icons.sentiment_very_dissatisfied,
      };
    }
  }

  Future<void> _pagarCuota(CuotaAhorro cuota) async {
    if (cuota.estado != 'PENDIENTE' && cuota.estado != 'VENCIDA') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta cuota ya ha sido pagada'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pagar Cuota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Deseas pagar la cuota #${cuota.numeroCuota}?'),
            const SizedBox(height: 16),
            _buildInfoRow('Monto:', CurrencyFormatter.format(cuota.montoCuota)),
            _buildInfoRow('Fecha programada:', cuota.fechaProgramada),
            _buildInfoRow('Estado:', cuota.estado),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pagar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _metaAhorroService.pagarCuota(widget.metaId, cuota.id!);
        _cargarDetalle();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuota pagada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getColorByEstadoCuota(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return Colors.orange;
      case 'PAGADA':
        return Colors.green;
      case 'VENCIDA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconByEstadoCuota(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return Icons.schedule;
      case 'PAGADA':
        return Icons.check_circle;
      case 'VENCIDA':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Meta')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_meta == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Meta')),
        body: const Center(child: Text('Meta no encontrada')),
      );
    }

    // Calcular progreso: usar el del backend o calcularlo localmente
    final progreso = _meta!.progresoPorcentaje ?? 
        (_meta!.montoObjetivo > 0 
            ? (_meta!.montoAhorrado / _meta!.montoObjetivo * 100).clamp(0, 100)
            : 0.0);
    final cuotas = _meta!.proximasCuotas ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_meta!.nombreMeta),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDetalle,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDetalle,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tarjeta de progreso
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: progreso / 100,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _meta!.estado == 'COMPLETADA' 
                                    ? Colors.green 
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${progreso.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _meta!.estado,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            'Ahorrado',
                            CurrencyFormatter.format(_meta!.montoAhorrado),
                            Colors.green,
                            Icons.savings,
                          ),
                          Container(
                            height: 50,
                            width: 1,
                            color: Colors.grey[300],
                          ),
                          _buildStatColumn(
                            'Objetivo',
                            CurrencyFormatter.format(_meta!.montoObjetivo),
                            Colors.blue,
                            Icons.flag,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_meta!.montoFaltante != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Falta ahorrar',
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(_meta!.montoFaltante!),
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Información de la meta
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de la Meta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow('Cuota ${_meta!.frecuenciaCuota.toLowerCase()}', 
                          CurrencyFormatter.format(_meta!.valorCuota)),
                      _buildInfoRow('Número de cuotas', '${_meta!.numeroCuotas}'),
                      _buildInfoRow('Frecuencia', _meta!.frecuenciaCuota),
                      _buildInfoRow('Fecha inicio', _meta!.fechaInicio ?? 'No disponible'),
                      _buildInfoRow('Fecha fin estimada', _meta!.fechaFinEstimada ?? 'No disponible'),
                      if (_meta!.cuotasPagadas != null)
                        _buildInfoRow('Cuotas pagadas', '${_meta!.cuotasPagadas}'),
                      if (_meta!.cuotasPendientes != null)
                        _buildInfoRow('Cuotas pendientes', '${_meta!.cuotasPendientes}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tarjeta de Probabilidad de Éxito
              if (_probabilidadExito != null && _meta!.estado == 'ACTIVA')
                _buildProbabilidadExitoCard(),
              
              if (_probabilidadExito != null && _meta!.estado == 'ACTIVA')
                const SizedBox(height: 16),

              // Lista de cuotas
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cuotas Programadas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${cuotas.length} cuotas',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      if (cuotas.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No hay cuotas programadas',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cuotas.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final cuota = cuotas[index];
                            final estadoColor = _getColorByEstadoCuota(cuota.estado);
                            
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: estadoColor.withOpacity(0.2),
                                child: Icon(
                                  _getIconByEstadoCuota(cuota.estado),
                                  color: estadoColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                'Cuota #${cuota.numeroCuota}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fecha: ${cuota.fechaProgramada}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (cuota.fechaPago != null)
                                    Text(
                                      'Pagada: ${cuota.fechaPago}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(cuota.montoCuota),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: estadoColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      cuota.estado,
                                      style: TextStyle(
                                        color: estadoColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: cuota.estado == 'PENDIENTE' || cuota.estado == 'VENCIDA'
                                  ? () => _pagarCuota(cuota)
                                  : null,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mensaje motivacional
              if (_meta!.estado == 'ACTIVA')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.purple[400]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '¡Sigue así!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Estás ${progreso.toStringAsFixed(0)}% más cerca de tu meta',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              if (_meta!.estado == 'COMPLETADA')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.celebration, color: Colors.green[700], size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Felicitaciones!',
                              style: TextStyle(
                                color: Colors.green[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Has completado tu meta de ahorro',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProbabilidadExitoCard() {
    if (_probabilidadExito == null) return const SizedBox.shrink();

    final mensaje = _getMensajeProbabilidad(_probabilidadExito!);
    final color = mensaje['color'] as Color;
    final icono = mensaje['icono'] as IconData;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Probabilidad de Éxito',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Barra de probabilidad
              Stack(
                children: [
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    height: 30,
                    width: (MediaQuery.of(context).size.width - 112) * 
                           (_probabilidadExito! / 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${_probabilidadExito!.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: _probabilidadExito! > 30 ? Colors.white : Colors.transparent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if (_probabilidadExito! <= 30)
                    Positioned(
                      right: 12,
                      top: 6,
                      child: Text(
                        '${_probabilidadExito!.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Mensaje principal
              Row(
                children: [
                  Icon(icono, color: color, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mensaje['mensaje'] as String,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mensaje['detalle'] as String,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Análisis detallado
              if (_balance != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Análisis basado en:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildAnalisisRow(
                        'Balance actual',
                        CurrencyFormatter.format((_balance!['balance'] ?? 0).toDouble()),
                        Icons.account_balance_wallet,
                      ),
                      _buildAnalisisRow(
                        'Ingresos totales',
                        CurrencyFormatter.format((_balance!['totalIngresos'] ?? 0).toDouble()),
                        Icons.trending_up,
                      ),
                      _buildAnalisisRow(
                        'Gastos totales',
                        CurrencyFormatter.format((_balance!['totalGastos'] ?? 0).toDouble()),
                        Icons.trending_down,
                      ),
                      _buildAnalisisRow(
                        'Cuota requerida',
                        CurrencyFormatter.format(_meta!.valorCuota),
                        Icons.payments,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalisisRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
