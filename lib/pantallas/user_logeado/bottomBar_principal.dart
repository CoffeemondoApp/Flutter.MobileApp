import 'package:coffeemondo/pantallas/user_logeado/resenas.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../resenas/resenas.dart';
import 'Cafeterias.dart';
import 'Eventos.dart';
import 'Perfil.dart';
import 'carrito.dart';

class CustomBottomBar extends StatefulWidget {
  final inicio;
  final index;
  const CustomBottomBar({Key? key, this.inicio, this.index}) : super(key: key);

  @override
  _CustomBottomBarState createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 75,
          color: Colors.transparent,
          child: ClipPath(
              clipper: BackgroundBottomBar(),
              child: Container(
                color: Color.fromARGB(0xff, 0x52, 0x01, 0x9b),
              )),
        ),
        Container(
          height: 70,
          child: GNav(
              backgroundColor: Colors.transparent,
              color: Color.fromARGB(255, 255, 79, 52),
              activeColor: Color.fromARGB(255, 255, 79, 52),
              tabBackgroundColor: Color.fromARGB(50, 0, 0, 0),
              selectedIndex: widget.index,
              gap: 6,
              padding: EdgeInsets.all(10),
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Inicio', //Exportar la variable tiempo_inicio
                ),
                GButton(
                  icon: Icons.reviews,
                  text: 'Mis Reseñas',
                  onPressed: () {
                    //Exportar la variable tiempo_inicio
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ResenasPage(widget.inicio)));
                  },
                ),
                GButton(
                    icon: Icons.coffee_maker_outlined,
                    text: 'Cafeterias',
                    onPressed: () {
                      //Exportar la variable tiempo_inicio
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Cafeterias(widget.inicio)));
                    }),
                GButton(
                  icon: Icons.event_note,
                  text: 'Eventos',
                  onPressed: () {
                    //Exportar la variable tiempo_inicio
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventosPage(widget.inicio)));
                  },
                ),
                GButton(
                  icon: Icons.shopping_cart,
                  text: 'Carrito',
                  onPressed: () {
                    //Exportar la variable tiempo_inicio
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CarritoPage(widget.inicio)));
                  },
                ),
                GButton(
                  icon: Icons.account_circle,
                  text: 'Configuracion',
                  //Enlace a vista editar perfil desde Index
                  onPressed: () {
                    //Exportar la variable tiempo_inicio
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PerfilPage(widget.inicio)));
                  },
                ),
              ]),
        ),
      ],
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
