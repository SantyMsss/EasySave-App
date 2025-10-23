import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../utils/currency_formatter.dart';

class IngresosScreen extends StatefulWidget {
  final Usuario usuario;

  const IngresosScreen({super.key, required this.usuario});

  @override
  State<IngresosScreen> createState() => _IngresosScreenState();
}

class _IngresosScreenState extends State<IngresosScreen> {
  final _usuarioService = UsuarioService();
  List<Ingreso> _ingresos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarIngresos();
  }

  Future<void> _cargarIngresos() async {
    setState(() => _isLoading = true);
    try {
      final data = await _usuarioService.obtenerIngresos(widget.usuario.id!);
      setState(() {
        _ingresos = data.map((json) => Ingreso.fromJson(json)).toList();
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

  Future<void> _mostrarDialogoAgregar() async {
    final nombreController = TextEditingController();
    final valorController = TextEditingController();
    String estadoSeleccionado = 'fijo';

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Ingreso'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Ingreso',
                    hintText: 'Ej: Salario',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valorController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    hintText: '0',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: estadoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'fijo', child: Text('Fijo')),
                    DropdownMenuItem(value: 'variable', child: Text('Variable')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => estadoSeleccionado = value!);
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
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isEmpty || valorController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completa todos los campos')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (resultado == true) {
      try {
        await _usuarioService.agregarIngreso(
          widget.usuario.id!,
          {
            'nombreIngreso': nombreController.text,
            'valorIngreso': double.parse(valorController.text),
            'estadoIngreso': estadoSeleccionado,
          },
        );
        _cargarIngresos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ingreso agregado exitosamente'),
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

  Future<void> _confirmarEliminar(Ingreso ingreso) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Ingreso'),
        content: Text('¿Estás seguro de eliminar "${ingreso.nombreIngreso}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _usuarioService.eliminarIngreso(ingreso.id!);
        _cargarIngresos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ingreso eliminado'),
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

  @override
  Widget build(BuildContext context) {
    final total = _ingresos.fold(0.0, (sum, item) => sum + item.valorIngreso);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ingresos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarIngresos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[600]!, Colors.green[400]!],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Ingresos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(total),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _ingresos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No tienes ingresos registrados',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _ingresos.length,
                          itemBuilder: (context, index) {
                            final ingreso = _ingresos[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green[100],
                                  child: Icon(Icons.trending_up,
                                      color: Colors.green[700]),
                                ),
                                title: Text(
                                  ingreso.nombreIngreso,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  ingreso.estadoIngreso.toUpperCase(),
                                  style: TextStyle(
                                    color: ingreso.estadoIngreso == 'fijo'
                                        ? Colors.blue
                                        : Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(
                                          ingreso.valorIngreso),
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _confirmarEliminar(ingreso),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregar,
        child: const Icon(Icons.add),
      ),
    );
  }
}
