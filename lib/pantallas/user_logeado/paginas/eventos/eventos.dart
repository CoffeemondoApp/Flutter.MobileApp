import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
  const EventosPage(this.tiempo_inicio, {super.key, required this.subirPuntos, required this.changeIndex});

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
TextEditingController nombreEventoCE = TextEditingController();
TextEditingController direccionEventoCE = TextEditingController();
TextEditingController latitudEventoCC = TextEditingController();
TextEditingController longitudEventoCC = TextEditingController();
TextEditingController fechaEventoCE = TextEditingController();
TextEditingController imagenEventoCC = TextEditingController();
TextEditingController descripcionEventoCE = TextEditingController();
TextEditingController nombreLugarCE = TextEditingController();

bool esLugar = true;
int cant_imagenesEvento = 0;
String fechas_guardarEvento = '';

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

  void _limpiarCafeteria() async {
    // Se limpian los campos de texto
    nombreEventoCE.text = '';
    direccionEventoCC.text = '';
    latitudEventoCC.text = '';
    longitudEventoCC.text = '';
    fechaEventoCE.text = '';
    imagenEventoCC.text = '';
    descripcionEventoCC.text = '';
    setState(() {
      imagenSeleccionada = false;
    });
    //recargar pagina
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => IndexPage(inicio)));
  }

  TextEditingController nombreEventoCE = TextEditingController();
  TextEditingController direccionEventoCC = TextEditingController();
  TextEditingController latitudEventoCC = TextEditingController();
  TextEditingController longitudEventoCC = TextEditingController();
  TextEditingController fechaEventoCE = TextEditingController();
  TextEditingController imagenEventoCC = TextEditingController();
  TextEditingController descripcionEventoCC = TextEditingController();

  List<XFile>? imageFiles;
  List<String> imageUrls =
      []; // Lista para almacenar las URL de las imágenes subidas

  Future<List<String>> subirImagenes(List<XFile> files) async {
    List<String> urls = [];

    for (final file in files) {
      final path =
          'evento_evento_image/${docRef.id}/${docRef.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(File(file.path));
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  _openGallery(BuildContext context) async {
    //Funcion para abrir la galeria y obtener multiples imagenes
    imageFiles = await ImagePicker().pickMultiImage();
    if (imageFiles != null) {
      setState(() {
        cant_imagenesEvento = imageFiles!.length;
        if (cant_imagenesEvento > 0) {
          imagenSeleccionada = true;
        } else {
          imagenSeleccionada = false;
        }
      });
    } else {
      imagenSeleccionada = false;

      return;
    }
  }

  XFile? imageFile;

  _openCamera(BuildContext context) async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      setState(() {
        imageFilePath = imageFile!.path;
        imagenSeleccionada = true;
      });
    } else {
      imagenSeleccionada = false;
      return;
    }
    //obtener nombre de imagen antes de ser guardada

    setState(() {});
  }

  final ImagePicker _picker = ImagePicker();

  Widget _containerMensajeError() {
    return (AnimatedOpacity(
      opacity: _visible2 ? 1.0 : 0.0,
      duration: Duration(milliseconds: 1500),
      child: Container(
        margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.02,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05),
        width: MediaQuery.of(context).size.width * 0.9,
        height: (!_visible2) ? 0 : MediaQuery.of(context).size.height * 0.15,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
          borderRadius: BorderRadius.circular(20),
        ),
        child: //Crear columna que contenga el titulo y el cuerpo del container
            Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02),
              child: Text(
                'Error!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.04),
              child: Text('Debe llenar todos los campos',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ));
  }

  final DocumentReference docReCafeteriaf =
      FirebaseFirestore.instance.collection("eventos").doc();

  Future<void> guardarEvento() async {
    User? user = Auth().currentUser;
    if (nombreEventoCE.text != '' ||
        nombreLugarCE.text != '' ||
        fechas_guardarEvento != '' ||
        direccionEventoCE.text != '' ||
        descripcionEventoCE.text != '' ||
        imageFiles != null) {
      await FirebaseFirestore.instance
          .collection('eventos')
          .where('nombre', isEqualTo: nombreEventoCE.text)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.docs.isEmpty) {
          print('No existe la cafeteria');
          docRef.set(({
            'nombre': nombreEventoCE.text,
            'lugar': nombreLugarCE.text,
            'creador': user?.uid,
            'fecha': fechas_guardarEvento,
            'creador_correo': user?.email,
            'ubicacion': direccionEventoCE.text,
            'descripcion': descripcionEventoCE.text,
            'imagen': await subirImagenes(imageFiles!),
          }));

          print('Ingreso de cafeteria exitoso.');
          //enviar notificacion a todos los usuarios que tengan su token almacenado en firebase para que se les notifique que se ha creado un nuevo evento

          print("Notificacion enviada");
          //_limpiarCafeteria();
        } else {
          print('Ya existe el evento');
          setState(() {
            _visible2 = true;
          });
        }
      });
    } else {
      print('Se deben ingresar todos los datos');
      setState(() {
        _visible2 = true;
        //cambiar el estado de visible2 luego de 3 segundos a false

        //puntaje_actual += 100;
      });
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _visible2 = false;
        });
      });
    }
  }

  Widget textFieldNombreEvento(TextEditingController controller) {
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
          color: morado,
          fontSize: 14.0,
          height: 2.0,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: morado),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: morado),
            ),
            border: OutlineInputBorder(),
            prefixIcon:
                Icon(Icons.event_note_outlined, color: morado, size: 24),
            hintText: 'Nombre del evento',
            hintStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              color: morado,
            ))));
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
          color: morado,
          fontSize: 14.0,
          height: 2.0,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: morado),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: morado),
            ),
            border: OutlineInputBorder(),
            prefixIcon:
                Icon(Icons.coffee_maker_outlined, color: morado, size: 24),
            hintText: 'Nombre de lugar',
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: morado,
            ))));
  }

  //Crear widget date range picker dialog para seleccionar fecha y hora de inicio y fin de evento
  Widget dateRangePickerDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Seleccionar fecha y hora'),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.8,
        child: DateRangePickerDialog(
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 365))),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Aceptar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  String cambiarFormatoFecha(DateTimeRange fecha) {
    String fechaInicio = DateFormat('dd/MM/yyyy').format(fecha.start);
    String fechaFin = DateFormat('dd/MM/yyyy').format(fecha.end);
    return fechaInicio + ' - ' + fechaFin;
  }

  String transformarFechas(DateTime fecha_in, DateTime fecha_fin) {
    var fechaModificada = '';
    if (fecha_in.month == fecha_fin.month) {
      fechaModificada = 'Desde el ' +
          fecha_in.day.toString() +
          ' al ' +
          fecha_fin.day.toString() +
          ' de ' +
          //Obtener nombre del mes
          DateFormat.MMMM('es').format(fecha_in);
    } else {
      fechaModificada = 'Desde el ' +
          fecha_in.day.toString() +
          ' de ' +
          //Obtener nombre del mes
          DateFormat.MMMM('es').format(fecha_in) +
          ' al ' +
          fecha_fin.day.toString() +
          ' de ' +
          //Obtener nombre del mes
          DateFormat.MMMM('es').format(fecha_fin);
    }

    return fechaModificada;
  }

  Widget textFieldFechaCafeteria(TextEditingController controller) {
    return (TextField(
        cursorHeight: 0,
        cursorWidth: 0,
        readOnly: true,
        onTap: () async {
          DateTimeRange? pickeddate = await showDateRangePicker(
              locale: const Locale("es", "CL"),
              context: context,
              //initialDate: DateTime.now(),

              firstDate: DateTime(2023),
              lastDate: DateTime(2025),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      // or dark
                      primary: Color.fromARGB(255, 0x52, 0x01, 0x9b),
                      onPrimary: Colors.red,
                      surface: Color.fromARGB(255, 0x52, 0x01, 0x9b),
                      onSurface: Colors.black,

                      background: Color.fromARGB(255, 0x52, 0x01, 0x9b),
                      onBackground: Colors.black,

                      error: Color.fromARGB(255, 0x52, 0x01, 0x9b),
                      onError: Colors.red,
                      secondary: Color.fromARGB(255, 0x52, 0x01, 0x9b),
                      onSecondary: Colors.black,

                      primaryVariant: Color.fromARGB(255, 0x52, 0x01, 0x9b),
                      secondaryVariant: Color.fromARGB(255, 0x52, 0x01, 0x9b),
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        primary: Color.fromARGB(
                            255, 255, 79, 52), // button text color
                      ),
                    ),
                  ),
                  child: child!,
                );
              });

          if (pickeddate != null) {
            //Cambiar formato de daterangepicker a dd/mm/yyyy
            var fecha_cambiada = cambiarFormatoFecha(pickeddate);
            var fecha_evento = fecha_cambiada.split(' - ');
            var fecha_evento_inicio = fecha_evento[0].split(' ');
            var fecha_evento_fin = fecha_evento[1].split(' ');
            print(fecha_evento_inicio[0] + ' / ' + fecha_evento_fin[0]);
            setState(() {
              fechas_guardarEvento = pickeddate.start.day.toString() +
                  '/' +
                  pickeddate.start.month.toString() +
                  '/' +
                  pickeddate.start.year.toString() +
                  ' - ' +
                  pickeddate.end.day.toString() +
                  '/' +
                  pickeddate.end.month.toString() +
                  '/' +
                  pickeddate.end.year.toString();
              controller.text =
                  transformarFechas(pickeddate.start, pickeddate.end);
            });
          }
        },
        controller: controller,
        // onChanged: (((value) => validarCorreo())),
        style: const TextStyle(
          letterSpacing: 2,
          decoration: TextDecoration.none,
          color: morado,
          fontSize: 14.0,
          height: 2.0,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: morado),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: morado),
            ),
            border: OutlineInputBorder(),
            prefixIcon:
                Icon(Icons.date_range_outlined, color: morado, size: 24),
            hintText: 'Fecha del evento',
            hintStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              color: morado,
            ))));
  }

  navegarDireccion() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DireccionPage(widget.tiempo_inicio, '', '', '', '', '', 'cr')));
    setState(() {
      direccionEventoCC.text = result['direccion'];
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
          if (esLugar) {
            navegarDireccion();
          }
          ;
        },
        controller: controller,
        // onChanged: (((value) => validarCorreo())),
        style: const TextStyle(
          letterSpacing: 2,
          decoration: TextDecoration.none,
          color: morado,
          fontSize: 14.0,
          height: 2.0,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: morado),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: morado),
            ),
            border: OutlineInputBorder(),
            prefixIcon:
                Icon(Icons.location_on_outlined, color: morado, size: 24),
            hintText:
                (esLugar) ? 'Ubicacion del lugar' : 'Ubicacion de la cafeteria',
            hintStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: morado,
            ))));
  }

  Widget mostrarImagen(XFile imagen) {
    return (Container(
      width: (cant_imagenesEvento == 1) ? 40 : 30,
      height: (cant_imagenesEvento == 1) ? 40 : 30,
      margin: EdgeInsets.only(top: 10, left: 5, right: 5),
      child: Image.file(
        File(imagen.path),
        fit: BoxFit.cover,
      ),
    ));
  }

  Widget textFieldImagenCafeteria() {
    return (Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: (imagenSeleccionada) ? 2 : 15, left: 12),
          child: Row(children: [
            Icon(Icons.image_outlined, color: morado, size: 24),
            Container(
              margin: EdgeInsets.only(left: 10),
              child: (imagenSeleccionada)
                  ? Column(
                      children: [
                        Text(
                            (imagenSeleccionada)
                                ? //Comprobar si se selecciono una o mas imagenes
                                (cant_imagenesEvento > 1)
                                    ? '$cant_imagenesEvento Imagenes seleccionadas'
                                    : 'Imagen seleccionada'
                                : 'Logo/Imagen del evento',
                            style: TextStyle(
                                letterSpacing: 2,
                                color: morado,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        (cant_imagenesEvento > 1)
                            ? Container(
                                //Crear widget para mostrar la imagen de imageFile
                                margin: EdgeInsets.only(left: 10),
                                child: (imagenSeleccionada)
                                    ? Wrap(
                                        spacing: 1,
                                        runSpacing: 1,
                                        children: imageFiles!.map((image) {
                                          return mostrarImagen(image);
                                        }).toList(),
                                      )
                                    : Container(),
                              )
                            : Container()
                      ],
                    )
                  : Text(
                      (imagenSeleccionada)
                          ? //Comprobar si se selecciono una o mas imagenes
                          (cant_imagenesEvento > 1)
                              ? '$cant_imagenesEvento Imagenes seleccionadas'
                              : 'Imagen seleccionada'
                          : 'Logo/Imagen del evento',
                      style: TextStyle(
                          letterSpacing: 2,
                          color: morado,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
            ),
            (cant_imagenesEvento == 1)
                ? Container(
                    margin: EdgeInsets.only(left: 30, bottom: 5),
                    child: (imagenSeleccionada)
                        ? mostrarImagen(imageFiles![0])
                        : Container(),
                  )
                : Container()
          ]),
        ),
        Container(
          margin: EdgeInsets.only(top: (imagenSeleccionada) ? 4 : 15),
          height: 1,
          color: morado,
        )
      ],
    ));
  }

  void sugerencias() {
    //obtener coleccion de cafeterias
    List<String> cafeterias_list = [];
    FirebaseFirestore.instance
        .collection('cafeterias')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        //print(result.data());
        cafeterias_list.add(result.data()['nombre']);
      });
    });
    setState(() {
      cafeterias_nombre = cafeterias_list;
    });
  }

  Future<void> obtenerDireccion(String nombre_cafeteria) async {
    //obtener coleccion de cafeterias
    String direccion = '';
    FirebaseFirestore.instance
        .collection('cafeterias')
        .where('nombre', isEqualTo: nombre_cafeteria)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        direccion = result.data()['ubicacion'];
        print("direccion obtenida: $direccion");
      });
      setState(() {
        direccion_cafeteria = direccion;
      });
    });
  }

  Widget autoCompleteNombreCafeteria(controller) {
    return (EasyAutocomplete(
      inputTextStyle: TextStyle(
          color: morado,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          fontSize: 14),
      suggestionBackgroundColor: Color.fromARGB(255, 255, 79, 52),
      suggestionTextStyle: TextStyle(
          color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
          fontSize: 14,
          letterSpacing: 2,
          fontWeight: FontWeight.bold),
      suggestions: cafeterias_nombre,
      onChanged: (value) => {print('onChanged value: $value'), sugerencias()},
      onSubmitted: (value) => {
        print('valor subido: $value'),
        obtenerDireccion(value),
        print(direccionEventoCC.text),
        setState(() {
          cafeteria_CR = value;
          cafeteriaConfirmada = true;
          direccionEventoCC.text = direccion_cafeteria;
        }),
      },
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.coffee_maker_outlined,
          color: morado,
          size: 24,
        ),
        hintText: 'Nombre de cafetería',
        hintStyle: TextStyle(
            color: morado, fontWeight: FontWeight.bold, letterSpacing: 2),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: morado),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: morado),
        ),
      ),
    ));
  }

  Widget containerSeparador() {
    return (Container(
      margin: EdgeInsets.only(top: 15),
      height: 1,
      color: morado,
    ));
  }

  Widget textFieldDescripcionCafeteria(TextEditingController controller) {
    return TextField(
        style: TextStyle(
            color: morado,
            letterSpacing: 2,
            fontSize: 14,
            fontWeight: FontWeight.bold),
        controller: controller,
        maxLines: null,
        maxLength: 200,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.description_outlined, color: morado, size: 24),
          hintText: 'Descripcion del evento',
          hintStyle: TextStyle(
              color: morado,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 14),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: morado),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: morado),
          ),
        ));
  }

  Widget moduloCrearEvento() {
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
                      'Crear Evento',
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
                    child: textFieldNombreEvento(nombreEventoCE)),
                Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Text(
                        'Cafeteria',
                        style: TextStyle(
                            color: morado,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Switch(
                      value: esLugar,
                      onChanged: (value) {
                        setState(() {
                          esLugar = value;
                          if (value) {
                            direccionCafeteriaCC.text = '';
                          }
                          nombreEventoCE.text = '';
                          //direccionCafeteriaCC.text = '';
                        });
                      },
                      //activeTrackColor: Color.fromARGB(255, 255, 79, 52),
                      inactiveThumbColor: morado,
                      activeColor: morado,
                      inactiveTrackColor: Color.fromARGB(113, 102, 0, 255),
                    ),
                    Container(
                      child: Text(
                        'Lugar',
                        style: TextStyle(
                            color: morado,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )),
                Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05),
                    child: (!esLugar)
                        ? autoCompleteNombreCafeteria(nombreLugarCE)
                        : textFieldNombreCafeteria(nombreLugarCE)),
                Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05),
                    child: textFieldFechaCafeteria(fechaEventoCE)),
                Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05),
                    child: textFieldUbicacionCafeteria(direccionEventoCE)),
                Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05),
                    child: GestureDetector(
                      child: textFieldImagenCafeteria(),
                      onTap: () {
                        _openGallery(context);
                      },
                    )),
                Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05),
                    child: //crear textfield que se expanda con el texto
                        textFieldDescripcionCafeteria(descripcionEventoCE)),
                GestureDetector(
                  onTap: () {
                    guardarEvento();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: morado,
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.04,
                      ),
                      child: Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02,
                            bottom: MediaQuery.of(context).size.height * 0.02,
                            left: MediaQuery.of(context).size.width * 0.2,
                            right: MediaQuery.of(context).size.width * 0.2),
                        child: Text(
                          'Generar evento',
                          style: TextStyle(
                              color: colorScaffold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      )),
                )
              ],
            )
          : Text(
              'Crear Evento',
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

  Widget btnAsistir(String idEvento) {
    
    
    return (GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AsistirEvento(idEvento: idEvento, changeIndex: widget.changeIndex )));
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
        _containerMensajeError(),
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
                  ? MediaQuery.of(context).size.height * 0.7
                  : MediaQuery.of(context).size.height * 0.07,
              decoration: BoxDecoration(
                color: (abrirCrearCafeteria)
                    ? Colors.transparent
                    : Color.fromARGB(255, 0x52, 0x01, 0x9b),
                borderRadius: BorderRadius.circular(20),
              ),
              duration: Duration(seconds: 1),
              child: moduloCrearEvento()),
        ),

        //Crear container para mostrar las cafeterias obtenidas de firebase con la variable cafeterias
        //Container para mostrar las cafeterias

        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: [
              tituloEventos(),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
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
                                margin: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.02),
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(25),
                                        bottomRight: Radius.circular(25)),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: snapshot.data!
                                                .docs[index]['imagen'].length,
                                            itemBuilder: (context, index2) {
                                              return Container(
                                                child: Image.network(
                                                  snapshot.data!.docs[index]
                                                      ['imagen'][index2],
                                                  fit: BoxFit.cover,
                                                ),
                                              );
                                            }),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              margin: EdgeInsets.only(
                                                  left: 10, top: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      snapshot.data!.docs[index]
                                                          ['nombre'],
                                                      style: TextStyle(
                                                          color: colorMorado,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16)),
                                                  Text(
                                                      snapshot.data!.docs[index]
                                                          ['ubicacion'],
                                                      style: TextStyle(
                                                        color: colorMorado,
                                                      )),
                                                ],
                                              )),
                                          Container(
                                              //color: Colors.blue,
                                             
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Icon(Icons.attach_money,
                                                      color: colorMorado),
                                                  Icon(Icons.edit,
                                                      color: colorMorado),
                                                  Icon(Icons.delete,
                                                      color: colorMorado),
                                                ],
                                              ))
                                        ],
                                      ),
                                      Container(
                                        height: 1,
                                        margin:
                                            EdgeInsets.only(top: 55, left: 10),
                                        child: Text(
                                            snapshot.data!.docs[index]
                                                ['descripcion'],
                                            style: TextStyle(
                                              color: colorMorado,
                                            )),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 45, bottom: 25),
                                        child: Text(
                                            transformarFechas_string(snapshot
                                                .data!.docs[index]['fecha']),
                                            style: TextStyle(
                                              color: colorMorado,
                                            )),
                                      ),
                                      Container(
                                        //color: Colors.red,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            btnAsistir(snapshot.data!.docs[index].id),
                                            GestureDetector(
                                              onTap: () => {
                                                setState(() {
                                                  puntaje_actual += 100;
                                                }),
                                                print(
                                                    'puntaje actual $puntaje_actual'),
                                                // subirPuntaje()
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.35,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.05,
                                                decoration: BoxDecoration(
                                                    color: colorMorado,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20))),
                                                child: Container(
                                                    alignment: Alignment(0, 0),
                                                    child: Text(
                                                      'Mas información',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xffffebdcac),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    )),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
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
