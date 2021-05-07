import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import '../db_helper.dart';
import 'enterNewPassword.dart';

class AccountLock extends StatefulWidget {
  final usernameLogIn;
  final login;

  AccountLock({Key key, @required this.usernameLogIn, this.login}) : super(key: key);
  @override
  _AccountLock createState() => _AccountLock();
}

class _AccountLock extends State<AccountLock> {
  final db = RapidA();
  final otpCode = TextEditingController();
  List mobileList;
  var mobileNumber="";
  var realMobileNumber="";
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  String warning = "";
  String alert = "";


  checkOtpCode() async{
    var res = await db.checkOtpCode(otpCode.text,realMobileNumber);
    if(res == 'true'){
      otpCode.clear();
        Navigator.of(context).push(_enterNewPassword(realMobileNumber,widget.login));
    }
    if(res == 'false'){
      warning = "Notice!";
      alert = "You entered an invalid OTP code";
      alertDialog(alert, warning);
    }
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future getUserDetails() async{
    var res = await db.getUserDetails(widget.usernameLogIn);
    if (!mounted) return;
    setState(() {
      mobileList = res['user_details'];
      mobileNumber = mobileList[0]['mobile_number'];
      realMobileNumber = mobileList[0]['mobile_number'];
      var re = RegExp(r'\d(?!\d{0,2}$)'); // keep last 3 digits
      mobileNumber = mobileNumber.replaceAll(re, '*'); // ------789
    });

  }

  Future sendOtp() async{
    otpCode.clear();
    saveOTPNumber(realMobileNumber);
  }

  Future saveOTPNumber(realMobileNumber) async{
    db.saveOTPNumber(realMobileNumber);
  }


  @override
  void initState(){
    getUserDetails();
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
        title: Text("Enter OTP",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
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
                      Padding(padding: EdgeInsets.fromLTRB(35, 20, 25, 5),
                        child: new Text(
                          "Your account has been locked due to many log-in attempts.",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                        child: new Text(
                          "Please reset your password here",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                        child: new Text(
                          "Enter OTP CODE sent to: $mobileNumber",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                        child: new Text(
                          "OTP code",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child: new TextFormField(
                          textInputAction: TextInputAction.done,
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: otpCode,
                          validator: (value){
                            if (value.isEmpty) {
                              return 'Please enter the OTP code';
                            }
                            return null;
                          },
                          decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
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
                        padding:EdgeInsets.fromLTRB(40, 20, 40, 0),
                        child:Container(
                          width: 50.0,
                          // child: FlatButton(
                          //   disabledColor: Colors.grey,
                          //   child: Text('Send OTP code'),
                          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                          //   onPressed: (){
                          //     setState(() {
                          //       sendOtp();
                          //     });
                          //   },
                          // ),
                          child: OutlineButton(
                            borderSide: BorderSide(color: Colors.deepOrange),
                            highlightedBorderColor: Colors.deepOrange,
                            highlightColor: Colors.transparent,
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                            onPressed: (){
                                setState(() {
                                  sendOtp();
                                  // Fluttertoast.showToast(
                                  //     msg: "OTP is sent to your phone number",
                                  //     toastLength: Toast.LENGTH_SHORT,
                                  //     gravity: ToastGravity.BOTTOM,
                                  //     timeInSecForIosWeb: 2,
                                  //     backgroundColor: Colors.black.withOpacity(0.7),
                                  //     textColor: Colors.white,
                                  //     fontSize: 16.0
                                  // );
                                });
                            },
                            child: Text("Send OTP code"),
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
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (_key.currentState.validate()) {
                    // Navigator.of(context).push(_gcPickUpFinal(groupValue,_deliveryTime.text,_deliveryDate.text,_modeOfPayment.text));
                    checkOtpCode();
                  }
                },
                style: SleekButtonStyle.flat(
                  color: Colors.deepOrange,
                  inverted: false,
                  rounded: false,
                  size: SleekButtonSize.big,
                  context: context,
                ),
                child: Center(
                  child: Text(
                    "Confirm",
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

Route _enterNewPassword(realMobileNumber,login) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => EnterNewPassword(realMobileNumber:realMobileNumber,login:login),
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


