import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      "\$${cart.totalAmount}",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: cart.itemsCount,
                itemBuilder: (ctx, i) => CartItem(
                      cart.items.values.toList()[i].id,
                      cart.items.keys.toList()[i],
                      cart.items.values.toList()[i].price,
                      cart.items.values.toList()[i].quantity,
                      cart.items.values.toList()[i].title,
                    )),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {

  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: isLoading ? Container(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 2,)) : Text(
        "ORDER NOW",
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      onPressed: (widget.cart.totalAmount <= 0 || isLoading) ? null : ()  async {
        setState(() {
          isLoading = true;
        });

        await Provider.of<Orders>(context, listen: false).addOrder(
            widget.cart.items.values.toList(), widget.cart.totalAmount);

        setState(() {
          isLoading = false;
        });

        widget.cart.clear();
      },
    );
  }
}
