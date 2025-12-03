import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';
import 'package:kaskredit_1/features/products/presentation/controllers/product_controller.dart';
import 'package:kaskredit_1/shared/utils/formatters.dart';
import 'package:kaskredit_1/shared/models/product.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.put(ProductController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Produk"),
        actions: [
          // Sort/Filter button
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              // TODO: Implement sorting
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 20),
                    SizedBox(width: 12),
                    Text('Urutkan Nama'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'price',
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 20),
                    SizedBox(width: 12),
                    Text('Urutkan Harga'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'stock',
                child: Row(
                  children: [
                    Icon(Icons.inventory, size: 20),
                    SizedBox(width: 12),
                    Text('Urutkan Stok'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.ADD_PRODUCT),
        icon: const Icon(Icons.add),
        label: const Text("Tambah"),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari produk...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.updateSearchQuery(''),
                  );
                }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: controller.updateSearchQuery,
            ),
          ),

          // Stats Cards
          Obx(() {
            final products = controller.products;
            final totalValue = products.fold<double>(
              0,
              (sum, p) => sum + (p.sellingPrice * p.stock),
            );
            final lowStock = products.where((p) => p.stock <= p.minStock).length;

            return Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Produk',
                      value: '${products.length}',
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Nilai Stok',
                      value: Formatters.compact(totalValue),
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Stok Rendah',
                      value: '$lowStock',
                      icon: Icons.warning,
                      color: lowStock > 0 ? Colors.red : Colors.orange,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),
          
          // Product list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = controller.filteredProducts;

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        controller.searchQuery.isEmpty
                            ? Icons.inventory_2_outlined
                            : Icons.search_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.isEmpty
                            ? "Belum ada produk"
                            : "Produk tidak ditemukan",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (controller.searchQuery.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Tambah produk untuk memulai",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  controller.loadProducts();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductCard(product: product);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stock <= product.minStock;
    final profit = product.sellingPrice - product.capitalPrice;
    final profitMargin = (profit / product.sellingPrice * 100).toStringAsFixed(0);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLowStock
            ? BorderSide(color: Colors.red.withOpacity(0.3), width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed(
            AppRoutes.EDIT_PRODUCT,
            arguments: product,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Product Icon/Image placeholder
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (product.category != null &&
                            product.category!.isNotEmpty)
                          Text(
                            product.category!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.currency(product.sellingPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        '+$profitMargin%',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Stock & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Stock indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isLowStock
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isLowStock
                            ? Colors.red.withOpacity(0.3)
                            : Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLowStock ? Icons.warning : Icons.inventory,
                          size: 14,
                          color: isLowStock ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stok: ${product.stock}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLowStock ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Quick action
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: Colors.grey[600],
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.EDIT_PRODUCT,
                        arguments: product,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}