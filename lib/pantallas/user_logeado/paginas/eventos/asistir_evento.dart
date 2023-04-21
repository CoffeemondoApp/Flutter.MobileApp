import 'package:coffeemondo/pantallas/user_logeado/Calendario.dart';
import 'package:flutter/material.dart';

class AsistirEvento extends StatelessWidget {
  const AsistirEvento({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Calcula el tamaño del texto basado en el ancho de la pantalla
    final fontSize = screenWidth * 0.05 * textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Aplicación'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextoIcono(
              texto: 'Fechas disponibles:',
              icono: Icons.calendar_month,
              tamanoTexto: fontSize,
            ),
             Text('Fecha seleccionada:', ),
            ElevatedButton(
              onPressed: () {
                 Navigator.push(context,
              MaterialPageRoute(builder: (context) => CalendarioPage('')));
              },
              child: Text('Ver fechas'),
            ),
            TextoIcono(
              texto: 'Seleccione la cantidad de entradas',
              icono: Icons.confirmation_num_rounded,
              tamanoTexto: fontSize,
            ),

           
            SizedBox(height: 10),
            // Campo de entrada de texto para la cantidad de entradas
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad de entradas',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//Widget del texto junto a icono y tamaño personalizable
class TextoIcono extends StatelessWidget {
  String texto;
  IconData icono;
  double tamanoTexto;
  TextoIcono(
      {super.key,
      required this.texto,
      required this.icono,
      required this.tamanoTexto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono),
        SizedBox(width: 10),
        Text(
          texto,
          style: TextStyle(fontSize: tamanoTexto),
        ),
      ],
    );
  }
}
