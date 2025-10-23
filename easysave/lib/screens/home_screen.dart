import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_manager.dart';
import '../services/usuario_service.dart';
import '../utils/currency_formatter.dart';
import 'login_screen.dart';
import 'ingresos_screen.dart';
import 'gastos_screen.dart';

class HomeScreen extends StatefulWidget {
  final Usuario usuario;

  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authManager = AuthManager();
  final _usuarioService = UsuarioService();
  
  double? _totalIngresos;
  double? _totalGastos;
  double? _balance;
  bool _isLoadingBalance = false;

  @override
  void initState() {
    super.initState();
    _cargarBalance();
  }

  Future<void> _cargarBalance() async {
    if (widget.usuario.id == null) return;
    
    setState(() => _isLoadingBalance = true);
    try {
      print('🔄 Cargando resumen financiero para usuario ID: ${widget.usuario.id}');
      
      final resumenData = await _usuarioService.obtenerBalance(widget.usuario.id!);
      print('✅ Resumen financiero recibido: $resumenData');
      
      setState(() {
        _totalIngresos = (resumenData['totalIngresos'] ?? 0).toDouble();
        _totalGastos = (resumenData['totalGastos'] ?? 0).toDouble();
        _balance = (resumenData['balance'] ?? 0).toDouble();
        _isLoadingBalance = false;
      });
      
      print('📊 Total Ingresos: $_totalIngresos');
      print('📊 Total Gastos: $_totalGastos');
      print('📊 Balance: $_balance');
    } catch (e) {
      print('❌ Error al cargar resumen financiero: $e');
      setState(() => _isLoadingBalance = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar resumen financiero: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _handleCerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _authManager.cerrarSesion();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final saldo = _balance ?? 0;
    final totalIngresos = _totalIngresos ?? 0;
    final totalGastos = _totalGastos ?? 0;
    final porcentajeGastos = totalIngresos > 0
        ? (totalGastos / totalIngresos) * 100
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EasySave'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoadingBalance ? null : _cargarBalance,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleCerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de bienvenida
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            widget.usuario.username[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Hola, ${widget.usuario.username}!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.usuario.correo,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tarjeta de resumen financiero
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: saldo >= 0 ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Balance Mensual',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_isLoadingBalance)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(saldo),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: saldo >= 0 ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: porcentajeGastos.clamp(0, 100) / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        porcentajeGastos > 80
                            ? Colors.red
                            : porcentajeGastos > 60
                                ? Colors.orange
                                : Colors.green,
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gastos: ${porcentajeGastos.toStringAsFixed(1)}% de tus ingresos',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tarjetas de ingresos y gastos
            Row(
              children: [
                // Tarjeta de ingresos
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => IngresosScreen(usuario: widget.usuario),
                        ),
                      );
                      // Recargar balance al volver
                      _cargarBalance();
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.green[600],
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ingresos',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(totalIngresos),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Tarjeta de gastos
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GastosScreen(usuario: widget.usuario),
                        ),
                      );
                      // Recargar balance al volver
                      _cargarBalance();
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.trending_down,
                              color: Colors.red[600],
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Gastos',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(totalGastos),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Información de contacto
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Contacto',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Correo'),
                      subtitle: Text(widget.usuario.correo),
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Rol'),
                      subtitle: Text(widget.usuario.rol),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mensaje informativo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Más funcionalidades próximamente...',
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
