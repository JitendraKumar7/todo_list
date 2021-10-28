import 'dart:math';

import 'package:flutter/material.dart';

import '../index/movable_list.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class ItemData {
  ItemData(this.title, this.key);

  final String title;

  // Each item in reorderable list needs stable and unique key
  final Key key;
}

class Item extends StatelessWidget {
  Item({
    required this.data,
    required this.isFirst,
    required this.isLast,
  });

  final ItemData data;
  final bool isFirst;
  final bool isLast;

  Widget _buildChild(BuildContext context, MovableItemState state) {

    Random random = Random();
    BoxDecoration decoration;

    if (state == MovableItemState.dragProxy ||
        state == MovableItemState.dragProxyFinished) {
      decoration = BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == MovableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: isFirst && !placeholder
                  ? Divider.createBorderSide(context) //
                  : BorderSide.none,
              bottom: isLast && placeholder
                  ? BorderSide.none //
                  : Divider.createBorderSide(context)),
          color: placeholder ? null : Color.fromARGB(random.nextInt(255), 255, 0, 0));
    }

    Widget dragHandle = MovableListener(
      child: Container(
        padding: EdgeInsets.only(right: 18.0, left: 18.0),
        color: Color(0x08000000),
        child: Center(
          child: Icon(Icons.reorder, color: Color(0xFF888888)),
        ),
      ),
    );

    return Container(
      decoration: decoration,
      child: SafeArea(
          top: false,
          bottom: false,
          child: Opacity(
            // hide content for placeholder
            opacity: state == MovableItemState.placeholder ? 0.0 : 1.0,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
                        child: Text(data.title,
                            style: Theme.of(context).textTheme.subtitle1),
                      )),
                  // Triggers the reordering
                  dragHandle,
                ],
              ),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MovableItem(key: data.key, childBuilder: _buildChild);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late List<ItemData> _items;

  _MyHomePageState() {
    _items = [];

    _items.add(ItemData('Go to the gym', ValueKey(0)));
    _items.add(ItemData('Buy groceries', ValueKey(1)));
    _items.add(ItemData('Mow the lawn', ValueKey(2)));
    _items.add(ItemData('Get a haircut', ValueKey(3)));
    _items.add(ItemData('Pick up dry cleaning', ValueKey(4)));
  }

  int _indexOfKey(Key key) {
    return _items.indexWhere((ItemData d) => d.key == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    final draggedItem = _items[draggingIndex];
    setState(() {
      debugPrint("Moving $item -> $newPosition");
      _items.removeAt(draggingIndex);
      _items.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  void _reorderDone(Key item) {
    final draggedItem = _items[_indexOfKey(item)];
    debugPrint("Moving finished for ${draggedItem.title}}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MovableList(
          onMover: this._reorderCallback,
          onMoverDone: this._reorderDone,
          child: CustomScrollView(slivers: <Widget>[
            SliverPadding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, int index) {
                      return Item(
                        data: _items[index],
                        isFirst: index == 0,
                        isLast: index == _items.length - 1,
                      );
                    },
                    childCount: _items.length,
                  ),
                )),
          ]),
        ),
      ),
    );
  }
}