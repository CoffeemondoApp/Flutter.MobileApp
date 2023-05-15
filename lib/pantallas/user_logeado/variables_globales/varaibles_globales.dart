import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class GlobalController extends GetxController {
  // Declaracion de variables de colores
  static const Color morado = Color.fromARGB(255, 84, 14, 148);
  static const Color naranja = Color.fromARGB(255, 255, 100, 0);

  // Declaracion de variables de informacion de usuario
  RxString nombre = ''.obs;
  RxString nickname = ''.obs;
  RxString cumpleanos = ''.obs;
  RxString urlImage = ''.obs;
  RxInt nivel = 1.obs;
  RxInt puntaje_actual = 180.obs;
  RxDouble porcentaje = 0.0.obs;
  RxInt puntaje_nivel = 200.obs;
  RxString puntaje_actual_string = ''.obs;
  RxInt currentIndex = 0.obs;
  RxString telefono = ''.obs;
  RxString direccion = ''.obs;
  RxString cafetera = ''.obs;
  RxString molino = ''.obs;
  RxString tipo_cafe = ''.obs;
  RxString marca_cafe = ''.obs;

  List<Map<String, dynamic>> niveles = [
    {'nivel': 1, 'puntaje_nivel': 400, 'porcentaje': 0.0},
    {'nivel': 2, 'puntaje_nivel': 800, 'porcentaje': 0.0},
    {'nivel': 3, 'puntaje_nivel': 1200, 'porcentaje': 0.0},
    {'nivel': 4, 'puntaje_nivel': 1600, 'porcentaje': 0.0},
    {'nivel': 5, 'puntaje_nivel': 2000, 'porcentaje': 0.0},
    {'nivel': 6, 'puntaje_nivel': 2400, 'porcentaje': 0.0},
    {'nivel': 7, 'puntaje_nivel': 2800, 'porcentaje': 0.0},
    {'nivel': 8, 'puntaje_nivel': 3200, 'porcentaje': 0.0},
    {'nivel': 9, 'puntaje_nivel': 3600, 'porcentaje': 0.0},
    {'nivel': 10, 'puntaje_nivel': 4000, 'porcentaje': 0.0},
    {'nivel': 11, 'puntaje_nivel': 4400, 'porcentaje': 0.0},
    {'nivel': 12, 'puntaje_nivel': 4800, 'porcentaje': 0.0},
    {'nivel': 13, 'puntaje_nivel': 5200, 'porcentaje': 0.0},
    {'nivel': 14, 'puntaje_nivel': 5600, 'porcentaje': 0.0},
    {'nivel': 15, 'puntaje_nivel': 6000, 'porcentaje': 0.0},
    {'nivel': 16, 'puntaje_nivel': 6400, 'porcentaje': 0.0},
    {'nivel': 17, 'puntaje_nivel': 6800, 'porcentaje': 0.0},
    {'nivel': 18, 'puntaje_nivel': 7200, 'porcentaje': 0.0},
    {'nivel': 19, 'puntaje_nivel': 7600, 'porcentaje': 0.0},
    {'nivel': 20, 'puntaje_nivel': 8000, 'porcentaje': 0.0},
    {'nivel': 21, 'puntaje_nivel': 8400, 'porcentaje': 0.0},
    {'nivel': 22, 'puntaje_nivel': 8800, 'porcentaje': 0.0},
    {'nivel': 23, 'puntaje_nivel': 9200, 'porcentaje': 0.0},
    {'nivel': 24, 'puntaje_nivel': 9600, 'porcentaje': 0.0},
    {'nivel': 25, 'puntaje_nivel': 10000, 'porcentaje': 0.0},
    {'nivel': 26, 'puntaje_nivel': 10400, 'porcentaje': 0.0},
    {'nivel': 27, 'puntaje_nivel': 10800, 'porcentaje': 0.0},
    {'nivel': 28, 'puntaje_nivel': 11200, 'porcentaje': 0.0},
    {'nivel': 29, 'puntaje_nivel': 11600, 'porcentaje': 0.0},
    {'nivel': 30, 'puntaje_nivel': 12000, 'porcentaje': 0.0},
    {'nivel': 31, 'puntaje_nivel': 12400, 'porcentaje': 0.0},
    {'nivel': 32, 'puntaje_nivel': 12800, 'porcentaje': 0.0},
    {'nivel': 33, 'puntaje_nivel': 13200, 'porcentaje': 0.0},
    {'nivel': 34, 'puntaje_nivel': 13600, 'porcentaje': 0.0},
    {'nivel': 35, 'puntaje_nivel': 14000, 'porcentaje': 0.0},
    {'nivel': 36, 'puntaje_nivel': 14400, 'porcentaje': 0.0},
  ];

  void getData() async {
    print('Iniciando getData');
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot usuarioSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    if (usuarioSnapshot.exists) {
      // Obtener los datos del usuario del snapshot
      Map<String, dynamic>? datosUsuario =
          usuarioSnapshot.data() as Map<String, dynamic>?;

      if (datosUsuario != null) {
        // Guardar la información del usuario en variables globales
        nombre.value = datosUsuario['nombre'];
        nickname.value = datosUsuario['nickname'];
        cumpleanos.value = datosUsuario['cumpleanos'];
        urlImage.value = datosUsuario['urlImage'];
        puntaje_actual.value = int.parse(datosUsuario['puntaje']);
        nivel.value = datosUsuario['nivel'];
        telefono.value = datosUsuario['telefono'];
        direccion.value = datosUsuario['direccion'];
        cafetera.value = datosUsuario['nombreCafetera'];
        molino.value = datosUsuario['molino'];
        tipo_cafe.value = datosUsuario['tipo_cafe'];
        marca_cafe.value = datosUsuario['marca_cafe'];

        // puntaje_actual.value =
      } else {
        print('Los datos del usuario son nulos');
      }
    } else {
      print('El usuario no existe');
    }
  }
}

