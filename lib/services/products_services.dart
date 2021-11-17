import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:productos_app/models/models.dart';

class ProductsService extends ChangeNotifier {
  
  final String _baseURL = 'flutter-varios-de86f-default-rtdb.firebaseio.com';
  final List<Product> products = [];

  bool isSaving = false;
  bool isLoading = true;

  late Product selectedProduct;
  File? newPictureFile;

  ProductsService() {
    this.loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    this.isLoading = true;
    notifyListeners();

    final Uri url = Uri.https(_baseURL, 'products.json');
    final response = await http.get(url);
    
    final Map<String, dynamic> productsMap = json.decode(response.body);

    this.products.clear();

    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      this.products.add(tempProduct);
    });

    this.isLoading = false;
    notifyListeners();

    return this.products;
  }

  Future saveOrCreateProduct(Product product) async {

    isSaving = true;
    notifyListeners();

    if (product.id == null) {
      await this.createProduct(product);
    } else {
      await this.updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {

    final Uri url = Uri.https(_baseURL, 'products/${product.id}.json');
    final response = await http.put(url, body: product.toJson());
    final decodedData = response.body;

    final index = this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;

    return product.id!;
  }

  Future<String> createProduct(Product product) async {

    final Uri url = Uri.https(_baseURL, 'products.json');
    final response = await http.post(url, body: product.toJson());
    final decodedData = json.decode(response.body);

    product.id = decodedData['name'];

    this.products.add(product);


    return product.id!;
  }

  void updateSelectedProductImage(String path) {
    
    this.selectedProduct.picture = path;
    this.newPictureFile = File.fromUri( Uri(path: path) );

    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (this.newPictureFile == null) return null;

    this.isSaving = true;
    notifyListeners();

    final Uri url = Uri.parse('https://api.cloudinary.com/v1_1/do0sqipqk/image/upload?upload_preset=jozkbvlw');
    final imageUploadRequest = http.MultipartRequest('POST', url);
    final file = await http.MultipartFile.fromPath('file', newPictureFile!.path);
  
    imageUploadRequest.files.add(file);
    final streamResponse = await imageUploadRequest.send();

    final response = await http.Response.fromStream(streamResponse);
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      print(response.body);
    }

    this.newPictureFile = null;

    final decodedData = jsonDecode(response.body);
    return decodedData['secure_url'];
  }

}