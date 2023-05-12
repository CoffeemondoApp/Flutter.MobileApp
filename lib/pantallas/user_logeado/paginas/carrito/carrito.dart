import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pay/pay.dart';
import 'payment_configurations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../firebase/autenticacion.dart';
import '../../variables_globales/varaibles_globales.dart';

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
  List<PaymentItem> _paymentItems = <PaymentItem>[];

  bool mostrarBotonPago = true;

  int montoTotal = 0;
  // Si existe un usuario logeado, este asigna a currentUser la propiedad currentUser del Auth de FIREBASE
  User? get currentUser => _firebaseAuth.currentUser;
  @override
  void initState() {
    super.initState();
    convertirProductosAPaymentItems();
  }

  void convertirProductosAPaymentItems() {
    _paymentItems.clear(); // Limpiar la lista de items de pago
    final List<PaymentItem> prueba = [];
    for (var producto in carritoController.productosEnCarrito) {
      final label = producto.nombre;
      final amount = (producto.precio * producto.cantidad.value).toString();

      final paymentItem = PaymentItem(
        label: label,
        amount: amount,
        status: PaymentItemStatus.final_price,
      );
      prueba.add(paymentItem);
    }
    setState(() {
      _paymentItems = prueba;
    });
  }

  bool _visible = false;

  final numberFormat = NumberFormat.currency(
      locale: 'es_CL', symbol: "\$", name: "Pesos", decimalDigits: 0);

  bool moduloCarrito = true;
  bool moduloCarrito2 = true;
  bool moduloSelectInfo = false;
  bool moduloSelectInfo2 = false;
  bool moduloIngresarInfo = false;
  bool moduloIngresarInfo2 = false;
  bool moduloSelectPago = false;
  bool moduloSelectPago2 = false;

  bool infoGuardada = false;
  bool infoGuardada2 = false;

  bool moduloFilaBtns = true;

  void generarElpago(result) {
    {
      // debugPrint('Payment Result $result');
      debugPrint('Payment Result ${result['tokenizationData']}');
      if (result) {
        String token = result['tokenizationData']['token'];
        //crear orden de pago y en estado pendiente; 

        debugPrint('Este el token: $token');
      }
      // modal();
    }
  }

  void generarCarrito() {
    if (!moduloCarrito) {
      setState(() {
        moduloCarrito2 = !moduloCarrito2;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          moduloCarrito = !moduloCarrito;
          moduloSelectInfo = true;
        });
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          moduloSelectInfo2 = true;
        });
      });
    } else {
      setState(() {
        moduloCarrito = !moduloCarrito;
        moduloSelectInfo2 = !moduloSelectInfo2;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          moduloCarrito2 = !moduloCarrito2;
          moduloSelectInfo = !moduloSelectInfo;
        });
      });
    }
  }

  Widget btnComprarAhora() {
    return (InkWell(
      onTap: () {
        setState(() {
          moduloFilaBtns = !moduloFilaBtns;
          moduloCarrito2 = false;
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            moduloCarrito = false;
          });
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            moduloIngresarInfo2 = false;
            moduloSelectInfo = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            moduloSelectInfo2 = true;
            moduloIngresarInfo = false;
          });
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: colorNaranja,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
            width: MediaQuery.of(context).size.width * 0.47,
            margin: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: colorMorado,
                  size: 20,
                ),
                Text('Comprar ahora',
                    style: TextStyle(color: colorMorado, fontSize: 12)),
              ],
            )),
      ),
    ));
  }

  Widget btnIngresarInfo() {
    return (InkWell(
      onTap: () {
        if (moduloIngresarInfo) {
          setState(() {
            moduloIngresarInfo2 = !moduloIngresarInfo2;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              moduloIngresarInfo = !moduloIngresarInfo;
            });
          });
        } else {
          setState(() {
            moduloIngresarInfo = !moduloIngresarInfo;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              moduloIngresarInfo2 = !moduloIngresarInfo2;
            });
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(
            left: 40,
            right: 40,
            top: !moduloIngresarInfo2 ? 5 : 10,
            bottom: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.draw,
                color: colorNaranja,
                size: 28,
              ),
              Container(
                child: Text(
                  'Ingresar la informacion',
                  style: TextStyle(
                      color: colorNaranja,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }

  Widget textoConfirmacionPago(
      String text, double size, FontWeight fontWeight, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Future<void> modal() {
    return showModalBottomSheet<void>(
      context: context,
      shape: Border.all(),
      // isDismissible: false,
      builder: (BuildContext context) {
        return Container(
          color: colorNaranja,
          height: 310,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                color: colorMorado, // Cambia el color de fondo aquí
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.check_circle_outline_outlined,
                            size: 100, color: colorNaranja),
                        textoConfirmacionPago('¡Gracias por su compra!', 28,
                            FontWeight.bold, colorNaranja),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                color: colorNaranja,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    textoConfirmacionPago('El pago ha sido exitoso', 18,
                        FontWeight.w600, Colors.black87),
                    const SizedBox(height: 10),
                    textoConfirmacionPago(
                        'En un momento recibirá una notificación con su orden de compra',
                        18,
                        FontWeight.w500,
                        Colors.black54),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.red;
                            } else {
                              return colorMorado;
                            }
                          },
                        ),
                      ),
                      child: const Text('Confirmar'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget filaBtnsCarrito() {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // btnComprarAhora(),
        GooglePayButton(
          width: 200,
          // width: MediaQuery.of(context).size.width * 0.45,
          paymentConfiguration:
              PaymentConfiguration.fromJsonString(defaultGooglePay),
          paymentItems: _paymentItems,
          type: GooglePayButtonType.checkout,
          margin: const EdgeInsets.only(top: 15.0),

          onPaymentResult: generarElpago,
          loadingIndicator: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFFff8a65),
              ),
            ),
          ),
        ),
      ],
    ));
  }

  Widget barraCarrito() {
    return (Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorNaranja,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(Icons.confirmation_num_outlined,
                        color: colorMorado, size: 20),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        '${carritoController.productosEnCarrito.length} productos',
                        style: TextStyle(
                            color: colorMorado,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )),
          ),
          InkWell(
            onTap: () {
              setState(() {
                moduloFilaBtns = !moduloFilaBtns;
                moduloCarrito = true;
                moduloSelectInfo2 = false;
                infoGuardada = false;
              });
              Future.delayed(Duration(milliseconds: 300), () {
                setState(() {
                  moduloSelectInfo = false;
                });
              });
              Future.delayed(Duration(milliseconds: 500), () {
                setState(() {
                  moduloCarrito2 = true;
                });
              });
            },
            child: Icon(Icons.arrow_drop_down_circle_outlined,
                color: colorNaranja, size: 24),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorNaranja,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(Icons.money_outlined, color: colorMorado, size: 20),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Obx(() => Text(
                            '${carritoController.obtenerPrecioTotal()}',
                            style: TextStyle(
                                color: colorMorado,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          )),
                    )
                  ],
                )),
          )
        ],
      ),
    ));
  }

  Widget containerTotalCompra() {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 9,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Obx(() => Text(
                      'Total de la compra: ${carritoController.obtenerPrecioTotal()}',
                      style: TextStyle(
                          color: colorNaranja,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ))),
          ),
        ),
      ],
    ));
  }

  Widget containerSelectInputInfo() {
    return (AnimatedOpacity(
      opacity: !moduloIngresarInfo ? 1 : 0,
      duration: Duration(milliseconds: 500),
      child: Column(
        children: [
          Text(
            'Como desea ingresar la informacion?',
            style: TextStyle(
                color: colorNaranja, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Container(
            margin: EdgeInsets.only(left: 40, right: 40, top: 30, bottom: 10),
            decoration: BoxDecoration(
              color: colorNaranja,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 35,
                  ),
                  Container(
                    child: Text(
                      'Obtener desde la aplicacion',
                      style: TextStyle(
                          color: colorMorado,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),
          btnIngresarInfo(),
        ],
      ),
    ));
  }

  Widget textFieldInputNombre() {
    return (Container(
      child: TextField(
        decoration: InputDecoration(
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: colorNaranja),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorNaranja),
          ),
          hintText: 'Nombre',
          hintStyle: TextStyle(
              color: colorNaranja, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    ));
  }

  Widget containerSelectInfo() {
    return (AnimatedContainer(
        duration: Duration(milliseconds: 800),
        height: infoGuardada
            ? MediaQuery.of(context).size.height * 0.05
            : !moduloIngresarInfo
                ? MediaQuery.of(context).size.height * 0.25
                : MediaQuery.of(context).size.height * 0.6,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.97,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: moduloSelectInfo2
                  ? !moduloIngresarInfo2
                      ? containerSelectInputInfo()
                      : Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Column(
                            children: [
                              btnIngresarInfo(),
                              Divider(
                                color: colorNaranja,
                                thickness: 2,
                              ),
                              Expanded(
                                  child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  textFieldInputNombre(),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: colorNaranja),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: colorNaranja),
                                        ),
                                        hintText: 'Apellido',
                                        hintStyle: TextStyle(
                                            color: colorNaranja,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: colorNaranja),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: colorNaranja),
                                        ),
                                        hintText: 'Correo',
                                        hintStyle: TextStyle(
                                            color: colorNaranja,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: colorNaranja),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: colorNaranja),
                                        ),
                                        hintText: 'Telefono',
                                        hintStyle: TextStyle(
                                            color: colorNaranja,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: colorNaranja),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: colorNaranja),
                                        ),
                                        hintText: 'RUT',
                                        hintStyle: TextStyle(
                                            color: colorNaranja,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                            ],
                          ),
                        )
                  : infoGuardada
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: colorNaranja,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.person_outline,
                                        color: colorMorado, size: 20),
                                    Container(
                                        margin: EdgeInsets.only(left: 6),
                                        child: Text(
                                          'Carlos Vasquez',
                                          style: TextStyle(
                                              color: colorMorado,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  moduloSelectPago2 = false;
                                });
                                Future.delayed(
                                    const Duration(milliseconds: 200), () {
                                  setState(() {
                                    moduloSelectPago = false;
                                    infoGuardada = !infoGuardada;
                                  });
                                });
                                Future.delayed(
                                    const Duration(milliseconds: 900), () {
                                  setState(() {
                                    moduloSelectInfo2 = !moduloSelectInfo2;
                                  });
                                });
                              },
                              child: Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                color: colorNaranja,
                                size: 24,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: colorNaranja,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: colorMorado, size: 20),
                                    Container(
                                        margin: EdgeInsets.only(left: 6),
                                        child: Text(
                                          '14.234.423-5',
                                          style: TextStyle(
                                              color: colorMorado,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container()),
        )));
  }

  Widget containerCheckout() {
    return (Expanded(
        child: AnimatedOpacity(
      opacity: moduloSelectPago2 ? 1 : 0,
      duration: Duration(milliseconds: moduloSelectInfo ? 100 : 300),
      child: Container(
        decoration: BoxDecoration(
          color: colorMorado,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(
                'Checkout',
                style: TextStyle(
                    color: colorNaranja,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.27,
                  child: Obx(
                    () => carritoController.productosEnCarrito.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                Text('Tu carrito está vacío.'),
                                Text(
                                    '¡Visita la sección de eventos y participa!'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount:
                                carritoController.productosEnCarrito.length,
                            itemBuilder: (context, index) {
                              final producto =
                                  carritoController.productosEnCarrito[index];

                              return ProductoEnCarritoWidget(
                                producto: producto,
                                onRemover: () {
                                  carritoController.removerDelCarrito(producto);
                                },
                                onAumentar: () {
                                  carritoController.aumentarCantidad(producto);
                                },
                                onDisminuir: () {
                                  carritoController.disminuirCantidad(producto);
                                },
                              );
                            },
                          ),
                  ),
                ),
              ),
              Divider(
                color: colorNaranja,
                thickness: 2,
              ),
              Obx(
                () => Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total de entradas: ',
                            style: TextStyle(
                              color: colorNaranja,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            numberFormat.format(
                                carritoController.obtenerCantidadTotal()),
                            style: TextStyle(
                                color: colorNaranja,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Precio total: ',
                            style: TextStyle(
                              color: colorNaranja,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            numberFormat
                                .format(carritoController.obtenerPrecioTotal()),
                            style: TextStyle(
                                color: colorNaranja,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: colorNaranja,
                thickness: 2,
              ),
              Text(
                'Seleccione su metodo de pago',
                style: TextStyle(
                    color: colorNaranja,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              GooglePayButton(
                onPaymentResult: (result) {
                  print('Resultado de pago: $result');
                  modal();
                },
                paymentConfiguration:
                    PaymentConfiguration.fromJsonString(defaultGooglePay),
                paymentItems: _paymentItems,
                type: GooglePayButtonType.pay,
                margin: const EdgeInsets.only(top: 15.0),
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFff8a65),
                    ),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                margin: EdgeInsets.symmetric(horizontal: 55, vertical: 10),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Text(
                            'Pagar con ',
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 191, 255),
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Image.asset(
                          'assets/mercadopago.png',
                          width: 36,
                        ),
                      ]),
                ),
              )
            ],
          ),
        ),
      ),
    )));
  }

  Widget btnGuardarInfo() {
    return (InkWell(
      onTap: () {
        setState(() {
          moduloSelectInfo2 = false;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            infoGuardada = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            moduloSelectPago = true;
          });
        });
        Future.delayed(const Duration(milliseconds: 1500), () {
          setState(() {
            moduloSelectPago2 = true;
          });
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 70),
        decoration: BoxDecoration(
          color: colorNaranja,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.check_circle_outline, color: colorMorado, size: 20),
                Text(
                  'Guardar informacion',
                  style: TextStyle(
                      color: colorMorado,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )),
      ),
    ));
  }

  var fontSize = 0.0;

  @override
  Widget build(BuildContext context) {
    print('Payment');
    for (var producto in _paymentItems) {
      print('Nombre: ${producto.label}');
      print('Fecha: ${producto.amount}');

      print('---');
    }

    // print('El  directo a pagar: ${obtenerMontoTotal()}');
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // Calcula el tamaño del texto basado en el ancho de la pantalla
    setState(() {
      fontSize = screenWidth * 0.045 * textScaleFactor;
    });

    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          children: [
            SizedBox(height: moduloCarrito ? 20 : 0),
            AnimatedContainer(
                duration: Duration(milliseconds: 700),
                curve: Curves.fastOutSlowIn,
                height: !moduloCarrito
                    ? MediaQuery.of(context).size.height * 0.05
                    : MediaQuery.of(context).size.height * 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 9,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: moduloCarrito2
                        ? Column(
                            children: [
                              Center(
                                child: Text(
                                  "Tu orden",
                                  style: TextStyle(
                                      color: colorNaranja,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: Obx(
                                  () => carritoController
                                          .productosEnCarrito.isEmpty
                                      ? Center(
                                          child: Column(
                                            children: [
                                              Text('Tu carrito está vacío.'),
                                              Text(
                                                  '¡Visita la sección de eventos y participa!'),
                                            ],
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: carritoController
                                              .productosEnCarrito.length,
                                          itemBuilder: (context, index) {
                                            final producto = carritoController
                                                .productosEnCarrito[index];

                                            return ProductoEnCarritoWidget(
                                              producto: producto,
                                              onRemover: () {
                                                carritoController
                                                    .removerDelCarrito(
                                                        producto);
                                                convertirProductosAPaymentItems();
                                              },
                                              onAumentar: () {
                                                carritoController
                                                    .aumentarCantidad(producto);
                                                convertirProductosAPaymentItems();
                                              },
                                              onDisminuir: () {
                                                carritoController
                                                    .disminuirCantidad(
                                                        producto);
                                                print('disminuir');
                                                convertirProductosAPaymentItems();
                                              },
                                            );
                                          },
                                        ),
                                ),
                              ),
                            ],
                          )
                        : barraCarrito(),
                  ),
                )),
            SizedBox(height: 10),
            moduloCarrito2
                ? containerTotalCompra()
                : moduloSelectInfo
                    ? containerSelectInfo()
                    : Container(),
            SizedBox(height: 10),
            moduloSelectPago ? containerCheckout() : Container(),
            //Expanded(child: Container()),
            moduloFilaBtns
                ? filaBtnsCarrito()
                : (moduloIngresarInfo2 && !infoGuardada)
                    ? btnGuardarInfo()
                    : Container(),
          ],
        ),
      ),
    );
  }
}

