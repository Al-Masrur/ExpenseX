import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/data/models/income.dart';
import 'package:expensex/features/income/pages/add_income_page.dart';
import 'package:expensex/features/income/providers/income_provider.dart';
import 'package:expensex/shared/widgets/app_card.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

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

  List<Income> _filteredIncomes(List<Income> incomes) {
    if (_searchText.trim().isEmpty) {
      return incomes;
    }

    final query = _searchText.toLowerCase();

    return incomes.where((income) {
      return income.title.toLowerCase().contains(query) ||
          income.category.toLowerCase().contains(query) ||
          (income.note ?? '').toLowerCase().contains(query);
    }).toList();
  }

  String currency(double amount) => '৳ ${amount.toStringAsFixed(2)}';

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Income deleted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncomeProvider>();

    final incomes = _filteredIncomes(provider.incomes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final incomeProvider = context.read<IncomeProvider>();

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddIncomePage(),
            ),
          );

          if (!mounted) return;

          await incomeProvider.loadIncomes();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
              onRefresh: provider.loadIncomes,
              child: incomes.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Icon(
                          Icons.account_balance_wallet,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            'No Income Yet',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Tap + to add your first income.',
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: incomes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
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
                              final incomeProvider =
                                  context.read<IncomeProvider>();

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddIncomePage(
                                    income: income,
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              await incomeProvider.loadIncomes();
                            },
                            child: AppCard(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  child: Icon(
                                    categoryIcon(income.category),
                                  ),
                                ),
                                title: Text(income.title),
                                subtitle: Text(income.category),
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currency(income.amount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${income.date.day}/${income.date.month}/${income.date.year}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
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