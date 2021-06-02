import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'create_account_signin.dart';
import 'package:intl/intl.dart';
import 'package:sleek_button/sleek_button.dart';
import 'track_order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class SubmitOrder extends StatefulWidget {
  final int townId;
  final int barrioId;
  final String contactNo;
  final String placeRemark;
  final String specialInstruction;
  final String placeOrderTown;
  final String placeOrderBrg;
  final String street;
  final String houseNo;
  final String changeForText;
  final double deliveryCharge;
  final double grandTotal;
  final groupValue;
  final deliveryDate;
  final deliveryTime;

  SubmitOrder({Key key, @required this.changeForText, this.townId, this.barrioId, this.contactNo,this.placeRemark,this.specialInstruction,this.placeOrderTown,this.placeOrderBrg,this.street,this.houseNo,this.deliveryCharge,this.grandTotal,this.groupValue,this.deliveryDate,this.deliveryTime}) : super(key: key);

  @override
  _SubmitOrder createState() => _SubmitOrder();
}

class _SubmitOrder extends State<SubmitOrder>  {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;
  String comma;
  String separator;


  List getBu;
  List getTenant;
  List getItemsData;

  _placeOrder() async{
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('street', widget.street);
    // prefs.setString('houseNo', widget.houseNo);
    // prefs.setString('houseNo', widget.houseNo);
    // prefs.setString('placeRemark', widget.placeRemark);

    await db.placeOrder(widget.townId.toString(),widget.barrioId.toString(),widget.contactNo,widget.placeRemark,widget.specialInstruction,widget.houseNo,widget.changeForText,widget.street,widget.deliveryCharge.toString(),widget.deliveryDate.toString(),widget.deliveryTime.toString(),widget.groupValue.toString());
    //
    // print(widget.townId.toString());
    // print(widget.barrioId.toString());
    // print(widget.contactNo);
    // print(widget.placeRemark);
    // print(widget.houseNo);
    // print(widget.changeForText);
    // print(widget.street);
    // print(widget.deliveryCharge.toString());
    // print(widget.deliveryDate.toString());
    // print(widget.deliveryTime.toString());
    // print(widget.groupValue.toString());

  }

