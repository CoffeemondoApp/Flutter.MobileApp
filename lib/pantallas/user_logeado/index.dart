import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeemondo/pantallas/user_logeado/paginas/eventos/eventos.dart';
import 'package:coffeemondo/pantallas/user_logeado/paginas/cafeterias/Cafeterias.dart';
import 'package:coffeemondo/pantallas/user_logeado/paginas/home/home.dart';
import 'package:coffeemondo/pantallas/user_logeado/paginas/resenas/resenas.dart';
import 'package:coffeemondo/pantallas/user_logeado/variables_globales/varaibles_globales.dart';
import 'package:coffeemondo/pantallas/user_logeado/paginas/perfil/Perfil.dart';
import 'app_bar/app_bar_custom.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../firebase/autenticacion.dart';

import 'dart:math' as math;
import 'bottomBar_principal.dart';
import 'paginas/carrito/carrito.dart';

class IndexPage extends StatefulWidget {
  final String tiempo_inicio;
  const IndexPage(this.tiempo_inicio, {super.key});

  @override
  IndexPageState createState() => IndexPageState();
}

const Color morado = Color.fromARGB(255, 84, 14, 148);
const Color naranja = Color.fromARGB(255, 255, 100, 0);
const colorScaffold = Color(0xffffebdcac);

String tab = '';
var inicio = '';
int index = 0;

class IndexPageState extends State<IndexPage> {
  // Se declara la instancia de firebase en la variable _firebaseAuth
  final GlobalController globalController = GlobalController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late GoogleMapController googleMapController;
  // Si existe un usuario logeado, este asigna a currentUser la propiedad currentUser del Auth de FIREBASE
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  void initState() {
    super.initState();
    // Se inicia la funcion de getData para traer la informacion de usuario proveniente de Firebase

    globalController.getData();
  }

  bool _visible = false;
  int _currentIndex = 0;

//Crear funcion que retorne en una lista el nivel del usuario y el porcentaje de progreso
  List<Map<String, dynamic>> getNivel() {
    var nivel_actual = globalController.nivel.value;
    var nivel_usuario = 0;

    for (var i = 0; i < globalController.niveles.length; i++) {
      if (globalController.puntaje_actual.value <=
          globalController.niveles[i]['puntaje_nivel']) {
        nivel_usuario = globalController.niveles[i]['nivel'];
        globalController.porcentaje.value =
            (globalController.puntaje_actual.value) /
                globalController.niveles[i]['puntaje_nivel'];
        //Cuando sube de nivel se reinicia el porcentaje
        if (i >= 1) {
          globalController.porcentaje.value =
              (globalController.puntaje_actual.value.toDouble() -
                      globalController.niveles[i - 1]['puntaje_nivel']) /
                  (globalController.niveles[i]['puntaje_nivel'] -
                      globalController.niveles[i - 1]['puntaje_nivel']);
        }

        globalController.puntaje_nivel.value =
            globalController.niveles[i]['puntaje_nivel'];
        break;
      }
    }
    return [
      {
        'nivel': nivel_usuario,
        'porcentaje': globalController.porcentaje.value,
        'puntaje_nivel': globalController.puntaje_nivel.value,
        'nivel actual': nivel_actual
      },
    ];
  }

  _subirNivel() async {
    //Se declara en user al usuario actual
    User? user = Auth().currentUser;
    //Se crea una instancia de la base de datos de Firebase
    FirebaseFirestore db = FirebaseFirestore.instance;
    //Se crea una instancia de la coleccion de usuarios
    CollectionReference users = db.collection('users');
    //Se crea una instancia del documento del usuario actual
    DocumentReference documentReference = users.doc(user?.uid);
    //Se actualiza el nivel del usuario
    documentReference.update({'nivel': globalController.nivel.value});
    _subirPuntaje();
  }

  _subirPuntaje() {
    //Se declara en user al usuario actual
    User? user = Auth().currentUser;
    //Se crea una instancia de la base de datos de Firebase
    FirebaseFirestore db = FirebaseFirestore.instance;
    //Se crea una instancia de la coleccion de usuarios
    CollectionReference users = db.collection('users');
    //Se crea una instancia del documento del usuario actual
    DocumentReference documentReference = users.doc(user?.uid);
    //Se actualiza el nivel del usuario
    documentReference
        .update({'puntaje': globalController.puntaje_actual.value.toString()});
  }

