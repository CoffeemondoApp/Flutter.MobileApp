// ignore_for_file: use_build_context_synchronously, avoid_print, unused_field, prefer_final_fields, override_on_non_overriding_member, non_constant_identifier_names, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, annotate_overrides, use_full_hex_values_for_flutter_colors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeemondo/pantallas/Registro.dart';
import 'package:coffeemondo/firebase/autenticacion.dart';
import 'package:coffeemondo/pantallas/user_logeado/Info.dart';
import 'package:coffeemondo/pantallas/user_logeado/Perfil.dart';
import 'package:coffeemondo/pantallas/user_logeado/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginApp createState() => LoginApp();
}

class LoginApp extends State<Login> {
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();
  final FocusNode focusNode4 = FocusNode();
  final FocusNode focusNode5 = FocusNode();
  var colorScaffold = Color(0xffffebdcac);

  void dispose() {
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    focusNode5.dispose();
    super.dispose();
  }

  String? errorMessage = '';
  bool isLogin = true;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  final TextEditingController _controladoremail = TextEditingController();
  final TextEditingController _controladoremailOC = TextEditingController();
  final TextEditingController _controladorcontrasena = TextEditingController();

  // Validacion con cuenta email de usuario
  Future<void> signInWithEmailAndPassword() async {
    try {
      final authResult = await Auth().signInWithEmailAndPassword(
          email: _controladoremail.text, password: _controladorcontrasena.text);
      print('Inicio de sesion con email satisfactorio.');
      final uid = currentUser?.uid;
      final DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      if (!snapshot.exists) {
        // Crear un nuevo documento para el usuario
        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          'cumpleanos': 'Sin informacion de edad',
          'email': _controladoremail.text,
          'nickname': 'Sin informacion de nombre de usuario',
          'nombre': 'Sin informacion de nombre y apellido',
          'urlImage':
              'https://firebasestorage.googleapis.com/v0/b/coffeemondo-365813.appspot.com/o/profile_profile_image%2Fuser_img.png?alt=media&token=bd00aebc-7161-41ba-9303-9d3354d8fb37',
          'telefono': 'Sin informacion de telefono',
          'direccion': 'Sin informacion de direccion',
          'nivel': 1,
        });
      }
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const PerfilPage('0')));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No se ha encontrado un usuario asociado a este email.');
      } else if (e.code == 'wrong-password') {
        print('Contrasena incorrecta.');
      }
    }
  }

