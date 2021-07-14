import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import '../db_helper.dart';
import 'package:arush/create_account_signin.dart';
import 'accountLock.dart';

class EnterUsername extends StatefulWidget {
  final login;
  EnterUsername({Key key, @required this.login,}) : super(key: key);
  @override
  _EnterUsername createState() => _EnterUsername();
}

class _EnterUsername extends State<EnterUsername> {
  final db = RapidA();

  final findUsername = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey<FormState>();

  bool boolSignInErrorTextEmail = false;
  var signUpErrorText = "";

  Future checkUsernameIfExist(username) async{
    var res = await db.checkUsernameIfExist(username);
    if (!mounted) return;
    setState(() {
      // checkUsernameIfExistVar = res;
      if(res == "true"){
        boolSignInErrorTextEmail = true;
        Navigator.of(context).push(accountLock(username,widget.login));
        findUsername.clear();
      }if(res == "false"){
        if (!mounted) return;
        setState(() {
          boolSignInErrorTextEmail = false;
          signUpErrorText = "Username not found";
        });
      }
    });
  }

  @override
  void initState(){

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
        title: Text("Find username",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
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
                        "Enter Username",
                        style: GoogleFonts.openSans(
                            fontStyle: FontStyle.normal, fontSize: 15.0),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                      child: new TextFormField(
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.deepOrange.withOpacity(0.8),
                        controller: findUsername,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                          errorText: boolSignInErrorTextEmail == false ? signUpErrorText : null,
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
                    // changePassword();
                    checkUsernameIfExist(findUsername.text);
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
                    "Next",
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



Route accountLock(_usernameLogIn,login){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AccountLock(usernameLogIn:_usernameLogIn,login:login),
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
