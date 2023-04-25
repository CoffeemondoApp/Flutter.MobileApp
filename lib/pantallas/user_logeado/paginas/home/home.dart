import 'package:flutter/material.dart';

import '../../variables_globales/varaibles_globales.dart';

class Home extends StatefulWidget {
  final GlobalController globalController;
  final Function(int) subirPuntos;
  final Future<void> Function() enviarAlGrupo;


  const Home({Key? key, required this.globalController, required this.subirPuntos, required this.enviarAlGrupo,}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const Color morado = Color.fromARGB(255, 84, 14, 148);
  static const Color naranja = Color.fromARGB(255, 255, 100, 0);
  static const  colorScaffold = Color(0xffffebdcac);

  int contPremio = 0;
  bool _visible = false;


    @override
    Widget _tituloContainer() {
      return (Text(
        'Felicitaciones!',
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ));
    }

    @override
    Widget _cuerpoContainer() {
      return (Text(
        'Enhorabuena! Has subido al nivel ${widget.globalController.nivel.value}',
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ));
    }

    Widget _containerMensajeNivel() {
      return (AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: Duration(milliseconds: 1500),
        child: Container(
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.02,
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05),
          width: MediaQuery.of(context).size.width * 0.9,
          height: (!_visible) ? 0 : MediaQuery.of(context).size.height * 0.15,
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
                child: _tituloContainer(),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.04),
                child: _cuerpoContainer(),
              ),
            ],
          ),
        ),
      ));
    }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _containerMensajeNivel(),
        Container(
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.02,
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05),
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            //color: Color.fromARGB(255, 0x52, 0x01, 0x9b),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.02),
                child: Text('Bienvenido a la Beta !!!',
                    style: TextStyle(
                        color: morado,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
              
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.04),
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Text(
                            'En esta versión de la aplicación, podrás ver las reseñas de los cafes que visitas y subir tus propias reseñas. Además, podrás ver el puntaje de los lugares que visitas y el puntaje de los lugares que has visitado.',
                            style: TextStyle(
                                color: morado,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                              'Felicitaciones! Fuiste seleccionado como Beta Tester, eres uno de los primeros usuarios y por eso te damos un premio de 500 puntos. ¡Disfruta de la aplicación!',
                              style: TextStyle(
                                  color: morado,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (contPremio < 100) {
                                      widget.subirPuntos(500);

                                      setState(() {
                                        contPremio++;
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    decoration: BoxDecoration(
                                        color: morado,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Container(
                                      child: Center(
                                        child: Text(
                                          'Obtener premio :D',
                                          style: TextStyle(
                                              color: colorScaffold,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    widget.enviarAlGrupo();
                                  },
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    decoration: BoxDecoration(
                                        color: morado,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Container(
                                      child: Center(
                                        child: Text(
                                          'Unirse al grupo de WhatsApp',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: colorScaffold,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ))
                      ],
                    )),
              ),
            ],
          ),
        )
        //Padding(padding: EdgeInsets.only(top: 10), child: _containerMapa()),
        //btnsDev(),
      ],
    );
  }
}
