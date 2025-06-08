import 'package:flutter/material.dart';

class ContadorNumerico extends StatelessWidget {
  final int valor;
  final int min;
  final int max;
  final void Function(int) onChanged;

  const ContadorNumerico({
    super.key,
    required this.valor,
    this.min = 0,
    this.max = 99,
    required this.onChanged,
  });

  void _incrementar() {
    if (valor < max) onChanged(valor + 1);
  }

  void _decrementar() {
    if (valor > min) onChanged(valor - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _decrementar,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          valor.toString(),
          style: const TextStyle(fontSize: 20),
        ),
        IconButton(
          onPressed: _incrementar,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
