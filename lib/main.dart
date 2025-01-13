


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'custom_image_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
// );
  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cafe Ordering System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MenuScreen(),
    );
  }
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}



class _MenuScreenState extends State<MenuScreen> {
  final String googleScriptUrl = "https://script.google.com/macros/s/AKfycbyP8JO7o-71084AHpanyVkdsVCT7zJCfTmVz8eXuxcAFEL_jj36WTDEk_iVomuVAZhBAA/exec";
  List<Map<String, dynamic>> menu = [];
  Map<String, int> cart = {}; 
  String tableNumber = "Unknown";
  String searchQuery = "";
   bool _loading = false;

  
  @override
  void initState() {
    super.initState();
    fetchMenu();
    fetchTableNumber();
  }

  void fetchTableNumber() {
    // final uri = Uri.base;
    setState(() {
      tableNumber = '1';
      // uri.queryParameters['table'] ?? "Unknown";
    });
  }

 
  Future<void> fetchMenu() async {
  final response = await http.get(Uri.parse("$googleScriptUrl?action=getMenu"));
  if (response.statusCode == 200) {
    try {
      final data = json.decode(response.body);
      if (data is List) {
        setState(() {
          menu = List<Map<String, dynamic>>.from(data);
        });
      } else if (data is Map && data.containsKey('error')) {
        debugPrint("Error from script: ${data['error']}");
      } else {
        debugPrint("Invalid data format: ${data}");
      }
    } catch (e) {
      debugPrint("Error decoding JSON: $e");
      debugPrint("Response body: ${response.body}");
    }
  } else {
    debugPrint("Failed to load menu: ${response.body}");
  }
  }
   void addToCart(String itemId) {
    setState(() {
      cart[itemId] = (cart[itemId] ?? 0) + 1;
    });
  }

  void removeFromCart(String itemId) {
    setState(() {
      if (cart.containsKey(itemId) && cart[itemId]! > 0) {
        cart[itemId] = cart[itemId]! - 1;
        if (cart[itemId] == 0) {
          cart.remove(itemId);
        }
      }
    });
  }


    Future<void> placeOrder() async {
    try {
      setState(() {
        _loading = true;
      });

      final orderDetails = cart.entries.map((entry) {
        try {
          final itemId = entry.key.toString();
          final item = menu.firstWhere(
            (element) => element['id'].toString() == itemId,
            orElse: () => throw Exception('Item not found: $itemId'),
          );
         
          return "${entry.value}x ${item['name']}\n";
        } catch (e) {
          debugPrint('Error processing item ${entry.key}: $e');
          return "Unknown Item x${entry.value}";
        }
      }).join("");

      if (orderDetails.isEmpty) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cart is empty!")),
        );
        return;
      }

      debugPrint("Order details: $orderDetails");
       final total = cart.entries.fold<double>(
                    0,
                    (sum, entry) {
                      final item = menu.firstWhere((i) => i['id'].toString() == entry.key);
                      final price = double.tryParse(item['price'].toString()) ?? 0.0;
                      return sum + (price * entry.value);
                    },
                  );
      final response = await http.get(Uri.parse(
        "$googleScriptUrl?action=placeOrder&table=$tableNumber&order=$orderDetails&amount=$total"));
         debugPrint("Order details: ADDEDDDD");
         debugPrint("Order details: ${response.statusCode}");

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
         setState(() {
        _loading = false;
      });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order placed successfully!")),
        );
        setState(() {
          cart.clear();
        });
      } else {
        throw Exception('Failed to place order: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMenu = menu.where((item) {
      return item['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Table $tableNumber'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: Colors.white,

                context: context,
                builder: (context) {
                  final cartItems = cart.entries
                      .map((entry) {
                        final item = menu.firstWhere((i) => i['id'].toString() == entry.key);
                        // Convert price to double for calculation
                        final price = double.tryParse(item['price'].toString()) ?? 0.0;
                        return ListTile(
                          title: Text("${item['name']} x${entry.value}"),
                          trailing: Text("₹${(price * entry.value).toStringAsFixed(2)}"),
                        );
                      })
                      .toList();

                  final total = cart.entries.fold<double>(
                    0,
                    (sum, entry) {
                      final item = menu.firstWhere((i) => i['id'].toString() == entry.key);
                      final price = double.tryParse(item['price'].toString()) ?? 0.0;
                      return sum + (price * entry.value);
                    },
                  );

                  return Container(
                    color: Colors.white10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...cartItems,
                        const Divider(),
                        ListTile(
                          title: const Text("Total"),
                          trailing: Text("₹${total.toStringAsFixed(2)}"),
                        ),
                        ElevatedButton(
                          
                          onPressed: placeOrder,
                          child: _loading? const CircularProgressIndicator() : const Text("Place Order"),
                        ),
                        SizedBox(
                          height: 20
                        )
                      ],
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: TextField(
              
              maxLines: 1,
              decoration:  InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                labelText: "Search",
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300, width: .5)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: menu.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(18.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: filteredMenu.length,
                    itemBuilder: (context, index) {
                      final item = filteredMenu[index];
                      return Card(
                        
                        shape: Border.all(
                         
                          color: Colors.grey.shade400,
                          width: .5,
                        ),
                        elevation: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3,
                              child: CustomImageView(
                                width: double.infinity,
                                url: 
                                
                                item['image'].toString(),
                                fit: BoxFit.cover,
                                
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal:  8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'].toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("₹${item['price']}",
                                        style: const TextStyle(color: Colors.green)),
                                    Text(item['description'].toString(),
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () => removeFromCart(item['id'].toString()),
                                        ),
                                        Text(cart[item['id'].toString()]?.toString() ?? "0"),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () => addToCart(item['id'].toString()),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}











