import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:instant/instant.dart';
import 'package:jio/app/home/models/friend.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/home/events/CategoryDropDownList.dart';
import 'package:jio/app/home/events/invite_list.dart';
import 'package:jio/app/home/events/participants_list.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/common_widgets/platform_alert_dialog.dart';
import 'package:jio/common_widgets/platform_exception_alert_dialog.dart';
import 'package:jio/services/auth.dart';
import 'package:jio/services/database.dart';
import '../../../common_widgets/date_time_picker.dart';
import '../../../services/database.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage(
      {Key key, @required this.database, this.event, this.specialInvite})
      : super(key: key);
  final Database database;
  final Event event;
  final Friend specialInvite;

  static Future<void> show(
    BuildContext context, {
    Database database,
    Event event,
    Friend specialInvite,
  }) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => EditEventPage(
          database: database,
          event: event,
          specialInvite: specialInvite,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();

  bool error;
  String _name;
  String _location;
  Map<String, dynamic> _category;
  List<String> _participants = [];
  static DateTime _startDate = dateTimeByUtcOffset(offset: 8);
  TimeOfDay _startTime = TimeOfDay.fromDateTime(_startDate);
  String hostid;
  bool _isLoading = false;
  List<int> _selectedList = [];
  List<String> _inviteList = [];
  String _description;
  FocusNode _focusNode = new FocusNode();
  bool _submitting = false;
  double averageLevel;

  callback(newlist, selectedList) {
    setState(() {
      _selectedList = selectedList;
      _inviteList = newlist;
    });
  }

  callback2(category) {
    setState(() {
      _category = category;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _name = widget.event.name;
      _location = widget.event.location;
      _participants = widget.event.participants;
      _description = widget.event.description;
      _category = widget.event.category;
      _startDate = DateTime.fromMillisecondsSinceEpoch(widget.event.startDate,
          isUtc: true);
      _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
      averageLevel = widget.event.averageLevel;
    }
  }

  bool _validateAndSaveForm() {
    setState(() {
      _submitting = true;
    });
    final form = _formKey.currentState;
    if (form.validate() && _category != null) {
      form.save();
      return true;
    }
    return false;
  }

  DateTime combine(DateTime date, TimeOfDay time) {
    return new DateTime(
        date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _delete(Event event) async {
    try {
      final didRequestSignOut = await PlatformAlertDialog(
        title: 'Delete',
        content: 'Are you sure that you want to delete the event?',
        cancelActionText: 'Cancel',
        defaultActionText: 'Delete',
      ).show(context);
      if (didRequestSignOut == true) {
        setState(() {
          _isLoading = true;
        });
        await widget.database.deleteEvent(event);
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        setState(() {
          _isLoading = true;
        });
        var currentStartDate =
            combine(_startDate, _startTime).toUtc().millisecondsSinceEpoch;
        final id = widget.event?.id ?? documentIdFromCurrentDate();
        final auth = Provider.of<AuthBase>(context);
        final User user = await auth.firebaseToUser(widget.database.host);
        hostid = widget.event?.hostid ?? user.uid;
        if (widget.event == null) {
          _participants.add(user.uid);
          averageLevel = user.expToLevel(user.exp).floorToDouble();
          FirebaseMessaging().subscribeToTopic(id);
        }

        final event = Event(
          id: id,
          name: _name,
          location: _location,
          hostid: hostid,
          startDate: currentStartDate,
          category: _category,
          participants: _participants,
          hostPhotoURL: user.photoUrl,
          hostDisplayName: user.displayName,
          description: _description,
          averageLevel: averageLevel,
        );
        await widget.database.setEvent(event);
        if (_inviteList.isNotEmpty) {
          await widget.database.createInviteList(_inviteList, id, user.uid);
        }
        if (widget.event == null) {
          await widget.database.createGroupConversation(context, event);
        }
        setState(() {
          _isLoading = false;
          PlatformAlertDialog(
            title: 'Event ${widget.event != null ? "updated" : "created"}',
            content: 'Success',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          widget.event == null ? 'New Event' : 'Edit Event',
          style: TextStyle(
            fontFamily: 'KaushanScript',
            color: Colors.white,
            fontSize: 32.0,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            color: Colors.transparent,
            child: Text(
              'Delete',
              style: TextStyle(
                  fontSize: 18,
                  color: widget.event != null
                      ? Colors.redAccent
                      : Colors.transparent),
            ),
            onPressed: () {
              if (widget.event != null) {
                _delete(widget.event);
              }
            },
          ),
          FlatButton(
            child: Text(
              'Submit',
              style: TextStyle(fontSize: 18, color: Colors.yellowAccent),
            ),
            onPressed: _submit,
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: FocusWatcher(
        child: ModalProgressHUD(
          inAsyncCall: _isLoading,
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                child: _buildContents(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(context),
      ),
    );
  }

  List<Widget> _buildFormChildren(BuildContext context) {
    return [
      TextFormField(
        decoration: InputDecoration(labelText: 'Event name'),
        initialValue: _name,
        validator: (value) => value.isNotEmpty ? null : 'Name can\'t be empty',
        onSaved: (value) => _name = value,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Location'),
        initialValue: _location,
        validator: (value) =>
            value.isNotEmpty ? null : 'Location can\'t be empty',
        onSaved: (value) => _location = value,
      ),
      _dateCategory(),
      ParticipantsList(
        database: widget.database,
        event: widget.event ?? null,
        edit: widget.event != null,
      ),
      InvitePlayersList(
        database: widget.database,
        participants: _participants,
        specialInvite: widget.specialInvite,
        callback: callback,
        selectedList: _selectedList,
      ),
      _describe(context),
    ];
  }

  Widget _dateCategory() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: DateTimePicker(
              labelText: 'Start',
              selectedDate: _startDate,
              selectedTime: _startTime,
              onSelectedDate: (date) => setState(() {
                    _startDate = date;
                  }),
              onSelectedTime: (time) => setState(() {
                    _startTime =
                        combine(_startDate, time).isBefore(DateTime.now())
                            ? TimeOfDay.fromDateTime(DateTime.now())
                            : time;
                  })),
        ),
        SizedBox(
          width: 12.0,
        ),
        Expanded(
          flex: 5,
          child: CategoryDropDownList(
            database: widget.database,
            submitting: _submitting,
            preSelectedValue: _category != null ? _category['name'] : null,
            callback: callback2,
            hint: _hint(),
          ),
        ),
      ],
    );
  }


  Widget _hint(){
    return InputDecorator(
      decoration: InputDecoration(
        labelText: "Category",
        border: InputBorder.none,
      ),
      baseStyle: TextStyle(fontSize: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Pick one", style: TextStyle(fontSize: 14)),
          Icon(Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade700
                  : Colors.white70),
        ],
      ),
    );
  }

  Widget _describe(BuildContext context) {
    return TextFormField(
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: 'Description',
          hintText: 'Optional',
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        maxLines: null,
        initialValue: _description != null ? _description : null,
        onSaved: (value) {
          FocusScope.of(context).requestFocus(_focusNode);
          _description = value;
        });
  }
}
