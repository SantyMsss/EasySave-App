import 'package:flutter/material.dart';
import '../models/meta_ahorro.dart';
import '../services/meta_ahorro_service.dart';
import '../utils/currency_formatter.dart';

class MetaAhorroDetalleScreen extends StatefulWidget {
  final int metaId;

  const MetaAhorroDetalleScreen({super.key, required this.metaId});

  @override
  State<MetaAhorroDetalleScreen> createState() => _MetaAhorroDetalleScreenState();
}

class _MetaAhorroDetalleScreenState extends State<MetaAhorroDetalleScreen> {
  final _metaAhorroService = MetaAhorroService();
  MetaAhorro? _meta;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    setState(() => _isLoading = true);
    try {
      final meta = await _metaAhorroService.obtenerDetalleMeta(widget.metaId);
      setState(() {
        _meta = meta;
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

    final progreso = _meta!.progresoPorcentaje ?? 0;
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
                      _buildInfoRow('Fecha inicio', _meta!.fechaInicio),
                      _buildInfoRow('Fecha fin estimada', _meta!.fechaFinEstimada),
                      if (_meta!.cuotasPagadas != null)
                        _buildInfoRow('Cuotas pagadas', '${_meta!.cuotasPagadas}'),
                      if (_meta!.cuotasPendientes != null)
                        _buildInfoRow('Cuotas pendientes', '${_meta!.cuotasPendientes}'),
                    ],
                  ),
                ),
              ),
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
