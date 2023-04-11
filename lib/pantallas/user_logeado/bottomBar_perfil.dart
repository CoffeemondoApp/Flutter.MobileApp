import 'package:coffeemondo/pantallas/user_logeado/Foto.dart';
import 'package:coffeemondo/pantallas/user_logeado/resenas.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../resenas/resenas.dart';
import 'Cafeterias.dart';
import 'Eventos.dart';
import 'Info.dart';
import 'InfoUsuario.dart';
import 'Perfil.dart';
import 'carrito.dart';
import 'index.dart';

class CustomBottomBarProfile extends StatefulWidget {
  final inicio;
  final index;
  const CustomBottomBarProfile({Key? key, this.inicio, this.index})
      : super(key: key);

  @override
  _CustomBottomBarProfileState createState() => _CustomBottomBarProfileState();
}

class _CustomBottomBarProfileState extends State<CustomBottomBarProfile> {
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
              gap: 8,
              padding: EdgeInsets.all(16),
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Perfil',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PerfilPage(widget.inicio)),
                    );
                  },
                ),
                GButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FotoPage(widget.inicio)),
                    );
                  },
                  icon: Icons.image,
                  text: 'Foto de perfil',
                ),
                GButton(
                  icon: Icons.info_outline,
                  text: 'Editar perfil',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              InfoPage(widget.inicio, '', '', '', '', '')),
                    );
                  },
                ),
                GButton(
                  icon: Icons.info,
                  text: 'Editar usuario',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InfoUsuarioPage(widget.inicio)),
                    );
                  },
                ),
                GButton(
                  icon: Icons.arrow_back,
                  text: 'Volver atras',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => IndexPage(widget.inicio)),
                    );
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
