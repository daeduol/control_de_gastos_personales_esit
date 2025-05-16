import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../bd/expensed_database.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _category = '';
  double _amount = 0.0;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _title = widget.expense!.title;
      _category = widget.expense!.category;
      _amount = widget.expense!.amount;
      _date = widget.expense!.date;
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newExpense = Expense(
        title: _title,
        category: _category,
        amount: _amount,
        date: _date,
      );
      if (widget.expense != null) {
        await ExpenseDatabase.instance.update(newExpense);
      } else {
        await ExpenseDatabase.instance.create(newExpense);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  void _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => _date = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.expense != null ? 'Agregar Gasto' : 'Editar Gasto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un título';
                  }
                  final regex = RegExp(r'^[a-zA-Z0-9\s]+$');
                  if (!regex.hasMatch(value)) {
                    return 'El título solo puede contener letras y números';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una categoría';
                  }
                  final regex = RegExp(r'^[a-zA-Z0-9\s]+$');
                  if (!regex.hasMatch(value)) {
                    return 'La categoría solo puede contener letras y números';
                  }
                  return null;
                },
                onSaved: (value) => _category = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un monto';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'El monto debe ser mayor que cero';
                  }
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fecha: ${_date.toLocal().toString().split(' ')[0]}'),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Seleccionar Fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.expense != null ? 'Actualizar' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}