// This is a colors collection

import 'package:flutter/material.dart';

// // 1 Pallet
// const primary = Color.fromRGBO(238, 238, 238, 1);
// const secondary = Color.fromRGBO(55, 58, 64, 1);
// const terceary = Colors.blue;


// const acent = Color.fromRGBO(220, 95, 0, 1);

// const textTitle = Colors.yellow;
// const textBody = Color.fromRGBO(104, 109, 118, 1);

// 2 Pallet
const primary = Color.fromRGBO(40, 43, 45, 1);
const secondary = Color.fromRGBO(64, 75, 105, 1);
// const terceary = Colors.blue;


const acent = Color.fromRGBO(1, 141, 255, 1);
const textBody = Color.fromRGBO(192, 192, 192, 1);


const textTitle = Color.fromRGBO(1, 141, 255, 1);


  Color darkenColor(Color color, double amount) {
    // Asegurarse de que la cantidad está entre 0 y 1
    assert(amount >= 0 && amount <= 1);

    final int r = (color.red * (1 - amount)).clamp(0, 255).toInt();
    final int g = (color.green * (1 - amount)).clamp(0, 255).toInt();
    final int b = (color.blue * (1 - amount)).clamp(0, 255).toInt();

    return Color.fromRGBO(r, g, b, color.opacity);
  }