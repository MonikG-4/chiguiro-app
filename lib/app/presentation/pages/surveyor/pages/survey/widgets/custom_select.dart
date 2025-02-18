import 'package:flutter/material.dart';

import 'custom_input.dart';

class CustomSelect extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String label;
  final ValueChanged<String?> onSelected;
  final FormFieldState? state;
  final GlobalKey keyDropdown;

  const CustomSelect({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onSelected,
    this.state,
    required this.keyDropdown,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInput(
      key: keyDropdown,
      hasError: state!.hasError,
      hasValue: value != null,
      onTap: () async {
        final RenderBox renderBox = keyDropdown.currentContext!.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);

        final selectedValue = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + renderBox.size.height,
            offset.dx + renderBox.size.width,
            offset.dy + renderBox.size.height + 200,
          ),
          color: Colors.white,
          items: items.map((item) {
            return PopupMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
          constraints: BoxConstraints(
            minWidth: renderBox.size.width,
            maxWidth: renderBox.size.width,
          ),
        );

        if (selectedValue == value) {
          onSelected(null);
        } else if (selectedValue != null) {
          onSelected(selectedValue);
        }
      },
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              value ?? 'Selecciona $label',
              style: TextStyle(
                color: value != null ? Colors.black : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
        const Icon(Icons.arrow_drop_down),
      ],
    );
  }
}
