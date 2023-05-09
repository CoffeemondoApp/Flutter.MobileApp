import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeemondo/pantallas/user_logeado/Calendario.dart';
import 'package:coffeemondo/pantallas/user_logeado/colores/colores.dart';
import 'package:coffeemondo/pantallas/user_logeado/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../variables_globales/varaibles_globales.dart';


//Clase para asistir a un evento
class AsistirEvento extends StatefulWidget {
  final String idEvento;
  final Function(int) changeIndex;
  const AsistirEvento(
      {Key? key, required this.idEvento, required this.changeIndex})
      : super(key: key);
  @override
  State<AsistirEvento> createState() => _AsistirEventoState();
}

class _AsistirEventoState extends State<AsistirEvento> {
  final CarritoController carritoController = Get.put(CarritoController());
  //Informacion completa del evento
  Map<String, dynamic> infoEvento = {};

  //Lista de todas las fechas
  List<DateTime> fechaLista = [];

  //Informacion completa del carrito
  Map<String, dynamic> infoCarrito = { };

  //Fechas seleccionadas y su cantidad de entradas
  final List<Map<String, dynamic>> _fechasSeleccionadas = [];


  late DocumentReference
      _docRef; // Declarar la variable y asignarla en initState

 int entradasDisponibles = 0;
  @override
  void initState() {
    super.initState();
    _docRef =
        FirebaseFirestore.instance.collection('eventos').doc(widget.idEvento);
    getEventoData().then((eventosData) {
      setState(() {
        infoEvento = eventosData;
        fechaLista = obtenerFechasDeRango(infoEvento['fecha']);
        //  entradasDisponibles = infoEvento['tickets'].length ~/ fechaLista.length;
      });
    });
  }

  //------FIREBASE----------//

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Obtengo la información de un evento usando su ID
  Future<Map<String, dynamic>> getEventoData() async {
    DocumentSnapshot eventoSnapshot = await _docRef.get();
    Map<String, dynamic> eventoData =
        eventoSnapshot.data() as Map<String, dynamic>;
    eventoData['id'] =
        eventoSnapshot.id; // Agrega el ID del documento al mapa de datos
    return eventoData;
  }

