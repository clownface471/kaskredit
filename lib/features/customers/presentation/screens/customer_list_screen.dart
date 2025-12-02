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
        title: const Text("Daftar Pelanggan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.ADD_CUSTOMER),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari pelanggan...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: controller.updateSearchQuery,
            ),
          ),
          
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
                      Icon(Icons.people_outline, 
                           size: 64, 
                           color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.isEmpty
                            ? "Belum ada pelanggan"
                            : "Pelanggan tidak ditemukan",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  controller.loadCustomers();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: InkWell(
        // UPDATED: Buka customer detail screen, bukan edit
        onTap: () => Get.toNamed(
          AppRoutes.CUSTOMER_DETAIL,
          arguments: customer,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: hasDebt 
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: hasDebt ? Colors.red : Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              
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
                      Text(
                        customer.phoneNumber!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    if (hasDebt) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Utang: ${Formatters.currency(customer.totalDebt)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action buttons
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
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
                        SizedBox(width: 8),
                        Text('Lihat Detail'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
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
                          SizedBox(width: 8),
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