import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
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
  late GoogleMapController googleMapController;
  final CarritoController carritoController = Get.put(CarritoController());

  // Si existe un usuario logeado, este asigna a currentUser la propiedad currentUser del Auth de FIREBASE
  User? get currentUser => _firebaseAuth.currentUser;
  @override
  void initState() {
    super.initState();
    // Se inicia la funcion de getData para traer la informacion de usuario proveniente de Firebase
  }

  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    print('El carrito: ${carritoController.productosEnCarrito}');
    // TODO: implement build
    return Container(
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
              child: Obx(() => ListView.builder(
                    itemCount: carritoController.productosEnCarrito.length,
                    itemBuilder: (BuildContext context, int index) {
                      final producto =
                          carritoController.productosEnCarrito[index];
                      List<Map<String, dynamic>> fechasAsistir =
                          producto['fechasAsistir'];

                      return Column(
                                    children: [
                                      SizedBox(
                                        height: 5,
                                      ),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Expanded(
                                      //       child: Text(
                                      //         producto['nombre'] ?? '',
                                      //         overflow: TextOverflow.ellipsis,
                                      //         style: TextStyle(
                                      //             fontWeight: FontWeight.bold),
                                      //       ),
                                      //     ),
                                      //     SizedBox(
                                      //       width: 120,
                                      //       child: Text(
                                      //           DateFormat('dd/MM/yyyy').format(
                                      //             compra['fecha']?.toLocal() ??
                                      //                 DateTime.now(),
                                      //           ),
                                      //           overflow: TextOverflow.ellipsis,
                                      //           style: TextStyle(
                                      //               fontWeight:
                                      //                   FontWeight.bold)),
                                      //     ),
                                      //     Expanded(
                                      //       child: SizedBox(
                                      //         width: 100,
                                      //         child: Wrap(
                                      //           spacing: 10,
                                      //           children: [
                                      //             Row(
                                      //               children: [
                                      //                 IconButton(
                                      //                   icon:
                                      //                       Icon(Icons.remove),
                                      //                   onPressed: () {
                                      //                     setState(() {
                                      //                       if (cantidad > 1) {
                                      //                         listaCompras[index]
                                      //                                     [
                                      //                                     'compra${index + 1}']![
                                      //                                 'cantidad'] =
                                      //                             (cantidad - 1)
                                      //                                 .toString();
                                      //                         _total -=
                                      //                             precioUnitario;
                                      //                         print(
                                      //                             listaCompras);
                                      //                       } else {
                                      //                         listaCompras[
                                      //                                     index]
                                      //                                 [
                                      //                                 'compra${index + 1}']![
                                      //                             'cantidad'] = '1';
                                      //                       }
                                      //                     });
                                      //                   },
                                      //                 ),
                                      //                 Text(
                                      //                   '$cantidad',
                                      //                   style: TextStyle(
                                      //                       fontSize: 18,
                                      //                       fontWeight:
                                      //                           FontWeight
                                      //                               .bold),
                                      //                 ),
                                      //                 IconButton(
                                      //                   icon: Icon(Icons.add),
                                      //                   onPressed: () {
                                      //                     setState(() {
                                      //                       listaCompras[index][
                                      //                                   'compra${index + 1}']![
                                      //                               'cantidad'] =
                                      //                           (cantidad + 1)
                                      //                               .toString();
                                      //                       _total +=
                                      //                           precioUnitario;
                                      //                       print(listaCompras);
                                      //                     });
                                      //                   },
                                      //                 ),
                                      //               ],
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ),
                                      //     Expanded(
                                      //       child: Text(
                                      //           '\$${precioTotal.toString()}',
                                      //           overflow: TextOverflow.ellipsis,
                                      //           style: TextStyle(
                                      //               fontWeight:
                                      //                   FontWeight.bold)),
                                      //     ),
                                      //     IconButton(
                                      //       icon: Icon(Icons.delete),
                                      //       onPressed: () {
                                      //         setState(() {
                                      //           listaCompras.removeAt(index);
                                      //         });
                                      //       },
                                      //     ),
                                      //   ],
                                      // ),
                                      Divider(),
                                    ],
                                  );
                    },
                  )))
        ],
      ),
    );
//     Obx(() => ListView.builder(
//   itemCount: carritoController.productosEnCarrito.length,
//   itemBuilder: (BuildContext context, int index) {
//     final producto = carritoController.productosEnCarrito[index];
//     List<Map<String, dynamic>> fechasAsistir = producto['fechasAsistir'];

//     return ListTile(
//       title: Text(producto['nombre']),
//       subtitle: ListView.builder(
//         shrinkWrap: true,
//         physics: ClampingScrollPhysics(),
//         itemCount: fechasAsistir.length,
//         itemBuilder: (BuildContext context, int index) {
//           final fecha = fechasAsistir[index];
//           return Text('${fecha['fecha']} - Cantidad: ${fecha['cantidad']}');
//         },
//       ),
//       trailing: IconButton(
//         icon: Icon(Icons.delete),
//         onPressed: () {
//           carritoController.removerDelCarrito(index);
//         },
//       ),
//     );
//   },
// ));
  }
}
