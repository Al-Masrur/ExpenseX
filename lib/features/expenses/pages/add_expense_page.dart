import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/data/models/expense.dart';
import 'package:expensex/features/expenses/providers/expense_provider.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key, this.expense});

  final Expense? expense;

  bool get isEditing => expense != null;

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String _selectedCategory = 'Food';

  bool _saving = false;

  final List<String> _categories = const [
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

    final expense = widget.expense;

    if (expense == null) return;

    _titleController.text = expense.title;
    _amountController.text = expense.amount.toString();
    _noteController.text = expense.note ?? '';

    _selectedCategory = expense.category;
    _selectedDate = expense.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final expense = Expense(
      id: widget.expense?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text.trim(),
    );

    final provider = context.read<ExpenseProvider>();

    if (widget.isEditing) {
      await provider.updateExpense(expense);
    } else {
      await provider.addExpense(expense);
    }

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense Added Successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Expense Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter expense title';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '৳ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter amount';
                }

                final amount = double.tryParse(value);

                if (amount == null || amount <= 0) {
                  return 'Invalid amount';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(),
              ),
              title: const Text('Date'),
              subtitle: Text(
                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: _pickDate,
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(widget.isEditing ? 'Update Expense' : 'Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
