import 'package:flutter/material.dart';

import 'custom_input.dart';

class CustomSelect extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String label;
  final FormFieldState? state;

  final ValueChanged<String?> onSelected;
  final GlobalKey keyDropdown;
  final double maxHeight;
  final bool hasError;

  const CustomSelect({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    this.state,
    required this.onSelected,
    required this.keyDropdown,
    this.maxHeight = 300.0,
    this.hasError = false,
  });

  Future<void> _showDropdownMenu(BuildContext context) async {
    final RenderBox renderBox = keyDropdown.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;
    final spaceBelow = screenSize.height - offset.dy - size.height;
    final spaceAbove = offset.dy;
    final requiredHeight = (items.length * 44.0).clamp(0.0, maxHeight);
    final showAbove = spaceBelow < requiredHeight && spaceAbove > spaceBelow;

    final double calculatedHeight = showAbove
        ? spaceAbove.clamp(0.0, maxHeight)
        : spaceBelow.clamp(0.0, maxHeight);

    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy,
      offset.dx + size.width,
      offset.dy + size.height,
    );

    final selectedValue = await Navigator.of(context).push(
      _CustomPopupMenuRoute<String>(
        position: position,
        items: items,
        selectedIndex: items.indexOf(value ?? ''),
        menuWidth: size.width,
        maxHeight: calculatedHeight,
        showAbove: showAbove,
      ),
    );

    if (selectedValue != null) {
      onSelected(selectedValue == value ? null : selectedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 80),
      child: CustomInput(
        key: keyDropdown,
        hasError: state?.hasError ?? false,
        hasValue: value != null,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          _showDropdownMenu(context);
        },
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                value ?? label,
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
      ),
    );
  }
}

class _CustomPopupMenuRoute<T> extends PopupRoute<T> {
  final RelativeRect position;
  final List<String> items;
  final int selectedIndex;
  final double menuWidth;
  final double maxHeight;
  final bool showAbove;

  _CustomPopupMenuRoute({
    required this.position,
    required this.items,
    required this.selectedIndex,
    required this.menuWidth,
    required this.maxHeight,
    required this.showAbove,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return CustomSingleChildLayout(
      delegate: _PopupMenuRouteLayout(position, showAbove),
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(4),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            maxWidth: menuWidth,
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () => Navigator.of(context).pop(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: index == selectedIndex ? Colors.grey[200] : null,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontWeight: index == selectedIndex ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  final RelativeRect position;
  final bool showAbove;

  _PopupMenuRouteLayout(this.position, this.showAbove);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => BoxConstraints.loose(constraints.biggest);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double dx = position.left;
    double dy = showAbove ? position.top - childSize.height : position.bottom;

    if (dx + childSize.width > size.width) dx = size.width - childSize.width;
    if (dy + childSize.height > size.height) dy = size.height - childSize.height;
    if (dy < 0) dy = 0;

    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(covariant _PopupMenuRouteLayout oldDelegate) =>
      position != oldDelegate.position || showAbove != oldDelegate.showAbove;
}
