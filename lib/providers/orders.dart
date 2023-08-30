import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        "https://namakala-flutter-learning-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken");
    final response = await http.get(url);
    List<OrderItem> loadedList = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if(extractedData == null) return;
      extractedData.forEach((orderId, orderData) {
        loadedList.add(OrderItem(
            id: orderId,
            amount: orderData['amount'],
            products: (orderData['products'] as List<dynamic>)
                .map((item) =>
                CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price']))
                .toList(),
            dateTime: DateTime.parse(orderData['dateTime'])));
      });
      _orders = loadedList.reversed.toList();
      notifyListeners();

  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        "https://namakala-flutter-learning-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken");
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((ci) => {
                    'id': ci.id,
                    'title': ci.title,
                    'price': ci.price,
                    'quantity': ci.quantity
                  })
              .toList(),
        }));

    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timeStamp));

    notifyListeners();
  }
}
