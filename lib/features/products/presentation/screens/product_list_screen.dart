import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';
import 'package:kaskredit_1/features/products/presentation/controllers/product_controller.dart';
import 'package:kaskredit_1/shared/utils/formatters.dart';
import 'package:kaskredit_1/shared/models/product.dart';

// Enhanced dengan Filter & Sort functionality
enum ProductSortType { nameAsc, nameDesc, priceAsc, priceDesc, stockAsc, stockDesc }
enum ProductFilterType { all, lowStock, active, inactive }

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.put(ProductController());
    
    // Tambahkan reactive state untuk filter & sort
    final Rx<ProductSortType> currentSort = ProductSortType.nameAsc.obs;
    final Rx<ProductFilterType> currentFilter = ProductFilterType.all.obs;

    // Fungsi untuk sorting
    List<Product> getSortedProducts(List<Product> products) {
      final sorted = [...products];
      switch (currentSort.value) {
        case ProductSortType.nameAsc:
          sorted.sort((a, b) => a.name.compareTo(b.name));
          break;
        case ProductSortType.nameDesc:
          sorted.sort((a, b) => b.name.compareTo(a.name));
          break;
        case ProductSortType.priceAsc:
          sorted.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
          break;
        case ProductSortType.priceDesc:
          sorted.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
          break;
        case ProductSortType.stockAsc:
          sorted.sort((a, b) => a.stock.compareTo(b.stock));
          break;
        case ProductSortType.stockDesc:
          sorted.sort((a, b) => b.stock.compareTo(a.stock));
          break;
      }
      return sorted;
    }

    // Fungsi untuk filtering
    List<Product> getFilteredProducts(List<Product> products) {
      switch (currentFilter.value) {
        case ProductFilterType.lowStock:
          return products.where((p) => p.stock <= p.minStock).toList();
        case ProductFilterType.active:
          return products.where((p) => p.isActive).toList();
        case ProductFilterType.inactive:
          return products.where((p) => !p.isActive).toList();
        case ProductFilterType.all:
        default:
          return products;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Produk"),
        actions: [
          // Filter button
          Obx(() {
            final hasFilter = currentFilter.value != ProductFilterType.all;
            return Badge(
              isLabelVisible: hasFilter,
              label: const Text('1'),
              child: PopupMenuButton<ProductFilterType>(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter',
                onSelected: (value) => currentFilter.value = value,
                itemBuilder: (context) => [
                  _buildFilterItem(
                    ProductFilterType.all,
                    'Semua Produk',
                    Icons.all_inclusive,
                    currentFilter.value,
                  ),
                  _buildFilterItem(
                    ProductFilterType.lowStock,
                    'Stok Rendah',
                    Icons.warning,
                    currentFilter.value,
                  ),
                  _buildFilterItem(
                    ProductFilterType.active,
                    'Aktif',
                    Icons.check_circle,
                    currentFilter.value,
                  ),
                  _buildFilterItem(
                    ProductFilterType.inactive,
                    'Nonaktif',
                    Icons.block,
                    currentFilter.value,
                  ),
                ],
              ),
            );
          }),
          
          // Sort button
          PopupMenuButton<ProductSortType>(
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan',
            onSelected: (value) => currentSort.value = value,
            itemBuilder: (context) => [
              _buildSortItem(
                ProductSortType.nameAsc,
                'Nama (A-Z)',
                Icons.sort_by_alpha,
              ),
              _buildSortItem(
                ProductSortType.nameDesc,
                'Nama (Z-A)',
                Icons.sort_by_alpha,
              ),
              const PopupMenuDivider(),
              _buildSortItem(
                ProductSortType.priceAsc,
                'Harga (Termurah)',
                Icons.arrow_upward,
              ),
              _buildSortItem(
                ProductSortType.priceDesc,
                'Harga (Termahal)',
                Icons.arrow_downward,
              ),
              const PopupMenuDivider(),
              _buildSortItem(
                ProductSortType.stockAsc,
                'Stok (Terendah)',
                Icons.arrow_upward,
              ),
              _buildSortItem(
                ProductSortType.stockDesc,
                'Stok (Tertinggi)',
                Icons.arrow_downward,
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
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari produk...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.isEmpty) return const SizedBox.shrink();
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

          // Active Filter Chips
          Obx(() {
            final hasActiveFilter = currentFilter.value != ProductFilterType.all;
            final hasActiveSort = currentSort.value != ProductSortType.nameAsc;
            
            if (!hasActiveFilter && !hasActiveSort) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.withOpacity(0.05),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (hasActiveFilter)
                            Chip(
                              label: Text(_getFilterLabel(currentFilter.value)),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => currentFilter.value = ProductFilterType.all,
                              backgroundColor: Colors.blue.withOpacity(0.1),
                            ),
                          if (hasActiveFilter && hasActiveSort)
                            const SizedBox(width: 8),
                          if (hasActiveSort)
                            Chip(
                              label: Text(_getSortLabel(currentSort.value)),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => currentSort.value = ProductSortType.nameAsc,
                              backgroundColor: Colors.green.withOpacity(0.1),
                            ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      currentFilter.value = ProductFilterType.all;
                      currentSort.value = ProductSortType.nameAsc;
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            );
          }),

          // Stats Cards
          Obx(() {
            final allProducts = controller.products;
            final totalValue = allProducts.fold<double>(
              0,
              (sum, p) => sum + (p.sellingPrice * p.stock),
            );
            final lowStock = allProducts.where((p) => p.stock <= p.minStock).length;

            return Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Produk',
                      value: '${allProducts.length}',
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

              // Apply search, filter, dan sort
              var products = controller.filteredProducts;
              products = getFilteredProducts(products);
              products = getSortedProducts(products);

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

  PopupMenuItem<ProductFilterType> _buildFilterItem(
    ProductFilterType value,
    String label,
    IconData icon,
    ProductFilterType current,
  ) {
    final isSelected = value == current;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check, size: 16, color: Colors.blue),
        ],
      ),
    );
  }

  PopupMenuItem<ProductSortType> _buildSortItem(
    ProductSortType value,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  String _getFilterLabel(ProductFilterType filter) {
    switch (filter) {
      case ProductFilterType.lowStock:
        return 'Stok Rendah';
      case ProductFilterType.active:
        return 'Aktif';
      case ProductFilterType.inactive:
        return 'Nonaktif';
      case ProductFilterType.all:
      default:
        return 'Semua';
    }
  }

  String _getSortLabel(ProductSortType sort) {
    switch (sort) {
      case ProductSortType.nameAsc:
        return 'Nama A-Z';
      case ProductSortType.nameDesc:
        return 'Nama Z-A';
      case ProductSortType.priceAsc:
        return 'Harga Termurah';
      case ProductSortType.priceDesc:
        return 'Harga Termahal';
      case ProductSortType.stockAsc:
        return 'Stok Terendah';
      case ProductSortType.stockDesc:
        return 'Stok Tertinggi';
    }
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
                  // Product Icon
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