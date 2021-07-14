import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../db_helper.dart';
import 'package:intl/intl.dart';
import 'package:sleek_button/sleek_button.dart';
import '../track_order.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arush/create_account_signin.dart';

class GcPickUpFinal extends StatefulWidget {
  final groupValue;
  final deliveryDateData;
  final deliveryTimeData ;
  final buNameData;
  final buData ;
  final totalData ;
  final convenienceData;
  final placeRemarksData;
  final modeOfPayment;
  GcPickUpFinal({Key key, @required this.groupValue,this.deliveryDateData,this.deliveryTimeData,this.buNameData,this.buData,this.totalData,this.convenienceData,this.placeRemarksData,this.modeOfPayment}) : super(key: key);
  @override
  _GcPickUpFinal createState() => _GcPickUpFinal();
}

class _GcPickUpFinal extends State<GcPickUpFinal> {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = false;
  var totalLoading = true;
  var timeCount;
  var bill = 0.0;
  var conFee = 0.0;
  var grandTotal = 0.0;
  var minimumAmount = 0.0;
  var lt = 0;
  List getBillList,getConFeeList,getBuName;
  List<String> billPerBu = [];


  getBill() async{
    var res = await db.getBill();
    if (!mounted) return;
    setState((){
      totalLoading = false;
      getBillList = res['user_details'];
      bill = double.parse(getBillList[0]['d_subtotal']);
      grandTotal = bill+(conFee*lt);
      totalLoading = false;
    });
  }

  gcGroupByBu() async{
    var res = await db.gcGroupByBu();
    if (!mounted) return;
    setState((){
      getBuName = res['user_details'];
      lt=getBuName.length;
      for(int q=0;q<getBuName.length;q++){
        billPerBu.add(getBuName[q]['total']);
      }
      totalLoading = false;
    });
  }


  getConFee() async{
    var res = await db.getConFee();
    isLoading = false;
    if (!mounted) return;
    setState(() {
      getConFeeList = res['user_details'];
      conFee = double.parse(getConFeeList[0]['pickup_charge']);
      minimumAmount = double.parse(getConFeeList[0]['minimum_order_amount']);
      // print(getConFeeList[0]['pickup_charge']);
    });
  }

  submitOrder() async{
    await db.submitOrder(widget.groupValue,widget.deliveryDateData,widget.deliveryTimeData,widget.buData,widget.totalData,widget.convenienceData,widget.placeRemarksData);
  }

  getSuccessMessage() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "Thank you for using Alturush delivery",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible:false,
      onConfirmBtnTap: () async{
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String username = prefs.getString('s_customerId');
        if(username == null){
          Navigator.of(context).push(_signIn());
        }if(username != null){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).push(_profilePageRoute());
        }
      },
    );
  }

  @override
  void initState(){
    super.initState();
    gcGroupByBu();
    getBill();
    getConFee();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.1,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed:() {
                Navigator.pop(context);
              }
          ),
          title: Text("Preview",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child:Scrollbar(
                child: ListView(
                  children: [
                    totalLoading
                        ? Padding(
                      padding:EdgeInsets.fromLTRB(20.0,20.0, 5.0, 20.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ),
                    ) : Wrap(
                      direction: Axis.horizontal,
                      children:[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:EdgeInsets.fromLTRB(20.0, 7.0, 5.0, 5.0),
                              child: new Text("Convenience Fee:", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
                            ),
                            Padding(
                              padding:EdgeInsets.fromLTRB(20.0, 7.0, 20.0, 5.0),
                              child: new Text("₱ ${oCcy.format(conFee*lt)}", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:EdgeInsets.fromLTRB(20.0, 7.0, 5.0, 5.0),
                              child: new Text("Total:", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
                            ),
                            Padding(
                              padding:EdgeInsets.fromLTRB(20.0, 7.0, 20.0, 5.0),
                              child: new Text("₱ ${oCcy.format(bill)}", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:EdgeInsets.fromLTRB(20.0, 7.0, 5.0, 5.0),
                              child: new Text("Grand Total:", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
                            ),

                            Padding(
                              padding:EdgeInsets.fromLTRB(20.0, 7.0, 20.0, 5.0),
                              child: new Text("₱ ${oCcy.format(grandTotal)}", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
                            ),
                          ],
                        ),

                        ],
                      ),
                      Divider(
                        color: Colors.black87.withOpacity(0.8),
                      ),

                      ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.buNameData == null ? 0: widget.buNameData.length,
                      itemBuilder: (BuildContext context, int index) {
                          // return Text(widget.buNameData[index]);
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 5, 5),
                                  child: new Text(widget.buNameData[index], style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 22.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 5, 5),
                                  child: new Text("Total: ₱ ${oCcy.format(double.parse(widget.totalData[index]))}", style: TextStyle(fontStyle: FontStyle.normal,fontSize: 20.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 5, 5),
                                  child: new Text("Convenience fee: "+conFee.toString(), style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 20.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 5, 5),
                                  child: new Text("Pick up date: ${widget.deliveryDateData[index]} : ${widget.deliveryTimeData[index]}" , style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 20.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
                                  child: new Text("Remarks ${widget.placeRemarksData[index]}", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 20.0),),
                                ),
                                // Padding(
                                //   padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
                                //   child: new Text(widget.placeRemarks[index], style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 18.0),),
                                // ),
                              ]);
                            }
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
                            child: new Text("MOP : ${widget.modeOfPayment}", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 20.0),),
                          ),


                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: SleekButton(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String username = prefs.getString('s_customerId');
                        if(username == null){
                          Navigator.of(context).push(_signIn());
                        }else{
                          submitOrder();
                          getSuccessMessage();
                        }
                      },
                      style: SleekButtonStyle.flat(
                        color: Colors.green,
                        inverted: false,
                        rounded: true,
                        size: SleekButtonSize.big,
                        context: context,
                      ),
                      child: Center(
                        child: Text(
                          "Submit order",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Route _profilePageRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => TrackOrder(),
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
