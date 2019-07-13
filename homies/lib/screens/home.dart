import 'dart:io';

import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

import 'package:homies/screens/profile.dart';
import 'package:homies/screens/settings.dart';

import "../items/message.dart";
import "../items/image.dart";

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textEditingController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  File _media;

  Future<bool> getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return false;
    } else {
      setState(() {
        _media = image;
      });

      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HOMIE CHAT")),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('HOMIE CHAT'),
              decoration: BoxDecoration(
                color: Colors.blue
              ),
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                print("Profile");
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            ListTile(
              title: Text("Gallery"),
              onTap: () {
                print("Gallery");
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text("Settings"),
              onTap: () {
                print("Settings");
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
              },
            )
          ],
        )
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            )
          ),
          new Divider(height: 1.0),
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          )
        ],
      ),
    );
  }

  _handleSubmittedMessage(String text) {
    _textEditingController.clear();
    ChatMessage message = new ChatMessage(text: text, media: _media);
    setState(() {
      _messages.insert(0, message);
      _media = null;
    });
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Container(
              //margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () async {
                  showModalBottomSheet(context: context, builder: (BuildContext context) {
                    return new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new ListTile(
                          leading: new Icon(Icons.camera_alt),
                          title: new Text('Camera'),
                          onTap: () {
                            print("camera");
                            Navigator.pop(context);
                          }
                        ),
                        new ListTile(
                          leading: new Icon(Icons.photo_album),
                          title: new Text('Gallery'),
                          onTap: () {
                            print("Gallery");
                            Navigator.pop(context);
                          }
                        ),
                      ],
                    );
                  });
                  /*var result = await getImage();
                  if (result == true) {
                    /_handleSubmittedMessage("");
                  }*/
                },
              ),
            ),
            Flexible(
              child: TextField(
                controller: _textEditingController,
                minLines: 1,
                maxLines: 8,
                decoration: InputDecoration.collapsed(hintText: "Message"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _handleSubmittedMessage(_textEditingController.text),
              ),
            )
          ],
        )
      ),
    );
  }
}