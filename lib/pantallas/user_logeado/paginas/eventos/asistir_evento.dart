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
  Map<String, dynamic> infoCarrito = {};

  //Fechas seleccionadas y su cantidad de entradas
  final List<Map<String, dynamic>> _fechasSeleccionadas = [];

  late DocumentReference
      _docRef; // Declarar la variable y asignarla en initState

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
    final formateador = DateFormat('dd/MMM', 'es_ES');
    return formateador.format(date);
  }

//Agregar fecha seleccionada y darle un ticket
  void _handleFechaSelected(DateTime fecha, int index) {
    String ticketsString = infoEvento['ticketsDispo'][index];
    ticketsString = ticketsString.substring(1, ticketsString.length - 1);
    // Separar los elementos utilizando la coma como delimitador
    List<String> tickets = ticketsString.split(' ');

    setState(() {
      int index = _fechasSeleccionadas
          .indexWhere((element) => element['fecha'] == fecha);
      if (index >= 0) {
        _fechasSeleccionadas.removeAt(index);
      } else {
        _fechasSeleccionadas.add({
          'nombre': infoEvento['nombre'],
          'disponibles': tickets.length,
          'fecha': fecha,
          'cantidad': 1,
          'precio': 300
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // Calcula el tamaño del texto basado en el ancho de la pantalla
    final fontSize = screenWidth * 0.045 * textScaleFactor;
    IndexPage indexPage = const IndexPage('');

    List<Widget> fechasText = _fechasSeleccionadas.map((fechaSeleccionada) {
      List<String> opciones = ['1', '2', '3', '4', '5', '6', '7', '8'];
      List<DropdownMenuItem<String>> items = [];

      for (String opcion in opciones) {
        items.add(DropdownMenuItem(
          value: opcion,
          child: Text(opcion),
        ));
      }

      return Container(
        width: MediaQuery.of(context).size.width * 0.95,
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
          color: colorNaranja,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: Text(
                  formatoFecha(fechaSeleccionada['fecha']),
                  style: TextStyle(
                      fontSize: fontSize - 4,
                      color: colorMorado,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          if (fechaSeleccionada['cantidad'] > 1) {
                            fechaSeleccionada['cantidad']--;
                          }
                        });
                      },
                      icon: Icon(
                        Icons.remove,
                        color: colorMorado,
                      )),
                  Container(
                    child: Text(
                      fechaSeleccionada['cantidad'].toString(),
                      style: TextStyle(
                          fontSize: fontSize - 1,
                          color: colorMorado,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          fechaSeleccionada['cantidad']++;
                        });
                      },
                      icon: Icon(
                        Icons.add,
                        color: colorMorado,
                      )),
                  Text(
                    'Disponibles: ${fechaSeleccionada['disponibles'].toString()}',
                    style: TextStyle(
                        fontSize: fontSize - 1,
                        color: colorMorado,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorMorado,
        title: Text('Comprar entradas'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: colorsScaffold,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                      color: colorMorado,
                    ),
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        infoEvento['nombre'],
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorNaranja),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                  color: colorMorado,
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextoIcono(
                          texto: 'Fechas disponibles',
                          icono: Icons.calendar_month,
                          tamanoTexto: fontSize - 2,
                        ),
                      ),
                      FechasListView(
                        fechaLista: fechaLista,
                        onFechaSelected: _handleFechaSelected,
                        formatoFecha: formatoFecha,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Container(
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                  color: colorMorado,
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      TextoIcono(
                        texto: 'Seleccione la cantidad de entradas',
                        icono: Icons.confirmation_num_rounded,
                        tamanoTexto: fontSize - 2,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: SingleChildScrollView(
                          child: Column(
                            children: fechasText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: Container()),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _fechasSeleccionadas.isNotEmpty
                        ? () {
                            carritoController
                                .agregarAlCarrito(_fechasSeleccionadas);

                            Navigator.popUntil(
                                context, ModalRoute.withName('/'));
                            widget.changeIndex(4);
                          }
                        : null,
                    icon: Icon(
                      Icons.add_shopping_cart,
                      color: colorNaranja,
                    ),
                    label: Text(
                      'Agregar al carrito',
                      style: TextStyle(
                          color: _fechasSeleccionadas.isNotEmpty
                              ? colorNaranja
                              : Colors.grey),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(colorMorado),
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
        Icon(icono, color: colorNaranja),
        SizedBox(width: 10),
        Text(
          texto,
          style: TextStyle(fontSize: tamanoTexto, color: colorNaranja),
        ),
      ],
    );
  }
}

//Lista de fechas disponibles
class FechasListView extends StatefulWidget {
  final List<DateTime> fechaLista;
  final Function(DateTime, int) onFechaSelected;
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
      runSpacing: 2, // espacio vertical entre las filas
      children: List.generate(widget.fechaLista.length, (index) {
        final fecha = widget.fechaLista[index];
        return ChoiceChip(
          label: Text(
            widget.formatoFecha(fecha),
            style: TextStyle(
              color: _selectedChipIndices.contains(index)
                  ? colorNaranja
                  : Colors.white, // color del texto
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
            widget.onFechaSelected(fecha, index);
            print(_selectedChipIndices);
          },
          selectedColor: colorMorado,
          backgroundColor: colorNaranja,
        );
      }),
    );
  }
}
