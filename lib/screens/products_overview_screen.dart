import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';

enum FilterOptions {
  OnlyFavorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var showFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isLoading = true;
      Provider.of<Products>(context)
          .fetchAndSetProducts()
          .then((value) => {_isLoading = false});
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      key: GlobalKey(debugLabel: "SDFD"),
      appBar: AppBar(
        title: Text("Namakala"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          PopupMenuButton(
              onSelected: (FilterOptions selectedValue) {
                setState(() {
                  if (selectedValue == FilterOptions.OnlyFavorites) {
                    showFavorites = true;
                  } else {
                    showFavorites = false;
                  }
                });
              },
              icon: Icon(Icons.more_vert_rounded),
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text("Only Favorites"),
                      value: FilterOptions.OnlyFavorites,
                    ),
                    PopupMenuItem(
                      child: Text("All"),
                      value: FilterOptions.All,
                    ),
                  ]),
          Consumer<Cart>(
            builder: (ctx, cart, ch) => Baddge(
              child: ch,
              value: cart.itemsCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart_rounded),
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : ProductsGrid(showFavorites),
    );
  }
}
