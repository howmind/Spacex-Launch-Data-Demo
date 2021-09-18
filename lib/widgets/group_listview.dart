import 'package:flutter/material.dart';

class GroupListView<T, E> extends StatefulWidget {
  GroupListView(
      {Key? key,
      required this.elements,
      required this.groupBy,
      this.groupCompare,
      required this.groupHeaderBuilder,
      this.itemCompare,
      required this.itemBuilder})
      : super(key: key);

  final List<T> elements;
  final E Function(T element)? groupBy;
  final int Function(E value1, E value2)? groupCompare;
  final int Function(T element1, T element2)? itemCompare;
  final Widget Function(E value) groupHeaderBuilder;
  final Widget Function(BuildContext context, T element)? itemBuilder;

  @override
  _GroupListViewState createState() => _GroupListViewState<T, E>();
}

class _GroupListViewState<T, E> extends State<GroupListView<T, E>> {
  List<T> _sortedElements = [];

  @override
  Widget build(BuildContext context) {
    _sortedElements = _sortElements();
    return ListView.builder(
      key: widget.key,
      itemCount: _sortedElements.length * 2,
      itemBuilder: (context, index) {
        var actualIndex = index ~/ 2;
        if (index == 0) {
          return widget.groupBy == null
              ? SizedBox.shrink()
              : widget.groupHeaderBuilder(
                  widget.groupBy!(_sortedElements[actualIndex])!);
        }
        if (index.isEven) {
          if (widget.groupBy == null) return SizedBox.shrink();
          var curr = widget.groupBy!(_sortedElements[actualIndex]);
          var prev = widget.groupBy!(_sortedElements[actualIndex - 1]);
          if (prev != curr) {
            return widget.groupHeaderBuilder(
                widget.groupBy!(_sortedElements[actualIndex])!);
          }
          return const SizedBox.shrink();
        }
        return widget.itemBuilder!(context, _sortedElements[actualIndex]);
      },
    );
  }

  List<T> _sortElements() {
    var elements = widget.elements;
    if (elements.isNotEmpty) {
      elements.sort((e1, e2) {
        var compareResult;
        // compare groups
        if (widget.groupBy != null && widget.groupCompare != null) {
          compareResult =
              widget.groupCompare!(widget.groupBy!(e1), widget.groupBy!(e2));
        }
        // compare elements inside group
        if ((compareResult == null || compareResult == 0)) {
          compareResult = widget.itemCompare?.call(e1, e2) ?? 0;
        }
        return compareResult;
      });
    }
    return elements;
  }
}
