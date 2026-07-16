import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/data/models/expense.dart';
import 'package:expensex/features/expenses/pages/add_expense_page.dart';
import 'package:expensex/features/expenses/providers/expense_provider.dart';
import 'package:expensex/shared/widgets/app_card.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

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

  List<Expense> _filteredExpenses(List<Expense> expenses) {
    if (_searchText.trim().isEmpty) {
      return expenses;
    }

    final query = _searchText.toLowerCase();

    return expenses.where((expense) {
      return expense.title.toLowerCase().contains(query) ||
          expense.category.toLowerCase().contains(query) ||
          (expense.note ?? '').toLowerCase().contains(query);
    }).toList();
  }

  String currency(double amount) => '৳ ${amount.toStringAsFixed(2)}';

  IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      case 'bills':
        return Icons.receipt_long;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.payments;
    }
  }

  Future<void> _deleteExpense(int id) async {
    await context.read<ExpenseProvider>().deleteExpense(id);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final expenses = _filteredExpenses(provider.expenses);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchText = '';
                          });
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.loadExpenses,
              child: expenses.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            'No Expenses Yet',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Tap + on Dashboard to add your first expense.',
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: expenses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final expense = expenses[index];

                        return Dismissible(
                          key: ValueKey(expense.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            if (expense.id != null) {
                              _deleteExpense(expense.id!);
                            }
                          },
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
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
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  child: Icon(categoryIcon(expense.category)),
                                ),
                                title: Text(expense.title),
                                subtitle: Text(expense.category),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currency(expense.amount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
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
