
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../resenas/resenas.dart';
import 'paginas/cafeterias/Cafeterias.dart';
import 'paginas/perfil/Perfil.dart';
import 'paginas/carrito/carrito.dart';
import 'variables_globales/varaibles_globales.dart';

class CustomBottomBar extends StatefulWidget {
  final inicio;
  final Function(int) changeIndex;
  final GlobalController globalController;

  const CustomBottomBar({Key? key, this.inicio, required this.globalController, required this.changeIndex}) : super(key: key);

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
              selectedIndex: widget.globalController.currentIndex.value,
              gap: 6,
              padding: EdgeInsets.all(10),
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Inicio', //Exportar la variable tiempo_inicio
                  onPressed: () {
                   widget.changeIndex(0);
                  },
                ),
                GButton(
                  icon: Icons.reviews,
                  text: 'Mis Reseñas',
                  onPressed: () {
                   widget.changeIndex(1);
                  },
                ),
                GButton(
                    icon: Icons.coffee_maker_outlined,
                    text: 'Cafeterias',
                    onPressed: () {
                      //Exportar la variable tiempo_inicio
                 widget.changeIndex(2);
                    }),
                GButton(
                  icon: Icons.event_note,
                  text: 'Eventos',
                  onPressed: () {
                    //Exportar la variable tiempo_inicio
                widget.changeIndex(3);
                  },
                ),
                GButton(
                  icon: Icons.shopping_cart,
                  text: 'Carrito',
                  onPressed: () {
                    //Exportar la variable tiempo_inicio
                widget.changeIndex(4);
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
