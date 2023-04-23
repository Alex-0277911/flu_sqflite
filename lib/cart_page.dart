import 'package:flutter/material.dart';
import 'sqlhelper.dart';
import 'global_var.dart' as globals;

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Всі журнали
  final List<Map<String, dynamic>> _cartItems = [];

  // дані з кошика у вигляді списку товарів
  List<CartItem> _cartItemsList = [];
  bool _isLoading = true;

  // змінна в якій зберігаємо кількість одиниць товарів
  int _quantityCartItem = 0;
  double _totalCostCart = 0.0;

  // індекс вибраного елемента списку
  int? selectedIndex;

// ------------------CART

  void _editQuantityItem(int? id) async {
    double currentQuantity = _cartItemsList[id!].quantity!;
    int currentItemId = _cartItemsList[id].id!;

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          // це не дозволить клавіатурі перекривати текстові поля
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Text('Editing quantity item'),
            ),
            TextField(
              controller: _quantityController,
              decoration:
                  InputDecoration(hintText: 'Old q-ty: $currentQuantity'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                currentQuantity = double.tryParse(_quantityController.text)!;

                // оновлення кошика після зміни кількості товару
                _itemUpdateQuantityCartItem(
                  id,
                  currentItemId,
                  currentQuantity,
                );
                // Очистити текстові поля
                _quantityController.text = '';
                // Close the bottom sheet
                Navigator.of(context).pop();
              },
              child: const Text('Update quantity item'),
            )
          ],
        ),
      ),
    );
  }

// -------------------CART

  // Ця функція використовується для отримання всіх даних з бази даних
  void _refreshCart() async {
    final data = await SQLHelper.getCartItems();

    // видаляємо записи якщо вони не належать поточному користувачу
    data.removeWhere((element) => element.userId != globals.activeUserId);

    // сума всіх покупок в кошику
    _totalCostCart = 0.0;
    for (int i = 0; i < data.length; i++) {
      _totalCostCart +=
          (data[i].price! * data[i].quantity!); // Додавання елемента до суми
      String totalCost = (_totalCostCart).toStringAsFixed(2);
      _totalCostCart = double.tryParse(totalCost)!;
    }

    setState(() {
      _cartItemsList = data;
      _isLoading = false;
      // кількість товарів у кошику
      if (_cartItemsList.isEmpty) {
        _quantityCartItem = 0;
      } else {
        _quantityCartItem = _cartItemsList.length;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshCart(); // Завантаження списку товарів під час запуску програми
    selectedIndex = 0;
  }

  final TextEditingController _quantityController = TextEditingController();

//----------------UPDATE CART ITEM
  Future<void> _itemUpdateQuantityCartItem(
      int id, int idItem, double quantity) async {
    await SQLHelper.updateCartItem(
      // int id
      idItem,
      // int userId
      globals.activeUserId,
      // int productId
      _cartItemsList[id].productId!,
      // double? price
      _cartItemsList[id].price,
      // int? quantity
      quantity, // quantity
      //  String? statusCart
      _cartItemsList[id].statusCart, // order status
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Змінена кількість товару ${_cartItemsList[id].productId!} в кошику'),
    ));
    _refreshCart();
  }
// ---------------UPDATE CART ITEM

  // clear cart (deleting element from database)
  Future<void> _clearCart() async {
    for (var element in _cartItemsList) {
      await SQLHelper.removeFromCart(element.id!);
      _refreshCart();
    }
  }

  // add cart to order (transfer cart to hystory list)
  Future<void> _addCartToOrder() async {
    String orderDescription = '';
    for (var element in _cartItemsList) {
      orderDescription +=
          'id: ${element.id} product_id: ${element.productId} price: ${element.price} quantity: ${element.quantity} ';
    }
    SQLHelper.createItemHistory(
      globals.activeUserId,
      orderDescription,
      _totalCostCart,
    );
    //
    _clearCart();
    _refreshCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart user ${globals.activeUserId}'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Cart',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          // ----------------------
          // button Place an order
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _addCartToOrder();
                },
                child: const Text('Place an order'),
              ),
              const SizedBox(width: 10),
              // button Clear cart
              ElevatedButton(
                onPressed: () {
                  _clearCart();
                },
                child: const Text('Clear cart'),
              ),
            ],
          ),

          // ----------------------
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _cartItemsList.length,
                    itemBuilder: (context, index) => Card(
                      color: selectedIndex == index
                          ? Colors.green[200]
                          : Colors.orange[200],
                      margin: const EdgeInsets.all(5),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            _quantityCartItem = _cartItems.length;
                          });
                        },
                        title: Text('ID: ${_cartItemsList[index].id}'),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'productId: ${_cartItemsList[index].productId}'),
                            Text('userId: ${_cartItemsList[index].userId}'),
                            Text('price: ${_cartItemsList[index].price}'),
                            Text(
                                'statusCart: ${_cartItemsList[index].statusCart}'),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 150,
                          child: Row(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      _editQuantityItem(index);
                                    },
                                    child: Text(
                                      'Q-ty: ${_cartItemsList[index].quantity}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                  icon: const Icon(
                                      Icons.remove_shopping_cart_outlined),
                                  onPressed: () {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                    SQLHelper.removeFromCart(
                                        _cartItemsList[index].id!);
                                    _refreshCart();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Товар ${_cartItemsList[index].id} видалено з кошика'),
                                    ));
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          // ----------------------
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Quantity items: $_quantityCartItem'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total cost: $_totalCostCart.',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
