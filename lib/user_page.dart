import 'package:flutter/material.dart';

import 'home_page.dart';
import 'sqlhelper.dart';
import 'global_var.dart' as globals;

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // Всі журнали
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;

  // змінна в якій зберігаємо id активного користувача
  // int _activeUserId = 0;
  // Ця функція використовується для отримання всіх даних з бази даних
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
      if (_journals.isEmpty) {
        globals.activeUserId = -1;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Завантаження щоденника під час запуску програми
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Ця функція спрацьовує при натисканні плаваючої кнопки
  // Вона також спрацьовує, коли ви хочете оновити елемент
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
      _descriptionController.text = existingJournal['description'];
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
                    child: Text(id == null ? 'Create New User' : 'Update User'),
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

                      // Close the bottom sheet
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

// Додавання нового запису до бази даних
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _nameController.text, _descriptionController.text);
    _refreshJournals();
  }

  // Оновлення існуючого запису
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _nameController.text, _descriptionController.text);
    _refreshJournals();
  }

  // Видалити елемент
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Успішно видалено запис!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Action for back button
            // Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),
        title: Text('Active user ID: ${globals.activeUserId}'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                color: (_journals[index]['id'] == globals.activeUserId
                    ? Colors.green[200]
                    : Colors.orange[200]),
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    onTap: () {
                      setState(() {
                        globals.activeUserId = _journals[index]['id'];
                      });
                    },
                    title: Text(_journals[index]['name']),
                    subtitle: Text(_journals[index]['description']),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_journals[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteItem(_journals[index]['id']),
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
