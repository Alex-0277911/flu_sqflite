import 'package:flutter/material.dart';
import 'global_var.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLITE database: user ID: ${globals.activeUserId}'),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, '/userPage');
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cartPage');
              },
              child: const Text('<--- CART page --->')),
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/shopHistory');
              },
              child: const Text('<--- HISTORY page --->')),
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/shopPageAdmin');
              },
              child: const Text('<--- SHOP ADMIN page --->')),
          Center(
            child: globals.activeUserId == 0
                ? const Text('Select active user')
                : TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/shopPage');
                    },
                    child: const Text('<--- SHOP page --->'),
                  ),
          )
        ],
      ),
    );
  }
}
