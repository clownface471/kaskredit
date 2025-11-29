import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/features/products/presentation/controllers/product_controller.dart';
import 'package:kaskredit_1/shared/models/product.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key}); // HAPUS parameter product

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _capitalPriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _categoryController;

  // Get product from arguments
  late final Product product;

  @override
  void initState() {
    super.initState();
    
    // Get argument menggunakan GetX
    product = Get.arguments as Product;
    
    _nameController = TextEditingController(text: product.name);
    _capitalPriceController = TextEditingController(
      text: product.capitalPrice.toStringAsFixed(0),
    );
    _sellingPriceController = TextEditingController(
      text: product.sellingPrice.toStringAsFixed(0),
    );
    _stockController = TextEditingController(text: product.stock.toString());
    _categoryController = TextEditingController(text: product.category);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capitalPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<ProductController>();
    
    final updatedProduct = product.copyWith(
      name: _nameController.text,
      capitalPrice: double.tryParse(_capitalPriceController.text) ?? 0.0,
      sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
      stock: int.tryParse(_stockController.text) ?? 0,
      category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
      updatedAt: DateTime.now(),
    );

    await controller.updateProduct(updatedProduct);
  }

  Future<void> _delete() async {
    final controller = Get.find<ProductController>();
    await controller.deleteProduct(product.id!);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Produk"),
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _update,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: _delete,
                ),
              ],
            );
          }),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama Produk",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? "Nama produk tidak boleh kosong"
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: "Kategori (Opsional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capitalPriceController,
              decoration: const InputDecoration(
                labelText: "Harga Modal",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money_off),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => (value == null || value.isEmpty)
                  ? "Harga modal tidak boleh kosong"
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sellingPriceController,
              decoration: const InputDecoration(
                labelText: "Harga Jual",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => (value == null || value.isEmpty)
                  ? "Harga jual tidak boleh kosong"
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: "Jumlah Stok Awal",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => (value == null || value.isEmpty)
                  ? "Stok tidak boleh kosong"
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}