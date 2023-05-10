import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:coffeemondo/pantallas/user_logeado/paginas/eventos/crear_evento.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../firebase/autenticacion.dart';
import '../perfil/Perfil.dart';
import 'asistir_evento.dart';
import 'package:coffeemondo/pantallas/user_logeado/Direccion.dart';
import 'package:coffeemondo/pantallas/user_logeado/paginas/cafeterias/Cafeterias.dart';
import 'package:coffeemondo/pantallas/user_logeado/paginas/resenas/resenas.dart';

class EventosPage extends StatefulWidget {
  final String tiempo_inicio;
  final Function(int) subirPuntos;
  final Function(int) changeIndex;
  const EventosPage(this.tiempo_inicio,
      {super.key, required this.subirPuntos, required this.changeIndex});

  @override
  EventosState createState() => EventosState();
}

String tab = '';
var colorScaffold = Color(0xffffebdcac);
// Declaracion de variables de informaicon de usuario
var _visible2 = false;

// acceso developers

bool acceso_dev = false;
bool abrirCrearCafeteria = false;

bool esLugar = true;
int cant_imagenesEvento = 0;
String fechas_guardarEvento = '';
int cantidadDias = 0;

//Declarar una variable de color from argb
const Color morado = Color.fromARGB(255, 84, 14, 148);
const Color naranja = Color.fromARGB(255, 255, 100, 0);

class EventosState extends State<EventosPage> {
  // Se declara la instancia de firebase en la variable _firebaseAuth

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late GoogleMapController googleMapController;
  // Si existe un usuario logeado, este asigna a currentUser la propiedad currentUser del Auth de FIREBASE
  User? get currentUser => _firebaseAuth.currentUser;
  @override
  void initState() {
    super.initState();
    // Se inicia la funcion de getData para traer la informacion de usuario proveniente de Firebase

    _getEmailUsuario();
  }

