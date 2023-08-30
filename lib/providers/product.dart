import 'package:flutter/foundation.dart';
import 'package:flutter_complete_guide/models/http_exception.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void toggleFavoriteStatus(String authToken, String userId)  async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse("https://namakala-flutter-learning-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$authToken");
    await http.put(url, body: json.encode(
      isFavorite,
    )).then((response) {
      print(response.statusCode);
      if (response.statusCode >= 400) {
        isFavorite = !isFavorite;
        notifyListeners();
        throw HttpException("Couldn't add to favorites");
      }
    });

  }
}
