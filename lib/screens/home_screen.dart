import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:productos_app/models/models.dart';
import 'package:productos_app/screens/screens.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/widgets/widgets.dart';


class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    final productsServices = Provider.of<ProductsService>(context);

    if (productsServices.isLoading) return LoadingScreen();

    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
      ),
      body: RefreshIndicator(
        onRefresh: productsServices.loadProducts,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: productsServices.products.length,
          itemBuilder: ( BuildContext context, int index ) => GestureDetector(
            child: ProductCard(product: productsServices.products[index]),
            onTap: () {
              productsServices.selectedProduct = productsServices.products[index].copy();
              Navigator.pushNamed(context, 'product');
            }
          ) 
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          productsServices.selectedProduct = new Product(available: false, name: '', price: 0);
          Navigator.pushNamed(context, 'product');
        }
      ),
    );
  }
}