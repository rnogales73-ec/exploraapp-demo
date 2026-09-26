import 'package:flutter/material.dart';

void main() {
  runApp(const ExploraEcApp());
}

class ExploraEcApp extends StatelessWidget {
  const ExploraEcApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExploraEC',
      home: const BienvenidaScreen(),
    );
  }
}

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ExploraEC-prueba',
        style: TextStyle(fontSize: 26),
        textAlign: TextAlign.center)),
      body: const Center(
        child: Text(
          'Descubre y guarda lugares cerca de ti prueba',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26),
        ),
      ),
    );
  }
}
