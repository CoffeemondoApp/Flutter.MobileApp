import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coffeemondo/pantallas/resenas/crearRese%C3%B1a.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../../../firebase/autenticacion.dart';
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
  // Si existe un usuario logeado, este asigna a currentUser la propiedad currentUser del Auth de FIREBASE
  User? get currentUser => _firebaseAuth.currentUser;
  @override
  void initState() {
    super.initState();
    // Se inicia la funcion de getData para traer la informacion de usuario proveniente de Firebase
  }

  bool _visible = false;

  Widget _bodyIndex() {
    return (Column(children: [
      Container(
          decoration: BoxDecoration(
            //color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.02),
                child: Text('Carrito de compras',
                    style: TextStyle(
                        color: colorMorado,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                //color: Colors.blue,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      height: MediaQuery.of(context).size.height * 0.2,
                      decoration: BoxDecoration(
                        color: colorMorado,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text('Debe agregar productos al carrito',
                            style: TextStyle(
                                color: colorNaranja,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                  color: colorMorado,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: \$ 0',
                          style: TextStyle(
                              color: colorNaranja,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.payment,
                                color: colorNaranja,
                              )),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.remove_shopping_cart,
                                color: colorNaranja,
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              )
              //Padding(padding: EdgeInsets.only(top: 10), child: _containerMapa()),
              //btnsDev(),
            ],
          ))
    ]));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _bodyIndex();
  }
}
