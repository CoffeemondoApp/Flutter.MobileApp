// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeemondo/pantallas/user_logeado/variables_globales/varaibles_globales.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../../../firebase/autenticacion.dart';
import '../../Direccion.dart';
import '../../bottomBar_principal.dart';
import '../../index.dart';
import '../perfil/Perfil.dart';
import 'dart:math' as math;

import '../resenas/resenas.dart';

class Cafeterias extends StatefulWidget {
  final String tiempo_inicio;
  final GlobalController globalController;
  const Cafeterias(this.tiempo_inicio,
      {super.key, required this.globalController});

  @override
  CafeteriasState createState() => CafeteriasState();
}

num puntaje_actual = 180;
var puntaje_actual_string = puntaje_actual.toStringAsFixed(0);
num puntaje_nivel = 200;
var puntaje_nivel_string = puntaje_nivel.toStringAsFixed(0);
var porcentaje = puntaje_actual / puntaje_nivel;
var nivel = 1;
var niveluser;
var inicio = '';
var contPremio = 0;

// acceso developers

bool acceso_dev = false;
bool abrirCrearCafeteria = false;
TextEditingController nombreCafeteriaCC = TextEditingController();
TextEditingController direccionCafeteriaCC = TextEditingController();
TextEditingController correoCafeteriaCC = TextEditingController();
TextEditingController latitudCafeteriaCC = TextEditingController();
TextEditingController longitudCafeteriaCC = TextEditingController();
TextEditingController urlCafeteriaCC = TextEditingController();
TextEditingController imagenCafeteriaCC = TextEditingController();

class CafeteriasState extends State<Cafeterias> {
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

  final DocumentReference docRef =
      FirebaseFirestore.instance.collection("cafeterias").doc();

  var imagenSeleccionada = false;
  XFile? imageFile;
  UploadTask? uploadTask;
  String imageFilePath = '';

