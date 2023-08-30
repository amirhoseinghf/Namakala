import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //   'https://dkstatics-public.digikala.com/digikala-products/42469004ed27e91887d00f3109fc8b0e06d5c2c5_1604320545.jpg?x-oss-process=image/resize,m_lfit,h_800,w_800/quality,q_90',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //   'https://dkstatics-public.digikala.com/digikala-products/b5e2e6160722bf650136357a42e6e702a886f2cd_1659614348.jpg?x-oss-process=image/resize,m_lfit,h_800,w_800/format,webp/quality,q_90',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //   'https://files.aassttiinn.com/aassttiinn-website-main/aassttiinn-fashion-zad_637905255685811101.jpeg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //   'https://dkstatics-public.digikala.com/digikala-products/3645365.jpg?x-oss-process=image/resize,m_lfit,h_800,w_800/quality,q_90',
    // ),
  ];

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if(_showFavoritesOnly) {
    // return _items.where((prod) => prod.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final String filter = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse('https://namakala-flutter-learning-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken&$filter');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      url = Uri.parse("https://namakala-flutter-learning-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken");
      final favoritesResponse = await http.get(url);
      final favoriteData = json.decode(favoritesResponse.body);
      final List<Product> list = [];
      if(extractedData.isEmpty) return;
      extractedData.forEach((prodId, prodData) {
        list.add(Product(
          id: prodId,
          title: prodData['title'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          description: prodData['description'],
          isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
        _items = list;
        notifyListeners();
      });

    } catch (error) {
      throw (error);
    }

  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse("https://namakala-flutter-learning-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken");
    try {
      final response = await http.post(url, body: json.encode({
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'isFavorite': product.isFavorite,
        'creatorId': userId,
      }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
      );
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }

    notifyListeners();
  }



  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    final url = Uri.parse("https://namakala-flutter-learning-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken");
    await http.patch(url, body: json.encode({
      'title': newProduct.title,
      'price': newProduct.price,
      'imageUrl': newProduct.imageUrl,
      'description': newProduct.description,
    }));
    _items[prodIndex] = newProduct;
    notifyListeners();
  }

  void removeProduct(String id) async {
    final url = Uri.parse("https://namakala-flutter-learning-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken");
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    await http.delete(url).then((response) {
      if(response.statusCode >= 400) {
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw HttpException(response.statusCode.toString() + " - Removing products failed!");
      }
      existingProduct = null;
      notifyListeners();
    });
  }

// void showFavoritesOnly() {
//   _showFavoritesOnly = true;
//   notifyListeners();
// }
//
// void showAll() {
//   _showFavoritesOnly = false;
//   notifyListeners();
}
