import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {

    return new RequestListState();
  }
}

class RequestListState extends State<RequestList> {

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('request').where('status', isEqualTo: 'PENDING').snapshots(),
      builder: (context, snapshot) {

        if(!snapshot.hasData)
          return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      }
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {

    return FutureBuilder(
      future: _getPhoneNameList(snapshot),
      builder: (BuildContext context, AsyncSnapshot<List<String>> asyncSnap) {

        switch(asyncSnap.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return new Container (width: 0.0, height: 0.0);

          case ConnectionState.done:
            if (asyncSnap.error != null)
              return new Container(height: 0.0, width: 0.0);

            List<Widget> children = new List();
            for (var data in snapshot) {
              Request request = Request.fromSnapshot(data);
              children.add(_buildListItem(request, asyncSnap.data));
            }

            return ListView(
                padding: const EdgeInsets.only(top: 10.0),
                children: children
            );
          }
      }
    );
  }

  Widget _buildListItem(Request request, List<String> names) {

    return Center(
        child: Card(
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.only(left: 10.0, top: 0, bottom: 0),
                  leading: Icon(Icons.phone_iphone),
                  title: Text('Phone: ' + names[request.phoneId - 1]),
                  subtitle: Text('Requested by: ' + request.name),
                ),
                ButtonTheme.bar(
                    child: ButtonBar(
                      children: <Widget>[
                        RaisedButton(
                          child: const Text('Return Phone'),
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () {
                            _updateRequest(request);
                          },
                        )
                      ],
                    )
                )
              ],
            )
        )
    );
  }

  Future<List<String>> _getPhoneNameList(List<DocumentSnapshot> snapshot) async {

    List<String> phones = new List();
    for (var document in snapshot) {

      Request request = Request.fromSnapshot(document);
      String name;
      name = await Firestore.instance.collection('phone').where('id', isEqualTo: request.phoneId).getDocuments().then((snapshot) {
        return snapshot.documents[0]['name'];
      });

      phones.add(name);
    }

    return phones;
  }

  void _updateRequest(Request request) {

    Firestore.instance.runTransaction((transaction) async {
      await transaction.update(request.ref, {'status': 'COMPLETE'});
    });
  }
}

class Request {

  //final int id;
  final String name;
  final int phoneId;
  final String status;

  final DocumentReference ref;

  Request.fromMap(Map<String, dynamic> map, {this.ref})
    : assert(map['name'] != null),
      assert(map['phone_id'] != null),

      //id = map['id'],
      name = map['name'],
      phoneId = map['phone_id'],
      status = map['status'];

  Request.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, ref: snapshot.reference);

}