  void _limpiarCafeteria() async {
    // Se limpian los campos de texto
    nombreCafeteriaCC.text = '';
    direccionCafeteriaCC.text = '';
    correoCafeteriaCC.text = '';
    direccionCafeteriaCC.text = '';
    urlCafeteriaCC.text = '';
    setState(() {
      imagenSeleccionada = false;
    });
    //recargar pagina
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => IndexPage(inicio)));
  }

  Future subirImagen() async {
    // Se crea la ruta de la imagen en el Storage con el nombre del documento creado en la coleccion
    final path = 'cafeteria_cafeteria_image/${docRef.id}.jpg';
    final file = File(imageFile!.path);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlUserImage = await snapshot.ref.getDownloadURL();

    // Se retorna la url de la imagen para llamarla desde la funcion de guardarInformacion
    return urlUserImage;
  }

  _openGallery(BuildContext context) async {
    //imageFile = await ImagePicker().pickMultiImage();
    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        imageFilePath = imageFile!.path;
        imagenSeleccionada = true;
      });
      print('image: $imageFilePath');
    } else {
      imagenSeleccionada = false;
      return;
    }
    //obtener nombre de imagen antes de ser guardada

    setState(() {});
  }

  _openCamera(BuildContext context) async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      setState(() {
        imageFilePath = imageFile!.path;
        imagenSeleccionada = true;
      });
      print('image: $imageFilePath');
    } else {
      imagenSeleccionada = false;
      return;
    }
    //obtener nombre de imagen antes de ser guardada

    setState(() {});
  }

  final ImagePicker _picker = ImagePicker();

  final DocumentReference docReCafeteriaf =
      FirebaseFirestore.instance.collection("cafeterias").doc();

  Future<void> guardarCafeteria() async {
    User? user = Auth().currentUser;
    if (nombreCafeteriaCC.text != '') {
      await FirebaseFirestore.instance
          .collection('cafeterias')
          .where('nombre', isEqualTo: nombreCafeteriaCC.text)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.docs.isEmpty) {
          print('No existe la cafeteria');
          docReCafeteriaf.set(({
            'nombre': nombreCafeteriaCC.text,
            'creador': user?.uid,
            'calificacion': 0.0,
            'correo': correoCafeteriaCC.text,
            'web': urlCafeteriaCC.text,
            'ubicacion': direccionCafeteriaCC.text,
            'imagen': await subirImagen(),
          }));
          print('Ingreso de cafeteria exitoso.');
          _limpiarCafeteria();
        } else {
          print('Ya existe la cafeteria');
          setState(() {
            _visible = true;
          });
        }
      });
    } else {
      print('No se ha ingresado un nombre');
      setState(() {
        _visible = true;
      });
    }
  }

  Widget textFieldNombreCafeteria(TextEditingController controller) {
    return (TextField(
        cursorHeight: 0,
        cursorWidth: 0,
        onTap: () {
          setState(() {});
        },
        controller: controller,
        // onChanged: (((value) => validarCorreo())),
        style: const TextStyle(
          letterSpacing: 2,
          decoration: TextDecoration.none,
          color: Color.fromARGB(255, 255, 79, 52),
          fontSize: 14.0,
          height: 2.0,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 79, 52)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 79, 52)),
            ),
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.coffee_maker_outlined,
                color: Color.fromARGB(255, 255, 79, 52), size: 24),
            hintText: 'Nombre de la cafeteria',
            hintStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 255, 79, 52),
            ))));
  }

  Widget textFieldCorreoCafeteria(TextEditingController controller) {
    return (TextField(
        cursorHeight: 0,
        cursorWidth: 0,
        onTap: () {
          setState(() {});
        },
        controller: controller,
        // onChanged: (((value) => validarCorreo())),
        style: const TextStyle(
          letterSpacing: 2,
          decoration: TextDecoration.none,
          color: Color.fromARGB(255, 255, 79, 52),
          fontSize: 14.0,
          height: 2.0,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 79, 52)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 79, 52)),
            ),
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined,
                color: Color.fromARGB(255, 255, 79, 52), size: 24),
            hintText: 'Correo de la cafeteria',
            hintStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 255, 79, 52),
            ))));
  }

  Widget textFieldWebCafeteria(TextEditingController controller) {
    return (TextField(
        cursorHeight: 0,
        cursorWidth: 0,
        onTap: () {
          setState(() {});
        },
        controller: controller,
        // onChanged: (((value) => validarCorreo())),
        style: const TextStyle(
          letterSpacing: 2,
          decoration: TextDecoration.none,
          color: Color.fromARGB(255, 255, 79, 52),
          fontSize: 14.0,
          height: 2.0,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 79, 52)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 79, 52)),
            ),
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.web_outlined,
                color: Color.fromARGB(255, 255, 79, 52), size: 24),
            hintText: 'Web de la cafeteria',
            hintStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 255, 79, 52),
            ))));
  }

  navegarDireccion() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DireccionPage(widget.tiempo_inicio, '', '', '', '', '', 'cr')));
    setState(() {
      direccionCafeteriaCC.text = result['direccion'];
    });
    print('este es el resultado: $result');
  }

  Widget textFieldUbicacionCafeteria(TextEditingController controller) {
    return (TextField(
        readOnly: true,
        cursorHeight: 0,
        cursorWidth: 0,
        onTap: () {
          //navegar hacia direccion.dart para obtener la ubicacion de la cafeteria y mostrarla en el campo de texto
          navegarDireccion();
        },
        controller: controller,
        // onChanged: (((value) => validarCorreo())),
        style: const TextStyle(
          letterSpacing: 2,
          decoration: TextDecoration.none,
          color: Color.fromARGB(255, 255, 79, 52),
          fontSize: 14.0,
          height: 2.0,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 79, 52)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 79, 52)),
            ),
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on_outlined,
                color: Color.fromARGB(255, 255, 79, 52), size: 24),
            hintText: 'Ubicacion de la cafeteria',
            hintStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 255, 79, 52),
            ))));
  }

  Widget textFieldImagenCafeteria(TextEditingController controller) {
    return (Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: (imagenSeleccionada) ? 2 : 15, left: 12),
          child: Row(children: [
            Icon(Icons.image_outlined,
                color: Color.fromARGB(255, 255, 79, 52), size: 24),
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
                  (imagenSeleccionada)
                      ? 'Imagen seleccionada'
                      : 'Logo/Imagen de la cafeteria',
                  style: TextStyle(
                      letterSpacing: 2,
                      color: Color.fromARGB(255, 255, 79, 52),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
            Container(
              //Crear widget para mostrar la imagen de imageFile
              margin: EdgeInsets.only(left: 10),
              child: (imagenSeleccionada)
                  ? Image.file(
                      File(imageFilePath),
                      width: 50,
                      height: 50,
                    )
                  : Container(),
            ),
          ]),
        ),
        Container(
          margin: EdgeInsets.only(top: (imagenSeleccionada) ? 4 : 15),
          height: 1,
          color: Color.fromARGB(255, 255, 79, 52),
        )
      ],
    ));
  }

  Widget moduloCrearCafeteria() {
    return (Container(
      //color: Colors.white,
      margin: EdgeInsets.only(top: (!abrirCrearCafeteria) ? 0 : 15),
      alignment: (abrirCrearCafeteria) ? Alignment.topCenter : Alignment.center,
      child: (abrirCrearCafeteria)
          ? Column(
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        abrirCrearCafeteria = false;
                      });
                    },
                    child: Text(
                      'Crear Cafeteria',
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 79, 52),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )),
                Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05),
                    child: textFieldNombreCafeteria(nombreCafeteriaCC)),
                Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05),
                    child: textFieldCorreoCafeteria(correoCafeteriaCC)),
                Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05),
                    child: textFieldWebCafeteria(urlCafeteriaCC)),
                Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05),
                    child: textFieldUbicacionCafeteria(direccionCafeteriaCC)),
                Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05),
                    child: GestureDetector(
                      child: textFieldImagenCafeteria(imagenCafeteriaCC),
                      onTap: () {
                        _openGallery(context);
                      },
                    )),
                GestureDetector(
                  onTap: () {
                    guardarCafeteria();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 79, 52),
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.05,
                      ),
                      child: Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02,
                            bottom: MediaQuery.of(context).size.height * 0.02,
                            left: MediaQuery.of(context).size.width * 0.2,
                            right: MediaQuery.of(context).size.width * 0.2),
                        child: Text(
                          'Generar cafeteria',
                          style: TextStyle(
                              color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      )),
                )
              ],
            )
          : Text(
              'Crear Cafeteria',
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 79, 52),
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
    ));
  }

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

  CollectionReference cafeterias =
      FirebaseFirestore.instance.collection('cafeterias');

  Widget _bodyCafeterias() {
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
    return (Column(children: [
      GestureDetector(
        onTap: () {
          setState(() {
            if (!abrirCrearCafeteria) {
              abrirCrearCafeteria = !abrirCrearCafeteria;
            }
          });
        },
        child: AnimatedContainer(
            width: MediaQuery.of(context).size.width * 0.9,
            height: (abrirCrearCafeteria)
                ? MediaQuery.of(context).size.height * 0.60
                : MediaQuery.of(context).size.height * 0.07,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
              borderRadius: BorderRadius.circular(20),
            ),
            duration: Duration(seconds: 1),
            child: moduloCrearCafeteria()),
      ),

      //Crear container para mostrar las cafeterias obtenidas de firebase con la variable cafeterias
      //Container para mostrar las cafeterias
      Container(
        decoration: BoxDecoration(
            //color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text(
                'Cafeterias',
                style: TextStyle(
                    color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: StreamBuilder<QuerySnapshot>(
                stream: cafeterias.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Algo salio mal');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Cargando");
                  }

                  return
                      //Crear un ListView.builder para mostrar las cafeterias obtenidas de firebase de forma horizontal
                      ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        bottom:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02),
                                            child: Icon(Icons.coffee_sharp,
                                                color: Color.fromARGB(
                                                    255, 255, 79, 52)),
                                          ),
                                          Container(
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      snapshot.data!.docs[index]
                                                          ['nombre'],
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 255, 79, 52),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18)),
                                                  Text(
                                                      snapshot.data!.docs[index]
                                                          ['ubicacion'],
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 255, 79, 52),
                                                      )),
                                                ],
                                              ))
                                        ],
                                      )),
                                  Container(
                                    child: Image.network(
                                      snapshot.data!.docs[index]['imagen'],
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.3,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  containerTazasCalificadas(snapshot
                                      .data!.docs[index]['calificacion']),
                                  GestureDetector(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                      margin: EdgeInsets.only(
                                          top: 5,
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 255, 79, 52),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Container(
                                          alignment: Alignment(0, 0),
                                          child: Text(
                                            'Visitar Web',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 0x52, 0x01, 0x9b),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          )),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 255, 79, 52),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Container(
                                          alignment: Alignment(0, 0),
                                          child: Text(
                                            'Ver reseñas',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 0x52, 0x01, 0x9b),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          )),
                                    ),
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
    ]));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      child: _bodyCafeterias(),
    );

    //Hacer que _recompensa se ejecute todo el tiempo
    //Timer.periodic(Duration(seconds: 2), (timer) {
    //_recompensa();
    //});

    //Crear funcion para actualizar el puntaje

    //Crear funcion para detectar cuando el nivel inicial es diferente al nivel actual

    //print(nivel.toString() + ' ' + niveluser.toString());
  }
}
