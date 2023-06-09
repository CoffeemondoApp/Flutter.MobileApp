import 'dart:io';
import 'dart:math';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeemondo/firebase/autenticacion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../Direccion.dart';
import '../cafeterias/Cafeterias.dart';
import '../resenas/resenas.dart';

class CrearEvento extends StatefulWidget {
  final String tiempo_inicio;
  const CrearEvento({Key? key, required this.tiempo_inicio}) : super(key: key);

  @override
  _CrearEventoState createState() => _CrearEventoState();
}

var colorScaffold = Color(0xffffebdcac);
bool acceso_dev = false;
bool abrirCrearCafeteria = false;

bool esLugar = true;
int cant_imagenesEvento = 0;
const Color morado = Color.fromARGB(255, 84, 14, 148);
const Color naranja = Color.fromARGB(255, 255, 100, 0);

class _CrearEventoState extends State<CrearEvento> {
  String email = '';
  void initState() {
    super.initState();
    // Se inicia la funcion de getData para traer la informacion de usuario proveniente de Firebase

    _getEmailUsuario();
  }

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
    nombreLugarCE.text = '';
    fechaEventoCE.text = '';
    direccionEventoCC.text = '';
    latitudEventoCC.text = '';
    longitudEventoCC.text = '';
    imageFiles = [];
    descripcionEventoCE.text = '';
    capacidadMaximaPersonas.text = '';
    precioUnidad.text = '';
    separarEntradas.text = '';
    setState(() {
      imagenSeleccionada = false;
    });
  }

  String fechas_guardarEvento = '';
  int cantidadDias = 0;
  double ingresosEstimados = 0;
  double ingresosNeto = 0;
  double comision = 0;
  String estado = '';
  TextEditingController nombreEventoCE = TextEditingController();
  TextEditingController nombreLugarCE = TextEditingController();
  TextEditingController fechaEventoCE = TextEditingController();
  TextEditingController direccionEventoCC = TextEditingController();
  TextEditingController latitudEventoCC = TextEditingController();
  TextEditingController longitudEventoCC = TextEditingController();
  TextEditingController descripcionEventoCE = TextEditingController();
  TextEditingController capacidadMaximaPersonas = TextEditingController();
  TextEditingController precioUnidad = TextEditingController();
  TextEditingController separarEntradas = TextEditingController();
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

  final Random random = Random();
  static const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  String generateRandomString(chars, int length) =>
      Iterable.generate(length, (idx) => chars[random.nextInt(chars.length)])
          .join();

  List<String> constructorTickets(String capacidadMaxima, int dias) {
    int cantidadTicketsDia = int.parse(capacidadMaximaPersonas.text);
    //generar strings random que solo contengan numeros y letras mayusculas y minusculas y que no se repitan
    List<String> tickets = [];
    for (var i = 0; i < cantidadTicketsDia * dias; i++) {
      tickets.add(generateRandomString(chars, 20));
    }
    return tickets;
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

//Crear el evento y enviarlo a la base de datos
  Future<void> guardarEvento() async {
    User? user = Auth().currentUser;

    if (nombreEventoCE.text != '' &&
        nombreLugarCE.text != '' &&
        fechaEventoCE.text != '' &&
        direccionEventoCC.text != '' &&
        descripcionEventoCE.text != '' &&
        capacidadMaximaPersonas.text != '' &&
        precioUnidad.text != '' &&
        separarEntradas.text != '' &&
        imageFiles != null) {
      await FirebaseFirestore.instance
          .collection('eventos')
          .where('nombre', isEqualTo: nombreEventoCE.text)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.docs.isEmpty) {
          print('No existe el evento');

          // docRef.set(({
          //   'nombre': nombreEventoCE.text,
          //   'lugar': nombreLugarCE.text,
          //   'creador': user?.uid,
          //   'fecha': fechas_guardarEvento,
          //   'creador_correo': user?.email,
          //   'ubicacion': direccionEventoCC.text,
          //   'descripcion': descripcionEventoCE.text,
          //   'imagen': await subirImagenes(imageFiles!),
          //   // 'tickets': constructorTickets(cantidadTicketsDia, cantidadDias)
          // }));

          print('Evento creado');
          //enviar notificacion a todos los usuarios que tengan su token almacenado en firebase para que se les notifique que se ha creado un nuevo evento

          print("Notificacion enviada");
          //_limpiarCafeteria();
        } else {
          print('Ya existe el evento');
        }
      });
    } else {
      print('Se deben ingresar todos los datos');
      showCustomDialog(context, 'Todos los campos deben estar llenos');
    }
  }

  void verDatos() {
    print(nombreEventoCE.text);
    print(nombreLugarCE.text);
    print(fechaEventoCE.text);
    print(direccionEventoCC.text);
    print(imageFiles);
    print(descripcionEventoCE.text);
    print(capacidadMaximaPersonas.text);
    print(precioUnidad.text);
    print(separarEntradas.text);
    print('FECHA ${fechas_guardarEvento}');
    // print(imagenEventoCC.text);
  }

  InputDecoration buildInputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: naranja, size: 24),
      hintText: hintText,
      hintStyle: TextStyle(
        color: morado,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        fontSize: 14,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: morado),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: morado),
      ),
    );
  }

  Widget textFieldNombreEvento(TextEditingController controller) {
    return (TextField(
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
        decoration: buildInputDecoration(
            'Nombre del evento', Icons.event_note_outlined)));
  }

  Widget textFieldNombreCafeteria(TextEditingController controller) {
    return (TextField(
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
        decoration: buildInputDecoration(
            'Nombre del lugar', Icons.coffee_maker_outlined)));
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

  void onControllerChanged(TextEditingController controller) {
    int cantidadTickets =
        cantidadDias * int.parse(capacidadMaximaPersonas.text);
    double ingresoEstimados = cantidadTickets * double.parse(precioUnidad.text);
    double comisiones = ingresosEstimados * 0.01;
    double ingresoNeto = ingresosEstimados - comision;
    print(cantidadTickets);
    setState(() {
      ingresosEstimados = ingresoEstimados;
      comision = comisiones;
      ingresosNeto = ingresoNeto;
    });
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
            // Convertir fechas seleccionadas a objetos DateTime
            DateTime fechaInicio = pickeddate.start;
            DateTime fechaFin = pickeddate.end;

            // Calcular la cantidad de días entre las fechas
            Duration duracion = fechaFin.difference(fechaInicio);

            //Cambiar formato de daterangepicker a dd/mm/yyyy
            var fecha_cambiada = cambiarFormatoFecha(pickeddate);
            var fecha_evento = fecha_cambiada.split(' - ');
            var fecha_evento_inicio = fecha_evento[0].split(' ');
            var fecha_evento_fin = fecha_evento[1].split(' ');
            print(fecha_evento_inicio[0] + ' / ' + fecha_evento_fin[0]);
            setState(() {
              cantidadDias = duracion.inDays + 1;
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
        decoration: buildInputDecoration(
            'Fecha del evento', Icons.date_range_outlined)));
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
                Icon(Icons.location_on_outlined, color: naranja, size: 24),
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
            Icon(Icons.image_outlined, color: naranja, size: 24),
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
        direccionEventoCC.text = direccion;
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
        decoration: buildInputDecoration(
            'Nombre de la cafetería', Icons.coffee_maker_outlined)));
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
        decoration: buildInputDecoration(
            'Descripcion del evento', Icons.description_outlined));
  }

