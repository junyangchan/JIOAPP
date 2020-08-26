import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/common_widgets/avatar.dart';
import 'package:jio/common_widgets/platform_alert_dialog.dart';
import 'package:jio/common_widgets/platform_exception_alert_dialog.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key key, @required this.user, @required this.database})
      : super(key: key);
  final User user;
  final database;

  static Future<void> show(
    BuildContext context, {
    user,
    database,
  }) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => EditProfile(user: user, database: database),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File _image;
  String _initialText;
  String _initialBio;
  bool _isChangedName = false;
  bool _isChangedPicture = false;
  bool _isBioChanged = false;
  bool _isLoading = false;
  TextEditingController _nameController;
  TextEditingController _descriptionController;
  double _deviceWidth;
  double _deviceHeight;


  @override
  void initState() {
    super.initState();
    _initialText = widget.user.displayName;
    _initialBio = widget.user.description!=null? widget.user.description:"NIL";
    _nameController = TextEditingController(text: _initialText);
    _descriptionController = TextEditingController(text: _initialBio!="NIL"?_initialBio:"");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (croppedImage != null) {
      setState(() {
        _image = croppedImage;
        _isChangedPicture = true;
      });
    }
  }

  Future _submit(BuildContext context) async {
    try {
      //upload username
      if (_isChangedName) {
        setState(() {
          _isLoading = true;
        });
        if (_initialText != null) {
          await widget.database.changeUsername(widget.user, _initialText);
          await widget.database.updateHostName(widget.user, _initialText);
        }
        setState(() {
          _isLoading = false;
        });
      }
      if (_isBioChanged) {
        setState(() {
          _isLoading = true;
        });
        if (_initialBio != null) {
          await widget.database.changeUserBio(widget.user, _initialBio);
        }
        setState(() {
          _isLoading = false;
        });
      }
      if (_isChangedPicture) {
        setState(() {
          _isLoading = true;
        });
        var url = await widget.database
            .uploadMediaMessage(widget.user.uid, _image, "_profile");
        if (widget.user.photoUrl != null) {
          await widget.database
              .deleteImage(widget.user.uid, widget.user.photoUrl);
        }
        if (url != null) {
          await widget.database.changeProfilePic(widget.user, url);
          await widget.database.updateProfilePic(widget.user, url);
        }

        setState(() {
          _isLoading = false;
        });
      }
      setState(() {
        _isChangedName = false;
        _isChangedPicture = false;
        PlatformAlertDialog(
          title: 'Profile updated',
          content: '',
          defaultActionText: 'OK',
          special: true,
        ).show(context);
      });
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      color: Colors.transparent,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "Edit Profile",
            style: TextStyle(
              fontFamily: 'KaushanScript',
              color: Colors.white,
              fontSize: 32.0,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              onPressed: () => _submit(context),
            ),
          ],
          backgroundColor: Colors.black,
        ),
        body: Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  height: (_deviceHeight -
                          kToolbarHeight -
                          MediaQuery.of(context).padding.top) *
                      0.6,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: _deviceHeight * 0.04),
                      _profilePicture(context),
                    ],
                  )),
              Container(
                height: (_deviceHeight -
                        kToolbarHeight -
                        MediaQuery.of(context).padding.top) *
                    0.4,
                width: _deviceWidth,
                padding: EdgeInsets.only(left:35.0,right: 35.0),
                child: ListView(
                  children: [
                    _buildText(context,_nameController,_initialText,"Name"),
                    Divider(color: Colors.white54,),
                    _buildText(context,_descriptionController,_initialBio,"Bio"),
                    Divider(color: Colors.white54,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context,TextEditingController _controller,String _text,String label) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white70,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _text,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white54,
                    ),
                    softWrap: true,
                    maxLines: _controller != _nameController?null:1,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white54,
                  ),
                  onPressed: () => setState(
                    () {
                      showDialog(
                        context: context,
                        child: Dialog(
                          child: _buildDialogBox(_controller,_text),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
    );
  }

  Widget _buildDialogBox(TextEditingController _controller, String initial) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            autofocus: true,
            maxLines: _controller != _nameController?null:1,
            maxLength: _controller != _nameController?null:15,
            decoration: InputDecoration(
              hintText: initial,
            ),
            style: TextStyle(color: Colors.black),
            textCapitalization: TextCapitalization.words,
            controller: _controller,
          ),
          Row(
            children: [
              Expanded(
                child: RaisedButton(
                  elevation: 0,
                  color: Colors.transparent,
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Expanded(
                child: RaisedButton(
                  elevation: 0,
                  color: Colors.transparent,
                  child: Text("Done"),
                  onPressed: () {
                    if(_controller == _nameController){
                      _isChangedName = true;
                      _initialText = _controller.text;
                    }else{
                      _isBioChanged = true;
                      _initialBio = _controller.text;
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profilePicture(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Avatar(
          image: _image ?? widget.user.photoUrl,
          radius: _deviceWidth * 0.50,
        ),
        SizedBox(
          height: _deviceHeight * 0.02,
        ),
        RaisedButton(
          color: Colors.white,
          child: Text(
            "Change Picture",
            style: TextStyle(
              fontFamily: "PermanentMarker",
              fontSize: 14.0
            ),
          ),
          onPressed: () async {
            File image = await widget.database.getImage();
            if (image != null) {
              _cropImage(image);
            }
          },
        ),
      ],
    );
  }
}
