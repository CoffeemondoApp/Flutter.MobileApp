// ignore_for_file: use_build_context_synchronously, avoid_print, unused_field, prefer_final_fields, override_on_non_overriding_member, non_constant_identifier_names, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, annotate_overrides, use_full_hex_values_for_flutter_colors, use_key_in_widget_constructors

import 'dart:async';

import 'package:coffeemondo/pantallas/Registro.dart';
import 'package:coffeemondo/firebase/autenticacion.dart';
import 'package:coffeemondo/pantallas/user_logeado/paginas/perfil/Foto.dart';
import 'package:coffeemondo/pantallas/user_logeado/Direccion.dart';
import 'package:coffeemondo/pantallas/user_logeado/paginas/perfil/Info.dart';
import 'package:coffeemondo/pantallas/user_logeado/paginas/perfil/Perfil.dart';
import 'package:coffeemondo/pantallas/user_logeado/paginas/perfil/bottomBar_perfil.dart';
import 'package:coffeemondo/pantallas/user_logeado/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

//Obtener variable desde direccion.dart

class InfoUsuarioPage extends StatefulWidget {
  final String inicio;

  const InfoUsuarioPage(this.inicio, {super.key});

  @override
  InfoUsuarioApp createState() => InfoUsuarioApp();
}

var largo_nombre_usuario = 15;

class InfoUsuarioApp extends State<InfoUsuarioPage> {
  @override
  void initState() {
    super.initState();
    // Se inicia la funcion de getData para traer la informacion de usuario proveniente de Firebase
    _getdata();
  }

  // Se declara la instancia de firebase en la variable _firebaseAuth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Si existe un usuario logeado, este asigna a currentUser la propiedad currentUser del Auth de FIREBASE
  User? get currentUser => _firebaseAuth.currentUser;
  var colorScaffold = Color(0xffffebdcac);

  String? errorMessage = '';
  bool isLogin = true;
  bool mostrarSetCafeteras = false;
  bool mostrarSetCafeteras2 = false;
  String nombreCafetera = '';

  bool mostrarMolinoCafe = false;
  bool mostrarMolinoCafe2 = false;

  bool usoMolino = false;
  bool usoMolino2 = false;

  String marca_molino = '';

  bool mostrarCafeEnCasa = false;
  bool mostrarCafeEnCasa2 = false;

  bool usoCafe = false;
  bool usoCafe2 = false;

  String tipo_cafe = '';

  bool tipoCafe_Seleccionado = false;
  bool tipoCafe_Seleccionado2 = false;

  String marcaTipoCafe = '';

  // Este estado define si el usuario aun no ha editado ningun textField,
  //si edita alguno, se dejan de recibir en tiempo real los datos de la bbdd
  //para asi poder modificar los campos sin ser reseteados
  bool estadoInicial = true;
  // Declaracion de email del usuario actual
  final email = FirebaseAuth.instance.currentUser?.email;

  final TextEditingController _controladoremail = TextEditingController();
  final TextEditingController _controladoredad = TextEditingController();
  final TextEditingController _controladortelefono = TextEditingController();
  final TextEditingController _controladordireccion = TextEditingController();
  final TextEditingController _controladornombreUsuario =
      TextEditingController();
  final TextEditingController _controladornombreApellido =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final TextEditingController marca_MolinoController = TextEditingController();
  final TextEditingController tipoCafeController = TextEditingController();
  final TextEditingController marcaTipoCafeController = TextEditingController();

