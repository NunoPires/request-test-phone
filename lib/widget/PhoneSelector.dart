import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PhoneSelector extends StatefulWidget {

  PhoneSelector({Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() {

    final List<DropdownMenuItem<PhoneListItem>> _list =  [];
    _list.add(new DropdownMenuItem(child: new Text("iPhone SE 1"), value: new PhoneListItem(name: "iPhone SE 1")));
    _list.add(new DropdownMenuItem(child: new Text("BQ"), value: new PhoneListItem(name: "BQ")));

    return new PhoneSelectorState(items: _list, hint: "Select phone");
  }

}

class PhoneSelectorState extends State<PhoneSelector> {

  PhoneSelectorState({this.items, this.hint});

  final List<DropdownMenuItem<PhoneListItem>> items;
  final String hint;

  PhoneListItem _phone;
  PhoneListItem get createdObject => _phone;

  @override
  Widget build(BuildContext context) {
    return new DropdownButton<PhoneListItem>(
        value: _phone,
        hint: new Text(hint),
        items: items,
        onChanged: (value) {
          setState(() {
            _phone = value;
          });
        });
  }
}

class PhoneListItem extends StatelessWidget {

  PhoneListItem({this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return new Text(name);
  }
}