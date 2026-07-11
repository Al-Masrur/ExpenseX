import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/data/models/budget.dart';
import 'package:expensex/features/budget/providers/budget_provider.dart';

class AddBudgetPage extends StatefulWidget {
  const AddBudgetPage({
    super.key,
    this.budget,
  });

  final Budget? budget;

  bool get isEditing => budget != null;

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();

  late int _month;
  late int _year;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _month = now.month;
    _year = now.year;

    if (widget.budget != null) {
      _month = widget.budget!.month;
      _year = widget.budget!.year;
      _amountController.text = widget.budget!.amount.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final budget = Budget(
      id: widget.budget?.id,
      month: _month,
      year: _year,
      amount: double.parse(_amountController.text),
    );

    final provider = context.read<BudgetProvider>();

    if (widget.isEditing) {
      await provider.updateBudget(budget);
    } else {
      await provider.addBudget(budget);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Budget' : 'Monthly Budget',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              "Budget for $_month/$_year",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Budget Amount',
                prefixText: '৳ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter budget';
                }

                if (double.tryParse(value) == null) {
                  return 'Invalid amount';
                }

                return null;
              },
            ),

            const SizedBox(height: 30),

            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(
                widget.isEditing
                    ? 'Update Budget'
                    : 'Save Budget',
              ),
            ),
          ],
        ),
      ),
    );
  }
}