  // Funcion para guardar informacion del usuario en Firebase Firestore
  Future<void> guardarInfoUsuario() async {
    try {
      // Importante: Este tipo de declaracion se utiliza para solamente actualizar la informacion solicitada y no manipular informacion adicional, como lo es la imagen y esto permite no borrar otros datos importantes

      // Se busca la coleccion 'users' de la BD de Firestore en donde el uid sea igual al del usuario actual
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection("users").doc(currentUser?.uid);
      // Se actualiza la informacion del usuario actual mediante los controladores, que son los campos de informacion que el usuario debe rellenar

      if (nombreCafetera != '') {
        docRef.update({
          'nombreCafetera': nombreCafetera,
        });
      }
      if (marca_molino != '') {
        docRef.update({
          'molino': marca_molino,
        });
      }
      if (tipo_cafe != '' && marcaTipoCafeController.text != '') {
        docRef.update({
          'tipo_cafe': tipo_cafe,
          'marca_cafe': marcaTipoCafeController.text,
        });
      }
      docRef.update({});
      print('Ingreso de informacion exitoso.');
      // Una vez actualizada la informacion, se devuelve a InfoUser para mostrar su nueva informacion
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const PerfilPage('0')));
    } catch (e) {
      print("Error al intentar ingresar informacion");
    }
  }

  mostrarMapa() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => DireccionPage(
                inicio,
                _controladornombreApellido.text,
                _controladornombreUsuario.text,
                _controladoredad.text,
                _controladortelefono.text,
                _controladordireccion.text,
                'ip')));
  }

  String nombre = '';
  String nickname = '';
  String cumpleanos = '';
  String telefono = '';
  String direccion = '';

  // Mostrar informacion del usuario en pantalla
  void _getdata() async {
    // Se declara en user al usuario actual
    User? user = Auth().currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      setState(() {
        // Se setea en variables la informacion recopilada del usuario extraido de los campos de la BD de FireStore
        nombre = userData.data()!['nombre'];
        nickname = userData.data()!['nickname'];
        direccion = userData.data()!['direccion'];
        cumpleanos = userData.data()!['cumpleanos'];
        telefono = userData.data()!['telefono'];
      });
    });
  }

  @override
  Widget _NombreApellido(
    TextEditingController controller,
  ) {
    return TextField(
        onTap: () {
          setState(() {
            estadoInicial = false;
          });
        },
        controller: controller,
        // onChanged: (((value) => validarCorreo())),
        style: const TextStyle(
          color: Color.fromARGB(255, 84, 14, 148),
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
            prefixIcon: Icon(Icons.account_circle_outlined,
                color: Color.fromARGB(255, 255, 79, 52), size: 24),
            hintText: 'N o m b r e  y  A p e l l i d o',
            hintStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 84, 14, 148),
            )));
  }

  var mes_nacimiento = '';
  void getMes(numero_mes) {
    var meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    for (int i = 0; i < meses.length; i++) {
      if (i == numero_mes - 1) {
        print((numero_mes - 1).toString());
        print(meses[i]);
        mes_nacimiento = meses[i];
      }
    }
  }

  @override
  Widget _Edad(
    TextEditingController controller,
  ) {
    return TextField(
      readOnly: true,
      controller: controller,
      // onChanged: (((value) => validarCorreo())),
      style: const TextStyle(
        color: Color.fromARGB(255, 84, 14, 148),
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
          prefixIcon: Icon(Icons.cake,
              color: Color.fromARGB(255, 255, 79, 52), size: 24),
          hintText: 'E d a d',
          hintStyle: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 84, 14, 148),
          )),
      onTap: () async {
        DateTime? pickeddate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2024),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Color.fromARGB(255, 255, 79, 52), // <-- SEE HERE
                    onPrimary: Color.fromARGB(255, 84, 14, 148), // <-- SEE HERE
                    onSurface: Color.fromARGB(255, 84, 14, 148), //<-- SEE HERE
                    secondary: Color.fromARGB(255, 235, 220, 172),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      primary:
                          Color.fromARGB(255, 255, 79, 52), // button text color
                    ),
                  ),
                ),
                child: child!,
              );
            });

        if (pickeddate != null) {
          getMes(pickeddate.month);
          setState(() {
            var string_fecha = pickeddate.day.toString() +
                ' de ' +
                mes_nacimiento +
                ' de ' +
                pickeddate.year.toString();
            print(string_fecha);
            print("esta es la fecha ingresada");
            estadoInicial = false;
            _controladoredad.text = string_fecha;
          });
        }
      },
    );
  }

  @override
  Widget FotoPerfil() {
    return ElevatedButton(
      onPressed: () {
        print('Editar foto de perfil');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: const Image(
          image: AssetImage('./assets/user_img.png'),
          width: 150,
        ),
      ),
      style: ElevatedButton.styleFrom(shape: CircleBorder()),
    );
  }

  @override
  Widget _NombreUsuario(
    TextEditingController controller,
  ) {
    return TextField(
        maxLength: largo_nombre_usuario,
        onTap: () {
          setState(() {
            estadoInicial = false;
          });
        },
        //darle un texto inicial al textfield para que se vea el texto de ejemplo y no el hinttext que es el texto que se muestra cuando no hay nada escrito
        controller: controller,
        // onChanged: (((value) => validarCorreo())),
        style: const TextStyle(
          color: Color.fromARGB(255, 84, 14, 148),
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
            prefixIcon: Icon(Icons.account_circle_rounded,
                color: Color.fromARGB(255, 255, 79, 52), size: 24),
            hintText: 'N o m b r e   u s u a r i o',
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 84, 14, 148),
            )));
  }

  //Formato telefono CL
  var maskFormatter = MaskTextInputFormatter(
      mask: '+(##) # ### ### ##)',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  Widget _Telefono(
    TextEditingController controller,
  ) {
    return TextField(
        onTap: () {
          setState(() {
            estadoInicial = false;
          });
        },
        keyboardType: TextInputType.phone,
        inputFormatters: [maskFormatter],
        controller: controller,
        // onChanged: (((value) => validarCorreo())),
        style: const TextStyle(
          color: Color.fromARGB(255, 84, 14, 148),
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
            prefixIcon: Icon(Icons.mobile_friendly_outlined,
                color: Color.fromARGB(255, 255, 79, 52), size: 24),
            hintText: 'T e l e f o n o',
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 84, 14, 148),
            )));
  }

  @override
  Widget _Direccion(
    TextEditingController controller,
  ) {
    return TextField(
        inputFormatters: [maskFormatter],
        controller: controller,
        readOnly: true,
        onTap: (() => {mostrarMapa(), estadoInicial = false}),
        // onChanged: (((value) => validarCorreo())),
        style: const TextStyle(
          color: Color.fromARGB(255, 84, 14, 148),
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
            prefixIcon: Icon(Icons.location_on,
                color: Color.fromARGB(255, 255, 79, 52), size: 24),
            hintText: 'D i r e c c i o n',
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 84, 14, 148),
            )));
  }

  //Funcion para saber cuanto tiempo lleva el usuario en la app

  void seleccionarCafetera(Map cafetera) {
    setState(() {
      mostrarSetCafeteras = !mostrarSetCafeteras;
      nombreCafetera = cafetera['nombre'];
      if (!mostrarSetCafeteras2) {
        Timer(Duration(milliseconds: 500), () {
          setState(() {
            mostrarSetCafeteras2 = !mostrarSetCafeteras2;
          });
        });
      } else {
        mostrarSetCafeteras2 = !mostrarSetCafeteras2;
      }
    });
    print(nombreCafetera);
    ;
  }

  //crear array con objetos dentro
  List<Map> _crearCafeteras() {
    final List<Map> cafeteras = [];
    final List<String> cafeteras_nombre = [
      'prensa francesa',
      'moka italiana',
      'V60',
      'kalitta',
      'aeroPress',
      'maquina de espresso'
    ];
    final List<String> cafeteras_descripcion = [
      'La Prensa Francesa es un\nmétodo por inmersión*,\n' +
          'permite controlar todo el\nproceso de extracción,\n' +
          'desde el tiempo de\n contacto, la temperatura\ny la turbulencia,' +
          '\nentre otras variables.\n\nTambién al actuar\ndirectamente sobre' +
          'todo\nel café molido nos da la\nposibilidad' +
          'de extraer\n muy bien los sabores.',
      'La cafetera italiana o\ncafetera moka produce\nun café de calidad,\n' +
          'intenso y con cuerpo\nen pocos minutos.\n\nEs la forma casera de\n' +
          'conseguir un café\nexpreso a baja presión,\nmucho más parecido\n' +
          'al de los bares que\nel café de goteo.',
      'Un único orificio grande\nen el V60 permite\nmodificar el sabor al\n' +
          'alterar la velocidad del\nflujo de agua.\n\nCon este método se\n' +
          'obtiene un café de\ncuerpo sedodo\ny sabor frutal.',
      'Es una cafetera de filtro\nparecida al V60 que\nconsiste en verter ' +
          'agua\ncaliente sobre el café\nmolido contenido en\nun filtro.\n\nEl ' +
          'agua pasa a través\nde la cama de café,\nobtiene sus\ncomponentes ' +
          'y se\nfiltra a un recipiente.',
      'Es como una jeringuilla\ngigante, en el interior\nde la cual se ' +
          'mezclan\ncafé y agua caliente\ny el café se extrae por\nla presión ' +
          'de un émbolo.\n\nEl método aeropress\ncuenta cada vez con\nmás adeptos ' +
          'porque\npermite preparar un\ncafé excelente y con\nmucho ' +
          'cuerpo en\ncuestión de segundos.',
      'Calientan el agua para\nlograr una alta presión\nque pasa por el café\n' +
          'molido para hacer la\ninfusión.\n\nGeneralmente a 90°\ngrados, a ' +
          'presión de\n8-10 atmósferas por\n20 a 30 segundos por\ncafé molido ' +
          'muy fino,\nextrayendo su sabor\ny esencia.'
    ];

    for (var i = 0; i < 6; i++) {
      cafeteras.add({
        'nombre': cafeteras_nombre[i],
        'imagen': 'assets/cafetera${i + 1}.jpg',
        'descripcion': cafeteras_descripcion[i],
      });
    }
    return cafeteras;
  }

  void mecanicaPregunta1(String side) {
    if (side == 'out') {
      setState(() {
        mostrarSetCafeteras2 = false;

        // cambiar estado de infoPerfilPressed2 luego de 2 segundos
        Timer(Duration(milliseconds: 200), () {
          setState(() {
            mostrarSetCafeteras = false;
          });
        });
      });
    } else if (side == 'in') {
      setState(() {
        mostrarSetCafeteras = !mostrarSetCafeteras;

        // cambiar estado de infoPerfilPressed2 luego de 2 segundos
        if (!mostrarSetCafeteras2) {
          Timer(Duration(milliseconds: 1000), () {
            setState(() {
              mostrarSetCafeteras2 = !mostrarSetCafeteras2;
            });
          });
        } else {
          mostrarSetCafeteras2 = !mostrarSetCafeteras2;
        }
      });
    }
  }

  void mecanicaPregunta2(String side) {
    if (side == 'in') {
      setState(() {
        mostrarMolinoCafe = !mostrarMolinoCafe;

        // cambiar estado de infoPerfilPressed2 luego de 2 segundos
        if (!mostrarMolinoCafe2) {
          Timer(Duration(milliseconds: 1000), () {
            setState(() {
              mostrarMolinoCafe2 = !mostrarMolinoCafe2;
            });
          });
        } else {
          mostrarMolinoCafe2 = !mostrarMolinoCafe2;
        }
      });
    } else if (side == 'out') {
      setState(() {
        mostrarMolinoCafe2 = false;

        // cambiar estado de infoPerfilPressed2 luego de 2 segundos
        Timer(Duration(milliseconds: 200), () {
          setState(() {
            mostrarMolinoCafe = false;
          });
        });
      });
    }
  }

  void mecanicaPregunta3(String side) {
    if (side == 'in') {
      setState(() {
        mostrarCafeEnCasa = !mostrarCafeEnCasa;
        marcaTipoCafe = '';
        // cambiar estado de infoPerfilPressed2 luego de 2 segundos
        if (!mostrarCafeEnCasa2) {
          Timer(Duration(milliseconds: 1000), () {
            setState(() {
              mostrarCafeEnCasa2 = !mostrarCafeEnCasa2;
            });
          });
        } else {
          mostrarCafeEnCasa2 = !mostrarCafeEnCasa2;
        }
      });
    } else if (side == 'out') {
      setState(() {
        mostrarCafeEnCasa2 = false;

        // cambiar estado de infoPerfilPressed2 luego de 2 segundos
        Timer(Duration(milliseconds: 200), () {
          setState(() {
            mostrarCafeEnCasa = false;
          });
        });
      });
    }
  }

  Widget botonCafeteraEnCasa() {
    return (GestureDetector(
      child: Text(
        (nombreCafetera != '')
            ? 'En mi casa uso $nombreCafetera'
            : '¿Que cafetera usas en tu casa?',
        style: TextStyle(
            color: Color(0xffffebdcac),
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
      onTap: () {
        mecanicaPregunta1('in');
        mecanicaPregunta2('out');
        mecanicaPregunta3('out');
      },
    ));
  }

  Widget moduloCafeteraEnCasa() {
    var cafeteras = _crearCafeteras();

    return (Container(
        margin: EdgeInsets.only(top: 20),
        height: 290,
        child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: cafeteras.length,
            itemBuilder: (BuildContext context, int index) {
              return (Container(
                margin: EdgeInsets.only(right: 10),
                width: MediaQuery.of(context).size.width * 0.91,
                child: Card(
                  color: colorNaranja,
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(40)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Image.asset(
                            cafeteras[index]['imagen'],
                            width: 210,
                            height: 282,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              child: Text(
                                cafeteras[index]['nombre'],
                                style: TextStyle(
                                  color: colorMorado,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 20, right: 10),
                                //color: Colors.white,
                                height: 200,
                                child: Text(
                                  cafeteras[index]['descripcion'],
                                  style: TextStyle(
                                      color: colorMorado,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800),
                                  maxLines: null,
                                )),
                            GestureDetector(
                                onTap: () {
                                  seleccionarCafetera(cafeteras[index]);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: 10, top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                      color: colorMorado,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                      margin: EdgeInsets.only(
                                          bottom: 5, left: 10, right: 10),
                                      child: Text(
                                        'Seleccionar cafetera',
                                        style: TextStyle(
                                            color: colorNaranja,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ));
            })));
  }

  Widget botonMolinoCafe() {
    return (GestureDetector(
      child: Text(
        (marca_molino != '')
            ? 'Uso $marca_molino para moler mi cafe'
            : '¿Usas molino de cafe?',
        style: TextStyle(
            color: colorScaffold, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        mecanicaPregunta1('out');
        mecanicaPregunta2('in');
        mecanicaPregunta3('out');
      },
    ));
  }

  Widget botonUsoMolino() {
    return (GestureDetector(
        onTap: () {
          setState(() {
            usoMolino = !usoMolino;

            // cambiar estado de infoPerfilPressed2 luego de 2 segundos
            if (!usoMolino2) {
              Timer(Duration(milliseconds: 1000), () {
                setState(() {
                  usoMolino2 = !usoMolino2;
                });
              });
            } else {
              usoMolino2 = !usoMolino2;
            }
          });
        },
        child: AnimatedAlign(
            duration: Duration(milliseconds: 500),
            alignment: (usoMolino) ? Alignment.topCenter : Alignment.center,
            child: Container(
              margin: EdgeInsets.only(top: (usoMolino) ? 10 : 0),
              child: Text(
                'Si, uso molino',
                style: TextStyle(
                    color: colorMorado,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ))));
  }

  Widget AutoCompleteMarcas_Molinos(controller) {
    var marcas_molino = [
      'Oster',
      'DeLonghi',
      'Sindelen',
      'Bosch',
      'Nima',
      'Hario',
      'Graef',
      'Krups',
      'Gaggia',
      'Bialetti',
      'Cuisinart',
      'Hamilton Beach',
      'Mr. Coffee'
    ];
    return (EasyAutocomplete(
      inputTextStyle: TextStyle(
          color: colorMorado,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          fontSize: 14),
      suggestionBackgroundColor: colorMorado,
      suggestionTextStyle: TextStyle(
          color: colorNaranja,
          fontSize: 14,
          letterSpacing: 2,
          fontWeight: FontWeight.bold),
      suggestions: marcas_molino,
      onChanged: (value) => {print('onChanged value: $value')},
      onSubmitted: (value) => {
        print('valor subido: $value'),
        setState(() {}),
      },
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.coffee_maker_outlined,
          color: colorMorado,
          size: 24,
        ),
        hintText: 'Ingrese marca del molino de cafe',
        hintStyle: TextStyle(
            color: colorMorado, fontWeight: FontWeight.bold, letterSpacing: 2),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorMorado),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorMorado),
        ),
      ),
    ));
  }

  Widget AutoComplete_TipoCafe(controller) {
    var tipo_cafe = [
      'Café comercial',
      'Café especial',
      'Café molido',
      'Café en grano',
    ];
    return (EasyAutocomplete(
      inputTextStyle: TextStyle(
          color: colorMorado,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          fontSize: 14),
      suggestionBackgroundColor: colorMorado,
      suggestionTextStyle: TextStyle(
          color: colorNaranja,
          fontSize: 14,
          letterSpacing: 2,
          fontWeight: FontWeight.bold),
      suggestions: tipo_cafe,
      onChanged: (value) => {print('onChanged value: $value')},
      onSubmitted: (value) => {
        print('valor subido: $value'),
        setState(() {}),
      },
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.coffee_maker_outlined,
          color: colorMorado,
          size: 24,
        ),
        hintText: 'Ingrese tipo de cafe',
        hintStyle: TextStyle(
            color: colorMorado, fontWeight: FontWeight.bold, letterSpacing: 2),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorMorado),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorMorado),
        ),
      ),
    ));
  }

  List<String> obtenerMarcasTipoCafe(String tipo) {
    //Hacer un case segun el tipo de cafe seleccionado
    switch (tipo) {
      case 'Café comercial':
        return [
          "Nescafé",
          "Tostado",
          "Sello Rojo",
          "El Chancho con Trenzas",
          "Pilón",
          "Don Francisco",
          "Carozzi",
          "Café Doña Gloria",
          "Folgers",
          "Starbucks"
        ];
      case 'Café especial':
        return [
          "Juan Valdez",
          "Starbucks Reserve",
          "Lavazza",
          "Illy",
          "Café Britt",
          "Toffee Coffee",
          "Catalejo Café",
          "Café del Cerro",
          "Taf",
          "Boreta"
        ];
      case 'Café en grano':
        return [
          "Volcán del Sur",
          "Hacienda La Esmeralda",
          "Toma Café",
          "Bazzar",
          "Café Haití",
          "Tostaduría Talca",
          "Coffee & Woods",
          "The Coffee Factory",
          "Café Chilote",
          "Café Capsule"
        ];
      case 'Café molido':
        return [
          "Molino La Fama",
          "Sello Rojo",
          "Delta",
          "El Chancho con Trenzas",
          "Café de Colombia",
          "Café Doña Gloria",
          "Café Cabrales",
          "Café Haití",
          "Cafe Justo",
          "Cafe Natura"
        ];
      default:
        return [];
    }
  }

  Widget AutoComplete_marcaPorTipoCafe(controller) {
    //Crear lista vacia marcas_tipoCafe
    List<String> marcas_tipoCafe = obtenerMarcasTipoCafe(tipo_cafe);

    return (EasyAutocomplete(
      inputTextStyle: TextStyle(
          color: colorMorado,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          fontSize: 14),
      suggestionBackgroundColor: colorMorado,
      suggestionTextStyle: TextStyle(
          color: colorNaranja,
          fontSize: 14,
          letterSpacing: 2,
          fontWeight: FontWeight.bold),
      suggestions: marcas_tipoCafe,
      onChanged: (value) => {print('onChanged value: $value')},
      onSubmitted: (value) => {
        print('valor subido: $value'),
        setState(() {}),
      },
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.coffee_outlined,
          color: colorMorado,
          size: 24,
        ),
        hintText: 'Ingrese marca de ${tipo_cafe.toLowerCase()}',
        hintStyle: TextStyle(
            color: colorMorado, fontWeight: FontWeight.bold, letterSpacing: 2),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorMorado),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorMorado),
        ),
      ),
    ));
  }

  void confirmarMolino(String marca) {
    setState(() {
      usoMolino2 = !usoMolino2;
      mostrarMolinoCafe2 = !mostrarMolinoCafe2;
      marca_molino = marca;
      if (!mostrarSetCafeteras2) {
        Timer(Duration(milliseconds: 500), () {
          setState(() {
            usoMolino = !usoMolino;
            mostrarMolinoCafe = !mostrarMolinoCafe;
          });
        });
      } else {
        usoMolino = !usoMolino;
        mostrarMolinoCafe = !mostrarMolinoCafe;
      }
    });
  }

  void confirmarTipoCafe(String tipoCafe) {
    setState(() {
      tipo_cafe = tipoCafe;
      tipoCafe_Seleccionado = true;
      Timer(Duration(milliseconds: 1000), () {
        setState(() {
          tipoCafe_Seleccionado2 = true;
        });
      });
    });
  }

  Widget moduloUsoMolino() {
    return (Container(
      child: Column(children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          child: AutoCompleteMarcas_Molinos(marca_MolinoController),
        ),
        GestureDetector(
          onTap: () {
            confirmarMolino(marca_MolinoController.text);
          },
          child: Container(
              margin: EdgeInsets.only(top: 15),
              width: MediaQuery.of(context).size.width * 0.85,
              height: 30,
              decoration: BoxDecoration(
                  color: colorMorado, borderRadius: BorderRadius.circular(10)),
              child: Align(
                child: Text(
                  'Confirmar',
                  style: TextStyle(
                      color: colorNaranja, fontWeight: FontWeight.bold),
                ),
              )),
        )
      ]),
    ));
  }

  Widget contenedorCafeComercial() {
    return (Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          child: FittedBox(
              child: Image.asset(
            'assets/cafeComercial.jpg',
            width: MediaQuery.of(context).size.width,
            height: 200,
            fit: BoxFit.fill,
          )),
        ),
        (Container(
            //color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.18,
            margin: EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
            child: Text(
              'Este tipo de café se produce en grandes cantidades y ' +
                  'se vende en tiendas de abarrotes, supermercados y ' +
                  'tiendas de conveniencia. Este café a menudo se cultiva ' +
                  'en grandes plantaciones y se procesa de manera ' +
                  'industrial. Es una opción conveniente y económica para ' +
                  'aquellos que buscan una taza de café ' +
                  'rápida y fácil en casa o en la oficina.',
              style: TextStyle(
                  color: colorMorado,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ))),
      ],
    ));
  }

  Widget contenedorCafeEspecial() {
    return (Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          child: FittedBox(
              child: Image.asset(
            'assets/cafeEspecial.jpg',
            width: MediaQuery.of(context).size.width,
            height: 200,
            fit: BoxFit.fill,
          )),
        ),
        (Container(
            height: MediaQuery.of(context).size.height * 0.18,
            //color: Colors.white,
            margin: EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
            child: Text(
              'El café especial es un café de alta calidad y se selecciona ' +
                  'cuidadosamente. Este café se produce en pequeñas cantidades ' +
                  'y se cultiva en condiciones ideales. Los granos se procesan ' +
                  'de manera cuidadosa y se tuestan de forma artesanal para ' +
                  'resaltar las características únicas de cada grano. El ' +
                  'resultado es una taza de café con sabor y aroma excepcionales.',
              style: TextStyle(
                  color: colorMorado,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ))),
      ],
    ));
  }

  Widget contenedorCafeMolido() {
    return (Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          child: FittedBox(
              child: Image.asset(
            'assets/cafeMolido.jpg',
            width: MediaQuery.of(context).size.width,
            height: 200,
            fit: BoxFit.fill,
          )),
        ),
        Container(
            height: MediaQuery.of(context).size.height * 0.18,
            margin: EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
            child: Text(
              'El café molido es aquel que ya está molido y listo para ' +
                  'preparar. Es una opción práctica y conveniente para aquellos ' +
                  'que no tienen un molinillo de café en casa o que no quieren ' +
                  'molestarse en moler los granos. Este café se vende en ' +
                  'paquetes y se puede encontrar en una variedad de ' +
                  'molidos, desde grueso hasta fino.',
              style: TextStyle(
                  color: colorMorado,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            )),
      ],
    ));
  }

  Widget constructorTipoCafe(String tipo) {
    //Hacer un case para cada tipo de cafe
    switch (tipo) {
      case 'Café comercial':
        return contenedorCafeComercial();

      case 'Café especial':
        return contenedorCafeEspecial();

      case 'Café molido':
        return contenedorCafeMolido();

      case 'Café en grano':
        return Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              child: FittedBox(
                  child: Image.asset(
                'assets/cafeGrano.jpg',
                width: MediaQuery.of(context).size.width,
                height: 200,
                fit: BoxFit.fill,
              )),
            ),
            Container(
                height: MediaQuery.of(context).size.height * 0.18,
                //color: Colors.white,
                margin:
                    EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
                child: Text(
                  'El café en grano es aquel que no ha sido molido y se ' +
                      'vende en su forma natural. Para preparar el café, se ' +
                      'necesita un molinillo de café para moler los granos. ' +
                      'Este tipo de café es ideal para aquellos que buscan ' +
                      'la máxima frescura y aroma en su taza de café, ya que ' +
                      'los granos se pueden moler justo antes de ' +
                      'preparar el café.',
                  style: TextStyle(
                      color: colorMorado,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                )),
          ],
        );
    }
    return (Container());
  }

  void seleccionarTipoMarcaCafe(String tipo, String marca) {
    print('Tipo: $tipo, Marca: $marca');
    setState(() {
      usoCafe = !usoCafe;

      // cambiar estado de infoPerfilPressed2 luego de 2 segundos
      if (!usoCafe2) {
        Timer(Duration(milliseconds: 1000), () {
          setState(() {
            usoCafe2 = !usoCafe2;
          });
        });
      } else {
        usoCafe2 = !usoCafe2;
      }
    });

    Timer(Duration(milliseconds: 1500), () {
      setState(() {
        mostrarCafeEnCasa2 = !mostrarCafeEnCasa2;
      });
    });

    // cambiar estado de infoPerfilPressed2 luego de 2 segundos
    if (mostrarCafeEnCasa) {
      Timer(Duration(milliseconds: 2000), () {
        setState(() {
          mostrarCafeEnCasa = !mostrarCafeEnCasa;
        });
      });
    } else {
      mostrarCafeEnCasa = !mostrarCafeEnCasa;
    }
    Timer(Duration(milliseconds: 2000), () {
      setState(() {
        marcaTipoCafe = 'En casa uso ${tipo.toLowerCase()} de $marca';
      });
    });
  }

  Widget btnVolverAtras_TipoCafe() {
    return (GestureDetector(
        onTap: () {
          setState(() {
            tipoCafe_Seleccionado = !tipoCafe_Seleccionado;
            tipoCafe_Seleccionado2 = !tipoCafe_Seleccionado2;
            marcaTipoCafeController.text = '';
            tipoCafeController.text = '';
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.42,
          height: 30,
          decoration: BoxDecoration(
              color: colorMorado, borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: Text(
            'Volver atras',
            style: TextStyle(color: colorNaranja, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          )),
          margin: EdgeInsets.only(top: 20),
        )));
  }

  Widget btnSeleccionar_TipoCafe() {
    return (GestureDetector(
        onTap: () {
          seleccionarTipoMarcaCafe(tipo_cafe, marcaTipoCafeController.text);
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.42,
          height: 30,
          decoration: BoxDecoration(
              color: colorMorado, borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: Text(
            'Seleccionar',
            style: TextStyle(color: colorNaranja, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          )),
          margin: EdgeInsets.only(top: 20),
        )));
  }

  Widget moduloTipoCafe() {
    return (Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        constructorTipoCafe(tipo_cafe),
        AutoComplete_marcaPorTipoCafe(marcaTipoCafeController),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            btnVolverAtras_TipoCafe(),
            btnSeleccionar_TipoCafe(),
          ],
        )
      ],
    )));
  }

  Widget moduloMolinoCafe() {
    return (Container(
      child: Column(children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          child: FittedBox(
              child: Image.asset(
            'assets/molinoCafe.jpg',
            width: MediaQuery.of(context).size.width,
            height: 200,
            fit: BoxFit.fill,
          )),
        ),
        Container(
          margin: EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
          child: Text(
            'El molinillo de café es una herramienta que funciona ' +
                'precisamente para moler granos de café. De esta manera, ' +
                'es posible conseguir un sabor, aroma y frescura ' +
                'inigualable al preparar esta infusión.',
            style: TextStyle(color: colorScaffold),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 1000),
          width: MediaQuery.of(context).size.width * 0.9,
          height: usoMolino ? 140 : 30,
          decoration: BoxDecoration(
              color: colorNaranja, borderRadius: BorderRadius.circular(10)),
          child: (usoMolino2)
              ? Column(
                  children: [
                    botonUsoMolino(),
                    moduloUsoMolino(),
                  ],
                )
              : botonUsoMolino(),
          margin: EdgeInsets.only(bottom: 10),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 30,
          decoration: BoxDecoration(
              color: colorNaranja, borderRadius: BorderRadius.circular(10)),
          child: GestureDetector(
              child: Align(
            alignment: Alignment.center,
            child: Text(
              'No, no uso molino',
              style: TextStyle(
                  color: colorMorado,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              textAlign: TextAlign.center,
            ),
          )),
          margin: EdgeInsets.only(bottom: 10),
        )
      ]),
    ));
  }

  Widget imagenCafeEnCasa() {
    return (Container(
      margin: EdgeInsets.only(top: 20),
      child: FittedBox(
          child: Image.asset(
        'assets/cafe_casero.png',
        width: MediaQuery.of(context).size.width,
        height: 200,
        fit: BoxFit.fill,
      )),
    ));
  }

  Widget descripcionCafeEnCasa() {
    return (Container(
      margin: EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
      child: Text(
        'El café casero es aquel que se prepara en casa utilizando ' +
            'granos de café frescos y agua. Existen varias formas de ' +
            'prepararlo, siendo las más comunes la cafetera de goteo, ' +
            'la cafetera italiana o moka, y la prensa francesa.',
        style: TextStyle(color: colorScaffold),
      ),
    ));
  }

  Widget btnAnimadoSiUsoCafe() {
    return (AnimatedContainer(
      duration: Duration(milliseconds: 1000),
      width: MediaQuery.of(context).size.width * 0.9,
      height: usoCafe
          ? tipoCafe_Seleccionado
              ? 520
              : 140
          : 30,
      decoration: BoxDecoration(
          color: colorNaranja, borderRadius: BorderRadius.circular(10)),
      child: (usoCafe2)
          ? Column(
              children: [
                botonUsoCafe(),
                tipoCafe_Seleccionado2 ? moduloTipoCafe() : moduloUsoCafe(),
              ],
            )
          : botonUsoCafe(),
      margin: EdgeInsets.only(bottom: 10),
    ));
  }

  Widget btnNoUsoCafe() {
    return (Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 30,
      decoration: BoxDecoration(
          color: colorNaranja, borderRadius: BorderRadius.circular(10)),
      child: GestureDetector(
          child: Align(
        alignment: Alignment.center,
        child: Text(
          'No uso cafe en casa',
          style: TextStyle(
              color: colorMorado, fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )),
      margin: EdgeInsets.only(bottom: 10),
    ));
  }

  Widget moduloCafeEnCasa() {
    return (Container(
      child: Column(children: [
        imagenCafeEnCasa(),
        descripcionCafeEnCasa(),
        btnAnimadoSiUsoCafe(),
        btnNoUsoCafe(),
      ]),
    ));
  }

  Widget botonCafeEnCasa() {
    return (GestureDetector(
      child: Text(
        (marcaTipoCafe != '') ? marcaTipoCafe : '¿Que cafe usas en casa?',
        style: TextStyle(
            color: colorScaffold, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        mecanicaPregunta1('out');
        mecanicaPregunta2('out');
        mecanicaPregunta3('in');
      },
    ));
  }

  Widget botonUsoCafe() {
    return (GestureDetector(
        onTap: () {
          setState(() {
            usoCafe = !usoCafe;

            // cambiar estado de infoPerfilPressed2 luego de 2 segundos
            if (!usoCafe2) {
              Timer(Duration(milliseconds: 1000), () {
                setState(() {
                  usoCafe2 = !usoCafe2;
                });
              });
            } else {
              usoCafe2 = !usoCafe2;
            }
          });
        },
        child: AnimatedAlign(
            duration: Duration(milliseconds: 500),
            alignment: (usoCafe) ? Alignment.topCenter : Alignment.center,
            child: Container(
              margin: EdgeInsets.only(top: (usoCafe) ? 10 : 0),
              child: Text(
                tipoCafe_Seleccionado ? tipo_cafe : 'Si, uso cafe en casa',
                style: TextStyle(
                    color: colorMorado,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ))));
  }

  Widget moduloUsoCafe() {
    return (Container(
      child: Column(children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          child: AutoComplete_TipoCafe(tipoCafeController),
        ),
        GestureDetector(
          onTap: () {
            confirmarTipoCafe(tipoCafeController.text);
          },
          child: Container(
              margin: EdgeInsets.only(top: 15),
              width: MediaQuery.of(context).size.width * 0.85,
              height: 30,
              decoration: BoxDecoration(
                  color: colorMorado, borderRadius: BorderRadius.circular(10)),
              child: Align(
                child: Text(
                  'Siguiente',
                  style: TextStyle(
                      color: colorNaranja, fontWeight: FontWeight.bold),
                ),
              )),
        )
      ]),
    ));
  }

  Widget btnAnimadoCafeteraEnCasa() {
    return (AnimatedContainer(
      duration: Duration(milliseconds: 1000),
      width: MediaQuery.of(context).size.width * 0.95,
      height: mostrarSetCafeteras ? 380 : 30,
      decoration: BoxDecoration(
          color: colorMorado, borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: GestureDetector(
            child: Container(
                alignment: mostrarSetCafeteras2
                    ? Alignment.topCenter
                    : Alignment.center,
                margin: EdgeInsets.only(top: mostrarSetCafeteras2 ? 20 : 0),
                child: mostrarSetCafeteras2
                    ? Column(children: [
                        botonCafeteraEnCasa(),
                        moduloCafeteraEnCasa()
                      ])
                    : botonCafeteraEnCasa())),
      ),
    ));
  }

  Widget btnAnimadoMolinoEnCasa() {
    return (AnimatedContainer(
      margin: EdgeInsets.only(top: 10),
      duration: Duration(milliseconds: 1000),
      width: MediaQuery.of(context).size.width * 0.95,
      height: mostrarMolinoCafe
          ? (usoMolino)
              ? 550
              : 450
          : 30,
      decoration: BoxDecoration(
          color: colorMorado, borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: GestureDetector(
            child: Container(
                alignment:
                    mostrarMolinoCafe2 ? Alignment.topCenter : Alignment.center,
                margin: EdgeInsets.only(top: mostrarMolinoCafe2 ? 20 : 0),
                child: mostrarMolinoCafe2
                    ? Column(children: [botonMolinoCafe(), moduloMolinoCafe()])
                    : botonMolinoCafe())),
      ),
    ));
  }

  Widget btnAnimadoCafeEnCasa() {
    return (AnimatedContainer(
      margin: EdgeInsets.only(top: 10),
      duration: Duration(milliseconds: 1000),
      width: MediaQuery.of(context).size.width * 0.95,
      height: mostrarCafeEnCasa
          ? usoCafe
              ? tipoCafe_Seleccionado
                  ? 930
                  : 570
              : 470
          : 30,
      decoration: BoxDecoration(
          color: colorMorado, borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: GestureDetector(
            child: Container(
                alignment:
                    mostrarCafeEnCasa2 ? Alignment.topCenter : Alignment.center,
                margin: EdgeInsets.only(top: mostrarCafeEnCasa2 ? 20 : 0),
                child: mostrarCafeEnCasa2
                    ? Column(children: [botonCafeEnCasa(), moduloCafeEnCasa()])
                    : botonCafeEnCasa())),
      ),
    ));
  }

  Widget btnGuardarInformacion() {
    return (GestureDetector(
      onTap: () {
        guardarInfoUsuario();
      },
      child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 30,
          margin: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
              color: colorNaranja, borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Text(
              'Guardar informacion',
              style: TextStyle(color: colorMorado, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          )),
    ));
  }

  Widget _bodyInfoUsuario() {
    return (Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 20),
        //  decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            btnAnimadoCafeteraEnCasa(),
            btnAnimadoMolinoEnCasa(),
            btnAnimadoCafeEnCasa(),
            btnGuardarInformacion(),
          ],
        )));
  }

  Widget build(BuildContext context) {
    //          VALORES INICIALES TEXTFIELD EDITAR INFORMACION
    print(estadoInicial);

    return Scaffold(
      backgroundColor: Color(0xffffebdcac),
      appBar: AppBarcustom(),
      body: SingleChildScrollView(child: _bodyInfoUsuario()),
      bottomNavigationBar:
          CustomBottomBarProfile(inicio: widget.inicio, index: 2),
    );
  }
}

