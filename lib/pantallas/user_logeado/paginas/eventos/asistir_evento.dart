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
      int index = _fechasSeleccionadas
          .indexWhere((element) => element['fecha'] == fecha);
      if (index >= 0) {
        _fechasSeleccionadas.removeAt(index);
      } else {
        _fechasSeleccionadas.add({
          'nombre': infoEvento['nombre'],
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
    final fontSize = screenWidth * 0.049 * textScaleFactor;
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
          color: Colores.colorNaranja,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                child: Text(
                  formatoFecha(fechaSeleccionada['fecha']),
                  style: TextStyle(
                      fontSize: 16,
                      color: Colores.colorMorado,
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
                        color: Colores.colorMorado,
                      )),
                  Container(
                    child: Text(
                      fechaSeleccionada['cantidad'].toString(),
                      style: TextStyle(fontSize: 16, color: Colores.colorMorado),
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
                        color: Colores.colorMorado,
                      )),
                ],
              )
              // Text('Entradas disponibles:')
            ],
          ),
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
                      color: Colores.colorMorado,
                    ),
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        infoEvento['nombre'],
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colores.colorNaranja),
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
                  color: Colores.colorMorado,
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
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
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
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
                  color: Colores.colorMorado,
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
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
                      color: Colores.colorNaranja,
                    ),
                    label: Text(
                      'Agregar al carrito',
                      style: TextStyle(
                          color: _fechasSeleccionadas.isNotEmpty
                              ? Colores.colorNaranja
                              : Colors.grey),
                    ),
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
        Icon(icono, color: Colores.colorNaranja),
        SizedBox(width: 10),
        Text(
          texto,
          style: TextStyle(fontSize: tamanoTexto, color: Colores.colorNaranja),
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
