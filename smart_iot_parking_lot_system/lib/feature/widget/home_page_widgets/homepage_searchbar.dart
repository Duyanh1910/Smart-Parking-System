import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_iot_parking_lot_system/core/helper/category_list.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  List<Map<String, dynamic>> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      } else {
        if (_filteredCategories.isNotEmpty) _updateOverlay();
      }
    });
  }

  static final _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide.none,
  );

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _updateOverlay() {
    _removeOverlay();

    if (_filteredCategories.isEmpty || !_focusNode.hasFocus) return;

    final RenderBox renderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 250),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: _filteredCategories
                    .map(
                      (item) => ListTile(
                        leading: Icon(item['icons']),
                        title: Text(item['title']),
                        onTap: () => _onSuggestionTap(item),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _onSuggestionTap(Map<String, dynamic> item) {
    _controller.clear();
    _filteredCategories = [];
    _removeOverlay();
    _focusNode.unfocus();
    context.push(item['route']);
  }

  void _onTextChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = [];
      } else {
        _filteredCategories = categories
            .where(
              (item) =>
                  item['title'].toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });

    _updateOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Material(
          borderRadius: BorderRadius.circular(16),
          shadowColor: Colors.black,
          elevation: 8,
          child: TextField(
            key: _textFieldKey,
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Bạn đang tìm kiếm điều gì?',
              prefixIcon: Icon(Icons.search),
              border: _border,
              enabledBorder: _border,
              focusedBorder: _border,
            ),
            onChanged: _onTextChanged,
          ),
        ),
      ),
    );
  }
}
