import 'package:flutter/material.dart';

import 'sqlhelper.dart';
import 'global_var.dart' as globals;

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  // Всі журнали
  List<Map<String, dynamic>> _shopItems = [];

  bool _isLoading = true;

  // змінна в якій зберігаємо кількість одиниць товарів
  int _quantityShopItem = 0;

  // індекс вибраного єлемента списку
  int? selectedIndex;

  // Ця функція використовується для отримання всіх даних з бази даних
  void _refreshItems() async {
    final data = await SQLHelper.getShopItems();
    setState(() {
      _shopItems = data;
      _isLoading = false;
      // ID active items
      if (_shopItems.isEmpty) {
        _quantityShopItem = 0;
      } else {
        _quantityShopItem = _shopItems.length;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshItems(); // Завантаження списку товарів під час запуску програми
  }

  // add item to cart
  Future<void> _itemAddToCart(int id) async {
    await SQLHelper.addToCart(
      globals.activeUserId,
      _shopItems[id]['id'],
      _shopItems[id]['price'],
      1, // quantity
      'new order', // order status
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Товар ${_shopItems[id]['name']} додано до кошика'),
    ));
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Action for back button
            Navigator.pop(context);
          },
        ),
        title: Text('Shop: quantity item $_quantityShopItem'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _shopItems.length,
              itemBuilder: (context, index) => Card(
                color: selectedIndex == index
                    ? Colors.green[200]
                    : Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      _quantityShopItem = _shopItems.length;
                    });
                  },
                  title: Text('Name: ${_shopItems[index]['name']}'),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description: ${_shopItems[index]['description']}'),
                      Text('Image link: ${_shopItems[index]['image']}'),
                      Text('Price: ${_shopItems[index]['price']}'),
                    ],
                  ),
                  trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      onPressed: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        _itemAddToCart(selectedIndex!);
                      }),
                ),
              ),
            ),
    );
  }
}
