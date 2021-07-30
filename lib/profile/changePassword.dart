import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:arush/db_helper.dart';
import 'addNewAddress.dart';
import 'package:flutter/cupertino.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePassword createState() => _ChangePassword();
}

class _ChangePassword extends State<ChangePassword> {
  final db = RapidA();

  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Change password",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child:Scrollbar(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(25, 10, 5, 5),
                    child: new Text(
                      "Current password",
                      style: GoogleFonts.openSans(
                          fontStyle: FontStyle.normal, fontSize: 16.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Container(
                      height: 40.0,
                      child: CupertinoTextField(
                        controller: currentPassword,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black12,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),

                        style: TextStyle(fontSize: 15.0),
                        keyboardType: TextInputType.text,
                        prefix: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.vpn_key,color: Colors.black54,),
                        ),
                        cursorColor: Colors.black54,
                        // placeholder: "Old password",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1.0,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25, 10, 5, 5),
                    child: new Text(
                      "New password",
                      style: GoogleFonts.openSans(
                          fontStyle: FontStyle.normal, fontSize: 16.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Container(
                      height: 40.0,
                      child: CupertinoTextField(
                        controller: newPassword,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black12,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        style: TextStyle(fontSize: 15.0),
                        keyboardType: TextInputType.text,
                        prefix: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.vpn_key,color: Colors.black54,),
                        ),
                        cursorColor: Colors.black54,
                        // placeholder: "Old password",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 2.0,
                ),
                Flexible(
                  child: SleekButton(
                    onTap: () {
                      if (newPassword.text.isEmpty && currentPassword.text.isEmpty) {
                        showDialog<void>(
                          context: context,
                          builder:(BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                              title: Text(
                                'Hello!',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              content: SingleChildScrollView(
                                child:Padding(
                                    padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                                    child: Text("Please don't leave all the fields empty")
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                      else if(newPassword.text.isEmpty){
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                              title: Text(
                                'Hello!',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              content: SingleChildScrollView(
                                child:Padding(
                                    padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                                    child: Text("Please enter your new password")
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                      else if(currentPassword.text.isEmpty){
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                              title: Text(
                                'Hello!',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              content: SingleChildScrollView(
                                child:Padding(
                                    padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                                    child: Text("Please enter your current password")
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                      else{
                        print("hello nce kaau");
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
                      child: Text("Update password", style:TextStyle(fontStyle: FontStyle.normal,fontSize: 18.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



Route addNewAddress() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AddNewAddress(),
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