  void _navigateToCreateEvent(BuildContext context) async {
    // Navega a la pantalla para crear un evento
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearEvento(tiempo_inicio: widget.tiempo_inicio,)),
      
    );
  }



  bool _visible = false;

  String email = '';

  void _getEmailUsuario() async {
    User? user = Auth().currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      setState(() {
        email = userData.data()!['email'];
      });
    });
  }

  final DocumentReference docRef =
      FirebaseFirestore.instance.collection("eventos").doc();

  UploadTask? uploadTask;

  

  final DocumentReference docReCafeteriaf =
      FirebaseFirestore.instance.collection("eventos").doc();



  
  Widget containerTazasCalificadas(double promedio) {
    print(promedio);
    return (Container(
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            //color: Colors.white,
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //Crear iconos de tazas de acuerdo a la calificacion promedio de la tienda
            Row(
              children: [
                HalfFilledIcon(
                    (promedio >= 1) ? 1 : promedio, Icons.coffee, 30, "morado"),
                HalfFilledIcon((promedio >= 2) ? 1 : promedio - 1, Icons.coffee,
                    30, "morado"),
                HalfFilledIcon((promedio >= 3) ? 1 : promedio - 2, Icons.coffee,
                    30, "morado"),
                HalfFilledIcon((promedio >= 4) ? 1 : promedio - 3, Icons.coffee,
                    30, "morado"),
                HalfFilledIcon((promedio >= 5) ? 1 : promedio - 4, Icons.coffee,
                    30, "morado"),
              ],
            ),
            Container(
              child: Text(
                promedio.toString(),
                style: TextStyle(
                    color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            )
          ],
        )));
  }

  Widget moduloCafeterias(dynamic cafeteria) {
    return (Container(
      child: Text(cafeteria['nombre']),
    ));
  }

  CollectionReference eventos =
      FirebaseFirestore.instance.collection('eventos');

  String transformarMes(int mes) {
    var mes_string = '';
    switch (mes) {
      case 1:
        mes_string = 'Enero';
        break;
      case 2:
        mes_string = 'Febrero';
        break;
      case 3:
        mes_string = 'Marzo';
        break;
      case 4:
        mes_string = 'Abril';
        break;
      case 5:
        mes_string = 'Mayo';
        break;
      case 6:
        mes_string = 'Junio';
        break;
      case 7:
        mes_string = 'Julio';
        break;
      case 8:
        mes_string = 'Agosto';
        break;
      case 9:
        mes_string = 'Septiembre';
        break;
      case 10:
        mes_string = 'Octubre';
        break;
      case 11:
        mes_string = 'Noviembre';
        break;
      case 12:
        mes_string = 'Diciembre';
        break;
    }
    return mes_string;
  }

  String transformarFechas_string(String fechas) {
    var fechas_string = '';
    var fechas_list = fechas.split(' - ');
    var fecha_inicio_string = fechas_list[0];
    var fecha_fin_string = fechas_list[1];
    var fecha_inicio = fecha_inicio_string.split('/');
    var fecha_fin = fecha_fin_string.split('/');
    if (fecha_inicio[1] == fecha_fin[1]) {
      fechas_string =
          'Desde el ${fecha_inicio[0]} al ${fecha_fin[0]} de ${transformarMes(int.parse(fecha_inicio[1]))}';
    } else {
      fechas_string =
          'Desde el ${fecha_inicio[0]} de ${transformarMes(int.parse(fecha_inicio[1]))} al ${fecha_fin[0]} de ${transformarMes(int.parse(fecha_fin[1]))}';
    }
    return fechas_string;
  }

  Widget tituloEventos() {
    return (Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Text(
        'Eventos',
        style: TextStyle(
            color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
            fontWeight: FontWeight.bold,
            fontSize: 20),
      ),
    ));
  }

  Widget botonesCirculares(IconData icono, Function onPress) {
    return InkWell(
      onTap: () => onPress(),
      child: Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorMorado,
        ),
        child: Icon(
          icono,
          color: colorNaranja,
          size: 24.0,
        ),
      ),
    );
  }

  void asistirEvento(String idEvento) {
    ;
  }

  Widget btnAsistir(String idEvento) {
    return (GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AsistirEvento(
                    idEvento: idEvento, changeIndex: widget.changeIndex)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.35,
        height: MediaQuery.of(context).size.height * 0.05,
        margin: EdgeInsets.only(
          right: 5,
        ),
        decoration: BoxDecoration(
            color: colorMorado,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Container(
            alignment: Alignment(0, 0),
            child: Text(
              '¡Asistir!',
              style: TextStyle(
                color: Color(0xffffebdcac),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )),
      ),
    ));
  }

  Widget moduloFecha(String fecha) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorMorado,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Container(
            width: 200,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.event, color: Colors.white, size: 20),
                Text(
                  fecha,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bodyEventos() {
    User? user = Auth().currentUser;
    print(user!.uid);
    if (user.uid == '0UqMGUiuqjeMcNVXfcX2Hmp7na72' ||
        user.uid == 'n1OVOWft36cWJrZIn2haHwzXWOJ3' ||
        user.uid == 'zfkeofc6gTgfcUJiUZcnoBYdeNU2') {
      print("Acceso a botones de desarrollo permitido");
      setState(() {
        acceso_dev = true;
      });
    }
    List<String> hoursList = ['00:00', '00:30', '01:00'];
    return SingleChildScrollView(
      child: (Column(children: [

        GestureDetector(
          onTap: () {
            setState(() {
              _navigateToCreateEvent(context);
            });
          },
          child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        decoration: BoxDecoration(
          color: morado,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Crear Evento',
          style: TextStyle(
            color: naranja,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
        ),

        //Crear container para mostrar las cafeterias obtenidas de firebase con la variable cafeterias
        //Container para mostrar las cafeterias

        Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: [
              tituloEventos(),
              Container(
                height: MediaQuery.of(context).size.height * 0.55,
                child: StreamBuilder<QuerySnapshot>(
                  stream: eventos.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Algo salio mal');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Cargando");
                    }
                    return
                        //Crear un ListView.builder para mostrar los eventos obtenidas de firebase de forma horizontal
                        ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(right: 10.0),
                                width: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                  color: colorNaranja,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            snapshot.data!.docs[index]
                                                ['imagen'],
                                            filterQuality: FilterQuality.high,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                  color: colorMorado,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(colorMorado),
                                                ),
                                              );
                                            },
                                            fit: BoxFit.fill,
                                          ),
                                        )),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 10, top: 20, bottom: 10),
                                      child: Text(
                                          snapshot.data!.docs[index]['nombre'],
                                          style: TextStyle(
                                              color: colorMorado,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: ElevatedButton.icon(
                                        onPressed: () {},
                                        label: Container(
                                          child: Text(
                                            snapshot.data!.docs[index]
                                                ['ubicacion'],
                                            style: TextStyle(
                                                color: colorNaranja,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.location_on,
                                          color: colorNaranja,
                                          size: 18,
                                        ),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  colorMorado),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text('Precio:',
                                        style: TextStyle(
                                            color: colorMorado,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: colorMorado,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                snapshot.data!.docs[index]
                                                    ['descripcion'],
                                                style: TextStyle(
                                                  color: colorNaranja,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                    Expanded(child: Container()),
                                    moduloFecha(
                                        snapshot.data!.docs[index]['fecha']),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        botonesCirculares(
                                            Icons.info_outline, () {}),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        botonesCirculares(
                                            Icons.attach_money_rounded, () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AsistirEvento(
                                                          idEvento: snapshot
                                                              .data!
                                                              .docs[index]
                                                              .id,
                                                          changeIndex: widget
                                                              .changeIndex)));
                                        }),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        botonesCirculares(
                                            Icons.map_outlined, () {}),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        botonesCirculares(
                                            Icons.favorite_border_outlined,
                                            () {})
                                      ],
                                    )
                                  ],
                                ),
                              );
                            });

                  },
                ),
              )
            ]),
          ),
        )
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _bodyEventos();
  }
}
