import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/usuario.dart';
import '../models/meta_ahorro.dart';
import '../services/auth_manager.dart';
import '../services/usuario_service.dart';
import '../services/meta_ahorro_service.dart';
import '../services/notificacion_cuota_service.dart';
import '../utils/currency_formatter.dart';
import 'login_screen.dart';
import 'ingresos_screen.dart';
import 'gastos_screen.dart';
import 'metas_ahorro_screen.dart';
import 'meta_ahorro_detalle_screen.dart';

class HomeScreen extends StatefulWidget {
  final Usuario usuario;

  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _authManager = AuthManager();
  final _usuarioService = UsuarioService();
  final _metaAhorroService = MetaAhorroService();
  final _notificacionService = NotificacionCuotaService();
  
  double? _totalIngresos;
  double? _totalGastos;
  double? _balance;
  bool _isLoadingBalance = false;
  
  List<MetaAhorro> _metasActivas = [];
  bool _isLoadingMetas = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Agregar observador
    _cargarBalance();
    _cargarMetasActivas();
    // Inicializar servicio de notificaciones de cuotas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificacionService.inicializar(context, usuario: widget.usuario);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remover observador
    _notificacionService.detener();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Recargar datos cuando la app vuelve a estar activa
    if (state == AppLifecycleState.resumed) {
      print('[HOME] App resumed - Recargando datos...');
      _recargarDatos();
    }
  }

  /// Recarga todos los datos del home screen
  Future<void> _recargarDatos() async {
    await Future.wait([
      _cargarBalance(),
      _cargarMetasActivas(),
    ]);
  }

  Future<void> _cargarBalance() async {
    if (widget.usuario.id == null) return;
    
    setState(() => _isLoadingBalance = true);
    try {
      print('[HOME] Cargando resumen financiero para usuario ID: ${widget.usuario.id}');
      
      final resumenData = await _usuarioService.obtenerBalance(widget.usuario.id!);
      print('[HOME] Resumen financiero recibido: $resumenData');
      
      setState(() {
        _totalIngresos = (resumenData['totalIngresos'] ?? 0).toDouble();
        _totalGastos = (resumenData['totalGastos'] ?? 0).toDouble();
        _balance = (resumenData['balance'] ?? 0).toDouble();
        _isLoadingBalance = false;
      });
      
      print('[HOME] Total Ingresos: $_totalIngresos');
      print('[HOME] Total Gastos: $_totalGastos');
      print('[HOME] Balance: $_balance');
    } catch (e) {
      print('[HOME] Error al cargar resumen financiero: $e');
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

  Future<void> _cargarMetasActivas() async {
    if (widget.usuario.id == null) return;
    
    setState(() => _isLoadingMetas = true);
    try {
      print('[HOME] Cargando metas activas para usuario ID: ${widget.usuario.id}');
      
      final metas = await _metaAhorroService.listarMetasActivas(widget.usuario.id!);
      print('[HOME] Metas activas recibidas: ${metas.length}');
      
      setState(() {
        _metasActivas = metas.take(3).toList(); // Solo las primeras 3
        _isLoadingMetas = false;
      });
    } catch (e) {
      print('[HOME] Error al cargar metas activas: $e');
      setState(() => _isLoadingMetas = false);
      // No mostrar error al usuario, solo un log silencioso
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

    // Obtener ancho de pantalla para diseño responsivo
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EasySave'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: (_isLoadingBalance || _isLoadingMetas) ? null : _recargarDatos,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleCerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _recargarDatos,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
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
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: isSmallScreen ? 24 : 30,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            widget.usuario.username[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                      fontSize: isSmallScreen ? 18 : null,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.usuario.correo,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isSmallScreen ? 11 : 14,
                                ),
                                overflow: TextOverflow.ellipsis,
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
            SizedBox(height: isSmallScreen ? 12 : 24),

            // Tarjeta de resumen financiero (clickeable para ir a Metas de Ahorro)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MetasAhorroScreen(usuario: widget.usuario),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: saldo >= 0 ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Text(
                                  'Balance Mensual',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 13 : 16,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.savings_outlined,
                                  size: isSmallScreen ? 16 : 20,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                          if (_isLoadingBalance)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              Icons.arrow_forward_ios,
                              size: isSmallScreen ? 14 : 18,
                              color: Colors.grey[600],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(saldo),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 28 : 36,
                          fontWeight: FontWeight.bold,
                          color: saldo >= 0 ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12,
                          vertical: isSmallScreen ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flag,
                              size: isSmallScreen ? 12 : 14,
                              color: Colors.blue[900],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Tap para ver tus metas',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: isSmallScreen ? 10 : 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
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
                        'Gastos: ${porcentajeGastos.toStringAsFixed(1)}% de ingresos',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isSmallScreen ? 11 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 24),

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
                        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.green[600],
                              size: isSmallScreen ? 24 : 32,
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            Text(
                              'Ingresos',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.format(totalIngresos),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 16),
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
                        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.trending_down,
                              color: Colors.red[600],
                              size: isSmallScreen ? 24 : 32,
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            Text(
                              'Gastos',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.format(totalGastos),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
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
            SizedBox(height: isSmallScreen ? 12 : 24),

            // Preview de Metas de Ahorro Activas (SIEMPRE VISIBLE)
            Card(
              elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag,
                                  color: Colors.blue[700],
                                  size: isSmallScreen ? 20 : 24,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Tus Metas',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MetasAhorroScreen(
                                    usuario: widget.usuario,
                                  ),
                                ),
                              ).then((_) => _cargarMetasActivas());
                            },
                            icon: Icon(
                              Icons.arrow_forward,
                              size: isSmallScreen ? 14 : 18,
                            ),
                            label: Text(
                              'Ver',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 4 : 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _isLoadingMetas
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _metasActivas.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.savings_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No tienes metas activas',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => MetasAhorroScreen(
                                                  usuario: widget.usuario,
                                                ),
                                              ),
                                            ).then((_) => _cargarMetasActivas());
                                          },
                                          icon: const Icon(Icons.add, size: 18),
                                          label: const Text('Crear Meta'),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    ..._metasActivas.map((meta) {
                                      // Calcular progreso: usar el del backend o calcularlo localmente
                                      final progreso = meta.progresoPorcentaje ?? 
                                          (meta.montoObjetivo > 0 
                                              ? (meta.montoAhorrado / meta.montoObjetivo * 100).clamp(0, 100)
                                              : 0.0);
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: isSmallScreen ? 8 : 12,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => MetaAhorroDetalleScreen(
                                                  metaId: meta.id!,
                                                ),
                                              ),
                                            ).then((_) => _cargarMetasActivas());
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.blue[200]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        meta.nombreMeta,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: isSmallScreen ? 13 : 15,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: isSmallScreen ? 6 : 10,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue[100],
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        '${progreso.toStringAsFixed(0)}%',
                                                        style: TextStyle(
                                                          color: Colors.blue[900],
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: isSmallScreen ? 10 : 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(
                                                          CurrencyFormatter.format(meta.montoAhorrado),
                                                          style: TextStyle(
                                                            color: Colors.green[700],
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: isSmallScreen ? 11 : 13,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: Alignment.centerRight,
                                                        child: Text(
                                                          'de ${CurrencyFormatter.format(meta.montoObjetivo)}',
                                                          style: TextStyle(
                                                            color: Colors.grey[600],
                                                            fontSize: isSmallScreen ? 10 : 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(4),
                                                  child: LinearProgressIndicator(
                                                    value: progreso / 100,
                                                    backgroundColor: Colors.grey[300],
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Colors.blue[600]!,
                                                    ),
                                                    minHeight: 6,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      _getIconByFrecuencia(meta.frecuenciaCuota),
                                                      size: isSmallScreen ? 10 : 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        '${meta.cuotasPagadas ?? 0}/${meta.numeroCuotas} cuotas • ${CurrencyFormatter.format(meta.valorCuota)}/${meta.frecuenciaCuota.toLowerCase()}',
                                                        style: TextStyle(
                                                          color: Colors.grey[600],
                                                          fontSize: isSmallScreen ? 9 : 11,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    if (_metasActivas.length >= 3)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Center(
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => MetasAhorroScreen(
                                                    usuario: widget.usuario,
                                                  ),
                                                ),
                                              ).then((_) => _cargarMetasActivas());
                                            },
                                            child: const Text('Ver todas las metas'),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                    ],
                  ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 24),

            // Sección de Gráficos Estadísticos
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.pie_chart_outline,
                          color: Theme.of(context).primaryColor,
                          size: isSmallScreen ? 22 : 28,
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Flexible(
                          child: Text(
                            'Estadísticas',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 16 : null,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),                    // Gráfico de Barras Comparativo
                    Text(
                      'Ingresos vs Gastos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 13 : null,
                          ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    SizedBox(
                      height: isSmallScreen ? 150 : 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: () {
                            final maxValue = totalIngresos > totalGastos 
                                ? totalIngresos 
                                : totalGastos;
                            return maxValue > 0 ? maxValue * 1.2 : 10000.0;
                          }(),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                String label = groupIndex == 0 ? 'Ingresos' : 'Gastos';
                                return BarTooltipItem(
                                  '$label\n${CurrencyFormatter.format(rod.toY)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text('Ingresos',
                                          style: TextStyle(fontWeight: FontWeight.bold));
                                    case 1:
                                      return const Text('Gastos',
                                          style: TextStyle(fontWeight: FontWeight.bold));
                                    default:
                                      return const Text('');
                                  }
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: isSmallScreen ? 40 : 60,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '\$${(value / 1000).toStringAsFixed(0)}k',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 8 : 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: () {
                              final maxValue = totalIngresos > totalGastos 
                                  ? totalIngresos 
                                  : totalGastos;
                              return maxValue > 0 ? (maxValue / 4).toDouble() : 1000.0;
                            }(),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: totalIngresos,
                                  color: Colors.green[600],
                                  width: isSmallScreen ? 30 : 40,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: totalGastos,
                                  color: Colors.red[600],
                                  width: isSmallScreen ? 30 : 40,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 32),

                    // Gráfico de Pastel (Pie Chart)
                    Text(
                      'Distribución',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 13 : null,
                          ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    SizedBox(
                      height: isSmallScreen ? 180 : 220,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: isSmallScreen ? 30 : 40,
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green[600],
                                    value: totalIngresos,
                                    title: totalIngresos > 0
                                        ? '${((totalIngresos / (totalIngresos + totalGastos)) * 100).toStringAsFixed(1)}%'
                                        : '0%',
                                    radius: isSmallScreen ? 50 : 60,
                                    titleStyle: TextStyle(
                                      fontSize: isSmallScreen ? 11 : 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.red[600],
                                    value: totalGastos,
                                    title: (totalIngresos + totalGastos) > 0
                                        ? '${((totalGastos / (totalIngresos + totalGastos)) * 100).toStringAsFixed(1)}%'
                                        : '0%',
                                    radius: isSmallScreen ? 50 : 60,
                                    titleStyle: TextStyle(
                                      fontSize: isSmallScreen ? 11 : 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegendItem(
                                  color: Colors.green[600]!,
                                  label: 'Ingresos',
                                  value: CurrencyFormatter.format(totalIngresos),
                                ),
                                const SizedBox(height: 12),
                                _buildLegendItem(
                                  color: Colors.red[600]!,
                                  label: 'Gastos',
                                  value: CurrencyFormatter.format(totalGastos),
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  'Balance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(saldo),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: saldo >= 0 ? Colors.green[700] : Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 16),

                    // Indicadores adicionales
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 10 : 16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            child: _buildStatIndicator(
                              icon: Icons.trending_up,
                              label: 'Tasa Ahorro',
                              value: totalIngresos > 0
                                  ? '${((saldo / totalIngresos) * 100).toStringAsFixed(1)}%'
                                  : '0%',
                              color: Colors.blue[700]!,
                              isSmall: isSmallScreen,
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.blue[200],
                          ),
                          Flexible(
                            child: _buildStatIndicator(
                              icon: Icons.account_balance_wallet,
                              label: 'Diferencia',
                              value: CurrencyFormatter.format((totalIngresos - totalGastos).abs()),
                              color: saldo >= 0 ? Colors.green[700]! : Colors.red[700]!,
                              isSmall: isSmallScreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
      ), // Cierra RefreshIndicator
    );
  }

  // Widget para crear leyenda del gráfico de pastel
  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget para indicadores estadísticos
  Widget _buildStatIndicator({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isSmall = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: isSmall ? 20 : 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 9 : 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // Helper para obtener icono según frecuencia
  IconData _getIconByFrecuencia(String frecuencia) {
    switch (frecuencia.toUpperCase()) {
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
}
