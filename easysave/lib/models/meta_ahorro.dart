class CuotaAhorro {
  final int? id;
  final int numeroCuota;
  final double montoCuota;
  final String fechaProgramada;
  final String? fechaPago;
  final String estado; // PENDIENTE, PAGADA, VENCIDA

  CuotaAhorro({
    this.id,
    required this.numeroCuota,
    required this.montoCuota,
    required this.fechaProgramada,
    this.fechaPago,
    required this.estado,
  });

  factory CuotaAhorro.fromJson(Map<String, dynamic> json) {
    return CuotaAhorro(
      id: json['id'],
      numeroCuota: json['numeroCuota'],
      montoCuota: (json['montoCuota'] ?? 0).toDouble(),
      fechaProgramada: json['fechaProgramada'],
      fechaPago: json['fechaPago'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'numeroCuota': numeroCuota,
      'montoCuota': montoCuota,
      'fechaProgramada': fechaProgramada,
      if (fechaPago != null) 'fechaPago': fechaPago,
      'estado': estado,
    };
  }
}

class MetaAhorro {
  final int? id;
  final String nombreMeta;
  final double montoObjetivo;
  final double montoAhorrado;
  final double? montoFaltante;
  final double? progresoPorcentaje;
  final int numeroCuotas;
  final double valorCuota;
  final String frecuenciaCuota; // SEMANAL, QUINCENAL, MENSUAL
  final String? fechaInicio;
  final String? fechaFinEstimada;
  final String estado; // ACTIVA, COMPLETADA, CANCELADA
  final double? porcentajeBalance;
  final int? cuotasPagadas;
  final int? cuotasPendientes;
  final List<CuotaAhorro>? proximasCuotas;

  MetaAhorro({
    this.id,
    required this.nombreMeta,
    required this.montoObjetivo,
    this.montoAhorrado = 0.0,
    this.montoFaltante,
    this.progresoPorcentaje,
    required this.numeroCuotas,
    required this.valorCuota,
    required this.frecuenciaCuota,
    this.fechaInicio,
    this.fechaFinEstimada,
    required this.estado,
    this.porcentajeBalance,
    this.cuotasPagadas,
    this.cuotasPendientes,
    this.proximasCuotas,
  });

  factory MetaAhorro.fromJson(Map<String, dynamic> json) {
    return MetaAhorro(
      id: json['id'],
      nombreMeta: json['nombreMeta'] ?? 'Meta de Ahorro',
      montoObjetivo: (json['montoObjetivo'] ?? 0).toDouble(),
      montoAhorrado: (json['montoAhorrado'] ?? 0).toDouble(),
      montoFaltante: json['montoFaltante'] != null 
          ? (json['montoFaltante']).toDouble() 
          : null,
      progresoPorcentaje: json['progresoPorcentaje'] != null 
          ? (json['progresoPorcentaje']).toDouble() 
          : null,
      numeroCuotas: json['numeroCuotas'] ?? 12,
      valorCuota: (json['valorCuota'] ?? 0).toDouble(),
      frecuenciaCuota: json['frecuenciaCuota'] ?? 'MENSUAL',
      fechaInicio: json['fechaInicio'],
      fechaFinEstimada: json['fechaFinEstimada'],
      estado: json['estado'] ?? 'ACTIVA',
      porcentajeBalance: json['porcentajeBalance'] != null 
          ? (json['porcentajeBalance']).toDouble() 
          : null,
      cuotasPagadas: json['cuotasPagadas'],
      cuotasPendientes: json['cuotasPendientes'],
      proximasCuotas: json['proximasCuotas'] != null
          ? (json['proximasCuotas'] as List<dynamic>)
              .map((c) => CuotaAhorro.fromJson(c))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombreMeta': nombreMeta,
      'montoObjetivo': montoObjetivo,
      'montoAhorrado': montoAhorrado,
      if (montoFaltante != null) 'montoFaltante': montoFaltante,
      if (progresoPorcentaje != null) 'progresoPorcentaje': progresoPorcentaje,
      'numeroCuotas': numeroCuotas,
      'valorCuota': valorCuota,
      'frecuenciaCuota': frecuenciaCuota,
      if (fechaInicio != null) 'fechaInicio': fechaInicio,
      if (fechaFinEstimada != null) 'fechaFinEstimada': fechaFinEstimada,
      'estado': estado,
      if (porcentajeBalance != null) 'porcentajeBalance': porcentajeBalance,
      if (cuotasPagadas != null) 'cuotasPagadas': cuotasPagadas,
      if (cuotasPendientes != null) 'cuotasPendientes': cuotasPendientes,
      if (proximasCuotas != null) 
        'proximasCuotas': proximasCuotas!.map((c) => c.toJson()).toList(),
    };
  }

  // Getters adicionales para compatibilidad con PDF
  DateTime get fechaObjetivo {
    if (fechaFinEstimada != null) {
      try {
        return DateTime.parse(fechaFinEstimada!);
      } catch (e) {
        return DateTime.now().add(Duration(days: numeroCuotas * 30));
      }
    }
    return DateTime.now().add(Duration(days: numeroCuotas * 30));
  }

  double get montoActual => montoAhorrado;
  
  String get nombre => nombreMeta;
}

class SugerenciaAhorro {
  final String mensaje;
  final MetaAhorro sugerencia;
  final String? nota;

  SugerenciaAhorro({
    required this.mensaje,
    required this.sugerencia,
    this.nota,
  });

  factory SugerenciaAhorro.fromJson(Map<String, dynamic> json) {
    return SugerenciaAhorro(
      mensaje: json['mensaje'] ?? 'Sugerencia de ahorro calculada',
      sugerencia: MetaAhorro.fromJson(json['sugerencia']),
      nota: json['nota'],
    );
  }
}
