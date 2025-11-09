import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/usuario.dart';
import '../models/meta_ahorro.dart';

/// Servicio para generar y compartir reportes en PDF
class PdfService {
  final _formatoMoneda = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  final _formatoFecha = DateFormat('dd/MM/yyyy');

  /// Genera un PDF con el informe de Ingresos y Gastos
  Future<File> generarInformeIngresosGastos({
    required Usuario usuario,
    required List<Ingreso> ingresos,
    required List<Gasto> gastos,
  }) async {
    final pdf = pw.Document();

    // Calcular totales
    final totalIngresos = ingresos.fold(0.0, (sum, item) => sum + item.valorIngreso);
    final totalGastos = gastos.fold(0.0, (sum, item) => sum + item.valorGasto);
    final balance = totalIngresos - totalGastos;

    // Separar por tipo
    final ingresosFijos = ingresos.where((i) => i.estadoIngreso == 'fijo').toList();
    final ingresosVariables = ingresos.where((i) => i.estadoIngreso == 'variable').toList();
    final gastosFijos = gastos.where((g) => g.estadoGasto == 'fijo').toList();
    final gastosVariables = gastos.where((g) => g.estadoGasto == 'variable').toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'EasySave - Informe Financiero',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Usuario: ${usuario.username}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Fecha: ${_formatoFecha.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Divider(thickness: 2),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Resumen General
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'RESUMEN GENERAL',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                _buildResumenRow('Total Ingresos:', totalIngresos, PdfColors.green),
                _buildResumenRow('Total Gastos:', totalGastos, PdfColors.red),
                pw.Divider(),
                _buildResumenRow(
                  'Balance:',
                  balance,
                  balance >= 0 ? PdfColors.green : PdfColors.red,
                  isBold: true,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // Sección de Ingresos
          pw.Text(
            'INGRESOS',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green700,
            ),
          ),
          pw.SizedBox(height: 12),

          if (ingresosFijos.isNotEmpty) ...[
            pw.Text(
              'Ingresos Fijos:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildTablaIngresos(ingresosFijos),
            pw.SizedBox(height: 16),
          ],

          if (ingresosVariables.isNotEmpty) ...[
            pw.Text(
              'Ingresos Variables:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildTablaIngresos(ingresosVariables),
            pw.SizedBox(height: 16),
          ],

          if (ingresos.isEmpty)
            pw.Text('No hay ingresos registrados', style: const pw.TextStyle(fontSize: 12)),

          pw.SizedBox(height: 24),

          // Sección de Gastos
          pw.Text(
            'GASTOS',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red700,
            ),
          ),
          pw.SizedBox(height: 12),

          if (gastosFijos.isNotEmpty) ...[
            pw.Text(
              'Gastos Fijos:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildTablaGastos(gastosFijos),
            pw.SizedBox(height: 16),
          ],

          if (gastosVariables.isNotEmpty) ...[
            pw.Text(
              'Gastos Variables:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildTablaGastos(gastosVariables),
            pw.SizedBox(height: 16),
          ],

          if (gastos.isEmpty)
            pw.Text('No hay gastos registrados', style: const pw.TextStyle(fontSize: 12)),

          // Pie de página
          pw.SizedBox(height: 32),
          pw.Divider(),
          pw.Text(
            'Generado por EasySave App - ${_formatoFecha.format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    // Guardar el archivo
    return await _guardarPDF(
      await pdf.save(),
      'informe_financiero_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Genera un PDF con el informe de Metas de Ahorro
  Future<File> generarInformeMetas({
    required Usuario usuario,
    required List<MetaAhorro> metas,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final pdf = pw.Document();

    // Filtrar metas por fecha si se proporciona
    List<MetaAhorro> metasFiltradas = metas;
    if (fechaInicio != null || fechaFin != null) {
      metasFiltradas = metas.where((meta) {
        final fechaMeta = meta.fechaObjetivo;
        if (fechaInicio != null && fechaFin != null) {
          return fechaMeta.isAfter(fechaInicio.subtract(const Duration(days: 1))) &&
              fechaMeta.isBefore(fechaFin.add(const Duration(days: 1)));
        } else if (fechaInicio != null) {
          return fechaMeta.isAfter(fechaInicio.subtract(const Duration(days: 1)));
        } else if (fechaFin != null) {
          return fechaMeta.isBefore(fechaFin.add(const Duration(days: 1)));
        }
        return true;
      }).toList();
    }

    // Calcular estadísticas
    final metasActivas = metasFiltradas.where((m) => m.estado == 'activa').length;
    final metasCompletadas = metasFiltradas.where((m) => m.estado == 'completada').length;
    final metasCanceladas = metasFiltradas.where((m) => m.estado == 'cancelada').length;
    final totalObjetivo = metasFiltradas.fold(0.0, (sum, m) => sum + m.montoObjetivo);
    final totalAhorrado = metasFiltradas.fold(0.0, (sum, m) => sum + m.montoActual);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'EasySave - Metas de Ahorro',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Usuario: ${usuario.username}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Fecha: ${_formatoFecha.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                if (fechaInicio != null || fechaFin != null) ...[
                  pw.Text(
                    'Período: ${fechaInicio != null ? _formatoFecha.format(fechaInicio) : "Inicio"} - ${fechaFin != null ? _formatoFecha.format(fechaFin) : "Fin"}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
                pw.Divider(thickness: 2),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Resumen de Metas
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RESUMEN DE METAS',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildEstadisticaMeta('Total Metas:', metasFiltradas.length.toString()),
                    _buildEstadisticaMeta('Activas:', metasActivas.toString()),
                    _buildEstadisticaMeta('Completadas:', metasCompletadas.toString()),
                    _buildEstadisticaMeta('Canceladas:', metasCanceladas.toString()),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Divider(),
                _buildResumenRow('Total Objetivo:', totalObjetivo, PdfColors.blue),
                _buildResumenRow('Total Ahorrado:', totalAhorrado, PdfColors.green),
                _buildResumenRow(
                  'Por Ahorrar:',
                  totalObjetivo - totalAhorrado,
                  PdfColors.orange,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // Tabla de Metas
          pw.Text(
            'DETALLE DE METAS',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),

          if (metasFiltradas.isNotEmpty)
            _buildTablaMetas(metasFiltradas)
          else
            pw.Text(
              'No hay metas para el período seleccionado',
              style: const pw.TextStyle(fontSize: 12),
            ),

          // Pie de página
          pw.SizedBox(height: 32),
          pw.Divider(),
          pw.Text(
            'Generado por EasySave App - ${_formatoFecha.format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    // Guardar el archivo
    return await _guardarPDF(
      await pdf.save(),
      'informe_metas_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Guarda el PDF en un archivo temporal
  Future<File> _guardarPDF(Uint8List bytes, String filename) async {
    if (kIsWeb) {
      // En web, guardar en memoria y retornar un archivo "virtual"
      // Para web usaremos directamente Printing.sharePdf
      throw UnsupportedError(
        'Guardar archivos no está soportado en web. Use previsualizarPDFDirecto o compartirPDFDirecto',
      );
    } else {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/$filename');
      await file.writeAsBytes(bytes);
      return file;
    }
  }

  /// Previsualiza PDF directamente desde bytes (funciona en web)
  Future<void> previsualizarPDFDirecto(Uint8List pdfBytes, String nombre) async {
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name: nombre,
      format: PdfPageFormat.a4,
    );
  }

  /// Comparte PDF directamente desde bytes (funciona en web)
  Future<void> compartirPDFDirecto(Uint8List pdfBytes, String nombre, String asunto) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: nombre,
    );
  }

  /// Comparte un archivo PDF
  Future<void> compartirPDF(File pdfFile, String asunto) async {
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      subject: asunto,
      text: 'Informe generado por EasySave App',
    );
  }

  /// Previsualiza e imprime un PDF
  Future<void> previsualizarPDF(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      await Printing.layoutPdf(
        onLayout: (_) => bytes,
        name: 'informe_easysave.pdf',
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      // Si falla la previsualización, intentar compartir directamente
      print('Error al previsualizar: $e');
      rethrow;
    }
  }

  // Métodos auxiliares para construir componentes del PDF

  pw.Widget _buildResumenRow(String label, double valor, PdfColor color, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            _formatoMoneda.format(valor),
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEstadisticaMeta(String label, String valor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          valor,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildTablaIngresos(List<Ingreso> ingresos) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Encabezado
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green100),
          children: [
            _buildCeldaEncabezado('Nombre'),
            _buildCeldaEncabezado('Valor'),
          ],
        ),
        // Filas de datos
        ...ingresos.map((ingreso) => pw.TableRow(
              children: [
                _buildCelda(ingreso.nombreIngreso),
                _buildCelda(_formatoMoneda.format(ingreso.valorIngreso)),
              ],
            )),
        // Total
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green50),
          children: [
            _buildCelda('TOTAL', isBold: true),
            _buildCelda(
              _formatoMoneda.format(
                ingresos.fold(0.0, (sum, i) => sum + i.valorIngreso),
              ),
              isBold: true,
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTablaGastos(List<Gasto> gastos) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Encabezado
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.red100),
          children: [
            _buildCeldaEncabezado('Nombre'),
            _buildCeldaEncabezado('Valor'),
          ],
        ),
        // Filas de datos
        ...gastos.map((gasto) => pw.TableRow(
              children: [
                _buildCelda(gasto.nombreGasto),
                _buildCelda(_formatoMoneda.format(gasto.valorGasto)),
              ],
            )),
        // Total
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.red50),
          children: [
            _buildCelda('TOTAL', isBold: true),
            _buildCelda(
              _formatoMoneda.format(
                gastos.fold(0.0, (sum, g) => sum + g.valorGasto),
              ),
              isBold: true,
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTablaMetas(List<MetaAhorro> metas) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.2),
      },
      children: [
        // Encabezado
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue100),
          children: [
            _buildCeldaEncabezado('Meta'),
            _buildCeldaEncabezado('Objetivo'),
            _buildCeldaEncabezado('Ahorrado'),
            _buildCeldaEncabezado('Progreso'),
            _buildCeldaEncabezado('Fecha Objetivo'),
          ],
        ),
        // Filas de datos
        ...metas.map((meta) {
          final progreso = meta.montoObjetivo > 0 
              ? (meta.montoActual / meta.montoObjetivo * 100).toStringAsFixed(1)
              : '0.0';
          return pw.TableRow(
            children: [
              _buildCelda(meta.nombre),
              _buildCelda(_formatoMoneda.format(meta.montoObjetivo)),
              _buildCelda(_formatoMoneda.format(meta.montoActual)),
              _buildCelda('$progreso%'),
              _buildCelda(_formatoFecha.format(meta.fechaObjetivo)),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildCeldaEncabezado(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildCelda(String texto, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
