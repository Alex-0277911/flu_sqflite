import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

// Модель даних для елементів кошика
class CartItem {
  int? id;
  int? userId;
  int? productId;
  double? price;
  double? quantity;
  String? statusCart;

  CartItem({
    this.id,
    this.userId,
    this.productId,
    this.price,
    this.quantity,
    this.statusCart,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'price': price,
      'quantity': quantity,
      'status_cart': statusCart,
    };
  }
}
//

// Модель даних для елементів кошика
class HistoryItem {
  int? id;
  int? userId;
  String? orderDescription;
  double? totalCost;

  HistoryItem({
    this.id,
    this.userId,
    this.orderDescription,
    this.totalCost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'order_description': orderDescription,
      'total_cost': totalCost,
    };
  }
}
//

class SQLHelper {
  // метод створення таблиці БД USER
  static Future<void> createTablesUser(sql.Database database) async {
    await database.execute("""CREATE TABLE user(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }
// id: ідентифікатор користувача
// name, description: назву та опис (додаткові дані) користувача
// created_at: час створення елемента. Це буде автоматично оброблено SQLite

  // метод створення таблиці БД SHOP
  static Future<void> createTablesShop(sql.Database database) async {
    await database.execute("""CREATE TABLE shop(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        description TEXT,
        image TEXT,
        price REAL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  // метод створення таблиці БД USER
  static Future<void> createTablesCart(sql.Database database) async {
    await database.execute("""CREATE TABLE cart(
                id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                user_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                price REAL,
                quantity REAL,
                status_cart TEXT
                )
          """);
  }

  // FOREIGN KEY (user_id) REFERENCES user (id)
  // FOREIGN KEY (product_ID) REFERENCES shop (id)

  // метод створення таблиці БД HISTORY
  static Future<void> createTablesHistory(sql.Database database) async {
    await database.execute("""CREATE TABLE history(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        user_id INTEGER NOT NULL,
        order_description TEXT,
        total_cost REAL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  // ---------------------- HISTORY
  // метод створює новий елемент (запис журналу)
  // метод повертає id створеного елементу
  static Future<int> createItemHistory(
    int userId,
    String? orderDescription,
    double? totalCost,
  ) async {
    final db = await SQLHelper.db();

    final data = {
      'user_id': userId,
      'order_description': orderDescription,
      'total_cost': totalCost,
    };
    final id = await db.insert('history', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

// читати всі дані (записи журналу)
  // static Future<List<Map<String, dynamic>>> getItemsHistory() async {
  //   final db = await SQLHelper.db();
  //   return db.query('history', orderBy: "id");
  // }

  // ---------------------
// Отримання списку елементів кошика з бази даних
  static Future<List<HistoryItem>> getItemsHistory() async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.query('history');

    return List.generate(
      maps.length,
      (index) => HistoryItem(
        id: maps[index]['id'],
        userId: maps[index]['user_id'],
        orderDescription: maps[index]['order_description'],
        totalCost: maps[index]['total_cost'],
      ),
    );
  }
  //
// ---------------------

  // Зчитати один елемент за ідентифікатором

  static Future<List<Map<String, dynamic>>> getItemHistory(int id) async {
    final db = await SQLHelper.db();
    return db.query('history', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Оновлення елемента за ідентифікатором
  static Future<int> updateItemHistory(
    int id,
    int userId,
    String? orderDescription,
    String? orderStatus,
  ) async {
    final db = await SQLHelper.db();

    final data = {
      'user_id': userId,
      'order_description': orderDescription,
      'order_status': orderStatus,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('history', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItemHistory(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("history", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      // debugPrint("Something went wrong when deleting an user: $err");
      debugPrint("Щось пішло не так при видаленні даних з історії: $err");
    }
  }
// ---------------------- HISTORY

// метод відкриває існуючу БД або створює нову
// також метод створює нову або відкриває існуючу БД
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'dbsqlite.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTablesUser(database);
        await createTablesShop(database);
        await createTablesCart(database);
        await createTablesHistory(database);
      },
    );
  }

  // метод створює новий елемент (запис журналу)
  // метод повертає id створеного елементу
  static Future<int> createItem(String name, String? descrption) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'description': descrption,
    };
    final id = await db.insert('user', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // читати всі дані (записи журналу)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('user', orderBy: "id");
  }

  // Зчитати один елемент за ідентифікатором

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('user', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Оновлення елемента за ідентифікатором
  static Future<int> updateItem(int id, String name, String? descrption) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'description': descrption,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('user', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("user", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      // debugPrint("Something went wrong when deleting an user: $err");
      debugPrint("Щось пішло не так при видаленні користувача: $err");
    }
  }

// -------------------------

  // метод створює новий елемент (запис журналу)
  // метод повертає id створеного елементу
  static Future<int> createShopItem(
      String name, String? description, String? image, double? price) async {
    final dbShop = await SQLHelper.db();

    final data = {
      'name': name,
      'description': description,
      'image': image,
      'price': price,
    };
    final id = await dbShop.insert('shop', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // читати всі дані з таблиці магазин
  static Future<List<Map<String, dynamic>>> getShopItems() async {
    final db = await SQLHelper.db();
    return db.query('shop', orderBy: 'id');
  }

  // Зчитати один елемент за ідентифікатором з таблиці магазин

  static Future<List<Map<String, dynamic>>> getShopItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('shop', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Оновлення елемента за ідентифікатором з таблиці магазин
  static Future<int> updateShopItem(int id, String name, String? description,
      String? image, double? price) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'description': description,
      'image': image,
      'price': price.toString(),
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('shop', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete з таблиці магазин
  static Future<void> deleteShopItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("shop", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      // debugPrint("Something went wrong when deleting an user: $err");
      debugPrint("Щось пішло не так при видаленні товару: $err");
    }
  }

// ------------------------------ cart

  // Додавання елемента кошика до бази даних
  // метод повертає id доданого елементу
  static Future<int> addToCart(
    int userId,
    int productId,
    double? price,
    int? quantity,
    String? statusCart,
  ) async {
    final db = await SQLHelper.db();

    final data = {
      'user_id': userId,
      'product_id': productId,
      'price': price,
      'quantity': quantity,
      'status_cart': statusCart,
    };

    final id = await db.insert('cart', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Оновлення елемента за ідентифікатором з таблиці cart
  static Future<int> updateCartItem(
    int id,
    int userId,
    int productId,
    double? price,
    double? quantity,
    String? statusCart,
  ) async {
    final db = await SQLHelper.db();

    final data = {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'price': price,
      'quantity': quantity,
      'status_cart': statusCart,
    };

    final result =
        await db.update('cart', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Отримання списку елементів кошика з бази даних
  static Future<List<CartItem>> getCartItems() async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> maps = await db.query('cart');

    return List.generate(
      maps.length,
      (index) => CartItem(
        id: maps[index]['id'],
        userId: maps[index]['user_id'],
        productId: maps[index]['product_id'],
        price: maps[index]['price'],
        quantity: maps[index]['quantity'],
        statusCart: maps[index]['status_cart'],
      ),
    );
  }
  //

  // Видалення елемента з кошика з бази даних
  static Future<void> removeFromCart(int itemId) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('cart', where: 'id = ?', whereArgs: [itemId]);
    } catch (err) {
      // debugPrint("Something went wrong when deleting an user: $err");
      debugPrint("Щось пішло не так при видаленні товару: $err");
    }
  }
  //

  // Закриття бази даних
  static Future<void> closeDatabase() async {
    final db = await SQLHelper.db();
    await db.close();
  }
  //
}
