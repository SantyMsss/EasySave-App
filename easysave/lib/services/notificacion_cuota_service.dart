import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meta_ahorro.dart';
import '../models/usuario.dart';
import '../services/meta_ahorro_service.dart';
import '../services/usuario_service.dart';
import 'dart:async';

/// Servicio para gestionar notificaciones de cuotas de ahorro programadas
class NotificacionCuotaService {
  final _metaAhorroService = MetaAhorroService();
  final _usuarioService = UsuarioService();
  final _formatoMoneda = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  final _formatoFecha = DateFormat('dd/MM/yyyy');
  
  Timer? _timer;
  BuildContext? _context;
  Usuario? _usuario;

  /// Inicializa el servicio de notificaciones
  void inicializar(BuildContext context, {Usuario? usuario}) {
    _context = context;
    _usuario = usuario;
    // Verificar cuotas pendientes cada 6 horas
    _timer = Timer.periodic(const Duration(hours: 6), (_) {
      verificarCuotasPendientes();
    });
    // Verificar inmediatamente al iniciar
    verificarCuotasPendientes();
  }

  /// Detiene el servicio
  void detener() {
    _timer?.cancel();
    _timer = null;
  }

  /// Verifica si hay cuotas pendientes para hoy
  Future<void> verificarCuotasPendientes() async {
    if (_context == null || !_context!.mounted) return;

    try {
      // Obtener el usuario actual
      final usuario = _usuario ?? await _obtenerUsuarioActual();
      if (usuario == null) return;

      // Obtener metas activas
      final metas = await _metaAhorroService.listarMetasActivas(usuario.id!);
      
      final hoy = DateTime.now();
      final List<CuotaPendiente> cuotasPendientesHoy = [];

      // Revisar cada meta para cuotas pendientes
      for (final meta in metas) {
        if (meta.proximasCuotas != null && meta.proximasCuotas!.isNotEmpty) {
          for (final cuota in meta.proximasCuotas!) {
            if (cuota.estado == 'PENDIENTE') {
              try {
                final fechaCuota = DateTime.parse(cuota.fechaProgramada);
                // Si la cuota es para hoy
                if (fechaCuota.year == hoy.year &&
                    fechaCuota.month == hoy.month &&
                    fechaCuota.day == hoy.day) {
                  cuotasPendientesHoy.add(CuotaPendiente(
                    meta: meta,
                    cuota: cuota,
                    usuario: usuario,
                  ));
                }
              } catch (e) {
                print('Error al parsear fecha de cuota: $e');
              }
            }
          }
        }
      }

      // Mostrar notificación si hay cuotas pendientes
      if (cuotasPendientesHoy.isNotEmpty && _context != null && _context!.mounted) {
        _mostrarNotificacionCuota(cuotasPendientesHoy.first);
      }
    } catch (e) {
      print('Error al verificar cuotas pendientes: $e');
    }
  }

  /// Muestra una notificación con diálogo para pagar la cuota
  void _mostrarNotificacionCuota(CuotaPendiente cuotaPendiente) {
    if (_context == null || !_context!.mounted) return;

    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.notifications_active,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text(
          '💰 Recordatorio de Ahorro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hoy tienes programado un pago para tu meta de ahorro:',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cuotaPendiente.meta.nombreMeta,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildInfoRow(
                    'Cuota #',
                    '${cuotaPendiente.cuota.numeroCuota}',
                    Icons.numbers,
                  ),
                  _buildInfoRow(
                    'Monto',
                    _formatoMoneda.format(cuotaPendiente.cuota.montoCuota),
                    Icons.attach_money,
                  ),
                  _buildInfoRow(
                    'Fecha',
                    _formatoFecha.format(DateTime.parse(cuotaPendiente.cuota.fechaProgramada)),
                    Icons.calendar_today,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¿Deseas realizar el pago de esta cuota ahora?',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Más tarde'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _procesarPagoCuota(cuotaPendiente);
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Pagar ahora'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Procesa el pago de una cuota
  Future<void> _procesarPagoCuota(CuotaPendiente cuotaPendiente) async {
    if (_context == null || !_context!.mounted) return;

    try {
      // Mostrar diálogo de progreso
      showDialog(
        context: _context!,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Procesando pago...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Pagar la cuota
      await _metaAhorroService.pagarCuota(
        cuotaPendiente.meta.id!,
        cuotaPendiente.cuota.id!,
      );

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
            'estadoGasto': 'fijo', // Las cuotas programadas son gastos fijos
          },
        );
        gastoRegistrado = true;
        print('✅ Pago de cuota registrado como gasto: $nombreGasto');
        print('📊 Respuesta del servidor: $resultado');
      } catch (e) {
        // Guardar el error para mostrarlo al usuario
        errorGasto = e.toString().replaceAll('Exception: ', '');
        print('⚠️ Error al registrar gasto de cuota: $errorGasto');
      }

      // Cerrar diálogo de progreso
      if (_context!.mounted) {
        Navigator.pop(_context!);
      }

      // Mostrar mensaje de éxito con información del gasto
      if (_context!.mounted) {
        final mensajeGasto = gastoRegistrado 
            ? '\n✓ Registrado como gasto' 
            : '\n⚠ No se pudo registrar como gasto: $errorGasto';
        
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '¡Pago exitoso!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Cuota #${cuotaPendiente.cuota.numeroCuota} de ${cuotaPendiente.meta.nombreMeta}$mensajeGasto',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: gastoRegistrado ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                // Navegar a la pantalla de detalle de la meta
                // Esto dependerá de tu implementación de navegación
              },
            ),
          ),
        );
      }

      // Verificar si hay más cuotas pendientes
      await Future.delayed(const Duration(seconds: 2));
      verificarCuotasPendientes();
      
    } catch (e) {
      // Cerrar diálogo de progreso si está abierto
      if (_context!.mounted) {
        Navigator.pop(_context!);
      }

      // Mostrar error
      if (_context!.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el pago: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Construye una fila de información
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el usuario actual (implementar según tu lógica)
  Future<Usuario?> _obtenerUsuarioActual() async {
    // Aquí deberías implementar la lógica para obtener el usuario actual
    // Por ejemplo, desde AuthManager o desde shared preferences
    // Este es un ejemplo básico:
    try {
      // Importar AuthManager y obtener usuario
      // final authManager = AuthManager();
      // return await authManager.obtenerUsuarioActual();
      return null; // Temporal
    } catch (e) {
      print('Error al obtener usuario actual: $e');
      return null;
    }
  }
}

/// Clase auxiliar para almacenar información de cuotas pendientes
class CuotaPendiente {
  final MetaAhorro meta;
  final CuotaAhorro cuota;
  final Usuario usuario;

  CuotaPendiente({
    required this.meta,
    required this.cuota,
    required this.usuario,
  });
}