  //Funcion para calcular cuanto tiempo lleva el usuario en la aplicacion y actualizar el puntaje
  String _calcularTiempo() {
    //Se obtiene la fecha y hora actual
    var now = new DateTime.now();
    //Se obtiene la fecha y hora de inicio de sesion
    var inicio = DateTime.parse(widget.tiempo_inicio);
    //Se calcula la diferencia entre la fecha y hora actual y la fecha y hora de inicio de sesion
    var diferencia = now.difference(inicio);
    //Se calcula el tiempo en minutos
    var tiempo_hora = diferencia.inHours;
    var tiempo_minutos = diferencia.inMinutes;
    var tiempo_segundos = diferencia.inSeconds;

    return ' Hola $tiempo_hora/$tiempo_minutos/$tiempo_segundos';
  }

  subirPuntos(int puntos) {
    //aumentar en 10 el puntaje actual
    setState(() {
      globalController.puntaje_actual.value += puntos;
      globalController.porcentaje.value =
          globalController.puntaje_actual.value /
              globalController.puntaje_nivel.value;
      globalController.puntaje_actual_string.value =
          globalController.puntaje_actual.value.toString();
    });
  }

  final Uri _urlBT =
      Uri.parse('https://chat.whatsapp.com/KfA99u7QDyz4mebTEkiMoW');

  Future<void> enviarAlGrupo() async {
    if (!await launchUrl(_urlBT, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_urlBT');
    }
  }

  @override
  Widget build(BuildContext context) {
    //imprimir el tiempo que lleva el usuario en la aplicacion

    int elindex = globalController.currentIndex.value;
    print('Cual es el bendito index $elindex');

    // _recompensa() {
    //   if (int.parse(_calcularTiempo().split('/')[2]) == 10) {
    //     print('Recompensa por estar 10 secs en la app, has ganado 10 pts');
    //     setState(() {
    //       globalController.puntaje_actual.value += 10;
    //       porcentaje = puntaje_actual / puntaje_nivel;
    //       puntaje_actual_string = puntaje_actual.toString();
    //     });
    //   }
    // }

    Widget _containerMapa() {
      return (Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            color: Color.fromARGB(0, 0, 0, 0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.056,
                  bottom: MediaQuery.of(context).size.height * 0.056,
                ),
                //Mostrar mapa en el container

                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.12,
                    right: MediaQuery.of(context).size.width * 0.12),
                child: GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(-33.454572, -70.6559607),
                    zoom: 10,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                  },
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(0, 1, 155, 27),
                ),
              ),
            ],
          )));
    }

    //Hacer que _recompensa se ejecute todo el tiempo
    //Timer.periodic(Duration(seconds: 2), (timer) {
    //_recompensa();
    //});

    //Crear funcion para actualizar el puntaje

    //Crear funcion para detectar cuando el nivel inicial es diferente al nivel actual

    // print(nivel.toString() + ' ' + niveluser.toString());

    void changeIndex(int newNumber) {
      setState(() {
        index = newNumber;
      });
    }

    final List<Widget> _tabs = <Widget>[
      Home(
          globalController: globalController,
          subirPuntos: subirPuntos,
          enviarAlGrupo: enviarAlGrupo),
      ResenasPage(widget.tiempo_inicio, globalController: globalController, subirPuntos: subirPuntos,),
      Cafeterias(widget.tiempo_inicio, globalController: globalController),
      EventosPage(widget.tiempo_inicio , subirPuntos: subirPuntos),
      CarritoPage(widget.tiempo_inicio),
      PerfilPage(widget.tiempo_inicio)
      
    ];
    return SafeArea(
  child: Scaffold(
    backgroundColor: colorScaffold,
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: AppBarCustom(
        getNivel: getNivel,
        subirNivel: _subirNivel,
        urlImage: '',
        globalController: globalController,
      ),
    ),
    body: Padding(padding: EdgeInsets.only(top: 25.0), child: _tabs[index],),
    bottomNavigationBar: CustomBottomBar(
      inicio: widget.tiempo_inicio,
      globalController: globalController,
      changeIndex: changeIndex,
    ),
  ),
);

  }
}
