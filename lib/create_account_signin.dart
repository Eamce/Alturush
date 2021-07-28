import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import 'db_helper.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'showDpn.dart';
import 'dart:async';
import 'account_lock/accountLock.dart';
import 'account_lock/enterUsername.dart';

//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class CreateAccountSignIn extends StatefulWidget {
  @override
  _CreateAccountSignIn createState() => _CreateAccountSignIn();
}

class _CreateAccountSignIn extends State<CreateAccountSignIn> with SingleTickerProviderStateMixin {
  final db = RapidA();
  DateTime dateTime;
  List userData;
  List townData;
  List barrioData;
  List suffixData;
  final _usernameLogIn = TextEditingController();
  final _passwordLogIn = TextEditingController();
  final username = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final suffix = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final birthday = TextEditingController();
  final contactNumber = TextEditingController();
  final province = TextEditingController();
  final town = TextEditingController();
  final barrio = TextEditingController();
  final forgotPassUsername = TextEditingController();
  int townId;
  int barrioId;
  var isLoading = true;
  var userExist = "";
  var passwordError = "";
  var phoneNumberExist = "";
  bool checkUserName = false;
  bool checkPhoneNumber = false;
  bool checkPassword = false;


  TabController _tabController;
  @override
  void initState() {
    super.initState();
    loadTowns();
    selectSuffix();
//    loadBarrio();
    province.text = "Bohol";
    _tabController = TabController(vsync: this, length: 2);
  }

