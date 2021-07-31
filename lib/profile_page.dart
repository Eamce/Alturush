import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:flutter/cupertino.dart';
import 'profile/changePassword.dart';
import 'profile/addressMasterFile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final db = RapidA();
  var isLoading = false;

  Future loadProfile() async {

  }

  Widget yourOrder(){
    return Text("ad");
  }

  @override
  void initState() {
//    loadProfile();

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, () {
          setState(() {});
        });
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Profile",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
              )
            : ListView.builder(
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 0.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: new Stack(
                                    fit: StackFit.loose,
                                    children: <Widget>[
                                      new Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Container(
                                            width: 130.0,
                                            height: 130.0,
                                            child: Padding(
                                              padding:EdgeInsets.all(5.0),
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage("https://coachpennylove.com/wp-content/uploads/2019/08/facetune_29-07-2019-02-58-10.jpg"),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(top: 90.0, right: 90.0),
                                          child: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              GestureDetector(
                                                  onTap: () {

                                                  },
                                                  child: new CircleAvatar(
                                                    backgroundColor: Colors.white70,
                                                    radius: 20.0,
                                                    child: new Icon(
                                                      Icons.edit_outlined,
                                                      color: Colors.black87,
                                                    ),
                                                  )),
                                            ],
                                          )),
                                    ]),
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 0.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Paul jearic Niones",
                                        style: GoogleFonts.openSans(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 20.0),
                                      ),
                                    ],
                                  ),
                              ),
                              SizedBox(
                                  height: 20.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
                        child: Text("Settings",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.person,),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text("Account",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                          ],
                        ),
                      ),
                      Divider(color: Colors.black87,),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 0.0),
                        child: InkWell(
                          onTap: (){
                            Navigator.of(context).push(changePassword());
                          },
                          child: Card(
                            elevation: 0.0,
                            child: Padding(
                              padding: EdgeInsets.all(17),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Change password",style: TextStyle(fontSize: 18),),
                                  Icon(CupertinoIcons.forward,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 0.0),
                        child: InkWell(
                          onTap: (){
                            Navigator.of(context).push(addressMasterFileRoute());
                          },
                          child: Card(
                            elevation: 0.0,
                            child: Padding(
                              padding: EdgeInsets.all(17),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("View Address",style: TextStyle(fontSize: 18),),
                                  Icon(CupertinoIcons.forward,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 10.0),
                        child: InkWell(
                          onTap: () async{
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.clear();
                            // Navigator.of(context).pop();
                            // Navigator.of(context).pop();
                            // Navigator.of(context).pop();
                            // Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.of(context).push(createAccountSignInRoute());
                          },
                          child: Card(
                            elevation: 0.0,
                            child: Padding(
                              padding: EdgeInsets.all(17),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Log out",style: TextStyle(fontSize: 18),),
                                  Icon(CupertinoIcons.forward,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

Route changePassword() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ChangePassword(),
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

Route addressMasterFileRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AddressMasterFile(),
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