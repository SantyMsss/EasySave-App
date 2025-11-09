import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/usuario.dart';
import '../models/meta_ahorro.dart';
import '../services/meta_ahorro_service.dart';
import '../utils/currency_formatter.dart';
import 'meta_ahorro_detalle_screen.dart';

class MetasAhorroScreen extends StatefulWidget {
  final Usuario usuario;

  const MetasAhorroScreen({super.key, required this.usuario});

  @override
  State<MetasAhorroScreen> createState() => _MetasAhorroScreenState();
}

class _MetasAhorroScreenState extends State<MetasAhorroScreen> {
  final _metaAhorroService = MetaAhorroService();
  List<MetaAhorro> _metas = [];
  bool _isLoading = true;
  int _filtroEstado = 0; // 0: Todas, 1: Activas, 2: Completadas

  @override
  void initState() {
    super.initState();
    _cargarMetas();
  }

  Future<void> _cargarMetas() async {
    setState(() => _isLoading = true);
    try {
      List<MetaAhorro> metas;
      if (_filtroEstado == 1) {
        metas = await _metaAhorroService.listarMetasActivas(widget.usuario.id!);
      } else {
        metas = await _metaAhorroService.listarMetasAhorro(widget.usuario.id!);
      }

      setState(() {
        if (_filtroEstado == 2) {
          _metas = metas.where((m) => m.estado == 'COMPLETADA').toList();
        } else {
          _metas = metas;
        }
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

  Future<void> _mostrarDialogoCrearMeta() async {
    final nombreController = TextEditingController();
    final montoController = TextEditingController();
    final cuotasController = TextEditingController(text: '12');
    String frecuenciaSeleccionada = 'MENSUAL';

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Meta de Ahorro'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Meta',
                    hintText: 'Ej: Vacaciones 2026',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: montoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Monto Objetivo',
                    hintText: '0',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cuotasController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Número de Cuotas',
                    hintText: '12',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: frecuenciaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Frecuencia de Pago',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'SEMANAL', child: Text('Semanal')),
                    DropdownMenuItem(value: 'QUINCENAL', child: Text('Quincenal')),
                    DropdownMenuItem(value: 'MENSUAL', child: Text('Mensual')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => frecuenciaSeleccionada = value!);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _mostrarSugerencia(),
            child: const Text('Ver Sugerencia'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isEmpty || 
                  montoController.text.isEmpty ||
                  cuotasController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completa todos los campos')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (resultado == true) {
      try {
        await _metaAhorroService.crearMetaAhorro(
          widget.usuario.id!,
          {
            'nombreMeta': nombreController.text,
            'montoObjetivo': double.parse(montoController.text),
            'numeroCuotas': int.parse(cuotasController.text),
            'frecuenciaCuota': frecuenciaSeleccionada,
          },
        );
        _cargarMetas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meta de ahorro creada exitosamente'),
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

  Future<void> _mostrarSugerencia() async {
    try {
      final sugerencia = await _metaAhorroService.calcularSugerenciaAhorro(
        widget.usuario.id!,
        porcentajeBalance: 25,
        numeroCuotas: 12,
        frecuencia: 'MENSUAL',
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text('Sugerencia de Ahorro'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sugerencia.mensaje,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Monto Objetivo:',
                    CurrencyFormatter.format(sugerencia.sugerencia.montoObjetivo),
                  ),
                  _buildInfoRow(
                    'Número de Cuotas:',
                    '${sugerencia.sugerencia.numeroCuotas}',
                  ),
                  _buildInfoRow(
                    'Valor por Cuota:',
                    CurrencyFormatter.format(sugerencia.sugerencia.valorCuota),
                  ),
                  _buildInfoRow(
                    'Frecuencia:',
                    sugerencia.sugerencia.frecuenciaCuota,
                  ),
                  _buildInfoRow(
                    'Fecha Inicio:',
                    sugerencia.sugerencia.fechaInicio ?? 'No disponible',
                  ),
                  _buildInfoRow(
                    'Fecha Fin Estimada:',
                    sugerencia.sugerencia.fechaFinEstimada ?? 'No disponible',
                  ),
                  if (sugerencia.nota != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sugerencia.nota!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al calcular sugerencia: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
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

  Future<void> _confirmarCancelar(MetaAhorro meta) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Meta'),
        content: Text('¿Estás seguro de cancelar la meta "${meta.nombreMeta}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _metaAhorroService.cancelarMeta(meta.id!);
        _cargarMetas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meta cancelada'),
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

  Color _getColorByEstado(String estado) {
    switch (estado) {
      case 'ACTIVA':
        return Colors.blue;
      case 'COMPLETADA':
        return Colors.green;
      case 'CANCELADA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconByFrecuencia(String frecuencia) {
    switch (frecuencia) {
      case 'SEMANAL':
        return Icons.calendar_view_week;
      case 'QUINCENAL':
        return Icons.calendar_view_month;
      case 'MENSUAL':
        return Icons.calendar_month;
      default:
        return Icons.calendar_today;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas de Ahorro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarMetas,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Todas'),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Activas'),
                  icon: Icon(Icons.check_circle),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('Completadas'),
                  icon: Icon(Icons.done_all),
                ),
              ],
              selected: {_filtroEstado},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _filtroEstado = newSelection.first;
                  _cargarMetas();
                });
              },
            ),
          ),

          // Lista de metas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _metas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.savings_outlined,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No tienes metas de ahorro',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crea tu primera meta',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _metas.length,
                        itemBuilder: (context, index) {
                          final meta = _metas[index];
                          // Calcular progreso: usar el del backend o calcularlo localmente
                          final progreso = meta.progresoPorcentaje ?? 
                              (meta.montoObjetivo > 0 
                                  ? (meta.montoAhorrado / meta.montoObjetivo * 100).clamp(0, 100)
                                  : 0.0);
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MetaAhorroDetalleScreen(
                                      metaId: meta.id!,
                                    ),
                                  ),
                                );
                                _cargarMetas();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Encabezado
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: _getColorByEstado(meta.estado).withOpacity(0.2),
                                          child: Icon(
                                            Icons.flag,
                                            color: _getColorByEstado(meta.estado),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                meta.nombreMeta,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    _getIconByFrecuencia(meta.frecuenciaCuota),
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${meta.frecuenciaCuota} • ${meta.numeroCuotas} cuotas',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getColorByEstado(meta.estado).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            meta.estado,
                                            style: TextStyle(
                                              color: _getColorByEstado(meta.estado),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Progreso
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Progreso',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          '${progreso.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            color: _getColorByEstado(meta.estado),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: progreso / 100,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getColorByEstado(meta.estado),
                                      ),
                                      minHeight: 8,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    const SizedBox(height: 16),

                                    // Información financiera
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Ahorrado',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              CurrencyFormatter.format(meta.montoAhorrado),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Objetivo',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              CurrencyFormatter.format(meta.montoObjetivo),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Cuota mensual
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Cuota ${meta.frecuenciaCuota.toLowerCase()}',
                                            style: TextStyle(
                                              color: Colors.blue[900],
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            CurrencyFormatter.format(meta.valorCuota),
                                            style: TextStyle(
                                              color: Colors.blue[900],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Botones de acción
                                    if (meta.estado == 'ACTIVA') ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () => _confirmarCancelar(meta),
                                            icon: const Icon(Icons.cancel, size: 18),
                                            label: const Text('Cancelar'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => MetaAhorroDetalleScreen(
                                                    metaId: meta.id!,
                                                  ),
                                                ),
                                              );
                                              _cargarMetas();
                                            },
                                            icon: const Icon(Icons.visibility, size: 18),
                                            label: const Text('Ver Detalle'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoCrearMeta,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Meta'),
      ),
    );
  }
}
