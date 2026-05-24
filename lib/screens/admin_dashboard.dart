import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/electronics_provider.dart';
import '../services/auth_service.dart';
import 'add_edit_screen.dart';
import 'detail_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              context.read<AuthService>().logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Consumer<ElectronicsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalItems = provider.items.length;
          final totalStock =
              provider.items.fold<int>(0, (sum, item) => sum + item.quantity);
          final totalValue = provider.items.fold<double>(
              0, (sum, item) => sum + (item.costPrice * item.quantity));

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Stats',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatCard(
                            context,
                            'Total Items',
                            totalItems.toString(),
                            Icons.category_rounded,
                            Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            context,
                            'Total Stock',
                            totalStock.toString(),
                            Icons.inventory_2_rounded,
                            Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        context,
                        'Inventory Value',
                        '₹${totalValue.toStringAsFixed(0)}',
                        Icons.account_balance_wallet_rounded,
                        Colors.green,
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 24),
                      Text('Manage Inventory',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              provider.items.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('No items to manage.')))
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = provider.items[index];
                            final isLowStock = item.quantity < 5;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: isLowStock
                                    ? Border.all(
                                        color: Colors.red.withOpacity(0.3))
                                    : null,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  child: Icon(Icons.electrical_services,
                                      color: theme.colorScheme.primary),
                                ),
                                title: Text(item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    'Code: ${item.encodedCostPrice}\nStock: ${item.quantity}',
                                    style: TextStyle(
                                        height: 1.5,
                                        color: isLowStock
                                            ? Colors.red
                                            : Colors.grey[600])),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_note_rounded,
                                          color: Colors.blue),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddEditScreen(item: item)),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.red),
                                      onPressed: () => _confirmDelete(
                                          context, item.id!, provider),
                                    ),
                                  ],
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                          item: item, isAdmin: true)),
                                ),
                              ),
                            );
                          },
                          childCount: provider.items.length,
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color,
      {bool isFullWidth = false}) {
    return Expanded(
      flex: isFullWidth ? 0 : 1,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, String id, ElectronicsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Item'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              provider.deleteItem(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
