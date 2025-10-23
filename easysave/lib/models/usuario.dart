class Ingreso {
  final int? id;
  final String nombreIngreso;
  final double valorIngreso;
  final String estadoIngreso;

  Ingreso({
    this.id,
    required this.nombreIngreso,
    required this.valorIngreso,
    required this.estadoIngreso,
  });

  factory Ingreso.fromJson(Map<String, dynamic> json) {
    return Ingreso(
      id: json['id'],
      nombreIngreso: json['nombreIngreso'],
      valorIngreso: (json['valorIngreso'] ?? 0).toDouble(),
      estadoIngreso: json['estadoIngreso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombreIngreso': nombreIngreso,
      'valorIngreso': valorIngreso,
      'estadoIngreso': estadoIngreso,
    };
  }
}

class Gasto {
  final int? id;
  final String nombreGasto;
  final double valorGasto;
  final String estadoGasto;

  Gasto({
    this.id,
    required this.nombreGasto,
    required this.valorGasto,
    required this.estadoGasto,
  });

  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id'],
      nombreGasto: json['nombreGasto'],
      valorGasto: (json['valorGasto'] ?? 0).toDouble(),
      estadoGasto: json['estadoGasto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombreGasto': nombreGasto,
      'valorGasto': valorGasto,
      'estadoGasto': estadoGasto,
    };
  }
}

class Usuario {
  final int? id;
  final String rol;
  final String correo;
  final String username;
  final String password;
  final List<Ingreso> ingresos;
  final List<Gasto> gastos;

  Usuario({
    this.id,
    this.rol = 'USER',
    required this.correo,
    required this.username,
    required this.password,
    this.ingresos = const [],
    this.gastos = const [],
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      rol: json['rol'] ?? 'USER',
      correo: json['correo'],
      username: json['username'],
      password: json['password'] ?? '',
      ingresos: (json['ingresos'] as List<dynamic>?)
              ?.map((i) => Ingreso.fromJson(i))
              .toList() ??
          [],
      gastos: (json['gastos'] as List<dynamic>?)
              ?.map((g) => Gasto.fromJson(g))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'rol': rol,
      'correo': correo,
      'username': username,
      'password': password,
      'ingresos': ingresos.map((i) => i.toJson()).toList(),
      'gastos': gastos.map((g) => g.toJson()).toList(),
    };
  }

  double get totalIngresos =>
      ingresos.fold(0, (sum, item) => sum + item.valorIngreso);
  
  double get totalGastos =>
      gastos.fold(0, (sum, item) => sum + item.valorGasto);
  
  double get balance => totalIngresos - totalGastos;
}
