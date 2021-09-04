import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'profile/changePassword.dart';
import 'profile/addressMasterFile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'create_account_signin.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final db = RapidA();
  File _image;
  var isLoading = true;
  List listProfile = [];
  var firstName = "";
  var profilePicture = "";
  var lastName = "";
  String newFileName;
  final picker = ImagePicker();

  Future loadProfile() async{
    var res = await db.loadProfile();
    if (!mounted) return;
    setState(() {
      listProfile = res['user_details'];
      profilePicture =  listProfile[0]['d_photo'];
      firstName = listProfile[0]['d_fname'];
      lastName = listProfile[0]['d_lname'];
      isLoading = false;
    });
  }

  camera() async{
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
        newFileName = _image.toString();
        uploadId();
        Navigator.pop(context);
      }
    });
  }

  browseGallery() async{
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
        newFileName = _image.toString();
        uploadId();
        Navigator.pop(context);
      }
    });
  }

  Future uploadId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      await Navigator.of(context).push(_signIn());
    }else{
      loading();
       String base64Image = base64Encode(_image.readAsBytesSync());
      await db.uploadProfilePic(base64Image,newFileName);
      Navigator.of(context).pop();
      successMessage();
    }
  }

  successMessage(){
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text(
            "Success!",
            style: TextStyle(fontSize: 18.0),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.fromLTRB(23.0, 0.0, 20.0, 0.0),
                  child:Text(("Profile picture successfully updated")),
                ),
              ],
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  loading(){
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          content: Container(
            height:50.0, // Change as per your requirement
            width: 10.0, // Change as per your requirement
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
            ),
          ),
        );
      },
    );
  }

  void changeProfile(BuildContext context) async{
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
        ),
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height/7.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[

                Expanded(
                  child:Container(
                    height: 400.0, // Change as per your requirement
                    // width: 300.0, // Change as per your requirement
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          InkWell(
                            onTap: (){
                              browseGallery();
                            },
                            child: Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(15, 15, 10, 15),
                                    child: Text("Gallery",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),)
                                ),
                              ],
                            ),
                        ),
                        InkWell(
                          onTap: (){
                            camera();
                          },
                          child: Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.fromLTRB(15, 15, 10, 15),
                                  child: Text("Camera",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),)
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    loadProfile();
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
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Container(
                                            width: 130.0,
                                            height: 130.0,
                                            child: Padding(
                                              padding:EdgeInsets.all(5.0),
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage(profilePicture),
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
                                                    changeProfile(context);
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
                                      Text('$firstName $lastName',
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

Route _signIn() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => CreateAccountSignIn(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
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