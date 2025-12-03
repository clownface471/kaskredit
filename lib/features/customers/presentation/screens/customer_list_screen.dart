import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/features/customers/presentation/controllers/customer_controller.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/utils/formatters.dart';

// Enhanced dengan lebih banyak sort options
enum CustomerSortType { 
  nameAsc, 
  nameDesc, 
  debtAsc, 
  debtDesc,
  recentlyAdded,
  oldestFirst
}

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.put(CustomerController());
    final Rx<CustomerSortType> currentSort = CustomerSortType.nameAsc.obs;

    // Fungsi untuk sorting
    List<Customer> getSortedCustomers(List<Customer> customers) {
      final sorted = [...customers];
      switch (currentSort.value) {
        case CustomerSortType.nameAsc:
          sorted.sort((a, b) => a.name.compareTo(b.name));
          break;
        case CustomerSortType.nameDesc:
          sorted.sort((a, b) => b.name.compareTo(a.name));
          break;
        case CustomerSortType.debtAsc:
          sorted.sort((a, b) => a.totalDebt.compareTo(b.totalDebt));
          break;
        case CustomerSortType.debtDesc:
          sorted.sort((a, b) => b.totalDebt.compareTo(a.totalDebt));
          break;
        case CustomerSortType.recentlyAdded:
          sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case CustomerSortType.oldestFirst:
          sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
      }
      return sorted;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pelanggan"),
        actions: [
          // Filter button
          Obx(() {
            final currentFilter = controller.currentFilter.value;
            
            return PopupMenuButton<CustomerFilter>(
              icon: Badge(
                isLabelVisible: currentFilter != CustomerFilter.all,
                label: const Text('1'),
                child: const Icon(Icons.filter_list),
              ),
              tooltip: 'Filter',
              onSelected: (value) => controller.setFilter(value),
              itemBuilder: (context) => [
                _buildFilterItem(
                  CustomerFilter.all,
                  'Semua (${controller.totalCustomers})',
                  Icons.people,
                  currentFilter,
                  Colors.blue,
                ),
                _buildFilterItem(
                  CustomerFilter.withDebt,
                  'Berutang (${controller.debtorsCount})',
                  Icons.credit_card,
                  currentFilter,
                  Colors.red,
                ),
                _buildFilterItem(
                  CustomerFilter.noDebt,
                  'Lunas (${controller.totalCustomers - controller.debtorsCount})',
                  Icons.check_circle,
                  currentFilter,
                  Colors.green,
                ),
              ],
            );
          }),
          
          // Sort button
          PopupMenuButton<CustomerSortType>(
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan',
            onSelected: (value) => currentSort.value = value,
            itemBuilder: (context) => [
              _buildSortItem(
                CustomerSortType.nameAsc,
                'Nama (A-Z)',
                Icons.sort_by_alpha,
              ),
              _buildSortItem(
                CustomerSortType.nameDesc,
                'Nama (Z-A)',
                Icons.sort_by_alpha,
              ),
              const PopupMenuDivider(),
              _buildSortItem(
                CustomerSortType.debtDesc,
                'Utang Terbesar',
                Icons.arrow_downward,
              ),
              _buildSortItem(
                CustomerSortType.debtAsc,
                'Utang Terkecil',
                Icons.arrow_upward,
              ),
              const PopupMenuDivider(),
              _buildSortItem(
                CustomerSortType.recentlyAdded,
                'Terbaru',
                Icons.fiber_new,
              ),
              _buildSortItem(
                CustomerSortType.oldestFirst,
                'Terlama',
                Icons.history,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.ADD_CUSTOMER),
        icon: const Icon(Icons.person_add),
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
                hintText: "Cari nama atau nomor HP...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.clearSearch(),
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

          // Active Filters Display
          Obx(() {
            final hasFilter = controller.currentFilter.value != CustomerFilter.all;
            final hasSort = currentSort.value != CustomerSortType.nameAsc;
            
            if (!hasFilter && !hasSort) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.withOpacity(0.05),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (hasFilter)
                          Chip(
                            label: Text(_getFilterLabel(controller.currentFilter.value)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => controller.setFilter(CustomerFilter.all),
                            backgroundColor: Colors.blue.withOpacity(0.1),
                          ),
                        if (hasSort)
                          Chip(
                            label: Text(_getSortLabel(currentSort.value)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => currentSort.value = CustomerSortType.nameAsc,
                            backgroundColor: Colors.green.withOpacity(0.1),
                          ),
                      ],
                    ),
                  ),
                  if (hasFilter || hasSort)
                    TextButton(
                      onPressed: () {
                        controller.setFilter(CustomerFilter.all);
                        currentSort.value = CustomerSortType.nameAsc;
                      },
                      child: const Text('Reset'),
                    ),
                ],
              ),
            );
          }),

          // Summary Stats
          Obx(() {
            final totalDebt = controller.totalDebt;
            final debtorsCount = controller.debtorsCount;

            if (totalDebt == 0) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade700, Colors.orange.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Piutang',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.currency(totalDebt),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$debtorsCount pelanggan berutang',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
            );
          }),
          
          // Customer List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.customers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Apply search, filter, and sort
              var customers = controller.filteredCustomers;
              customers = getSortedCustomers(customers);

              if (customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        controller.searchQuery.isEmpty
                            ? Icons.people_outline
                            : Icons.search_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.isEmpty
                            ? "Belum ada pelanggan"
                            : "Pelanggan tidak ditemukan",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (controller.searchQuery.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Tambah pelanggan baru untuk memulai",
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
                  controller.loadCustomers();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return _CustomerCard(customer: customer);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<CustomerFilter> _buildFilterItem(
    CustomerFilter value,
    String label,
    IconData icon,
    CustomerFilter current,
    Color color,
  ) {
    final isSelected = value == current;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? color : Colors.grey,
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
            Icon(Icons.check, size: 16, color: color),
        ],
      ),
    );
  }

  PopupMenuItem<CustomerSortType> _buildSortItem(
    CustomerSortType value,
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

  String _getFilterLabel(CustomerFilter filter) {
    switch (filter) {
      case CustomerFilter.withDebt:
        return 'Berutang';
      case CustomerFilter.noDebt:
        return 'Lunas';
      case CustomerFilter.all:
      default:
        return 'Semua';
    }
  }

  String _getSortLabel(CustomerSortType sort) {
    switch (sort) {
      case CustomerSortType.nameAsc:
        return 'Nama A-Z';
      case CustomerSortType.nameDesc:
        return 'Nama Z-A';
      case CustomerSortType.debtDesc:
        return 'Utang Terbesar';
      case CustomerSortType.debtAsc:
        return 'Utang Terkecil';
      case CustomerSortType.recentlyAdded:
        return 'Terbaru';
      case CustomerSortType.oldestFirst:
        return 'Terlama';
    }
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;

  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final hasDebt = customer.totalDebt > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasDebt
            ? BorderSide(color: Colors.red.withOpacity(0.3), width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.CUSTOMER_DETAIL,
          arguments: customer,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: hasDebt
                      ? Colors.red.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: hasDebt
                        ? Colors.red.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: hasDebt ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (customer.phoneNumber != null &&
                        customer.phoneNumber!.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            customer.phoneNumber!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    if (hasDebt) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 14,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Utang: ${Formatters.currency(customer.totalDebt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (value) {
                  if (value == 'detail') {
                    Get.toNamed(
                      AppRoutes.CUSTOMER_DETAIL,
                      arguments: customer,
                    );
                  } else if (value == 'edit') {
                    Get.toNamed(
                      AppRoutes.EDIT_CUSTOMER,
                      arguments: customer,
                    );
                  } else if (value == 'pay' && hasDebt) {
                    Get.toNamed(AppRoutes.DEBT);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Lihat Detail'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  if (hasDebt)
                    const PopupMenuItem(
                      value: 'pay',
                      child: Row(
                        children: [
                          Icon(Icons.payment, size: 20, color: Colors.orange),
                          SizedBox(width: 12),
                          Text('Bayar Utang'),
                        ],
                      ),
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