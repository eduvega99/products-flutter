import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:productos_app/interfaces/input_decorations.dart';
import 'package:productos_app/models/models.dart';
import 'package:productos_app/providers/product_form_provider.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/widgets/widgets.dart';


class ProductScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final productsService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
      create: ( _ ) => ProductFormProvider(productsService.selectedProduct),
      child: _ProductsScreenBody(productsService: productsService),
    );
  }
}

class _ProductsScreenBody extends StatelessWidget {
  const _ProductsScreenBody({
    Key? key,
    required this.productsService,
  }) : super(key: key);

  final ProductsService productsService;

  @override
  Widget build(BuildContext context) {
    final productsFormProvider = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [

            Stack(
              children: [
                ProductImage(urlImage: productsService.selectedProduct.picture),
                Positioned(
                  top: 60,
                  left: 20,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 40,),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ),

                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 40,),
                    onPressed: () async {
                      
                      final picker = new ImagePicker();
                      final XFile? pickedFile = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 100
                      );

                      if(pickedFile != null) {
                        productsService.updateSelectedProductImage(pickedFile.path);
                      }
                    },
                  )
                )

              ],
            ),

            _ProductForm(),

            SizedBox(height: 100)

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: productsService.isSaving
          ? CircularProgressIndicator(color: Colors.white)
          : Icon(Icons.save_outlined),

        onPressed: productsService.isSaving
          ? null
          : () async {

          if (!productsFormProvider.isValidForm()) return;
          
          final String? imageUrl = await productsService.uploadImage();

          if (imageUrl != null) productsFormProvider.product.picture = imageUrl;

          productsService.saveOrCreateProduct(productsFormProvider.product); 
          
        },
      ),
    );
  }
}

class _ProductForm extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    final productFormProvider = Provider.of<ProductFormProvider>(context);
    final product = productFormProvider.product;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: _buildBoxDecoration(),
        child: Form(
          key: productFormProvider.formKey,
          child: Column(
            children: [
              SizedBox(height: 10,),

              TextFormField(
                initialValue: product.name,
                decoration: InputDecorations.authInputDecoration(
                  hintText: 'Nombre producto', 
                  labelText: 'Nombre'
                ),
                onChanged: (value) =>  product.name = value,
                validator: (value) {
                  if (value == null || value.length < 1) {
                    return 'El nombre del producto es obligatorio';
                  }
                },
              ),

              SizedBox(height: 20),

              TextFormField(
                initialValue: product.price.toString(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
                ],
                keyboardType: TextInputType.number,
                decoration: InputDecorations.authInputDecoration(
                  hintText: '50 €', 
                  labelText: 'Precio'
                ),
                onChanged: (value) => product.price = double.tryParse(value) == null ? 0 : double.parse(value)    
              ),

              SizedBox(height: 30),

              SwitchListTile.adaptive(
                value: product.available, 
                title: Text('Disponible'),
                activeColor: Colors.indigo,
                onChanged: productFormProvider.updateAvailability
              )
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: Offset(0, 5),
          blurRadius: 5
        )
      ]
    );
  }
}