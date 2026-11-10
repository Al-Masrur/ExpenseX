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
        return Icons.account_balance_wallet;
      case 'freelance':
        return Icons.laptop;
      case 'business':
        return Icons.business;
      case 'investment':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      case 'bonus':
        return Icons.workspace_premium;
      case 'rental':
        return Icons.home_work;
      default:
        return Icons.attach_money;
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
        title: const Text('Income'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Income',
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
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search income...',
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
            height: 40,
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
            height: 38,
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${incomes.length} income item${incomes.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Total: ${context.currency(totalFiltered)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
                      children: const [
                        SizedBox(height: 100),
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'No Income Found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Try adjusting your filters or record a new income.',
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: incomes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            if (income.id != null) {
                              _deleteIncome(income.id!);
                            }
                          },
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
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
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  child: Icon(categoryIcon(income.category)),
                                ),
                                title: Text(income.title),
                                subtitle: Text(
                                  '${income.category}${income.note != null && income.note!.isNotEmpty ? ' • ${income.note}' : ''}',
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      context.currency(income.amount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      '${income.date.day}/${income.date.month}/${income.date.year}',
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
