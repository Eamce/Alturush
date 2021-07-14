import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import '../db_helper.dart';
import 'package:arush/create_account_signin.dart';

class EnterNewPassword extends StatefulWidget {
  final realMobileNumber;
  final login;
  EnterNewPassword({Key key, @required this.login, this.realMobileNumber}) : super(key: key);
  @override
  _EnterNewPassword createState() => _EnterNewPassword();
}

class _EnterNewPassword extends State<EnterNewPassword> {
  final db = RapidA();

  final newPassWord = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  var t;
  String warning;
  String alert;

  Future changePassword() async{
    await db.changePassword(newPassWord.text,widget.realMobileNumber);
    warning = "Good job!";
    alert = "Password updated successfully";
    alertDialog(alert, warning);
  }

  alertDialog(alert, warning) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return  WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
            title: Text(
              warning,
              style: TextStyle(fontSize: 18.0),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(
                    child: Text(alert),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.deepOrange,
                  ),
                ),
                onPressed: () {
                  if(t == true){
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }if(t == 'false'){
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                  // Navigator.of(context).pushAndRemoveUntil(loginPage(), (Route<dynamic> route) => false);
                  // Navigator.of(context).popUntil(ModalRoute.withName('/loginPage'));
                  // Navigator.of(context).push(loginPage());
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState(){
    t=widget.login;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Reset password",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child:Scrollbar(
              child: Form(
                key: _key,
                child: ListView(
                  children: [
                    Padding(padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                      child: new Text(
                        "New password",
                        style: GoogleFonts.openSans(
                            fontStyle: FontStyle.normal, fontSize: 15.0),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                      child: new TextFormField(
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.deepOrange.withOpacity(0.8),
                        // obscureText: true,
                        controller: newPassWord,
                        validator: (value) {
                          // Pattern pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                          // RegExp regex = new RegExp(pattern);
                          if (value.isEmpty) {
                            return 'Please enter password';
                          }
                          // else {
                          //   if (!regex.hasMatch(value))
                          //     return 'Must be 8 in length with uppercase ang special character';
                          // }
                          return null;
                        },
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.deepOrange.withOpacity(0.8),
                                width: 2.0),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
              child: SleekButton(
                onTap: () {

                  if (_key.currentState.validate()) {
                    changePassword();
                  }
                },
                style: SleekButtonStyle.flat(
                  color: Colors.deepOrange,
                  inverted: false,
                  rounded: true,
                  size: SleekButtonSize.big,
                  context: context,
                ),
                child: Center(
                  child: Text(
                    "Reset password",
                    style: GoogleFonts.openSans(
                        fontStyle: FontStyle.normal,
                        fontSize: 14.0),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}


Route loginPage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => CreateAccountSignIn(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.decelerate;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

