import 'package:flu_sqflite/shop_page.dart';
import 'package:flutter/material.dart';

import 'cart_page.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'shop_page_admin.dart';
import 'user_page.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SQLITE database',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(), // becomes the route named '/'
    routes: <String, WidgetBuilder>{
      '/userPage': (BuildContext context) => const UserPage(),
      '/cartPage': (BuildContext context) => const CartPage(),
      '/shopPage': (BuildContext context) => const ShopPage(),
      '/shopPageAdmin': (BuildContext context) => const ShopPageAdmin(),
      '/shopHistory': (BuildContext context) => const HistoryPage(),
    },
  ));
}
