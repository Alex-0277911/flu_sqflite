import 'package:flutter/material.dart';

import 'sqlhelper.dart';

class ShopPageAdmin extends StatefulWidget {
  const ShopPageAdmin({Key? key}) : super(key: key);

  @override
  State<ShopPageAdmin> createState() => _ShopPageAdminState();
}

class _ShopPageAdminState extends State<ShopPageAdmin> {
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
        _quantityShopItem = -1;
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageItemController = TextEditingController();
  final TextEditingController _priceItemController = TextEditingController();

  // Ця функція спрацьовує при натисканні плаваючої кнопки
  // Вона також спрацьовує, коли ви хочете оновити елемент
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _shopItems.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
      _descriptionController.text = existingJournal['description'];
      _imageItemController.text = existingJournal['image'];
      _priceItemController.text = existingJournal['price'].toString();
    }

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
            Center(
              child: Text(id == null ? 'Create New Item' : 'Update Item'),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            TextField(
              controller: _imageItemController,
              decoration: const InputDecoration(hintText: 'Image'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _priceItemController,
              decoration: const InputDecoration(hintText: 'Price'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                // Зберегти новий журнал
                if (id == null) {
                  await _addItem();
                }

                if (id != null) {
                  await _updateItem(id);
                }

                // Очистити текстові поля
                _nameController.text = '';
                _descriptionController.text = '';
                _imageItemController.text = '';
                _priceItemController.text = '';

                // Close the bottom sheet
                if (!mounted) return;
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Create New Item' : 'Update Item'),
            )
          ],
        ),
      ),
    );
  }

// Додавання нового запису до бази даних
  Future<void> _addItem() async {
    await SQLHelper.createShopItem(
      _nameController.text,
      _descriptionController.text,
      _imageItemController.text,
      double.tryParse(_priceItemController.text),
    );
    _refreshItems();
  }

  // Оновлення існуючого запису
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateShopItem(
      id,
      _nameController.text,
      _descriptionController.text,
      _imageItemController.text,
      double.tryParse(_priceItemController.text),
    );
    _refreshItems();
  }

  // Видалити елемент
  void _deleteItem(int id) async {
    await SQLHelper.deleteShopItem(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Успішно видалено запис!'),
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
        title: Text('Shop admin: quantity item $_quantityShopItem'),
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
                        Text(
                            'Description: ${_shopItems[index]['description']}'),
                        Text('Image link: ${_shopItems[index]['image']}'),
                        Text('Price: ${_shopItems[index]['price']}'),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_shopItems[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteItem(_shopItems[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
