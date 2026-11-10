import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:expensex/core/utils/currency_helper.dart';
import 'package:expensex/features/recurring/models/recurring_transaction.dart';
import 'package:expensex/features/recurring/pages/add_recurring_page.dart';
import 'package:expensex/features/recurring/providers/recurring_provider.dart';
import 'package:expensex/shared/widgets/app_card.dart';

class RecurringPage extends StatefulWidget {
  const RecurringPage({super.key});

  @override
  State<RecurringPage> createState() => _RecurringPageState();
}

class _RecurringPageState extends State<RecurringPage> {
  int _selectedFilterIndex = 0; // 0: All, 1: Expenses, 2: Incomes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RecurringProvider>().loadTransactions();
    });
  }

  List<RecurringTransaction> _filterList(List<RecurringTransaction> items) {
    if (_selectedFilterIndex == 1) {
      return items.where((i) => i.type == RecurringType.expense).toList();
    }
    if (_selectedFilterIndex == 2) {
      return items.where((i) => i.type == RecurringType.income).toList();
    }
    return items;
  }

  IconData _categoryIcon(String category, RecurringType type) {
    if (type == RecurringType.income) {
      switch (category.toLowerCase()) {
        case 'salary':
          return Icons.account_balance_wallet;
        case 'freelance':
          return Icons.laptop;
        case 'business':
          return Icons.business;
        default:
          return Icons.attach_money;
      }
    } else {
      switch (category.toLowerCase()) {
        case 'bills':
          return Icons.receipt_long;
        case 'food':
          return Icons.restaurant;
        case 'transport':
          return Icons.directions_car;
        case 'shopping':
          return Icons.shopping_bag;
        default:
          return Icons.payments;
      }
    }
  }

  Future<void> _processDueNow() async {
    final provider = context.read<RecurringProvider>();
    final count = await provider.processDueTransactions();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count > 0
              ? 'Processed $count due transaction${count > 1 ? 's' : ''}!'
              : 'All recurring schedules are up to date.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecurringProvider>();
    final transactions = _filterList(provider.transactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring & Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Process Due Now',
            onPressed: _processDueNow,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'recurring_fab',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecurringPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Schedule'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('All')),
                ButtonSegment(value: 1, label: Text('Expenses')),
                ButtonSegment(value: 2, label: Text('Incomes')),
              ],
              selected: {_selectedFilterIndex},
              onSelectionChanged: (selected) {
                setState(() => _selectedFilterIndex = selected.first);
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.loadTransactions,
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : transactions.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 70,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: Text(
                                'No Recurring Schedules',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Add recurring bills, subscriptions, or salaries.',
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: transactions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = transactions[index];
                            final isExpense = item.type == RecurringType.expense;
                            final color = isExpense ? Colors.red : Colors.green;

                            return Dismissible(
                              key: ValueKey(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                if (item.id != null) {
                                  provider.deleteTransaction(item.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${item.title} deleted')),
                                  );
                                }
                              },
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddRecurringPage(transaction: item),
                                    ),
                                  );
                                },
                                child: AppCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: color.withValues(alpha: 0.15),
                                            child: Icon(
                                              _categoryIcon(item.category, item.type),
                                              color: color,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${item.category} • ${item.frequency.name.toUpperCase()}',
                                                  style: Theme.of(context).textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${isExpense ? '-' : '+'}${context.currency(item.amount)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: color,
                                                ),
                                              ),
                                              Transform.scale(
                                                scale: 0.8,
                                                child: Switch(
                                                  value: item.isActive,
                                                  onChanged: (_) {
                                                    provider.toggleActive(item);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.schedule,
                                                size: 16,
                                                color: Theme.of(context).hintColor,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Next due: ${DateFormat('dd MMM yyyy').format(item.nextDate)}',
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: item.isActive
                                                  ? Colors.green.withValues(alpha: 0.15)
                                                  : Colors.grey.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              item.isActive ? 'Active' : 'Paused',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: item.isActive
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