// Validaciones con cuenta google de usuario
  Future<void> signInWithGoogle() async {
    try {
      var resultado = await Auth().signInWithGoogle();
      if (resultado == null) return;
      final uid = currentUser?.uid;
      final DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      if (!snapshot.exists) {
        // Crear un nuevo documento para el usuario
        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          'cumpleanos': 'Sin informacion de edad',
          'nickname': "Sin informacion de nombre de usuario",
          'email': resultado!.user!.email,
          'nombre': resultado!.user!.displayName,
          'telefono': 'Sin informacion de telefono',
          'urlImage': resultado!.user!.photoURL,
          'direccion': 'Sin informacion de direccion',
          'nivel': 1,
        });
      }
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const PerfilPage('0')));
      print('Inicio de sesion con google satisfactorio.');
    } on FirebaseAuthException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  bool _obscureText = true;
  bool obs = true;
  bool obs_icon = true;

  var correoExisteLogin = false;
  var correoExisteRC = false;

  //Recuperar contraseña
  var olvideContra = false;
  var olvideContra2 = false;
  final TextEditingController digito1Controller = TextEditingController();
  final TextEditingController digito2Controller = TextEditingController();
  final TextEditingController digito3Controller = TextEditingController();
  final TextEditingController digito4Controller = TextEditingController();
  final TextEditingController digito5Controller = TextEditingController();
  var mostrarDigito1 = false;
  var mostrarDigito2 = false;
  var mostrarDigito3 = false;
  var mostrarDigito4 = false;
  var mostrarDigito5 = false;
  var correoEnviado = false;
  var correoEnviado2 = false;

  Future<bool> isEmailRegistered(String email, String contexto) async {
    final methods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    return methods.isNotEmpty;
  }

  @override
  Widget _Correo(TextEditingController controller, String contexto) {
    return TextField(
        controller: controller,
        onChanged: (value) {
          if (contexto == 'login') {
            isEmailRegistered(value, contexto).then((value) {
              setState(() {
                correoExisteLogin = value;
              });
            });
          } else {
            isEmailRegistered(value, contexto).then((value) {
              setState(() {
                correoExisteRC = value;
              });
            });
          }
        },
        style: const TextStyle(
          color: Color.fromARGB(255, 84, 14, 148),
          fontSize: 14.0,
          letterSpacing: 2,
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
                color: Color.fromARGB(255, 255, 79, 52), size: 20),
            suffixIcon: Visibility(
                visible:
                    (contexto == 'login') ? correoExisteLogin : correoExisteRC,
                child: Icon(Icons.check,
                    color: Color.fromARGB(255, 84, 14, 148), size: 20)),
            hintText: 'Correo electronico',
            hintStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 84, 14, 148),
            )));
  }

  Widget _Contrasena(
    TextEditingController controller,
  ) {
    return TextField(
        controller: controller,
        style: const TextStyle(
          color: Color.fromARGB(255, 84, 14, 148),
          fontSize: 14.0,
          letterSpacing: 2,
          height: 2.0,
          fontWeight: FontWeight.w900,
        ),
        obscureText: obs,
        decoration: InputDecoration(
          focusedBorder: const UnderlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Color.fromARGB(255, 255, 79, 52)),
          ),
          enabledBorder: const UnderlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Color.fromARGB(255, 255, 79, 52)),
          ),
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.lock,
              color: Color.fromARGB(255, 255, 79, 52), size: 20),
          suffixIcon: IconButton(
            icon: obs_icon == true
                ? const Icon(Icons.remove_red_eye,
                    color: Color.fromARGB(255, 255, 79, 52), size: 20)
                : const Icon(Icons.remove_red_eye_outlined,
                    color: Color.fromARGB(255, 255, 79, 52), size: 20),
            onPressed: () {
              setState(() {
                obs == true ? obs = false : obs = true;
                obs_icon == true ? obs_icon = false : obs_icon = true;
              });
            },
          ),
          hintText: 'Contraseña',
          hintStyle: const TextStyle(
              letterSpacing: 2,
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 84, 14, 148)),
        ));
  }

  Widget BotonLogin() {
    return Container(
      child: Container(
        width: 250,
        height: 50,
        child: CustomPaint(
          painter: BackgroundButton1(),
          child: InkWell(
            onTap: () {
              signInWithEmailAndPassword();
            },
            child: Center(
              child: Text(
                'Iniciar sesión',
                style: TextStyle(
                    color: colorScaffold,
                    fontSize: 16,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget BotonRecuperarContra() {
    return Container(
      child: Container(
        width: 250,
        height: 50,
        child: CustomPaint(
          painter: BackgroundButton1(),
          child: InkWell(
            onTap: () {
              sendPasswordResetEmail(_controladoremailOC.text);

              setState(() {
                correoEnviado = true;

                olvideContra2 = true;
              });

              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {
                  correoEnviado2 = true;
                });
              });
              Future.delayed(const Duration(seconds: 9), () {
                setState(() {
                  correoEnviado2 = false;
                });
              });
              Future.delayed(const Duration(seconds: 10), () {
                setState(() {
                  correoEnviado = false;
                });
              });
            },
            child: Center(
              child: Text(
                'Enviar codigo',
                style: TextStyle(
                    color: colorScaffold,
                    letterSpacing: 2,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget btnComprobarCodigo() {
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
                'Comprobar codigo',
                style: TextStyle(
                    color: colorScaffold,
                    letterSpacing: 2,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget botonGoogle() {
    return Container(
      child: Container(
        width: 250,
        height: 50,
        child: CustomPaint(
          painter: BackgroundButtongoogle(),
          child: InkWell(
            onTap: () {
              signInWithGoogle();
            },
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 15,
                      height: 12,
                      child: Image.asset('assets/google.png')),
                  SizedBox(width: 10), // Spacer
                  Text(
                    'Iniciar Sesion con Google',
                    style: TextStyle(
                        color: colorMorado,
                        fontSize: 14,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget contenedorLogo() {
    return (Container(
        margin: EdgeInsets.only(top: 50),
        child: Center(
          child: Container(
            width: 100,
            height: 100,
            child: Image.asset('assets/logo.png'),
          ),
        )));
  }

  Widget BotonBackRecuperarContra(BuildContext context) {
    return Container(
      child: Container(
        width: 250,
        height: 50,
        child: CustomPaint(
          painter: BackgroundButton2(),
          child: InkWell(
            onTap: () {
              setState(() {
                olvideContra = false;
              });
            },
            child: Center(
              child: Text(
                'Cancelar',
                style: TextStyle(
                    color: colorMorado,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget BtnBackCodigoEnviado(BuildContext context) {
    return Container(
      child: Container(
        width: 250,
        height: 50,
        child: CustomPaint(
          painter: BackgroundButton2(),
          child: InkWell(
            onTap: () {
              setState(() {
                olvideContra2 = false;
                digito1Controller.clear();
                digito2Controller.clear();
                digito3Controller.clear();
                digito4Controller.clear();
                digito5Controller.clear();
                mostrarDigito1 = false;
                mostrarDigito2 = false;
                mostrarDigito3 = false;
                mostrarDigito4 = false;
                mostrarDigito5 = false;
              });
            },
            child: Center(
              child: Text(
                'Cancelar',
                style: TextStyle(
                    color: colorMorado,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget avisoCorreoEnviado() {
    return AnimatedOpacity(
        opacity: (correoEnviado2) ? 1.0 : 0.0,
        duration: Duration(milliseconds: 1000),
        child: Container(
          margin: EdgeInsets.only(top: 40, right: 30, left: 30, bottom: 10),
          decoration: BoxDecoration(
              color: colorMorado, borderRadius: BorderRadius.circular(10)),
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(children: [
                Container(
                  child: Text('Restablecimiento exitoso',
                      style: TextStyle(
                          color: colorScaffold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                      'Se ha enviado un correo a ${_controladoremailOC.text} para recuperar su contraseña.',
                      style: TextStyle(
                          color: colorScaffold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
              ])),
        ));
  }

  Widget bodyLogin() {
    return (Column(children: <Widget>[
      (correoEnviado) ? avisoCorreoEnviado() : contenedorLogo(),
      Container(
          margin: EdgeInsets.only(top: 40, bottom: 20, left: 30, right: 30),
          child: _Correo(_controladoremail, 'login')),
      Container(
          margin: EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
          child: _Contrasena(_controladorcontrasena)),
      Container(
        width: MediaQuery.of(context).size.width * 0.85,
        //color: Colors.red,
        child: GestureDetector(
            onTap: () {
              setState(() {
                olvideContra = !olvideContra;
                olvideContra2 = false;
              });
            },
            child: Text(
              '¿Olvido su contraseña?',
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: colorNaranja,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            )),
      ),
      Container(
        padding: EdgeInsets.only(top: 60),
        child: BotonLogin(),
      ),
      Container(
        padding: EdgeInsets.only(top: 20),
        child: botonGoogle(),
      ),
      Padding(
        padding: EdgeInsets.only(left: 20, top: 50, right: 10),
        child: Botonregistrar(context),
      ),
    ]));
  }

  var _auth = FirebaseAuth.instance;
  Future<void> sendPasswordResetEmail(String email) async {
    //comprobar si se envio el correo de recuperacion de contraseña o no y mostrar un mensaje
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
      );
      print('Se envio el correo');
    } catch (e) {
      print('No se envio el correo $e');
    }
  }

  Widget bodyRecuperarContra() {
    return (Column(children: <Widget>[
      contenedorLogo(),
      Container(
          margin: EdgeInsets.only(top: 90, bottom: 20, left: 30, right: 30),
          child: _Correo(_controladoremailOC, 'recuperar contraseña')),
      Container(
        padding: EdgeInsets.only(top: 60),
        child: GestureDetector(
          child: BotonRecuperarContra(),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 20, top: 50, right: 10),
        child: BotonBackRecuperarContra(context),
      ),
    ]));
  }

  Widget contenedorDigito(
      TextEditingController controller, bool mostrarDigito, int digito) {
    return (AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
          color: (mostrarDigito)
              ? colorMorado
              : Color.fromARGB(100, 255, 255, 255),
          borderRadius: BorderRadius.circular(20)),
      width: MediaQuery.of(context).size.width * 0.13,
      height: MediaQuery.of(context).size.height * 0.10,
      child: Container(
          margin: EdgeInsets.only(top: 15, left: 5),
          child: TextField(
            focusNode: (digito == 1)
                ? focusNode1
                : (digito == 2)
                    ? focusNode2
                    : (digito == 3)
                        ? focusNode3
                        : (digito == 4)
                            ? focusNode4
                            : focusNode5,
            onTap: () => setState(() {}),
            onChanged: (value) {
              //comprobar si el largo del texto es 1 y pasar al siguiente digito
              if (value.length == 1) {
                if (digito == 1) {
                  setState(() {
                    mostrarDigito1 = true;
                  });
                  focusNode2.requestFocus();
                } else if (digito == 2) {
                  setState(() {
                    mostrarDigito2 = true;
                  });
                  focusNode3.requestFocus();
                } else if (digito == 3) {
                  setState(() {
                    mostrarDigito3 = true;
                  });
                  focusNode4.requestFocus();
                } else if (digito == 4) {
                  setState(() {
                    mostrarDigito4 = true;
                  });
                  focusNode5.requestFocus();
                } else if (digito == 5) {
                  setState(() {
                    mostrarDigito5 = true;
                  });
                  focusNode5.unfocus();
                }
              }
            },
            controller: controller,
            buildCounter: null,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorNaranja, fontSize: 25),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: "",
            ),
            keyboardType: TextInputType.number,
            maxLength: 1,
          )),
    ));
  }

  Widget contenedorCodigo() {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        contenedorDigito(digito1Controller, mostrarDigito1, 1),
        contenedorDigito(digito2Controller, mostrarDigito2, 2),
        contenedorDigito(digito3Controller, mostrarDigito3, 3),
        contenedorDigito(digito4Controller, mostrarDigito4, 4),
        contenedorDigito(digito5Controller, mostrarDigito5, 5),
      ],
    ));
  }

  Widget bodyCodigoEnviado() {
    return (Column(
      children: [
        contenedorLogo(),
        Container(
          child: contenedorCodigo(),
          margin: EdgeInsets.symmetric(vertical: 60, horizontal: 30),
        ),
        Container(
          child: btnComprobarCodigo(),
          margin: EdgeInsets.only(top: 40),
        ),
        Container(
          margin: EdgeInsets.only(top: 50),
          child: BtnBackCodigoEnviado(context),
        )
      ],
    ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffebdcac),
      appBar: AppBarcustom(),
      body: SingleChildScrollView(
        child: (olvideContra)
            ? (olvideContra2)
                ? bodyLogin() //bodyCodigoEnviado()
                : bodyRecuperarContra()
            : bodyLogin(),
      ),
      bottomNavigationBar: CustomBottomBar(),
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
      height: 88.0,
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: BackgroundAppBar(),
            child: Image.asset(
              'assets/Granos.png',
              width: MediaQuery.of(context).size.width,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 15,
            child: Center(
              child: Text(
                "Iniciar Sesión",
                style: TextStyle(
                  color: Colors.white,
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
  Size get preferredSize => Size.fromHeight(88.0);
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
//CUSTOM PAINTER APP BAR

//CUSTOM PAINTER BOTTOM BAR
class CustomBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      width: double.infinity,
      child: ClipPath(
        clipper: BackgroundBottomBar(),
        child: Image.asset(
          'assets/Granos.png',
          width: MediaQuery.of(context).size.width,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class BackgroundBottomBar extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 59);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
//CUSTOM PAINTER BOTTOM BAR

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

Widget Botonregistrar(BuildContext context) {
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
              'Soy nuevo',
              style: TextStyle(
                  color: colorMorado,
                  fontSize: 16,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ),
  );
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
