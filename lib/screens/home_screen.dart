import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';
import '../bd/expensed_database.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];
  double totalAmount = 0.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshExpenses();
  }

  Future<void> _refreshExpenses() async {
    setState(() => isLoading = true);
    expenses = await ExpenseDatabase.instance.readAll();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    _calculateTotal();
    setState(() => isLoading = false);
  }

  void _calculateTotal() {
    totalAmount = expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  void _deleteExpense(int id) async {
    await ExpenseDatabase.instance.delete(id);
    _refreshExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GASTOS PERSONALES')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total de gastos:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        expenses.isEmpty
                            ? const Center(child: Text('No hay gastos aún'))
                            : ListView.builder(
                              itemCount: expenses.length,
                              itemBuilder:
                                  (ctx, index) => Dismissible(
                                    key: ValueKey(expenses[index].id),
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (direction) async {
                                      return await showDialog(
                                        context: context,
                                        builder:
                                            (ctx) => AlertDialog(
                                              title: const Text(
                                                'Confirmar eliminación',
                                              ),
                                              content: const Text(
                                                '¿Estás seguro que quieres eliminar el gasto?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        ctx,
                                                      ).pop(false),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        ctx,
                                                      ).pop(true),
                                                  child: const Text('Eliminar'),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                    onDismissed: (_) {
                                      _deleteExpense(expenses[index].id!);
                                    },
                                    child: ExpenseCard(
                                      expense: expenses[index],
                                      onEdit: () async {
                                        await Navigator.of(
                                          context,
                                        ).push(
                                          MaterialPageRoute(
                                            builder: (ctx) =>
                                                AddExpenseScreen(
                                              expense: expenses[index],
                                            ),
                                          ),
                                        );
                                        _refreshExpenses();
                                      },
                                    ),
                                  ),
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const AddExpenseScreen()));
          _refreshExpenses();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
