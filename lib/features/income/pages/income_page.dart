import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/core/utils/currency_helper.dart';
import 'package:expensex/data/models/income.dart';
import 'package:expensex/features/income/pages/add_income_page.dart';
import 'package:expensex/features/income/providers/income_provider.dart';
import 'package:expensex/shared/widgets/app_card.dart';

enum IncomeDateFilter { all, today, thisWeek, thisMonth }

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';
  IncomeDateFilter _dateFilter = IncomeDateFilter.all;
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Bonus',
    'Rental',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<IncomeProvider>().loadIncomes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesDate(DateTime date, IncomeDateFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case IncomeDateFilter.all:
        return true;
      case IncomeDateFilter.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case IncomeDateFilter.thisWeek:
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        return !date.isBefore(startOfWeek);
      case IncomeDateFilter.thisMonth:
        return date.year == now.year && date.month == now.month;
    }
  }

  List<Income> _filteredIncomes(List<Income> incomes) {
    return incomes.where((income) {
      if (_selectedCategory != 'All' &&
          income.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      if (!_matchesDate(income.date, _dateFilter)) {
        return false;
      }

      if (_searchText.trim().isNotEmpty) {
        final query = _searchText.toLowerCase();
        final matches =
            income.title.toLowerCase().contains(query) ||
            income.category.toLowerCase().contains(query) ||
            (income.note ?? '').toLowerCase().contains(query);
        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'freelance':
        return Icons.laptop_chromebook_rounded;
      case 'business':
        return Icons.storefront_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'bonus':
        return Icons.workspace_premium_rounded;
      case 'rental':
        return Icons.apartment_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  Future<void> _deleteIncome(int id) async {
    await context.read<IncomeProvider>().deleteIncome(id);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Income deleted')));
  }

  String _dateFilterLabel(IncomeDateFilter filter) {
    switch (filter) {
      case IncomeDateFilter.all:
        return 'All Time';
      case IncomeDateFilter.today:
        return 'Today';
      case IncomeDateFilter.thisWeek:
        return 'This Week';
      case IncomeDateFilter.thisMonth:
        return 'This Month';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncomeProvider>();
    final incomes = _filteredIncomes(provider.incomes);
    final totalFiltered = incomes.fold<double>(0.0, (sum, i) => sum + i.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Income',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      // Right-thumb reachable Add Button
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'income_fab',
        backgroundColor: const Color(0xFF10B981), // Emerald Green
        foregroundColor: Colors.white,
        elevation: 3,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Add Income',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
        onPressed: () async {
          final incomeProvider = context.read<IncomeProvider>();

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddIncomePage()),
          );

          if (!mounted) return;

          await incomeProvider.loadIncomes();
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
                hintText: 'Search income...',
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
              itemCount: IncomeDateFilter.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = IncomeDateFilter.values[index];
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
                  '${incomes.length} income item${incomes.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Total: +${context.currency(totalFiltered)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 12),

          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.loadIncomes,
              child: incomes.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 90),
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: Theme.of(context).hintColor.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'No Income Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            'Try adjusting your filters or tap "Add Income" below.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemCount: incomes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final income = incomes[index];

                        return Dismissible(
                          key: ValueKey(income.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            if (income.id != null) {
                              _deleteIncome(income.id!);
                            }
                          },
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              final provider = context.read<IncomeProvider>();

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddIncomePage(income: income),
                                ),
                              );

                              if (!mounted) return;

                              await provider.loadIncomes();
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
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    categoryIcon(income.category),
                                    color: const Color(0xFF10B981),
                                    size: 22,
                                  ),
                                ),
                                title: Text(
                                  income.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${income.category}${income.note != null && income.note!.isNotEmpty ? ' • ${income.note}' : ''}',
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
                                      '+${context.currency(income.amount)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${income.date.day}/${income.date.month}/${income.date.year}',
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
