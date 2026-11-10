import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/core/utils/currency_helper.dart';
import 'package:expensex/data/models/expense.dart';
import 'package:expensex/features/expenses/pages/add_expense_page.dart';
import 'package:expensex/features/expenses/providers/expense_provider.dart';
import 'package:expensex/shared/widgets/app_card.dart';

enum ExpenseDateFilter { all, today, thisWeek, thisMonth }

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';
  ExpenseDateFilter _dateFilter = ExpenseDateFilter.all;
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Education',
    'Entertainment',
    'Travel',
    'Others',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesDate(DateTime date, ExpenseDateFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case ExpenseDateFilter.all:
        return true;
      case ExpenseDateFilter.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case ExpenseDateFilter.thisWeek:
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        return !date.isBefore(startOfWeek);
      case ExpenseDateFilter.thisMonth:
        return date.year == now.year && date.month == now.month;
    }
  }

  List<Expense> _filteredExpenses(List<Expense> expenses) {
    return expenses.where((expense) {
      if (_selectedCategory != 'All' &&
          expense.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      if (!_matchesDate(expense.date, _dateFilter)) {
        return false;
      }

      if (_searchText.trim().isNotEmpty) {
        final query = _searchText.toLowerCase();
        final matches =
            expense.title.toLowerCase().contains(query) ||
            expense.category.toLowerCase().contains(query) ||
            (expense.note ?? '').toLowerCase().contains(query);
        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'health':
        return Icons.local_hospital_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'travel':
        return Icons.flight_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Future<void> _deleteExpense(int id) async {
    await context.read<ExpenseProvider>().deleteExpense(id);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
  }

  String _dateFilterLabel(ExpenseDateFilter filter) {
    switch (filter) {
      case ExpenseDateFilter.all:
        return 'All Time';
      case ExpenseDateFilter.today:
        return 'Today';
      case ExpenseDateFilter.thisWeek:
        return 'This Week';
      case ExpenseDateFilter.thisMonth:
        return 'This Month';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final expenses = _filteredExpenses(provider.expenses);
    final totalFiltered = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenses',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      // Right-thumb reachable Add Button
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'expenses_fab',
        backgroundColor: const Color(0xFFF43F5E), // Vibrant Crimson
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          );
          if (!mounted) return;
          await provider.loadExpenses();
        },
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = '';
                          });
                        },
                      ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),

          // Date Filter Pills
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: ExpenseDateFilter.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = ExpenseDateFilter.values[index];
                final isSelected = _dateFilter == filter;
                return ChoiceChip(
                  label: Text(_dateFilterLabel(filter)),
                  selected: isSelected,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _dateFilter = filter;
                      });
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Category Chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : 'All';
                    });
                  },
                );
              },
            ),
          ),

          // Summary Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${expenses.length} expense${expenses.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Total: -${context.currency(totalFiltered)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFFF43F5E),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 12),

          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.loadExpenses,
              child: expenses.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 90),
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Theme.of(context).hintColor.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'No Expenses Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            'Try adjusting your filters or tap "Add Expense" below.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      // Padding at bottom ensures FAB never overlaps content
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemCount: expenses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final expense = expenses[index];

                        return Dismissible(
                          key: ValueKey(expense.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF43F5E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            if (expense.id != null) {
                              _deleteExpense(expense.id!);
                            }
                          },
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              final provider = context.read<ExpenseProvider>();

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddExpensePage(expense: expense),
                                ),
                              );

                              if (!mounted) return;

                              await provider.loadExpenses();
                            },
                            child: AppCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF43F5E)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    categoryIcon(expense.category),
                                    color: const Color(0xFFF43F5E),
                                    size: 22,
                                  ),
                                ),
                                title: Text(
                                  expense.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${expense.category}${expense.note != null && expense.note!.isNotEmpty ? ' • ${expense.note}' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '-${context.currency(expense.amount)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFFF43F5E),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ],
                                ),
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
