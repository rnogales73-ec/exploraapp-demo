import 'package:flutter/material.dart';

/// Pantalla de prueba que provoca un error para verificar el widget de respaldo.
class PantallaConFallo extends StatelessWidget {
  const PantallaConFallo({super.key});

  @override
  Widget build(BuildContext context) {
    throw StateError('Fallo intencional para probar el manejo de errores');
  }
}
