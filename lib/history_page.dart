import 'package:flutter/material.dart';
import 'sqlhelper.dart';
import 'global_var.dart' as globals;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Всі журнали
  List<HistoryItem> _historyItems = [];

  bool _isLoading = true;

  // змінна в якій зберігаємо кількість одиниць товарів
  int _quantityHistoryItem = 0;

  // індекс вибраного елемента списку
  int? selectedIndex;

  // Ця функція використовується для отримання всіх даних з бази даних
  void _refreshHistory() async {
    List<HistoryItem> data = await SQLHelper.getItemsHistory();

    // видаляємо записи якщо вони не належать поточному користувачу
    data.removeWhere((element) => element.userId != globals.activeUserId);

    setState(() {
      _historyItems = data;
      _isLoading = false;
      // кількість товарів у кошику
      if (_historyItems.isEmpty) {
        _quantityHistoryItem = 0;
      } else {
        _quantityHistoryItem = _historyItems.length;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshHistory(); // Завантаження списку товарів під час запуску програми
    selectedIndex = 0;
  }

  // final TextEditingController _quantityController = TextEditingController();

  // clear cart (deleting element from database)
  Future<void> _clearHistory() async {
    for (var element in _historyItems) {
      await SQLHelper.deleteItemHistory(element.id!);
      _refreshHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History user ${globals.activeUserId}'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'History',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          // ----------------------
          // button Create a report
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  //
                },
                child: const Text('Create a report'),
              ),
              const SizedBox(width: 10),
              // button Clear cart
              ElevatedButton(
                onPressed: () {
                  _clearHistory();
                },
                child: const Text('Clear history'),
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
                    itemCount: _historyItems.length,
                    itemBuilder: (context, index) => Card(
                      color: selectedIndex == index
                          ? Colors.green[200]
                          : Colors.orange[200],
                      margin: const EdgeInsets.all(5),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            _quantityHistoryItem = _historyItems.length;
                          });
                        },
                        title: Text('ID: ${_historyItems[index].id}'),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('userId: ${_historyItems[index].userId}'),
                            Text(
                                'order_description: ${_historyItems[index].orderDescription}'),
                            Text(
                                'total_cost: ${_historyItems[index].totalCost}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          // ----------------------
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Quantity history list items: $_quantityHistoryItem',
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