  bool validateStructure(String value){
    String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  @override
  void dispose() {
    _usernameLogIn.dispose();
    _passwordLogIn.dispose();
    username.dispose();
    firstName.dispose();
    lastName.dispose();
    suffix.dispose();
    password.dispose();
    confirmPassword.dispose();
    birthday.dispose();
    contactNumber.dispose();
    province.dispose();
    town.dispose();
    barrio.dispose();
    _tabController.dispose();
    // timer.cancel();
    super.dispose();
  }

  Future loadTowns() async {
    var res = await db.getTownsCi();
//    var res = await db.getTowns();
    if (!mounted) return;
    setState(() {
      townData = res['user_details'];
      isLoading = false;
    });
  }

  checkUsernameIfExist(text) async{
    if(text.length != 0){
      var res = await db.checkUsernameIfExist(text);
      if(!mounted) return;
      if(res == "true"){
        setState(() {
          checkUserName = true;
          userExist = "Username is already taken";
        });
      }else{
        setState(() {
          checkUserName = false;
        });
      }
    }
  }

  checkPhoneIfExist(text) async{
    if(text.length != 0){
      var res = await db.checkPhoneIfExist(text);
      if(!mounted) return;
      if(res == "true"){
        setState(() {
          checkPhoneNumber = true;
          phoneNumberExist = "Phone number is already taken";
        });
      }else{
        setState(() {
          checkPhoneNumber = false;
        });
      }
    }
  }

  Future loadBarrio() async {
    var res = await db.getBarrioCi(townId.toString());
    if (!mounted) return;
    setState(() {
      barrioData = res['user_details'];
      isLoading = false;
    });
  }

  Future selectSuffix() async {
    var res = await db.selectSuffixCi();
//    var res = await db.selectSuffix();
    if (!mounted) return;
    setState(() {
      suffixData = res['user_details'];
      isLoading = false;
    });
  }

  void selectSuffixDia() async{
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Select suffix',),
          content: Container(
            height: 200.0, // Change as per your requirement
            width: 300.0, // Change as per your requirement
            child: RefreshIndicator(
              onRefresh: selectSuffix,
              child: Scrollbar(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: suffixData == null ? 0 : suffixData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        suffix.text = suffixData[index]['suffix'];
                        Navigator.of(context).pop();
                      },
                      child: ListTile(
                        title: Text(suffixData[index]['suffix']),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                town.clear();
                barrio.clear();
                suffix.clear();
              },
            ),
          ],
        );
      },
    );
  }

  void selectTown() async {
    loadTowns();
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Select town'),
          content: Container(
            height: 400.0, // Change as per your requirement
            width: 300.0, // Change as per your requirement
            child: RefreshIndicator(
              onRefresh: loadTowns,
              child: Scrollbar(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: townData == null ? 0 : townData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        town.text = townData[index]['town_name'];
                        townId = int.parse(townData[index]['town_id']);
                        loadBarrio();
                        Navigator.of(context).pop();
                      },
                      child: ListTile(
                        title: Text(townData[index]['town_name']),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                town.clear();
                barrio.clear();
              },
            ),
          ],
        );
      },
    );
  }

  void selectBarrio() async {
    loadBarrio();
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Select barangay',),
          content: Container(
            height: 400.0,
            width: 300.0,
            child: RefreshIndicator(
              onRefresh: loadBarrio,
              child: Scrollbar(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: barrioData == null ? 0 : barrioData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap:(){
                        barrio.text = barrioData[index]['brgy_name'];
                        barrioId = int.parse(barrioData[index]['brgy_id']);
                        Navigator.of(context).pop();
                      },
                      child: ListTile(
                        title: Text(barrioData[index]['brgy_name']),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                barrio.clear();
              },
            ),
          ],
        );
      },
    );
  }
  void dpn(){
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
                child: Text("Please read our data privacy notice before proceeding.")
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Proceed',
                style: TextStyle(
                  color: Colors.deepOrange,
                ),
              ),
              onPressed: () async{
                Navigator.of(context).pop();
                await Navigator.of(context).push(_showDpn());
                // Navigator.of(context).pop();
                saveUser();
              },
            ),
          ],
        );
      },
    );
  }

  Future saveUser() async {
    // String alert;
    // String warning;
        await db.createAccountSample(
        townId.toString(),
        barrioId.toString(),
        username.text,
        firstName.text,
        lastName.text,
        suffix.text,
        password.text,
        birthday.text,
        contactNumber.text);
        _tabController.animateTo((_tabController.index + 1) % 2);
    // if (res == 'true') {
    //   Navigator.of(context).pop();
    //   warning = "Notice!";
    //   alert = "Phone number is already exist.";
    //   alertDialog(alert, warning);
    // } else {
    //   Navigator.of(context).pop();
    //   showDialog<void>(
    //     context: context,
    //     barrierDismissible: false, // user must tap button!
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(8.0))
    //         ),
    //         contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
    //         title: Text(
    //           'Success!',
    //           style: TextStyle(fontSize: 18.0),
    //         ),
    //         content: SingleChildScrollView(
    //           child: ListBody(
    //             children: <Widget>[
    //               Center(
    //                 child: Text("You can log in now"),
    //               ),
    //             ],
    //           ),
    //         ),
    //         actions: <Widget>[
    //           FlatButton(
    //             child: Text(
    //               'OK',
    //               style: TextStyle(
    //                 color: Colors.deepOrange,
    //               ),
    //             ),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //               _tabController.animateTo((_tabController.index + 1) % 2);
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
    username.clear();
    firstName.clear();
    lastName.clear();
    password.clear();
    birthday.clear();
    contactNumber.clear();
    town.clear();
    barrio.clear();
    suffix.clear();
  }

  trapInputs() {
    String alert;
    String warning;
    setState(() {

      if(username.text.isEmpty) {
        warning = "Notice!";
        alert = "Username is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }
      else if(username.text[0]==' '){
        warning = "Notice!";
        alert = "Please enter a valid username";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }
      else if(firstName.text.length < 2){
        warning = "Notice!";
        alert = "Please enter a valid first name";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }
      else if(firstName.text[0]==' '){
        warning = "Notice!";
        alert = "Please enter a valid firstname";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }
      else if (firstName.text.isEmpty ) {
        warning = "Notice!";
        alert = "First name is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }
      else if(lastName.text[0]==' '){
        warning = "Notice!";
        alert = "Please enter a valid lastname";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }
      else if (lastName.text.isEmpty) {
        warning = "Notice!";
        alert = "Last name is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }else if(lastName.text.length < 2){
        warning = "Notice!";
        alert = "Please enter a valid last name";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }
      else if (password.text.isEmpty) {
        warning = "Notice!";
        alert = "Password is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }
      else if(checkUserName == true){
        warning = "Notice!";
        alert = "Username is already taken";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }
      else if(checkPhoneNumber == true){
        warning = "Notice!";
        alert = "Phone number is already taken";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }else if(checkPassword == true){
        warning = "Notice!";
        alert = "Must be at least 8 characters long with a number and an uppercase letter";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }else if (birthday.text.isEmpty) {
        warning = "Notice!";
        alert = "Birthday is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (contactNumber.text.isEmpty) {
        warning = "Notice!";
        alert = "Contact number is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      }else if (contactNumber.text.length < 10 || contactNumber.text[0]=='0' || contactNumber.text[0]=='1' || contactNumber.text[0]=='2' || contactNumber.text[0]=='3' || contactNumber.text[0]=='4' || contactNumber.text[0]=='5' || contactNumber.text[0]=='6' || contactNumber.text[0]=='7' || contactNumber.text[0]=='8') {
        warning = "Notice!";
        alert = "Contact number is invalid.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (province.text.isEmpty) {
        warning = "Notice!";
        alert = "Province number is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (town.text.isEmpty) {
        warning = "Notice!";
        alert = "City number is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (barrio.text.isEmpty || barrioId == 0) {
        warning = "Notice!";
        alert = "Barangay is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else {
        FocusScope.of(context).requestFocus(FocusNode());
        dpn();
      }
    });
  }

  alertDialog(alert, warning) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
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
                Padding(
                  padding: EdgeInsets.fromLTRB(20,10,20,10),
                  child: Center(
                    child: Text(alert,textAlign: TextAlign.center,),
                  ),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future _getBirthDay() async {
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime newDateTime = await showRoundedDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 13),
      firstDate: DateTime(DateTime.now().year - 70),
      lastDate: DateTime(DateTime.now().year - 13),
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      borderRadius: 8.0,
    );
    if (newDateTime != null) {
      setState(() {
        dateTime = newDateTime;
        birthday.text = DateFormat("yMd").format(dateTime);
      });
    }
  }
//
//  _gSignIn() async {
//    try {
//      await _googleSignIn.signIn();
//      setState(() async {
//        SharedPreferences prefs = await SharedPreferences.getInstance();
//        prefs.setString('s_status', 'true');
//        prefs.setString('s_customerId', _googleSignIn.currentUser.id);
//        prefs.setString('s_userNameUs', _googleSignIn.currentUser.displayName);
//        Navigator.of(context).pop();
//        print(_googleSignIn.currentUser.photoUrl);
//      });
//    } catch (err) {}
//  }



  _signInCheck() {
    String alert;
    String warning;
    if(_passwordLogIn.text.isEmpty && _usernameLogIn.text.isEmpty){
      wrongAttempt = 0;
      warning = "Notice!";
      alert = "Username and password is empty.";
      alertDialog(alert, warning);
      FocusScope.of(context).requestFocus(FocusNode());
    } else if (_usernameLogIn.text.isEmpty) {
      wrongAttempt = 0;
      warning = "Notice!";
      alert = "Username/Phone # is empty";
      alertDialog(alert, warning);
      FocusScope.of(context).requestFocus(FocusNode());
    } else if (_passwordLogIn.text.isEmpty) {
      wrongAttempt = 0;
      warning = "Notice!";
      alert = "Password is empty.";
      alertDialog(alert, warning);
      FocusScope.of(context).requestFocus(FocusNode());
    } else {
      FocusScope.of(context).requestFocus(FocusNode());
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                    height: 60.0,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
      checkLogin();
    }
  }

  var wrongAttempt = 0;
  accountLockout() async{
    db.changeAccountStat(_usernameLogIn.text);
    setState(() {
      Navigator.of(context).pop();
      wrongAttempt = 0;
    });
    var login = true;
     Navigator.of(context).push(accountLock(_usernameLogIn.text,login));
    _usernameLogIn.clear();
    _passwordLogIn.clear();
  }

  Future checkLogin() async {
    String alert;
    String warning;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var res = await db.checkLogin(_usernameLogIn.text, _passwordLogIn.text);
    String lastUsername = prefs.getString('username');
    if(res == 'accountblocked'){
      wrongAttempt = 0;
      prefs.clear();
      accountLockout();
    }else{
      if(_usernameLogIn.text !=lastUsername.toString()){
        wrongAttempt = 0;
        prefs.clear();
      }
      if(res == 'wrongusername'){
        wrongAttempt = 0;
        prefs.clear();
        Navigator.of(context).pop();
        warning = "Notice!";
        alert = "Username not found";
        alertDialog(alert, warning);
      }
      if(res == 'wrongpass'){
        Navigator.of(context).pop();
        warning = "Notice!";
        alert = "Your password is incorrect";
        alertDialog(alert, warning);
        wrongAttempt +=1;
        prefs.setString('wrongAttempt', "$wrongAttempt");
        prefs.setString('username',_usernameLogIn.text);
        if(wrongAttempt == 4){
          accountLockout();
        }
      }
      if(res == 'false'){
        wrongAttempt = 0;
        prefs.clear();
        Navigator.of(context).pop();
        warning = "Notice!";
        alert = "Wrong username and password";
        alertDialog(alert, warning);
      } if(_isNumeric(res)==true){
        wrongAttempt = 0;
        var userRes = await db.getUserData(res);
        userData = userRes['user_details'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        prefs.setString('s_status', 'true');
        prefs.setString('s_customerId', userData[0]['d_customerId']);
        prefs.setString('s_userNameUs', userData[0]['d_userNameUs']);
        prefs.setString('s_firstname', userData[0]['d_firstname']);
        prefs.setString('s_lastname', userData[0]['d_lastname']);
        prefs.setString('s_contact', userData[0]['d_contact']);
        prefs.setString('s_suffix', userData[0]['d_suffix']);
        prefs.setString('s_townId', userData[0]['d_townId']);
        prefs.setString('s_brgId', userData[0]['d_brgId']);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }

  }
  bool _isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120.0),
          child: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            elevation: 0.1,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              indicatorColor: Colors.deepOrange,
              tabs: [
                Tab(
                  child: Text(
                    "Log in",
                    style: GoogleFonts.openSans(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0),
                  ),
                ),
                Tab(
                  child: Text(
                    "Sign up",
                    style: GoogleFonts.openSans(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0),
                  ),
                ),
              ],
            ),
//          title: Text(
//            "Alturush",
//            style: GoogleFonts.fasterOne(
//                color: Colors.deepOrange,
//                fontStyle: FontStyle.normal,
//                fontSize: 24.0),
//          ),
           title:Image.asset('assets/png/alturush_text_logo.png',height: 100.0,width: 130.0,),
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  //login
                  Scrollbar(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        // Padding(
                        //   padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 25.0),
                        //   child:Container(
                        //     height: 50.0,
                        //     child: SignInButton(
                        //       Buttons.FacebookNew,
                        //       text: "Sign in with facebook",
                        //       onPressed: () {
                        //         _facebookSignIn();
                        //       },
                        //     ),
                        //   ),
                        //  ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                          child: new Text(
                            "Username",
                            style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal, fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 5.0),
                          child: new TextFormField(
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            controller: _usernameLogIn,
                            decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepOrange
                                        .withOpacity(0.8),
                                    width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3.0)),
                            ),