class ProductoEnCarritoWidget extends StatelessWidget {
  final Product producto;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // Calcula el tamaño del texto basado en el ancho de la pantalla
    final fontSize = screenWidth * 0.045 * textScaleFactor;
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorNaranja,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.075,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          color: colorMorado,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 1),
                          child: Row(
                            children: [
                              Icon(Icons.event_note,
                                  color: colorNaranja, size: fontSize),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                producto.nombre,
                                style: TextStyle(
                                    color: colorNaranja,
                                    fontSize: fontSize - 5,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )),
                    Row(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              color: colorMorado,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 10),
                              child: Row(
                                children: [
                                  Icon(Icons.date_range_outlined,
                                      color: colorNaranja, size: 20),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    formatoFecha(producto.fecha),
                                    style: TextStyle(
                                      color: colorNaranja,
                                      fontSize: fontSize - 3,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Entradas:',
                      style: TextStyle(
                          color: colorMorado,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 24, color: colorMorado),
                      onPressed: onDisminuir,
                    ),
                    Obx(
                      () => Text(
                        producto.cantidad.toString(),
                        style: TextStyle(
                            color: colorMorado,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 24, color: colorMorado),
                      onPressed: onAumentar,
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 24, color: colorMorado),
              onPressed: onRemover,
            ),
          ],
        ),
      ),
    );
  }
}
