import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../variables_globales/varaibles_globales.dart';

class AppBarCustom extends StatefulWidget {
  final GlobalController globalController;
  final String urlImage;
  final List<Map<String, dynamic>> Function() getNivel;
  final Function() _subirNivel;
  const AppBarCustom({
    Key? key,
    required this.globalController,
    required this.urlImage,
    required this.getNivel,
    required Function() subirNivel,
  })  : _subirNivel = subirNivel,
        super(key: key);

  @override
  _AppBarCustomState createState() => _AppBarCustomState();
}

class _AppBarCustomState extends State<AppBarCustom> {
  @override
  Widget build(BuildContext context) {
  

    Widget AppBarcus() {
      return Container(
        //darle un ancho y alto al container respecto al tamaño de la pantalla

        height: 170,
        color: Color.fromARGB(0, 0, 0, 0),
        child: Column(
          children: [
            Container(
              height: 160,
              color: Color.fromARGB(255, 84, 14, 148),
            ),
  
          ],
        ),
      );
    }

    Widget FotoPerfil() {
  return Transform.translate(
    offset: Offset(0, 20),
    child: ElevatedButton(
      onPressed: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(160),
        child: Obx(
          () => widget.globalController.urlImage.value != ''
              ? Image.network(
                  widget.globalController.urlImage.value,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/user_img.png',
                  width: 120,
                ),
        ),
      ),
      style: ElevatedButton.styleFrom(shape: CircleBorder()),
    ),
  );
}

    @override
    Widget _textoAppBar() {
      return Obx(() => Text(
            (widget.globalController.nickname.value !=
                    'Sin informacion de nombre de usuario')
                ? "Bienvenido ${widget.globalController.nickname.value}!"
                : "Bienvenido anonimo!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ));
    }

    @override
    Widget _textoProgressBar() {
      //Obtener nivel de getNivel()
      int nivel_usuario = widget.getNivel()[0]['nivel'];
      //Obtener nivel actual de getNivel()
      int nivel_actual = widget.getNivel()[0]['nivel actual'];
      int puntaje_nivel = widget.getNivel()[0]['puntaje_nivel'];
      //Si el nivel actual es diferente al nivel de usuario, se actualiza el nivel de usuario
      if (nivel_usuario > nivel_actual) {
        widget.globalController.nivel.value = nivel_usuario;

        widget._subirNivel();
      }

      return (Container(
          width: MediaQuery.of(context).size.width * 0.6,
          //color: Colors.red,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Obx(() => Text(
                  'Nivel ${widget.globalController.nivel.value}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),),
              Container(
                child: Obx(() => Text(
                  '${widget.globalController.puntaje_actual.value}/${widget.globalController.puntaje_nivel.value}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),)
              ),
            ],
          )));
    }


    @override
    Widget _barraProgressBar() {
      return (Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
        width: 200,
        height: 25,
        decoration: BoxDecoration(
          color: Color.fromARGB(111, 0, 0, 0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeIn,
              width: 200 * widget.globalController.porcentaje.value,
              height: 25,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 79, 52),
                borderRadius: BorderRadius.circular(20),
              ),
              child: (widget.globalController.porcentaje.value > 0.15)
                  ? Container(
                      margin: EdgeInsets.only(top: 3),
                      child: Text(
                        '${(widget.globalController.porcentaje.value * 100).toStringAsFixed(0)}%',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color.fromARGB(0xff, 0x52, 0x01, 0x9b),
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      ));
    }

    @override
    Widget _ProgressBar() {
      return (Obx(() => Column(
        children: [
          _textoProgressBar(),
          _barraProgressBar(),
        ],
      )));
    }

    return Container(
      color: Color.fromARGB(255, 84, 14, 148),
      child: Stack(
        
        children: [
          // AppBarcus(),
          Row(
            children: [
              FotoPerfil(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                     _textoAppBar(),
                     Expanded(child: Container()),
                      _ProgressBar() 
                      
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