class Product {
  final String nombre;
  final DateTime fecha;
  final int precio;
  final RxInt cantidad;

  Product({
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.fecha,
  });
}

class CarritoController extends GetxController {
  RxList<Product> productosEnCarrito = <Product>[].obs;

  void agregarAlCarrito(productos) {
    for (var producto in productos) {
      Product nuevoProducto = Product(
        nombre: producto['nombre'],
        precio: producto['precio'],
        cantidad: RxInt(producto['cantidad']),
        fecha: producto['fecha'],
      );

      print('El producto en controller$nuevoProducto');
      bool encontrado = false;
      for (var item in productosEnCarrito) {
        if (item.nombre == nuevoProducto.nombre &&
            item.fecha == nuevoProducto.fecha) {
          // Si el producto ya existe en el carrito, aumentar la cantidad
          aumentarNCantidad(nuevoProducto.cantidad.value, item);

          encontrado = true;
          break;
        }
      }
      if (!encontrado) {
        // Si el producto no existe en el carrito, agregarlo
        productosEnCarrito.add(nuevoProducto);
      }
    }
  }

  void removerDelCarrito(Product producto) {
    productosEnCarrito.remove(producto);
  }

  void aumentarNCantidad(int cantidad, Product producto) {
    producto.cantidad.value += cantidad;
  }

  void aumentarCantidad(producto) {
    producto.cantidad.value++;
  }

  void disminuirCantidad(Product producto) {
    if (producto.cantidad.value <= 1) {
      producto.cantidad.value = 1;
    } else {
      producto.cantidad.value--;
    }
  }

  double obtenerPrecioTotal() {
    double precioTotal = 0.0;
    for (var producto in productosEnCarrito) {
      precioTotal += producto.precio * producto.cantidad.value;
    }
    return precioTotal;
  }

  int obtenerCantidadTotal() {
    int cantidadTotal = 0;
    for (var producto in productosEnCarrito) {
      cantidadTotal += producto.cantidad.value;
    }
    return cantidadTotal;
  }
}
