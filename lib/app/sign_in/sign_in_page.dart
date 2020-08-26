import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/sign_in/email_sign_in_form_change_notifier.dart';
import 'package:jio/app/sign_in/sign_in_manager.dart';
import 'package:jio/common_widgets/platform_exception_alert_dialog.dart';
import 'package:jio/services/auth.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({
    Key key,
    @required this.manager,
    @required this.isLoading,
  }) : super(key: key);
  final SignInManager manager;
  final bool isLoading;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, isLoading, __) => Provider<SignInManager>(
          create: (_) => SignInManager(auth: auth, isLoading: isLoading),
          child: Consumer<SignInManager>(
            builder: (context, manager, _) => SignInPage(
              manager: manager,
              isLoading: isLoading.value,
            ),
          ),
        ),
      ),
    );
  }

  void _showSignInError(BuildContext context, PlatformException exception) {
    PlatformExceptionAlertDialog(
      title: 'Sign in failed',
      exception: exception,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    double _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(color:Colors.black),
          child: FocusWatcher(child: _buildContent(context,_deviceHeight)),
        ),
    );
  }

  Widget _buildContent(BuildContext context,_deviceHeight) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: _deviceHeight*0.25,),
          Center(
            child: _buildHeader(_deviceHeight),
          ),
          SizedBox(height: _deviceHeight*0.1),
          _signInForm(context),
          //SignInButton(
          //text: 'Sign in with email',
          //textColor: Colors.white,
          //color: Colors.teal[700],
          //onPressed: isLoading ? null : () => _signInWithEmail(context),
          //),
        ],
      ),
    );
  }

  Widget _signInForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: EmailSignInFormChangeNotifier.create(context),
      ),
    );
  }

  Widget _buildHeader(double _deviceHeight) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      height: _deviceHeight*0.2,
      width: _deviceHeight*0.2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage(
            "images/app_logo.jpeg"
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
