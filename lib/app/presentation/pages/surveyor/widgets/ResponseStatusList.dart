import 'package:flutter/material.dart';

class ResponseStatusList extends StatelessWidget {
  final List<ResponseStatus> items;

  const ResponseStatusList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded( // Esto asegura que el ListView ocupe todo el espacio disponible
      child: ListView.separated(
        shrinkWrap: true, // Esto permite que el ListView ocupe solo el espacio necesario
        physics: const AlwaysScrollableScrollPhysics(), // Esto permite el desplazamiento
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Color(0xFFE8EDF4),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Row(
              children: [
                // Fecha
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatDate(item.date),
                    style: const TextStyle(
                      color: Color(0xFF6C7A9C),
                      fontSize: 14,
                    ),
                  ),
                ),
                // Porcentaje
                Expanded(
                  flex: 2,
                  child: Text(
                    '${(item.responsePercentage * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: Color(0xFF6C7A9C),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,

                  ),

                ),
                // Estado
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: item.isComplete
                          ? const Color(0xFF1DD1A1)
                          : const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(11 ),
                    ),
                    child: Text(
                      item.isComplete ? 'Completo' : 'Incompleto',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _getSpanishMonth(date.month).substring(0, 3).toLowerCase();
    final year = date.year.toString().substring(2);
    return '$day. $month. $year';
  }

  String _getSpanishMonth(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }
}


class ResponseStatus {
  final DateTime date;
  final double responsePercentage;
  final bool isComplete;

  ResponseStatus({
    required this.date,
    required this.responsePercentage,
    required this.isComplete,
  });
}
