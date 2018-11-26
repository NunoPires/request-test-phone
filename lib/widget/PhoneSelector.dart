import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PhoneSelector extends StatefulWidget {

  PhoneSelector({Key key, this.items}): super(key: key);
  final List<DropdownMenuItem<PhoneListItem>> items;

  @override
  State<StatefulWidget> createState() {

    return new PhoneSelectorState(hint: "Select phone", items: items);
  }
}

class PhoneSelectorState extends State<PhoneSelector> {

  PhoneSelectorState({this.hint, this.items});
  final String hint;
  final List<DropdownMenuItem<PhoneListItem>> items;

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

  PhoneListItem({this.id, this.name});
  final int id;
  final String name;

  @override
  Widget build(BuildContext context) {
    return new Text(name);
  }
}