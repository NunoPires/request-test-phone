import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final ThemeData kiOSTheme = new ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.grey[350],
);

void main() => runApp(new RequestPhoneApp());

class RequestPhoneApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "Sóce, orienta o móvel",
        theme: defaultTargetPlatform == TargetPlatform.iOS ? kiOSTheme : kDefaultTheme,
        home: new PhoneListScreen()
    );
  }
}

class PhoneListScreen extends StatefulWidget {

  @override
  State createState() => new PhoneRequestListScreenState();
}

class PhoneRequestListScreenState extends State<PhoneListScreen> with TickerProviderStateMixin {

  final List<PhoneRequestListItem> _requests = <PhoneRequestListItem>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Sóce, orienta o móvel"),
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: new Container(
            child: new Column(
                children: <Widget>[
                  /*new Flexible(
                      child: new ListView.builder(

                        reverse: false, // start from the top of the screen
                        itemBuilder: (_, int index) => _requests[index],
                        itemCount: _requests.length,
                      )
                  ),*/
                  new StreamBuilder(
                      stream: Firestore.instance.collection('phone').snapshots(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData) return new Text("Loading");
                        return new ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            padding: EdgeInsets.all(8.0),
                            itemExtent: 25.0,
                            itemBuilder: (context, index) {
                              DocumentSnapshot ds = snapshot.data.documents[index];
                              _insertPhone(ds);
                            }
                        );
                      }
                  )
                ],
            ),
            decoration: Theme.of(context).platform == TargetPlatform.iOS
                ? new BoxDecoration(
              border: new Border(top: new BorderSide(color: Colors.grey[200])),
            )
                : null
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: _openRequestDialog,
          tooltip: "Request Phone",
          child: new Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.blue,
        )
    );
  }

  Future<void> _openRequestDialog() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return _buildRequestDialog();
        }
    );
  }

  Widget _buildRequestDialog() {
    return new AlertDialog(
      title: new Text("Request Phone"),
      content: new Container(
        child: new Column(
          children: <Widget>[
            new Container(
                decoration: new BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer()
            )
          ]
        )
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text("CANCEL")
        ),
        new RaisedButton(
            onPressed: () {
              _requestPhone();
              Navigator.of(context).pop();
            },
            child: new Text("SUBMIT")
        )
      ],
    );
  }

  Widget _buildTextComposer() {
    return new Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: new Row(
            children: <Widget>[
              new Flexible(
                child: new TextField(
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  //textInputAction: TextInputAction.continueAction,
                  maxLength: 100,
                  maxLines: 1,
                  controller: _textController,
                  onChanged: (String text) {
                    setState(() {
                      _isWriting = text.length > 0;
                    });
                  },
                  onSubmitted: _submitRequest,
                  decoration: new InputDecoration(
                      labelText: "Enter your name:",
                      //hintText: "Type your name",
                      icon: Icon(Icons.person)
                  ),
                ),
              ), //automatically size the text field to use the remaining space that isn't used by the button
              /*new Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Theme.of(context).platform == TargetPlatform.iOS ?
                  new CupertinoButton(
                    child: new Text("Send"),
                    onPressed: _isWriting ? () => _submitRequest(_textController.text) : null,
                  ) :
                  new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: _isWriting ? () => _submitRequest(_textController.text) : null, // null automatically disables button
                    //color: Theme.of(context).accentColor
                  )
              )*/
            ]
        ),
    );
  }

  @override
  void dispose() {
    for (PhoneRequestListItem request in _requests)
      request.animationController.dispose();

    super.dispose();
  }

  // Aux functions
  void _requestPhone() {
    setState(() {

    });
  }

  void _submitRequest(String requester) {

    _textController.clear();
    setState(() {
      _isWriting = false;
    });

    PhoneRequestListItem request = new PhoneRequestListItem(
      requestName: requester,
      animationController: new AnimationController(
          duration: new Duration(milliseconds: 700),
          vsync: this
      ),
    );

    // Only sync operations
    setState(() {
      _requests.insert(0, request);
    });
    request.animationController.forward();
  }

  void _insertPhone(DocumentSnapshot phone) {

  }
}

class PhoneRequestListItem extends StatelessWidget {

  PhoneRequestListItem({this.requestName, this.animationController});
  final String requestName;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {

    const _name = "Requested by";

    return new SizeTransition(
        sizeFactor: new CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: new Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            // Row: main axis is horizontal; cross axis alignment start gives the highest position on the vertical axis
            child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: new CircleAvatar(child: new Text(_name[0]))
                    // Replace with Image: phone image
                    // child: new Image.asset('images/lake.jpg',height: 60.0,fit: BoxFit.cover)
                  ),
                  // Column: main axis is vertical; cross axis alignment start gives the furthest left position on the horizontal axis
                  new Expanded(
                    child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(_name, style: Theme.of(context).textTheme.button),
                          new Container(
                              margin: const EdgeInsets.only(top: 5.0),
                              child: new Text(requestName)
                          )
                        ]
                    ),
                  ),
                ]
            )
        )
    );
  }
}

class PhoneListItem extends PhoneRequestListItem {

}