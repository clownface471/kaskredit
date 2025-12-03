import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/features/customers/presentation/controllers/customer_controller.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/utils/formatters.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.put(CustomerController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pelanggan"),
        actions: [
          // Filter button untuk show all / debt only
          Obx(() {
            final debtorsCount = controller.customers
                .where((c) => c.totalDebt > 0)
                .length;
            
            return PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (value) {
                // TODO: Implement filter
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      const Icon(Icons.people, size: 20),
                      const SizedBox(width: 12),
                      Text('Semua (${controller.customers.length})'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'debt',
                  child: Row(
                    children: [
                      const Icon(Icons.credit_card, size: 20, color: Colors.red),
                      const SizedBox(width: 12),
                      Text('Berutang ($debtorsCount)'),
                    ],
                  ),
                ),
              ],
            );
          }),
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
                    onPressed: () {
                      controller.updateSearchQuery('');
                    },
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

          // Summary Stats
          Obx(() {
            final totalDebt = controller.customers.fold<double>(
              0,
              (sum, customer) => sum + customer.totalDebt,
            );
            final debtorsCount = controller.customers
                .where((c) => c.totalDebt > 0)
                .length;

            if (totalDebt == 0) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

              if (controller.filteredCustomers.isEmpty) {
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
                  itemCount: controller.filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = controller.filteredCustomers[index];
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