  //Obtener todas las fechas del evento
  List<DateTime> obtenerFechasDeRango(String rangoFecha) {
    // Separa el rango de fecha en dos fechas separadas
    List<String> fechas = rangoFecha.split(' - ');

    // Analiza las cadenas de fecha en objetos de fecha
    DateFormat formateado = DateFormat('dd/MM/yyyy');
    DateTime fechaInicial = formateado.parse(fechas[0]);
    DateTime fechaFinal = formateado.parse(fechas[1]);

    // Crea una lista para almacenar las fechas dentro del rango
    List<DateTime> listaFechas = [];

    // Agrega todas las fechas dentro del rango a la lista
    for (var i = 0; i <= fechaFinal.difference(fechaInicial).inDays; i++) {
      DateTime nuevaFecha = fechaInicial.add(Duration(days: i));
      listaFechas.add(nuevaFecha);
    }

    return listaFechas;
  }

//Cambia el formato de fecha ej: 13/apr/2023
  String formatoFecha(DateTime date) {
    final formateador = DateFormat('dd/MMM/yyyy');
    return formateador.format(date);
  }

//Agregar fecha seleccionada y darle un ticket
void _handleFechaSelected(DateTime fecha) {
 setState(() {
    int index = _fechasSeleccionadas.indexWhere((element) =>  element['fecha'] == fecha);
    if (index >= 0) {
      _fechasSeleccionadas.removeAt(index);
    } else {
      _fechasSeleccionadas.add({'nombre':infoEvento['nombre'],'fecha': fecha, 'cantidad': 1, 'precio': 0.1});
    }
  });
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // Calcula el tamaño del texto basado en el ancho de la pantalla
    final fontSize = screenWidth * 0.05 * textScaleFactor;
    IndexPage indexPage = const IndexPage('');

List<Widget> fechasText = _fechasSeleccionadas.map((fechaSeleccionada) {
  List<String> opciones = ['1', '2', '3', '4','5','6','7','8'];
  List<DropdownMenuItem<String>> items = [];

  for (String opcion in opciones) {
    items.add(DropdownMenuItem(
      value: opcion,
      child: Text(opcion),
    ));
  }

return Container(
  margin: EdgeInsets.only(bottom: 25),
  decoration: BoxDecoration(
    border: Border(bottom: BorderSide(color: Colores.colorNaranja, width: 2.0)),
  ),
  child: Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Padding(
        padding: EdgeInsets.only(right: 16),
        child: Row(
          children: [
            Text('Fecha ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colores.colorMorado)),
            Text(
              formatoFecha(fechaSeleccionada['fecha']),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colores.colorMorado),
            ),
          ],
        ),
      ),
      Row(children: [
        Text('Cantidad', style: TextStyle(fontSize: 18, color: Colores.colorMorado)),
        SizedBox(width: 10),
        DropdownButton<String>(
          // value: null,
          dropdownColor: Colors.white,
          icon: Icon(Icons.arrow_drop_down, color: Colores.colorMorado),
          iconEnabledColor: Colores.colorMorado,
          underline: Container(
      height: 1, 
      color: Colores.colorMorado, // Color de la línea
    ),
          hint: fechaSeleccionada['cantidad'] != null
            ? Text(fechaSeleccionada['cantidad'].toString(), style: TextStyle(fontSize: 18, color: Colores.colorMorado))
            : Text('Seleccionar opción'),
          items: items,
          onChanged: (value) {
            setState(() {
              fechaSeleccionada['cantidad'] = int.parse(value!);
            });
          },
        ),
      ]),
      // Text('Entradas disponibles:')
    ],
  ),
);

}).toList();


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colores.colorMorado,
        title: Text('Comprar entradas'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colores.colorsScaffold,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text(infoEvento['nombre'], style: TextStyle(fontSize: 25)),),
              SizedBox(height: 10,),
              TextoIcono(
                texto: 'Fechas disponibles:',
                icono: Icons.calendar_month,
                tamanoTexto: fontSize,
              ),
              FechasListView(
                fechaLista: fechaLista,
                onFechaSelected: _handleFechaSelected,
                formatoFecha: formatoFecha,
              ),
              TextoIcono(
                texto: 'Seleccione la cantidad de entradas',
                icono: Icons.confirmation_num_rounded,
                tamanoTexto: fontSize,
              ),
              SizedBox(
                height: 15,
              ),
              Column(
                children: fechasText,
              ),
              Expanded(child: Container()),
              Row(
                
                children: [
                  ElevatedButton.icon(
                    onPressed: _fechasSeleccionadas.isNotEmpty
                        ? () {
                          
                          carritoController.agregarAlCarrito(_fechasSeleccionadas);

                            Navigator.popUntil(
                                context, ModalRoute.withName('/'));
                            widget.changeIndex(4);
                          }
                        : null,
                    icon: Icon(Icons.add_shopping_cart, color: Colores.colorNaranja,),
                    label: Text('Agregar al carrito', style: TextStyle(color: _fechasSeleccionadas.isNotEmpty ? Colores.colorNaranja : Colors.grey),),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colores.colorMorado),
                    ),
                  ),
                  
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

//Widget del texto junto a icono y tamaño personalizable
class TextoIcono extends StatelessWidget {
  final String texto;
  final IconData icono;
  final double tamanoTexto;
  const TextoIcono({
    Key? key,
    required this.texto,
    required this.icono,
    required this.tamanoTexto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: Colores.colorMorado),
        SizedBox(width: 10),
        Text(
          texto,
          style: TextStyle(fontSize: tamanoTexto, color: Colores.colorMorado),
        ),
      ],
    );
  }
}

//Lista de fechas disponibles
class FechasListView extends StatefulWidget {
  final List<DateTime> fechaLista;
  final Function(DateTime) onFechaSelected;
  final Function(DateTime) formatoFecha;
  FechasListView(
      {required this.fechaLista,
      required this.onFechaSelected,
      required this.formatoFecha});

  @override
  _FechasListViewState createState() => _FechasListViewState();
}

class _FechasListViewState extends State<FechasListView> {
  List<int> _selectedChipIndices = [];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, // espacio horizontal entre los elementos
      runSpacing: 8, // espacio vertical entre las filas
      children: List.generate(widget.fechaLista.length, (index) {
        final fecha = widget.fechaLista[index];
        return FilterChip(
          label: Text(
            widget.formatoFecha(fecha),
            style: TextStyle(
              color: Colors.white, // color del texto
            ),
          ),
          selected: _selectedChipIndices.contains(index),
          onSelected: (isSelected) {
            setState(() {
              if (isSelected) {
                _selectedChipIndices.add(index);
              } else {
                _selectedChipIndices.remove(index);
              }
            });
            widget.onFechaSelected(fecha);
          },
          selectedColor: Colores.colorMorado,
          backgroundColor: Colores.colorNaranja,
        );
      }),
    );
  }
}
