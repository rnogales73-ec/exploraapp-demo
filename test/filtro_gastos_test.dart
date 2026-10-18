import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:exploraec/controllers/auth_controller.dart';
import 'package:exploraec/controllers/gastos_controller.dart';
import 'package:exploraec/screens/gastos_screen.dart';
import 'package:exploraec/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

/// Servidor falso con lo justo para entrar y listar tres gastos de dos
/// categorías. No necesita el backend ni el emulador.
class _Servidor implements HttpClientAdapter {
  final gastos = [
    {'id': 1, 'descripcion': 'Almuerzo en el Mercado Central', 'monto': 6.5, 'categoria': 'comida', 'fecha': '2026-10-08'},
    {'id': 2, 'descripcion': 'Taxi al aeropuerto', 'monto': 12, 'categoria': 'transporte', 'fecha': '2026-10-08'},
    {'id': 3, 'descripcion': 'Encebollado', 'monto': 4, 'categoria': 'comida', 'fecha': '2026-10-09'},
  ];

  ResponseBody _json(Object cuerpo, [Map<String, List<String>> h = const {}]) =>
      ResponseBody.fromString(jsonEncode(cuerpo), 200,
          headers: {Headers.contentTypeHeader: ['application/json'], ...h});

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? cuerpo, Future<void>? cancelar) async {
    switch (o.path) {
      case '/usuarios/token':
        return _json({'access_token': 'tok-prueba', 'token_type': 'bearer'});
      case '/usuarios/me':
        return _json({'id': 1, 'email': 'a@b.com'});
      case '/gastos/categorias':
        return _json({'categorias': ['comida', 'transporte', 'entretenimiento', 'otros'], 'limite_por_categoria': 500.0});
      case '/gastos/':
        return _json(gastos, {'x-total-count': ['${gastos.length}']});
    }
    return ResponseBody.fromString(jsonEncode({'detail': 'ruta no prevista en la prueba: ${o.path}'}), 404,
        headers: {Headers.contentTypeHeader: ['application/json']});
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(() => Hive.init(Directory.systemTemp.createTempSync('hive_filtro').path));

  /// Monta la app con el servidor falso, la sesión iniciada y los gastos cargados.
  Future<void> montar() async {
    Get.reset();
    Get.testMode = true;
    await Hive.deleteFromDisk();
    FlutterSecureStorage.setMockInitialValues({});
    Get.put(ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://prueba'))..httpClientAdapter = _Servidor()));
    final auth = Get.put(AuthController());
    await auth.iniciarSesion('a@b.com', 'clave-1234');
    final gastos = Get.put(GastosController());
    for (var i = 0; i < 200 && (gastos.gastos.isEmpty || gastos.estado.value.name != 'exito'); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  testWidgets('Al elegir «comida» solo se ven los gastos de comida', (tester) async {
    await tester.runAsync(montar);
    await tester.pumpWidget(const GetMaterialApp(home: GastosScreen()));
    await tester.pump();

    expect(find.text('Almuerzo en el Mercado Central'), findsOneWidget);
    expect(find.text('Encebollado'), findsOneWidget);
    expect(find.text('Taxi al aeropuerto'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'comida'));
    await tester.pump();

    expect(find.text('Almuerzo en el Mercado Central'), findsOneWidget);
    expect(find.text('Encebollado'), findsOneWidget);
    expect(find.text('Taxi al aeropuerto'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Todas'));
    await tester.pump();

    expect(find.text('Taxi al aeropuerto'), findsOneWidget);
  });
}
