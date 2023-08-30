import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit_product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: null, title: '', description: '', price: null, imageUrl: '');

  var _initialValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context).findById(productId);
        _initialValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': _editedProduct.imageUrl,
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _descriptionFocusNode.dispose();
    _priceFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    setState(() {});
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) return;
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);

    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      Icon(
                        Icons.error,
                        color: Colors.white,
                      ),
                      Text(
                        "Something went wrong",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  content: Text(
                    "That's all we know 😥",
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          "Okay",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ));
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ))
          : Padding(
              padding: EdgeInsets.all(13.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initialValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: value,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Value most not be empty";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initialValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) return "Please enter a price";
                        if (double.tryParse(value) == null)
                          return "Please enter a valid number";
                        if (double.parse(value) <= 0)
                          return "Value most be greater than zero";
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(value),
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initialValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: value,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty)
                          return "Description must not be empty";
                        if (value.length < 10)
                          return "Description must be at least 10 characters long";
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(top: 8, right: 8),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(8)),
                          child: _imageUrlController.text.isEmpty
                              ? Text("Enter a URL")
                              : Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: "Image URL"),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: value,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                            validator: (value) {
                              if (value.isEmpty)
                                return "URL must not be empty.";
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https"))
                                return "Invalid Url";
                              return null;
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
