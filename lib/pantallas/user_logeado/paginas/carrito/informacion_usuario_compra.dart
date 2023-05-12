import 'package:coffeemondo/pantallas/user_logeado/paginas/perfil/Perfil.dart';
import 'package:flutter/material.dart';
import 'package:coffeemondo/pantallas/user_logeado/colores/colores.dart';
import 'package:pay/pay.dart';
import 'payment_configurations.dart';

class InformacionUsuarioCompra extends StatefulWidget {
  const InformacionUsuarioCompra({Key? key}) : super(key: key);

  @override
  _InformacionUsuarioCompraState createState() =>
      _InformacionUsuarioCompraState();
}

class _InformacionUsuarioCompraState extends State<InformacionUsuarioCompra> {
  TextEditingController nombreUsuario = TextEditingController();
  TextEditingController apellidoUsuario = TextEditingController();
  TextEditingController rutUsuario = TextEditingController();
  TextEditingController direccionUsuario = TextEditingController();
  TextEditingController telefonoUsuario = TextEditingController();

  bool isButtonEnabled = false;
  bool mostrarBotonPago = false;

  @override
  void initState() {
    super.initState();
    nombreUsuario.addListener(comprobarCampos);
    apellidoUsuario.addListener(comprobarCampos);
    rutUsuario.addListener(comprobarCampos);
    direccionUsuario.addListener(comprobarCampos);
    telefonoUsuario.addListener(comprobarCampos);
  }

  void comprobarCampos() {
    setState(() {
      isButtonEnabled = nombreUsuario.text.isNotEmpty &&
          apellidoUsuario.text.isNotEmpty &&
          rutUsuario.text.isNotEmpty &&
          direccionUsuario.text.isNotEmpty &&
          telefonoUsuario.text.isNotEmpty;
    });
  }

  void onPaymentResult(result) {
    debugPrint('Payment Result $result');
    modal();
  }

  void regresarCarrito() {
    Navigator.pop(context);
  }

  InputDecoration buildInputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colores.colorMorado, size: 24),
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colores.colorMorado,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        fontSize: 14,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colores.colorMorado),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colores.colorMorado),
      ),
    );
  }

Widget textoConfirmacionPago(String text, int size, FontWeight fontWeight, Color color ) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black54,
    ),
    textAlign: TextAlign.center,
  );
}


  @override
Future<void> modal() {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    builder: (BuildContext context) {
      return Container(
        height: 400,
        color: colorNaranja,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_outlined, size: 100, color: Colors.black),
              textoConfirmacionPago('¡Gracias por su compra!', 28, FontWeight.bold, Colors.black),
              const SizedBox(height: 10),
              textoConfirmacionPago('El pago ha sido exitoso', 18, FontWeight.w600, Colors.black87),
              const SizedBox(height: 10),
              textoConfirmacionPago('En un momento recibirá una notificación con su orden de compra', 18, FontWeight.w500, Colors.black54),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.red; // Color when the button is pressed
                      } else {
                        return Colores.colorMorado; // Default color
                      }
                    },
                  ),
                ),
                child: const Text('Carrito'),
                onPressed: () {
                  Navigator.pop(context);
                  regresarCarrito();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget buildCustomTextField(
      TextEditingController controller, String labelText, IconData icon) {
    return TextField(
      onTap: () {
        // setState(() {});
      },
      controller: controller,
      style: const TextStyle(
        letterSpacing: 2,
        decoration: TextDecoration.none,
        color: Colores.colorMorado,
        fontSize: 14.0,
        height: 2.0,
        fontWeight: FontWeight.w900,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colores.colorMorado),
        prefixIcon: Icon(
          icon,
          color: Colores.colorMorado,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colores.colorMorado),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colores.colorMorado),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colores.colorMorado),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    var edgeInsets = EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.02,
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ingresa tus datos'),
          backgroundColor: Colores.colorMorado,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Regresar a la pantalla anterior
              regresarCarrito();
            },
          ),
        ),
        body: Container(
          color: Colores.colorsScaffold,
          child: Column(
            children: [
              Container(
                margin: edgeInsets,
                child:
                    buildCustomTextField(nombreUsuario, 'Nombre', Icons.person),
              ),
              Container(
                margin: edgeInsets,
                child: buildCustomTextField(
                    apellidoUsuario, 'Apellido', Icons.person),
              ),
              Container(
                margin: edgeInsets,
                child: buildCustomTextField(
                    rutUsuario, 'Rut', Icons.assignment_ind),
              ),
              Container(
                margin: edgeInsets,
                child: buildCustomTextField(
                    direccionUsuario, 'Direccion', Icons.home),
              ),
              Container(
                margin: edgeInsets,
                child: buildCustomTextField(
                    telefonoUsuario, 'Telefono', Icons.phone),
              ),
              if (!mostrarBotonPago)
                ElevatedButton(
                  onPressed: isButtonEnabled ? () => seguir() : null,
                  child: Text('Seguir'),
                ),
              if (mostrarBotonPago)
                GooglePayButton(
                  paymentConfiguration:
                      PaymentConfiguration.fromJsonString(defaultGooglePay),
                  paymentItems: [],
                  childOnError: const Text('Google Pay no es compatible'),
                  width: double.infinity,
                  type: GooglePayButtonType.pay,
                  margin: const EdgeInsets.only(top: 15.0),
                  onPaymentResult: onPaymentResult,
                  loadingIndicator: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void seguir() {
    setState(() {
      mostrarBotonPago = true;
    });
    // Realizar acciones cuando se presione el botón "Seguir"
    // Solo se ejecutará si todos los campos de texto están completos
  }
}