  void displayBottomSheet(BuildContext context,tenantId,buName,tenantName) async{
    var res = await db.displayOrder(tenantId);
    if (!mounted) return;
    setState(() {
      getItemsData = res['user_details'];

    });
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
        ),
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height  * 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                SizedBox(height:10.0),
                Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                  child:Text(buName+"-"+tenantName,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                ),
                Scrollbar(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: getItemsData == null ? 0 : getItemsData.length,
                    itemBuilder: (BuildContext context, int index) {
                      var f = index;
                      f++;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 5.0),
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
//                            Text('$f. ${getItemsData[index]['d_bu_name']} - ${getItemsData[index]['d_tenant']} ',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
//                            Text('₱${oCcy.format(double.parse(getItemsData[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                            Text('$f. ${getItemsData[index]['d_prodName']} ',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
//                            Text('₱${getItemsData[index]['prod_price']}',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
                            Text('₱${getItemsData[index]['prod_price']} x ${getItemsData[index]['d_quantity']}',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
                          ],
                        ),
//                          child: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  placeOrder() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }else{
      _placeOrder();
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Thank you for using Alturush",
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
  }

  Future getLastOrder() async{
//    await db.placeOrder(widget.townId.toString(),widget.barrioId.toString(),widget.contactNo,widget.placeRemark,widget.houseNo,widget.changeFor,widget.street);
//    var res = await model.getLastOrder();
//    if (!mounted) return;
//    setState(() {
//      list = res;
//    });
//
//    var res1 = await model.getLastItems(list[0]['d_ticket_id']);
//    if (!mounted) return;
//    setState(() {
//      list1 = res1;
//      print(list1);
//      isLoading = false;
//    });

    widget.houseNo.toString() == '' ? comma = '' : comma = ',';
    widget.deliveryTime.toString() == '' ? separator = '' : separator = ':';
  }

  Future getBuSegregate() async{
    var res = await db.getBuSegregate();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
    });
  }

  void displayOrder(tenantId) async{
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
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
            ),
          ),
        );
      },
    );

    var res = await db.displayOrder(tenantId);
    if (!mounted) return;
    setState(() {
      getItemsData = res['user_details'];
      Navigator.of(context).pop();
    });

    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          content: Container(
            height: 250.0, // Change as per your requirement
            width: 310.0, // Change as per your requirement
              child: Scrollbar(
                child: ListView.builder(
//                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: getItemsData == null ? 0 : getItemsData.length,
                  itemBuilder: (BuildContext context, int index) {
                    var f = index;
                    f++;
                    return ListTile(
                      title: Text('$f. ${getItemsData[index]['d_prodName']} ₱${getItemsData[index]['d_price']} x ${getItemsData[index]['d_quantity']}',style: TextStyle(fontSize: 15.0)),
                    );
                  },
                ),
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

  Future getTenantSegregate() async{
    var res = await db.getTenantSegregate();
    if (!mounted) return;
    setState(() {
      getTenant = res['user_details'];
      isLoading = false;
    });
  }

  @override
  void initState(){
    super.initState();
    getLastOrder();
    getTenantSegregate();
    getBuSegregate();
//    print(widget.deliveryDate);
//    print(widget.changeFor+"hello");
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
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
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
//              Navigator.pop(context);
//              Navigator.pop(context);
            }
          ),
          title: Text("Summary",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child:Scrollbar(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(17.0,10.0, 0.0,0.0),
                          child: new Text("*Edit delivery details on previous page*", style: GoogleFonts.openSans(color: Colors.deepOrange, fontStyle: FontStyle.normal,fontSize: 14.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 5.0),
                          child: Text("Delivery address",style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 17.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 5.0, 10.0, 5.0),
                          child: Text("${widget.houseNo.toString()}${comma.toString()} ${widget.street.toString()}, ${widget.placeOrderBrg.toString()}, ${widget.placeOrderTown.toString()}",style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 17.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                          child: Text("Delivery date & time",style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 17.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 5.0, 10.0, 5.0),
                          child: Text("${widget.deliveryDate.toString()}${separator.toString()}${widget.deliveryTime.toString()}",style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 17.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                          child: Text("Contact Number",style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 17.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 5.0, 10.0, 5.0),
                          child: Text("+63${widget.contactNo.toString()}",style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 17.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                          child: Text("Landmark",style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 17.0),),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                          child: Text("${widget.placeRemark.toString()}",style: GoogleFonts.openSans(fontSize: 17.0),),
                        ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                        child: Text("Special instruction",style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 17.0),),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                        child: Text("${widget.specialInstruction.toString()}",style: GoogleFonts.openSans(fontSize: 17.0),),
                      ),

//                        Padding(
//                          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
//                            child: Text("Ticket #: ${list[0]['d_ticket_id']}",style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 17.0),),
//                        ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Divider(),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Text("Item(s)",style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
// //                                Text("Amount",style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
//                               ],
//                             ),
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 Padding(
//                                   padding: EdgeInsets.fromLTRB(17.0,10.0, 0.0,10.0),
//                                   child: new Text("*click tenant to view your item(s)*", style: GoogleFonts.openSans(color: Colors.deepOrange, fontStyle: FontStyle.normal,fontSize: 14.0),),
//                                 ),
//
//                               ],
//                             ),
                            ListView.builder(
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:  getBu == null ? 0 : getBu.length,
                                itemBuilder: (BuildContext context, int index0) {
                                  int num = index0;
                                  num++;
                                  return Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(17.0,10.0, 0.0,10.0),
                                          child: Text('$num. ${getBu[index0]['d_bu_name'].toString()}',style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold ,fontSize: 15.0)),
                                        ),
//                                              Padding(
//                                                padding: EdgeInsets.fromLTRB(17.0,0.0, 0.0,10.0),
//                                                child: Text('${getBu[index0]['d_tenant'].toString()}',style: TextStyle(fontSize: 15.0)),
//                                              ),
                                        ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:  getTenant == null ? 0 : getTenant.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              return Visibility(
                                                visible: getTenant[index]['bu_id'] != getBu[index0]['d_bu_id'] ? false : true,
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: EdgeInsets.fromLTRB(15.0,0.0, 0.0,1.0),
                                                        child: OutlineButton(
                                                          borderSide: BorderSide(color: Colors.transparent),
                                                          highlightedBorderColor: Colors.deepOrange,
                                                          highlightColor: Colors.transparent,
                                                          child:Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text('${getTenant[index]['tenant_name']}'),
                                                              Text('₱${oCcy.format(int.parse(getTenant[index]['total'].toString()))}'),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                        ),
                                      ],
                                    ),
                                  );
                                }
                            ),
//                            ListView.builder(
//                                physics: BouncingScrollPhysics(),
//                                shrinkWrap: true,
//                                itemCount:  list1 == null ? 0 : list1.length,
//                                itemBuilder: (BuildContext context, int index) {
//                                      return Row(
//                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                        children: <Widget>[
//                                        Flexible(
//                                          flex: 3,
//                                          child: Text(list1[index]['d_items'],overflow: TextOverflow.ellipsis,style: GoogleFonts.openSans(fontSize: 17.0),),
//                                        ),
//                                        Flexible(
//                                          flex: 2,
//                                          child: Text("₱ ${oCcy.format(double.parse(list1[index]['d_price']))} x ${list1[index]['d_qty']}",style: TextStyle(fontSize: 17.0),),
//                                        ),
//                                   ],
//                                );
//                              }
//                            ),

                            Divider(),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: new Text("Rider's fee: ₱${oCcy.format(widget.deliveryCharge)}", style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: new Text("GRAND TOTAL: ₱${oCcy.format(widget.grandTotal)}", style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 23.0),),
                                ),
                              ],
                            ),
                            Divider(),

                          ],
                        ),
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
                        placeOrder();
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
                            "Confirm order",
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

