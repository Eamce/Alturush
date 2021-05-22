import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'model.dart';
import 'package:intl/intl.dart';
import 'create_account_signin.dart';
import 'package:sleek_button/sleek_button.dart';
import 'track_order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class SubmitPickUp extends StatefulWidget {
  final groupValue;
  final deliveryDateData;
  final deliveryTimeData;
  final getTenantData;
  final subtotal;
  SubmitPickUp({Key key, @required this.groupValue,this.deliveryDateData,this.deliveryTimeData,this.getTenantData,this.subtotal}) : super(key: key);
  @override
  _SubmitPickUp createState() => _SubmitPickUp();
}

class _SubmitPickUp extends State<SubmitPickUp>  {
  final db = RapidA();
  final model = Model();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;
  List getBu;
  List getTenant;
  List getItemsData;

  _placeOrderPickUp() async{
    await db.savePickup(widget.deliveryDateData,widget.deliveryTimeData,widget.subtotal,'1250');
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
                            Text('$f. ${getItemsData[index]['d_prodName']} ',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
                            Text('₱${getItemsData[index]['prod_price']} x ${getItemsData[index]['d_quantity']}',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
                          ],
                        ),
                       );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
  placeOrderPickUp() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }else{
      _placeOrderPickUp();
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
                valueColor:
                new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
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
            width: 310, // Change as per your requirement

            child: Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
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

  Future getBuSegregate() async{
    var res = await db.getBuSegregate();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];

      isLoading = false;
    });
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
    getTenantSegregate();
    getBuSegregate();
    super.initState();
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
              icon: Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              }
          ),
          title: Text("Summary",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        )  : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(17.0,10.0, 0.0,10.0),
                child:Text("Pick-up your items in the following Malls and tenants"),
              ),
              Expanded(
            child:Scrollbar(
            child:ListView.builder(
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
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Icon(
                                                Icons.more_vert,
                                                color: Colors.black26,
                                                size: 25.0,
                                              ),
                                              Text('${getTenant[index]['tenant_name']}'),
                                            ],
                                          ),
                                          Text('₱${oCcy.format(int.parse(getTenant[index]['total'].toString()))}'),
                                        ],
                                      ),
                                      color: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                      onPressed: () async{
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        String username = prefs.getString('s_customerId');
                                        if(username == null){
                                          Navigator.of(context).push(_signIn());
                                        }else{
                                          displayBottomSheet(context,getTenant[index]['tenant_id'],getBu[index0]['d_bu_name'],getTenant[index]['tenant_name']);
                                        }
                                      },
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
            ),
           ),
              Divider(),
              Padding(
                padding:EdgeInsets.fromLTRB(35.0, 7.0, 5.0, 5.0),
                child: new Text("GRAND TOTAL: ₱ ${ oCcy.format(widget.subtotal).toString()}", style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: SleekButton(
                        onTap: () async {
//                          placeOrder();
                          placeOrderPickUp();
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
                            "Confirm pick up",
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
