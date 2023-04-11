// ignore_for_file: use_build_context_synchronously, avoid_print, unused_field, prefer_final_fields, override_on_non_overriding_member, non_constant_identifier_names, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, annotate_overrides, use_full_hex_values_for_flutter_colors, use_key_in_widget_constructors, sort_child_properties_last

import 'dart:async';

import 'package:coffeemondo/firebase/autenticacion.dart';
import 'package:coffeemondo/pantallas/user_logeado/bottomBar_perfil.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:coffeemondo/firebase/autenticacion.dart';
import 'bottomBar_principal.dart';
import 'Foto.dart';

//importar morado y naranja de Eventos.dart
const Color colorMorado = Color.fromARGB(255, 84, 14, 148);
const Color colorNaranja = Color.fromARGB(255, 255, 100, 0);

class PerfilPage extends StatefulWidget {
  final String tiempo_inicio;
  const PerfilPage(this.tiempo_inicio, {super.key});

  @override
  PerfilApp createState() => PerfilApp();
}

String tab = '';
var colorScaffold = Color(0xffffebdcac);

class PerfilApp extends State<PerfilPage> {
  @override
  void initState() {
    super.initState();
    // Se inicia la funcion de getData para traer la informacion de usuario proveniente de Firebase
    _getdata();
  }

  // Declaracion de variables de informaicon de usuario
  String nombre = '';
  String nickname = '';
  String cumpleanos = '';
  String telefono = '';
  String direccion = '';
  String urlImage = '';
  String cafetera = '';
  String molino = '';
  String tipo_cafe = '';
  String marca_cafe = '';

  String? errorMessage = '';
  bool isLogin = true;

  //Informacion del perfil
  bool infoPerfilPressed = false;
  bool infoPerfilPressed2 = false;

  bool infoUserPressed = false;
  bool infoUserPressed2 = false;

