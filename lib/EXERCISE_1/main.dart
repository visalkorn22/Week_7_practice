import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// REPOS
abstract class PancakeRepository {
  Future<Pancake> addPancake({required String color, required double price});
  Future<List<Pancake>> getPancakes();
  Future<void> updatePancake(String id, String color, double price);
  Future<void> deletePancake(String id);
}

class FirebasePancakeRepository extends PancakeRepository {
  static const String baseUrl =
      'https://g2-first-project-default-rtdb.asia-southeast1.firebasedatabase.app';
  static const String pancakesCollection = "pancakes";
  static const String allPancakesUrl = '$baseUrl/$pancakesCollection.json';

  @override
  Future<Pancake> addPancake(
      {required String color, required double price}) async {
    Uri uri = Uri.parse(allPancakesUrl);
    final newPancakeData = {'color': color, 'price': price};
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newPancakeData),
    );

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to add pancake');
    }

    final newId = json.decode(response.body)['name'];
    return Pancake(id: newId, color: color, price: price);
  }

  @override
  Future<List<Pancake>> getPancakes() async {
    Uri uri = Uri.parse(allPancakesUrl);
    final response = await http.get(uri);
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to load');
    }
    final data = json.decode(response.body) as Map<String, dynamic>?;
    if (data == null) return [];
    return data.entries
        .map((entry) => PancakeDto.fromJson(entry.key, entry.value))
        .toList();
  }

  @override
  Future<void> updatePancake(String id, String color, double price) async {
    Uri uri = Uri.parse('$baseUrl/$pancakesCollection/$id.json');
    final updatedData = {'color': color, 'price': price};
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to update pancake');
    }
  }

  @override
  Future<void> deletePancake(String id) async {
    Uri uri = Uri.parse('$baseUrl/$pancakesCollection/$id.json');
    final response = await http.delete(uri);
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to delete pancake');
    }
  }
}

class PancakeProvider extends ChangeNotifier {
  final PancakeRepository _repository;
  List<Pancake> _pancakes = [];

  PancakeProvider(this._repository) {
    fetchPancakes();
  }

  List<Pancake> get pancakes => _pancakes;

  Future<void> fetchPancakes() async {
    _pancakes = await _repository.getPancakes();
    notifyListeners();
  }

  void addPancake(String color, double price) async {
    final newPancake = Pancake(id: "temp", color: color, price: price);
    _pancakes.add(newPancake);
    notifyListeners();
    try {
      final addedPancake =
          await _repository.addPancake(color: color, price: price);
      _pancakes[_pancakes.indexOf(newPancake)] = addedPancake;
    } catch (e) {
      _pancakes.remove(newPancake);
    }
    notifyListeners();
  }

  void updatePancake(String id, String color, double price) async {
    final index = _pancakes.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final oldPancake = _pancakes[index];
    _pancakes[index] = Pancake(id: id, color: color, price: price);
    notifyListeners();
    try {
      await _repository.updatePancake(id, color, price);
    } catch (e) {
      _pancakes[index] = oldPancake;
    }
    notifyListeners();
  }

  void deletePancake(String id) async {
    final pancakeToRemove = _pancakes.firstWhere((p) => p.id == id);
    _pancakes.remove(pancakeToRemove);
    notifyListeners();
    try {
      await _repository.deletePancake(id);
    } catch (e) {
      _pancakes.add(pancakeToRemove);
    }
    notifyListeners();
  }
}

void main() {
  final PancakeRepository pancakeRepository = FirebasePancakeRepository();
  runApp(
    ChangeNotifierProvider(
      create: (context) => PancakeProvider(pancakeRepository),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: PancakeApp()),
    ),
  );
}

class PancakeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PancakeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Pancakes"), actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => provider.addPancake("Blue", 4.5),
        ),
      ]),
      body: ListView.builder(
        itemCount: provider.pancakes.length,
        itemBuilder: (context, index) {
          final pancake = provider.pancakes[index];
          return ListTile(
            title: Text(pancake.color),
            subtitle: Text("Price: 7.0"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      provider.updatePancake(pancake.id, "Red", 5.0),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deletePancake(pancake.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Pancake {
  final String id;
  final String color;
  final double price;

  Pancake({required this.id, required this.color, required this.price});
}

class PancakeDto {
  static Pancake fromJson(String id, Map<String, dynamic> json) =>
      Pancake(id: id, color: json['color'], price: json['price']);
}