//                        onFieldSubmitted: (String value) {
//                          FocusScope.of(context).requestFocus(textSecondFocusNode);
//                        },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                          child: new Text(
                            "Password",
                            style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal, fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                          child: new TextFormField(
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            obscureText: true,
                            controller: _passwordLogIn,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepOrange.withOpacity(0.8),
                                    width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3.0)),
                            ),
//                        onFieldSubmitted: (String value) {
//                          FocusScope.of(context).requestFocus(textSecondFocusNode);
//                        },
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(30.0, 35.0, 30.0, 55.0),
                            child: SleekButton(
                                onTap: () {
                                  _signInCheck();
                                },
                                style: SleekButtonStyle.flat(
                                  color: Colors.deepOrange,
                                  inverted: false,
                                  rounded: true,
                                  size: SleekButtonSize.big,
                                  context: context,
                                ),
                                child:Center(
                                  child: Text("Login",
                                    style: GoogleFonts.openSans(
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19.0),
                                  ),
                                ),
                            ),
                        ),
                        Center(
                          child: GestureDetector(
                              onTap: (){
                                var login = "false";
                                Navigator.of(context).push(enterUsername(login));
                               },
                              child: Text("Forgot Password")
                          ),
                        ),
                      ],
                    ),
                  ),

                  //signUp
                  Scrollbar(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                          child: new Text(
                            "Username",
                            style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal, fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                          child: new TextFormField(
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            controller: username,
                            onChanged: (text) {
                              checkUsernameIfExist(text);
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                              errorText: checkUserName == true ? userExist : null,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepOrange.withOpacity(0.8),
                                    width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3.0)),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                          child: new Text(
                            "First Name",
                            style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal, fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 5.0),
                          child: new TextFormField(
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            controller: firstName,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepOrange
                                        .withOpacity(0.8),
                                    width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3.0)),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                          child: new Text(
                            "Last Name/Suffix",
                            style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal, fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 5.0),
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: new TextFormField(
                                  textInputAction: TextInputAction.done,
                                  cursorColor:
                                      Colors.deepOrange.withOpacity(0.8),
                                  controller: lastName,
                                  decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.deepOrange
                                              .withOpacity(0.8),
                                          width: 2.0),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(3.0)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 2.0,
                              ),
                              Container(
                                width: screenWidth / 4.5,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(3.0),
                                  onTap: () {
                                    barrio.clear();
                                    selectSuffixDia();
                                  },
                                  child: IgnorePointer(
                                    child: new TextFormField(
                                      readOnly: true,
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange.withOpacity(0.8),
                                      controller: suffix,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(17.5),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepOrange.withOpacity(0.8),
                                              width: 2.0),
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(3.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                          child: new Text(
                            "Password",
                            style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal, fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                          child: new TextFormField(
                            textInputAction: TextInputAction.done,
                            cursorColor:Colors.deepOrange.withOpacity(0.8),
                            obscureText: true,
                            controller: password,
                            onChanged: (text) {
                              if(validateStructure(text) == false){
                                 setState(() {
                                   checkPassword = true;
                                   passwordError = "Must be at least 8 characters long with a number and an uppercase letter";
                                 });
                              }else{
                                setState(() {
                                  checkPassword = false;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                              errorText: checkPassword == true ? passwordError:null,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepOrange.withOpacity(0.8),
                                    width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3.0)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                          child: new Text(
                            "Birthday",
                            style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal, fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(3.0),
                            onTap: _getBirthDay,
                            child: IgnorePointer(
                              child: new TextFormField(
                                textInputAction: TextInputAction.done,
                                cursorColor: Colors.deepOrange.withOpacity(0.8),
                                readOnly: true,
                                controller: birthday,
                                decoration: InputDecoration(
                                  hintText: "MM/DD/YYYY",
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 10.0, 10.0, 25.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange
                                            .withOpacity(0.8),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3.0)),
                                ),
//                      focusNode: textSecondFocusNode,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                          child: new Text(
                            "Contact Number",
                            style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal, fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: screenWidth / 5.5,
                                child: new TextFormField(
                                  cursorColor: Colors.deepOrange.withOpacity(0.8),
                                  enabled: false,
                                  decoration: InputDecoration(
                                    hintText: "+63",
                                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                    errorText: checkPhoneNumber == true ? phoneNumberExist : null,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.deepOrange.withOpacity(0.8),
                                          width: 2.0),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(3.0)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 2.0,
                              ),
                              Flexible(
                                child: new TextFormField(
                                  maxLength: 10,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.deny(new RegExp('[.-]'))],
                                  cursorColor: Colors.deepOrange.withOpacity(0.8),
                                  controller: contactNumber,
                                  onChanged: (text) {
                                    checkPhoneIfExist(text);
                                  },
                                  decoration: InputDecoration(
                                    counterText: "",
                                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                    errorText: checkPhoneNumber == true ? phoneNumberExist : null,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.deepOrange
                                              .withOpacity(0.8),
                                          width: 2.0),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(3.0)),
                                  ),
//                            focusNode: textSecondFocusNode,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                          child: new Text(
                            "Province",
                            style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal, fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(3.0),
                            onTap: () {},
                            child: IgnorePointer(
                              child: new TextFormField(
                                readOnly: true,
                                textInputAction: TextInputAction.done,
                                cursorColor:
                                    Colors.deepOrange.withOpacity(0.8),
                                controller: province,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 10.0, 10.0, 25.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange
                                            .withOpacity(0.8),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3.0)),
                                ),
//                      focusNode: textSecondFocusNode,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                          child: new Text(
                            "Town",
                            style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal, fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 5.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(3.0),
                            onTap: () {
                              barrio.clear();
                              selectTown();
                            },
                            child: IgnorePointer(
                              child: new TextFormField(
                                readOnly: true,
                                textInputAction: TextInputAction.done,
                                cursorColor:
                                    Colors.deepOrange.withOpacity(0.8),
                                controller: town,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 10.0, 10.0, 25.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange
                                            .withOpacity(0.8),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3.0)),
                                ),
                                //                         focusNode: textSecondFocusNode,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                          child: new Text(
                            "Barangay",
                            style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal, fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(3.0),
                            onTap: () {
                              town.text.isEmpty ? print('no town selected') : selectBarrio();
                            },
                            child: IgnorePointer(
                              child: new TextFormField(
                                readOnly: true,
                                textInputAction: TextInputAction.done,
                                cursorColor: Colors.deepOrange.withOpacity(0.8),
                                controller: barrio,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 10.0, 10.0, 25.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange
                                            .withOpacity(0.8),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 25.0),
                            child: SleekButton(
                              onTap: () {
                                trapInputs();
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
                                  "Proceed",
                                  style: GoogleFonts.openSans(
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19.0),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

Route _showDpn(){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ShowDpn(),
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

Route enterUsername(login){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => EnterUsername(login:login),
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