  // Declaracion de email del usuario actual
  final email = FirebaseAuth.instance.currentUser?.email;
  final TextEditingController _controladoremail = TextEditingController();
  final TextEditingController _controladoredad = TextEditingController();
  final TextEditingController _controladortelefono = TextEditingController();
  final TextEditingController _controladornombreUsuario =
      TextEditingController();
  final TextEditingController _controladordireccion = TextEditingController();

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
        cumpleanos = userData.data()!['cumpleanos'];
        telefono = userData.data()!['telefono'];
        direccion = userData.data()!['direccion'];
        urlImage = userData.data()!['urlImage'];
        cafetera = userData.data()!['cafetera'];
        molino = userData.data()!['molino'];
        tipo_cafe = userData.data()!['tipo_cafe'];
        marca_cafe = userData.data()!['marca_cafe'];
      });
    });
  }

  // Cerrar sesion del usuario
  Future<void> cerrarSesion() async {
    await Auth().signOut();
    print('Usuario ha cerrado sesion');
  }

  //Cambiar contraseña
  var cambiarContra = false;
  var verContra = false;
  var verContra2 = false;
  var errorCambiarContra = false;
  var errorCambiarContra2 = false;
  var errorCambiarContra_str = '';
  final TextEditingController contraActualController = TextEditingController();
  final TextEditingController contraNuevaController = TextEditingController();
  var contraActualizada = false;
  var contraActualizada2 = false;

  @override
  Widget _NombreApellido(
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
            prefixIcon: Icon(Icons.account_circle_outlined,
                color: Color.fromARGB(255, 255, 79, 52), size: 24),
            hintText: nombre,
            hintStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: colorNaranja,
                letterSpacing: 2)));
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
        prefixIcon:
            Icon(Icons.cake, color: Color.fromARGB(255, 255, 79, 52), size: 24),
        hintText: cumpleanos,
        hintStyle: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: colorNaranja,
            letterSpacing: 2),
      ),
    );
  }

  @override
  Widget _Telefono(
    TextEditingController controller,
  ) {
    return TextField(
        readOnly: true,
        keyboardType: TextInputType.phone,
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
            hintText: telefono,
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: colorNaranja,
            )));
  }

  Widget FotoPerfil() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FotoPage(widget.tiempo_inicio)));
        print('Editar foto de perfil');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: urlImage != ''
            ? Image.network(
                urlImage,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/user_img.png',
                width: 200,
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
        controller: controller,
        readOnly: true,
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
            hintText: nickname,
            hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorNaranja,
                letterSpacing: 2)));
  }

  Widget _Correo(
    TextEditingController controller,
  ) {
    return TextField(
        controller: controller,
        readOnly: true,
        // onChanged: (((value) => validarCorreo())),
        style: const TextStyle(
          color: colorNaranja,
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
            prefixIcon: Icon(Icons.email,
                color: Color.fromARGB(255, 255, 79, 52), size: 24),
            hintText: email,
            hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorNaranja,
                letterSpacing: 2)));
  }

  Widget BotonLogin() {
    return Container(
      child: Container(
        width: 250,
        height: 50,
        child: CustomPaint(
          painter: BackgroundButton1(),
          child: InkWell(
            onTap: () {},
            child: Center(
              child: Text(
                'Entrar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _Direccion(
    TextEditingController controller,
  ) {
    return TextField(
        controller: controller,
        readOnly: true,
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
            hintText: direccion,
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorNaranja,
            )));
  }

  // Widget de boton para cerrar sesion
  Widget botonCerrarSesion() {
    return Container(
      child: Container(
        width: 250,
        height: 50,
        child: CustomPaint(
          painter: BackgroundButton1(),
          child: InkWell(
            onTap: () => [
              _MostrarAlerta(context),
            ],
            child: Center(
              child: Text(
                'Cerrar sesion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Widget AlerDialog

  Widget AlertaCerrarSesion() {
    return AlertDialog(
      title: Text(
        'Cerrar sesión',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 79, 52),
        ),
      ),
      content: Text(
        '¿Usted desea cerrar su sesión en este dispositivo?',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 79, 52),
        ),
      ),
      backgroundColor: Color.fromARGB(0xff, 0x52, 0x01, 0x9b),
      actions: <Widget>[
        InkWell(
          child: Container(
            width: 50,
            height: 50,
            child: Center(
              child: Text(
                'Si',
                style: TextStyle(color: Color.fromARGB(255, 255, 79, 52)),
              ),
            ),
          ),
          onTap: () {
            cerrarSesion();
          },
        ),
        InkWell(
          child: Container(
            width: 50,
            height: 50,
            child: Center(
              child: Text(
                'No',
                style: TextStyle(color: Color.fromARGB(255, 255, 79, 52)),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  //Mostrar AlerDialog
  Future<void> _MostrarAlerta(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertaCerrarSesion(),
    );
  }

  Widget btnCambiarContra() {
    return (GestureDetector(
      onTap: (() {
        setState(() {
          cambiarContra = !cambiarContra;
        });
      }),
      child: Container(
        child: Container(
          child: Text(
            'Cambiar contraseña',
            style: TextStyle(color: colorMorado, fontWeight: FontWeight.bold),
          ),
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        ),
        decoration: BoxDecoration(
            color: colorNaranja, borderRadius: BorderRadius.circular(20)),
      ),
    ));
  }

  Widget iconoTFFC() {
    return (Container(
      child: Icon(Icons.lock_outline, color: colorNaranja, size: 24),
    ));
  }

  Widget textoTFFC() {
    return (Container(
        margin: EdgeInsets.only(top: 14, bottom: 10),
        child: Text('*******',
            style: TextStyle(
              color: colorNaranja,
              fontSize: 14.0,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ))));
  }

  Widget textFieldFalsoContra() {
    return (Container(
      margin: EdgeInsets.only(bottom: 5, left: 12),
      child: Row(children: [
        iconoTFFC(),
        Container(
          margin: EdgeInsets.only(left: 15),
          width: MediaQuery.of(context).size.width * 0.75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [textoTFFC(), btnCambiarContra()],
          ),
        )
      ]),
    ));
  }

  Widget _Password() {
    return (Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          textFieldFalsoContra(),
          containerSeparador(),
        ],
      ),
    ));
  }

  Widget itemsModuloInfoPerfil() {
    return (Column(
      children: [
        _Correo(_controladoremail),
        _NombreApellido(_controladoremail),
        _NombreUsuario(_controladornombreUsuario),
        _Password(),
        _Edad(_controladoredad),
        _Telefono(_controladortelefono),
        _Direccion(_controladordireccion),
      ],
    ));
  }

  Widget textFieldContraActual(TextEditingController controller) {
    return (Container(
      margin: EdgeInsets.only(
          top: (errorCambiarContra || contraActualizada) ? 10 : 40),
      child: TextField(
          controller: controller,
          obscureText: !verContra,
          //controller: controller,
          // onChanged: (((value) => validarCorreo())),
          style: const TextStyle(
            color: colorNaranja,
            fontSize: 14.0,
            height: 2.0,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
          decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorNaranja),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorNaranja),
              ),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock, color: colorNaranja, size: 24),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    verContra = !verContra;
                  });
                },
                child: Icon(
                  verContra
                      ? Icons.remove_red_eye
                      : Icons.remove_red_eye_outlined,
                  color: colorNaranja,
                ),
              ),
              hintText: 'Contraseña actual',
              hintStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: colorNaranja,
                  letterSpacing: 2))),
    ));
  }

  Widget textFieldContraNueva(TextEditingController controller) {
    return (Container(
      margin: EdgeInsets.only(top: 10),
      child: TextField(
          controller: controller,
          obscureText: !verContra2,
          //controller: controller,
          // onChanged: (((value) => validarCorreo())),
          style: const TextStyle(
            color: colorNaranja,
            fontSize: 14.0,
            height: 2.0,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
          decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorNaranja),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorNaranja),
              ),
              border: OutlineInputBorder(),
              prefixIcon:
                  Icon(Icons.lock_outline, color: colorNaranja, size: 24),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    verContra2 = !verContra2;
                  });
                },
                child: Icon(
                  verContra2
                      ? Icons.remove_red_eye
                      : Icons.remove_red_eye_outlined,
                  color: colorNaranja,
                ),
              ),
              hintText: 'Contraseña nueva',
              hintStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: colorNaranja,
                  letterSpacing: 2))),
    ));
  }

  Widget btnVolverAtrasCambiarContra() {
    return (Container(
      margin: EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width * 0.4,
      height: 40,
      decoration: BoxDecoration(
          color: colorNaranja, borderRadius: BorderRadius.circular(20)),
      child: GestureDetector(
        onTap: () {
          setState(() {
            cambiarContra = !cambiarContra;
          });
        },
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Volver atras',
            style: TextStyle(
              color: colorMorado,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ));
  }

  Widget btnGenerarCambiarContra() {
    return (Container(
      margin: EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width * 0.4,
      height: 40,
      decoration: BoxDecoration(
          color: colorNaranja, borderRadius: BorderRadius.circular(20)),
      child: GestureDetector(
        onTap: () {
          if (contraActualController.text == '' ||
              contraNuevaController.text == '') {
            setState(() {
              errorCambiarContra = true;
              errorCambiarContra_str = 'Por favor rellene todos los campos';
            });
            Future.delayed(Duration(milliseconds: 500), () {
              setState(() {
                errorCambiarContra2 = true;
              });
            });
            Future.delayed(Duration(seconds: 10), () {
              setState(() {
                errorCambiarContra = false;
                errorCambiarContra2 = false;
              });
            });
          } else {
            if (contraActualController.text == contraNuevaController.text) {
              setState(() {
                errorCambiarContra = true;
                errorCambiarContra_str =
                    'La contraseña nueva no puede ser igual a la actual';
              });
              Future.delayed(Duration(milliseconds: 500), () {
                setState(() {
                  errorCambiarContra2 = true;
                });
              });
              Future.delayed(Duration(seconds: 10), () {
                setState(() {
                  errorCambiarContra = false;
                  errorCambiarContra2 = false;
                });
              });
            } else {
              actualizarContra(email!, contraActualController.text,
                  contraNuevaController.text);
            }
          }
        },
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Generar cambio',
            style: TextStyle(
              color: colorMorado,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ));
  }

  Widget tituloMsjCC(String titulo) {
    return (Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        titulo,
        style: TextStyle(
            color: colorMorado, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ));
  }

  Widget textoMsjCC(String texto) {
    return (Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(texto,
          style: TextStyle(
              color: colorMorado, fontWeight: FontWeight.bold, fontSize: 14)),
    ));
  }

  var currentUser = FirebaseAuth.instance.currentUser;

  void actualizarContra(
      String email, String oldPassword, String newPassword) async {
    var cred =
        EmailAuthProvider.credential(email: email, password: oldPassword);
    await currentUser!.reauthenticateWithCredential(cred).then((value) {
      currentUser!.updatePassword(newPassword).then((value) {
        print('Contraseña actualizada');
        setState(() {
          errorCambiarContra = false;
          errorCambiarContra2 = false;
          contraActualizada = true;
          contraActualizada2 = true;
        });
        Future.delayed(Duration(seconds: 10), () {
          setState(() {
            contraActualizada = false;
            contraActualizada2 = false;
            cambiarContra = false;
          });
        });
      }).catchError((error) {
        print('Error al actualizar la contraseña');
        setState(() {
          errorCambiarContra = true;
          errorCambiarContra_str = 'Error al actualizar la contraseña';
          errorCambiarContra2 = true;
        });
        Future.delayed(Duration(seconds: 10), () {
          setState(() {
            errorCambiarContra = false;
            errorCambiarContra2 = false;
          });
        });
      });
    }).catchError((error) {
      print('Error al reautenticar');
      setState(() {
        errorCambiarContra = true;
        errorCambiarContra_str = 'La contraseña actual es incorrecta';
        errorCambiarContra2 = true;
      });
      Future.delayed(Duration(seconds: 10), () {
        setState(() {
          errorCambiarContra = false;
          errorCambiarContra2 = false;
        });
      });
    });
  }

  Widget contenedorMsjCC() {
    return (AnimatedOpacity(
        opacity: (errorCambiarContra2 || contraActualizada2) ? 1.0 : 0.0,
        duration: Duration(milliseconds: 500),
        child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
                color: colorNaranja, borderRadius: BorderRadius.circular(20)),
            child: (errorCambiarContra2 || contraActualizada2)
                ? Column(children: [
                    tituloMsjCC((contraActualizada2)
                        ? 'Contraseña actualizada'
                        : 'Error al cambiar la contraseña'),
                    textoMsjCC((contraActualizada2)
                        ? 'La contraseña se ha actualizado correctamente'
                        : errorCambiarContra_str),
                  ])
                : Container())));
  }

  Widget itemsModuloCambiarContra() {
    return (Column(
      children: [
        contenedorMsjCC(),
        textFieldContraActual(contraActualController),
        textFieldContraNueva(contraNuevaController),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            btnVolverAtrasCambiarContra(),
            btnGenerarCambiarContra(),
          ],
        ),
      ],
    ));
  }

  Widget tituloInfoPerfil() {
    return (Text(
      (!cambiarContra) ? 'Informacion de perfil' : 'Cambiar contraseña',
      style: TextStyle(
          color: Color(0xffffebdcac),
          fontWeight: FontWeight.bold,
          fontSize: 16),
    ));
  }

  Widget btnInfoPerfil() {
    return (Container(
        alignment: (infoPerfilPressed) ? Alignment.topCenter : Alignment.center,
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: GestureDetector(
            onTap: () {
              setState(() {
                infoPerfilPressed = !infoPerfilPressed;
                cambiarContra = false;
                contraActualController.text = '';
                contraNuevaController.text = '';
                // cambiar estado de infoPerfilPressed2 luego de 2 segundos
                if (!infoPerfilPressed2) {
                  Timer(Duration(milliseconds: 500), () {
                    setState(() {
                      infoPerfilPressed2 = !infoPerfilPressed2;
                    });
                  });
                } else {
                  infoPerfilPressed2 = !infoPerfilPressed2;
                }
              });
            },
            child: tituloInfoPerfil())));
  }

  Widget moduloInfoPerfil() {
    //hacer que el return se cree luego de 2 segundos
    return (Column(
      children: [
        (infoPerfilPressed2) ? btnInfoPerfil() : Container(),
        (cambiarContra) ? itemsModuloCambiarContra() : itemsModuloInfoPerfil(),
      ],
    ));
  }

  Widget containerSeparador() {
    return (Container(
      width: MediaQuery.of(context).size.width,
      height: 1,
      color: colorNaranja,
    ));
  }

  Widget iconoCafeteraInfoUsuario() {
    return (Container(
      child: Icon(
        Icons.coffee_maker_outlined,
        color: colorNaranja,
      ),
    ));
  }

  Widget infoCafeteraInfoUsuario() {
    return (Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: EdgeInsets.only(left: 10),
      //color: Colors.white,
      child: Container(
          child: Text(
        (cafetera != '') ? 'En mi casa uso $cafetera' : 'Sin informacion',
        style: TextStyle(
            color: colorNaranja, fontWeight: FontWeight.bold, letterSpacing: 2),
      )),
    ));
  }

  Widget contenedorCafeteraInfoUsuario() {
    return (Container(
      margin: EdgeInsets.only(top: 30, bottom: 10, left: 10),
      child: Column(children: [
        Row(
          children: [iconoCafeteraInfoUsuario(), infoCafeteraInfoUsuario()],
        )
      ]),
    ));
  }

  Widget iconoMolinoInfoUsuario() {
    return (Container(
      child: Icon(
        Icons.coffee_maker,
        color: colorNaranja,
      ),
    ));
  }

  Widget infoMolinoInfoUsuario() {
    return (Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: EdgeInsets.only(left: 10),
      //color: Colors.white,
      child: Container(
          child: Text(
        (molino != '') ? 'Uso $molino para moler mi cafe' : 'Sin informacion',
        style: TextStyle(
            color: colorNaranja, fontWeight: FontWeight.bold, letterSpacing: 2),
      )),
    ));
  }

  Widget contenedorMolinoInfoUsuario() {
    return (Container(
      margin: EdgeInsets.only(top: 30, bottom: 10, left: 10),
      child: Column(children: [
        Row(
          children: [iconoMolinoInfoUsuario(), infoMolinoInfoUsuario()],
        )
      ]),
    ));
  }

  Widget iconoCafeInfoUsuario() {
    return (Container(
      child: Icon(
        Icons.coffee_outlined,
        color: colorNaranja,
      ),
    ));
  }

  Widget infoCafeInfoUsuario() {
    return (Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: EdgeInsets.only(left: 10),
      //color: Colors.white,
      child: Container(
          child: Text(
        (tipo_cafe != '' && marca_cafe != '')
            ? 'En casa uso $tipo_cafe de la marca $marca_cafe'
            : 'Sin informacion',
        style: TextStyle(
            color: colorNaranja, fontWeight: FontWeight.bold, letterSpacing: 2),
      )),
    ));
  }

  Widget contenedorCafeInfoUsuario() {
    return (Container(
      margin: EdgeInsets.only(top: 30, bottom: 10, left: 10),
      child: Column(children: [
        Row(
          children: [iconoCafeInfoUsuario(), infoCafeInfoUsuario()],
        )
      ]),
    ));
  }

  Widget moduloInfoUsuario() {
    return (Column(
      children: [
        botonInfoUsuario(),
        contenedorCafeteraInfoUsuario(),
        containerSeparador(),
        contenedorMolinoInfoUsuario(),
        containerSeparador(),
        contenedorCafeInfoUsuario(),
        containerSeparador(),
      ],
    ));
  }

  Widget botonInfoUsuario() {
    return (Container(
        margin: EdgeInsets.only(top: (infoUserPressed2) ? 10 : 0),
        child: GestureDetector(
            onTap: () {
              setState(() {
                infoUserPressed = !infoUserPressed;
                // cambiar estado de infoPerfilPressed2 luego de 2 segundos
                if (!infoUserPressed2) {
                  Timer(Duration(milliseconds: 500), () {
                    setState(() {
                      infoUserPressed2 = !infoUserPressed2;
                    });
                  });
                } else {
                  infoUserPressed2 = !infoUserPressed2;
                }
              });
            },
            child: Align(
              alignment:
                  (infoUserPressed2) ? Alignment.topCenter : Alignment.center,
              child: Text(
                'Informacion de usuario',
                style: TextStyle(
                    color: colorScaffold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ))));
  }

  Widget bodyPerfil() {
    return (Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 40, top: 10, right: 40),
        child: FotoPerfil(),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
        child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            width: MediaQuery.of(context).size.width * 0.9,
            height: (infoPerfilPressed)
                ? (cambiarContra)
                    ? (errorCambiarContra || contraActualizada)
                        ? 320
                        : 270
                    : 420
                : 40,
            decoration: BoxDecoration(
              color: colorMorado,
              borderRadius: BorderRadius.circular(20),
            ),
            child: (infoPerfilPressed2) ? moduloInfoPerfil() : btnInfoPerfil()),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: (infoUserPressed) ? 240 : 40,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: colorMorado,
              borderRadius: BorderRadius.circular(20),
            ),
            child:
                (infoUserPressed2) ? moduloInfoUsuario() : botonInfoUsuario()),
      ),
      Padding(
          padding: const EdgeInsets.only(left: 50, top: 15, right: 40),
          child: botonCerrarSesion()),
    ]));
  }

  Widget build(BuildContext context) {
    print('esto pasa ' + widget.tiempo_inicio);
    print('fecha actual' + DateTime.now().toString());
    return Scaffold(
      backgroundColor: Color(0xffffebdcac),
      appBar: AppBarcustom(),
      body: SingleChildScrollView(child: bodyPerfil()),
      bottomNavigationBar:
          CustomBottomBarProfile(inicio: widget.tiempo_inicio, index: 0),
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
                "Perfil de usuario",
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
