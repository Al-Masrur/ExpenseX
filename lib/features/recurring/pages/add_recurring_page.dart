import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:expensex/core/utils/currency_helper.dart';
import 'package:expensex/features/recurring/models/recurring_transaction.dart';
import 'package:expensex/features/recurring/providers/recurring_provider.dart';

class AddRecurringPage extends StatefulWidget {
  const AddRecurringPage({super.key, this.transaction});

  final RecurringTransaction? transaction;

  bool get isEditing => transaction != null;

  @override
  State<AddRecurringPage> createState() => _AddRecurringPageState();
}

class _AddRecurringPageState extends State<AddRecurringPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  RecurringType _type = RecurringType.expense;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  DateTime _nextDate = DateTime.now();
  String _selectedCategory = 'Bills';
  bool _isActive = true;
  bool _saving = false;

  final List<String> _expenseCategories = const [
    'Bills',
    'Food',
    'Transport',
    'Shopping',
    'Health',
    'Education',
    'Entertainment',
    'Travel',
    'Others',
  ];

  final List<String> _incomeCategories = const [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Rental',
    'Bonus',
    'Gift',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.transaction;
    if (item != null) {
      _titleController.text = item.title;
      _amountController.text = item.amount.toString();
      _noteController.text = item.note ?? '';
      _type = item.type;
      _frequency = item.frequency;
      _nextDate = item.nextDate;
      _selectedCategory = item.category;
      _isActive = item.isActive;
    } else {
      _selectedCategory = _expenseCategories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String> get _currentCategories =>
      _type == RecurringType.expense ? _expenseCategories : _incomeCategories;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _nextDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final provider = context.read<RecurringProvider>();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    final item = RecurringTransaction(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: amount,
      category: _selectedCategory,
      type: _type,
      frequency: _frequency,
      nextDate: _nextDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      isActive: _isActive,
    );

    try {
      if (widget.isEditing) {
        await provider.updateTransaction(item);
      } else {
        await provider.addTransaction(item);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String _frequencyLabel(RecurringFrequency freq) {
    switch (freq) {
      case RecurringFrequency.daily:
        return 'Daily';
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.monthly:
        return 'Monthly';
      case RecurringFrequency.yearly:
        return 'Yearly';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Recurring' : 'New Recurring'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Toggle
              SegmentedButton<RecurringType>(
                segments: const [
                  ButtonSegment(
                    value: RecurringType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_downward, color: Colors.red),
                  ),
                  ButtonSegment(
                    value: RecurringType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_upward, color: Colors.green),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selected) {
                  setState(() {
                    _type = selected.first;
                    _selectedCategory = _currentCategories.first;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Netflix, Rent, Monthly Salary',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '${context.currencySymbol} ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.money),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _currentCategories.contains(_selectedCategory)
                    ? _selectedCategory
                    : _currentCategories.first,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _currentCategories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),

              const SizedBox(height: 16),

              // Frequency Dropdown
              DropdownButtonFormField<RecurringFrequency>(
                value: _frequency,
                decoration: InputDecoration(
                  labelText: 'Repeat Frequency',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.repeat),
                ),
                items: RecurringFrequency.values.map((freq) {
                  return DropdownMenuItem(
                    value: freq,
                    child: Text(_frequencyLabel(freq)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _frequency = val);
                },
              ),

              const SizedBox(height: 16),

              // Next Due Date
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'First / Next Due Date',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_nextDate)),
                ),
              ),

              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Active Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active Schedule'),
                subtitle: const Text('Paused schedules will not auto-generate transactions'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(
                          widget.isEditing ? 'Update Schedule' : 'Create Schedule',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