//Custom input para la configuracion de entradas al evento
  Widget customTextFormField(TextEditingController controller, String hintText,
      IconData icon, int maxLength) {
    controller.addListener(() {
      // Aquí puedes llamar a la función que deseas ejecutar cuando el controlador cambie
      onControllerChanged(controller);
    });
    return TextFormField(
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: morado,
        letterSpacing: 2,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      controller: controller,
      maxLength: maxLength,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      decoration: buildInputDecoration(hintText, icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    var edgeInsets = EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.02,
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05);
    return SafeArea(
      child: Scaffold(
          backgroundColor: colorScaffold,
          appBar: AppBar(
            backgroundColor: morado,
            title: Text('Crear Evento'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: (Container(
                child: Column(
              children: [
                Container(
                    margin: edgeInsets,
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
                            direccionEventoCC.text = '';
                            nombreLugarCE.text = '';
                          }
                          nombreLugarCE.text = '';
                          direccionEventoCC.text = '';

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
                    margin: edgeInsets,
                    child: textFieldFechaCafeteria(fechaEventoCE)),
                Container(
                    margin: edgeInsets,
                    child: textFieldUbicacionCafeteria(direccionEventoCC)),
                Container(
                    margin: edgeInsets,
                    child: GestureDetector(
                      child: textFieldImagenCafeteria(),
                      onTap: () {
                        _openGallery(context);
                      },
                    )),
                Container(
                    margin: edgeInsets,
                    child: //crear textfield que se expanda con el texto
                        textFieldDescripcionCafeteria(descripcionEventoCE)),
                Container(
                    margin: edgeInsets,
                    child: //crear textfield que se expanda con el texto
                        Text(
                      'Configurar entradas al evento',
                      style: TextStyle(
                          color: morado,
                          fontSize: 25,
                          fontWeight: FontWeight.w900),
                    )),
                Container(
                  margin: edgeInsets,
                  child: // Capacidad personas
                      customTextFormField(
                          capacidadMaximaPersonas,
                          'Capacidad máxima de personas',
                          Icons.person_outline,
                          5),
                ),
                Container(
                  margin: edgeInsets,
                  child: //Precio unitario tickets
                      customTextFormField(precioUnidad, 'Precio unidad',
                          Icons.confirmation_number_outlined, 10),
                ),
                Container(
                  margin: edgeInsets,
                  child: //Cantidad tickets
                      customTextFormField(separarEntradas, 'Separar entradas',
                          Icons.confirmation_number_outlined, 5),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: morado,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: edgeInsets,
                  child: Column(children: [
                    Row(
                      children: [
                        Text('Ingresos estimados:',
                            style: TextStyle(color: naranja)),
                        Expanded(child: Container()),
                        Text(
                          '\$ $ingresosEstimados',
                          style: TextStyle(color: naranja),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text('Comision(1%):', style: TextStyle(color: naranja)),
                        Expanded(child: Container()),
                        Text(
                          '\$ $comision',
                          style: TextStyle(color: naranja),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text('Ingresos neto', style: TextStyle(color: naranja)),
                        Expanded(child: Container()),
                        Text(
                          '\$ $ingresosNeto',
                          style: TextStyle(color: naranja),
                        )
                      ],
                    ),
                  ]),
                ),
                GestureDetector(
                  onTap: () {
                    guardarEvento();
                    // verDatos();
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
                ),
              ],
            ))),
          )),
    );
  }
}


class CustomDialog extends StatelessWidget {
  final String texto= '';
  CustomDialog({Key? key, required texto}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Aviso'),
      content: Text(texto),
      actions: <Widget>[
        TextButton(
          child: Text('Aceptar'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }
}

void showCustomDialog(BuildContext context, String  text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(texto: text,);
    },
  );
}