//CUSTOM APP BAR
class AppBarcustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarcustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: BackgroundAppBar(),
            child: Container(
              color: Color.fromARGB(0xff, 0x52, 0x01, 0x9b),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: Text(
                "Editar usuario",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 79, 52),
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100);
}
//CUSTOM APP BAR

//CUSTOM PAINTER APP BAR
class BackgroundAppBar extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);

    path.lineTo(size.width, size.height - 20);
    path.lineTo(size.width, 0.0);
    return path;
  }

  @override
  bool shouldReclip(BackgroundAppBar oldClipper) => oldClipper != this;
}

//CUSTOM PAINTER BOTON ENTRAR
class BackgroundButton1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Color color1 = Color.fromARGB(255, 97, 2, 185);
    Color color2 = Color.fromARGB(255, 43, 0, 83);

    final LinearGradient gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color1, color2]);

    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    var path = Path();
    path.lineTo(size.width - 240, size.height - 10);
    path.lineTo(size.width - 10, size.height - 3);
    path.lineTo(size.width, size.height - 52);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

//CUSTOM PAINTER BOTON ENTRAR
class Botonregistrar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        width: 250,
        height: 50,
        child: CustomPaint(
          painter: BackgroundButton2(),
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Registro()));
            },
            child: Center(
              child: Text(
                'Soy Nuevo',
                style: TextStyle(
                  color: Color.fromARGB(255, 97, 2, 185),
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BackgroundButtongoogle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Color color1 = Color.fromARGB(197, 219, 219, 219);

    final LinearGradient gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color1, color1]);

    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    var path = Path();
    path.lineTo(size.width - 240, size.height - 10);
    path.lineTo(size.width - 10, size.height - 3);
    path.lineTo(size.width, size.height - 52);

    path.close();

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
//CUSTOM PAINTER BOTON GOOGLE

//CUSTOM PAINTER BOTON REGISTRARSE
class BackgroundButton2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Color color1 = Color.fromARGB(255, 97, 2, 185);
    final paint = Paint()
      ..color = color1
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    var path = Path();
    path.lineTo(size.width - 240, size.height - 10);
    path.lineTo(size.width - 10, size.height - 3);
    path.lineTo(size.width, size.height - 52);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
//CUSTOM PAINTER BOTON REGISTRARSE
