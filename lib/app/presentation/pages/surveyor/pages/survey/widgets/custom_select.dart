import 'package:flutter/material.dart';
import 'custom_input.dart';

class CustomSelect extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String label;
  final ValueChanged<String?> onSelected;
  final FormFieldState? state;
  final GlobalKey keyDropdown;
  final double maxHeight;

  const CustomSelect({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onSelected,
    this.state,
    required this.keyDropdown,
    this.maxHeight = 300.0,
  });

  @override
  State<CustomSelect> createState() => _CustomSelectState();
}

class _CustomSelectState extends State<CustomSelect> {

  Future<void> _showDropdownMenu(BuildContext context) async {
    final RenderBox renderBox =
    widget.keyDropdown.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final int selectedIndex =
    widget.value != null ? widget.items.indexOf(widget.value!) : -1;

    final selectedValue = await Navigator.of(context).push(
      _CustomPopupMenuRoute<String>(
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy + renderBox.size.height,
          offset.dx + renderBox.size.width,
          offset.dy + renderBox.size.height + widget.maxHeight,
        ),
        items: widget.items,
        selectedIndex: selectedIndex,
        menuWidth: renderBox.size.width,
        maxHeight: widget.maxHeight,
      ),
    );

    if (selectedValue == widget.value) {
      widget.onSelected(null);
    } else if (selectedValue != null) {
      widget.onSelected(selectedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomInput(
      key: widget.keyDropdown,
      hasError: widget.state?.hasError ?? false,
      hasValue: widget.value != null,
      onTap: () => _showDropdownMenu(context),
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              widget.value ?? widget.label,
              style: TextStyle(
                color: widget.value != null ? Colors.black : Colors.grey,
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

class _CustomPopupMenuRoute<T> extends PopupRoute<T> {
  final RelativeRect position;
  final List<String> items;
  final int selectedIndex;
  final double menuWidth;
  final double maxHeight;

  _CustomPopupMenuRoute({
    required this.position,
    required this.items,
    required this.selectedIndex,
    required this.menuWidth,
    required this.maxHeight,
  });

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return CustomSingleChildLayout(
      delegate: _PopupMenuRouteLayout(position),
      child: Material(
        elevation: 2.0,
        child: Container(
          width: menuWidth,
          constraints: BoxConstraints(maxHeight: maxHeight, minHeight: 0),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.builder(
              controller: ScrollController(
                initialScrollOffset: selectedIndex >= 0 ? selectedIndex * 48.0 : 0.0,
              ),
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop(items[index]);
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Text(
                      items[index],
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: index == selectedIndex ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

}

class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  final RelativeRect position;

  _PopupMenuRouteLayout(this.position);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x = position.left;
    if (x + childSize.width > size.width) {
      x = size.width - childSize.width;
    }

    double y = position.top;
    if (y + childSize.height > size.height) {
      y = position.bottom - childSize.height;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}
