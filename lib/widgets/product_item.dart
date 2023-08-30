import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatefulWidget {
  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {

  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    var scaffold = ScaffoldMessenger.of(context);

    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: GridTile(
        child: GestureDetector(
            onTap: () => Navigator.pushNamed(
                  context,
                  ProductDetailScreen.routeName,
                  arguments: product.id,
                ),
            child: Hero(
                tag: product.id,
                child: FadeInImage(placeholder: AssetImage('assets/images/products_placeholder.png'), image: NetworkImage(product.imageUrl), fit: BoxFit.cover,)),),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              icon: isLoading ? Container(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,)) : Icon(product.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border_rounded),
              onPressed: () async {
                try {
                  setState(() {
                    isLoading = true;
                  });
                  await product.toggleFavoriteStatus(authData.token, authData.userId);
                  setState(() {
                    isLoading = false;
                  });
                } catch (error) {
                  print("Error occurred");
                  scaffold.showSnackBar(SnackBar(
                      content: Text(
                          error.toString())));
                  setState(() {
                    isLoading = false;
                  });
                }
              },
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Added item to cart!"),
                action: SnackBarAction(
                  label: "UNDO",
                  onPressed: () {
                    cart.removeSingleItem(product.id);
                  },
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}
