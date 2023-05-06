import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pay/pay.dart';
import 'payment_configurations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coffeemondo/pantallas/resenas/crearRese%C3%B1a.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../../../firebase/autenticacion.dart';
import '../../variables_globales/varaibles_globales.dart';
import '../cafeterias/Cafeterias.dart';

import '../perfil/Perfil.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

import '../../bottomBar_principal.dart';

class CarritoPage extends StatefulWidget {
  final String tiempo_inicio;
  const CarritoPage(this.tiempo_inicio, {super.key});

  @override
  CarritoPageState createState() => CarritoPageState();
}

var colorScaffold = Color(0xffffebdcac);

class CarritoPageState extends State<CarritoPage> {
  // Se declara la instancia de firebase en la variable _firebaseAuth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CarritoController carritoController = Get.put(CarritoController());
  // final CarritoController carritoController = Get.find();
  final _paymentItems = <PaymentItem>[];

  bool mostrarBotonPago = true;
  // Si existe un usuario logeado, este asigna a currentUser la propiedad currentUser del Auth de FIREBASE
  User? get currentUser => _firebaseAuth.currentUser;
  @override
  void initState() {
    super.initState();

    for (var producto in carritoController.productosEnCarrito) {
      var precioTotal = producto['precio'] * producto['cantidad'];

      if (!_paymentItems.any((item) => item.label == producto['nombre'])) {
        _paymentItems.add(
          PaymentItem(
            label: producto['nombre'],
            amount: precioTotal.toString(),
            status: PaymentItemStatus.final_price,
          ),
        );
      }
    }
  }

  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    print('El carrito: ${carritoController.productosEnCarrito}');
    print('El  directo a pagar: ${_paymentItems}');

    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                "Tu orden",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
                child: Obx(
              () => carritoController.productosEnCarrito.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          Text('Tu carrito está vacío.'),
                          Text('¡Visita la sección de eventos y participa!'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: carritoController.productosEnCarrito.length,
                      itemBuilder: (context, index) {
                        final producto =
                            carritoController.productosEnCarrito[index];

                        return ProductoEnCarritoWidget(
                          producto: producto,
                          onRemover: () {
                            carritoController.removerDelCarrito(index);
                          },
                          onAumentar: () {
                            carritoController.aumentarCantidad(index);
                          },
                          onDisminuir: () {
                            carritoController.disminuirCantidad(index);
                          },
                        );
                      },
                    ),
            )),
            Expanded(child: Container()),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GooglePayButton(
                  paymentConfiguration:
                      PaymentConfiguration.fromJsonString(defaultGooglePay),
                  paymentItems: _paymentItems,
                  childOnError: const Text('Google Pay no es compatible'),
                  width: double.infinity,
                  type: GooglePayButtonType.pay,
                  margin: const EdgeInsets.only(top: 15.0),
                  onPaymentResult: (result) =>
                      debugPrint('Payment Result $result'),
                  loadingIndicator: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
              // children: <Widget>[
              //   if (mostrarBotonPago)
              //     ElevatedButton(
              //       onPressed: () {
              //         // Aquí podrías hacer cualquier cosa que necesites antes de ocultar el botón
              //         if (carritoController.productosEnCarrito.isNotEmpty) {
              //           setState(() {
              //             mostrarBotonPago = false;
              //           });
              //         }

              //       },
              //       child: Text('Proceder con la compra'),
              //     ),
              //   if (!mostrarBotonPago)
              //     GooglePayButton(
              //       paymentConfiguration:
              //           PaymentConfiguration.fromJsonString(defaultGooglePay),
              //       paymentItems: _paymentItems,
              //       childOnError: const Text('Google Pay no es compatible'),
              //       width: double.infinity,
              //       type: GooglePayButtonType.pay,
              //       margin: const EdgeInsets.only(top: 15.0),
              //       onPaymentResult: (result) =>
              //           debugPrint('Payment Result $result'),
              //       loadingIndicator: const Center(
              //         child: CircularProgressIndicator(),
              //       ),
              //     ),
              // ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductoEnCarritoWidget extends StatelessWidget {
  final Map<String, dynamic> producto;
  final VoidCallback onRemover;
  final VoidCallback onAumentar;
  final VoidCallback onDisminuir;

  const ProductoEnCarritoWidget({
    required this.producto,
    required this.onRemover,
    required this.onAumentar,
    required this.onDisminuir,
  });

  String formatoFecha(DateTime fecha) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(fecha);
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(producto['nombre']),
              Text(formatoFecha(producto['fecha']))
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: onDisminuir,
            ),
            Text(producto['cantidad'].toString()),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: onAumentar,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onRemover,
            ),
          ],
        ),
      ],
    );
  }
}
