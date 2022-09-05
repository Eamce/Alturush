import 'dart:convert';
import 'dart:io';

import 'package:arush/profile/addNewAddress.dart';
import 'package:arush/submit_order_paymaya.dart';
import 'package:arush/submit_paymaya.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'db_helper.dart';
import 'create_account_signin.dart';
import 'package:intl/intl.dart';
import 'package:sleek_button/sleek_button.dart';
import 'discountManager.dart';
import 'track_order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class SubmitOrder extends StatefulWidget {
  final paymentMethod;
  final deliveryDateData;
  final deliveryTimeData;
  final getTenantData;
  final getTenantNameData;
  final getBuNameData;
  final subtotal;
  final grandTotal;
  final specialInstruction;
  final deliveryCharge;


  SubmitOrder(
      {Key key,
      @required
        this.paymentMethod,
        this.deliveryDateData,
        this.deliveryTimeData,
        this.getTenantData,
        this.getTenantNameData,
        this.getBuNameData,
        this.subtotal,
        this.grandTotal,
        this.specialInstruction,
        this.deliveryCharge
      })
      : super(key: key);

  @override
  _SubmitOrder createState() => _SubmitOrder();
}

class _SubmitOrder extends State<SubmitOrder> {
  var amountTender = TextEditingController();
  final changeFor = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;
  bool exist = false;
  String comma;
  String separator;

  List loadCartData = [];
  List getBu;
  List getTenant;
  List getItemsData;
  List placeOrder;
  List getItemsData2;

  List<String> productName = [];
  List<String> price = [];
  List<String> quantity = [];
  List<String> totalPrice = [];


  String placeOrderTown;
  String placeOrderBrg;
  String placeContactNo;
  String placeRemarks;
  String street;
  String userName;
  String houseNo;

  double deliveryCharge = 0.00;
  double grandTotal = 0.0;
  double minimumAmount = 0.0;
  double amt;
  var subtotal = 0.0;
  var townId, barrioId;
  var stores;
  var items;

  _placeOrder() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('street', widget.street);
    // prefs.setString('houseNo', widget.houseNo);
    // prefs.setString('houseNo', widget.houseNo);
    // prefs.setString('placeRemark', widget.placeRemark);

    await db.placeOrder(
      widget.deliveryDateData,
      widget.deliveryTimeData,
      widget.getTenantData,
      widget.specialInstruction,
      widget.deliveryCharge,
      amountTender.text
        );
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

  Future getPlaceOrderData() async{
    var res = await db.getPlaceOrderData();
    if (!mounted) return;
    setState(() {
      placeOrder = res['user_details'];
      deliveryCharge = double.parse(placeOrder[0]['d_charge_amt']);
      townId = placeOrder[0]['d_townId'];
      barrioId = placeOrder[0]['d_brgId'];
      placeOrderTown = placeOrder[0]['d_townName'];
      placeOrderBrg = placeOrder[0]['d_brgName'];
      placeContactNo = placeOrder[0]['d_contact'];
      placeRemarks = placeOrder[0]['land_mark'];
      street = placeOrder[0]['street_purok'];
      // houseNo = placeOrder[0]['complete_address'];
      userName = ('${placeOrder[0]['firstname']} ${placeOrder[0]['lastname']}');
      deliveryCharge = double.parse(placeOrder[0]['d_charge_amt']);
      grandTotal = deliveryCharge + subtotal;
      minimumAmount = double.parse(placeOrder[0]['minimum_order_amount']);
      getTenantSegregate();
      isLoading = false;
    });
  }

  Future loadCart() async {
    var res = await db.loadCartData();
    if (!mounted) return;
    setState(() {

      loadCartData = res['user_details'];
      items = loadCartData.length;
      isLoading = false;
    });
  }

  Future checkIfHasId() async{
    var res = await db.checkIfHasId();
    if (!mounted) return;
    setState(() {
      if(res == 'true'){
        exist = true;
      }else{
        exist = false;
      }
    });
  }

  Future loadId() async{
    var res = await db.displayId();
    if (!mounted) return;
    setState(() {
      loadIdList = res['user_details'];
      isLoading = false;
      print(loadIdList);
    });
  }

  void change(String amount){
    print(amount);
    amt = double.parse(amount);
    // amountTender.text = oCcy.format(amt).toString();
    if(amt < widget.grandTotal) {
      print('insufficient amount');
      changeFor.text = '';
    } else {
      double change = amt - widget.grandTotal;
      changeFor.text = oCcy.format(change).toString();
      print(change);
    }
  }

  void displayBottomSheet(BuildContext context, tenantId, buName, tenantName) async {
    var res = await db.displayOrder(tenantId);
    var index  = 0;
    if (!mounted) return;
    setState(() {
      getItemsData2 = res['user_details'];
      // while(productName.length > getItemsData2.length-1){
      //     productName.removeAt(index);
      // }
      productName.clear();

      for(int q=0;q<getItemsData2.length;q++) {

        productName.insert(q, getItemsData2[q]['product_name']);
        price.insert(q, getItemsData2[q]['price']);
        quantity.insert(q, getItemsData2[q]['quantity']);
        totalPrice.insert(q,getItemsData2[q]['total_price']);
      }

      print(getItemsData2);
      print(productName);
      // print(price);
      // print(quantity);
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
            child: ListView(
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      SizedBox(height:10.0),
                      Padding(
                        padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                        child:Text(buName+" - "+tenantName,style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(18.0, 0.0, 0.0, 0.0),
                            child:Text("Product Details",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 18.0, 10.0),
                            child:Text("Total Price",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                          ),
                        ],
                      ),
                      Scrollbar(
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: getItemsData2 == null ? 0 : getItemsData2.length,
                          itemBuilder: (BuildContext context, int index) {
                            var f = index;
                            f++;
                            return Padding(
                              padding: EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 0.0),
                              child: Container(
                                child:Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "$f. ${productName[index]} (x ${quantity[index]})",
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontStyle: FontStyle.normal,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.0),
                                                overflow: TextOverflow.ellipsis,),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "₱${totalPrice[index]}",
                                                        style: TextStyle(
                                                            color: Colors.deepOrangeAccent,
                                                            fontStyle: FontStyle.normal,
                                                            fontWeight: FontWeight.normal,
                                                            fontSize: 15.0),
                                                      ),
                                                    ],
                                                  )
                                              ),
                                            ],
                                          ),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(18.0, 0.0, 0.0, 0.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "₱${price[index]}",
                                                      style: TextStyle(
                                                          color: Colors.black54,
                                                          fontStyle: FontStyle.normal,
                                                          fontWeight: FontWeight.normal,
                                                          fontSize: 15.0),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          )

                                        ],
                                      ),
                                    ),
                                    // Expanded(
                                    //   child: Text(
                                    //     "$f. ${productName[index]} (x ${quantity[index]})",
                                    //     style: TextStyle(
                                    //         color: Colors.black54,
                                    //         fontStyle: FontStyle.normal,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontSize: 15.0),
                                    //     overflow: TextOverflow.ellipsis,
                                    //   ),
                                    // ),


                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  placeOrderNow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if (username == null) {
      Navigator.of(context).push(_signIn());
    } else if(changeFor.text.isEmpty) {
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
              "Notice!",
              style: TextStyle(fontSize: 18.0),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Padding(
                    padding:EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                    child: Text("Some fields is invalid or empty"),
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
    } else {
      _placeOrder();
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Thank you for using Alturush",
        confirmBtnColor: Colors.deepOrangeAccent,
        backgroundColor: Colors.deepOrangeAccent,
        barrierDismissible: false,
        onConfirmBtnTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String username = prefs.getString('s_customerId');
          if (username == null) {
            Navigator.of(context).push(_signIn());
          }
          if (username != null) {
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

  Future getLastOrder() async {
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
  }

  Future getBuSegregate() async {
    var res = await db.getBuSegregate();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
      stores = getBu.length;
    });
  }

  void displayAddresses(BuildContext context) async{
    var res = await db.displayAddresses();
    if (!mounted) return;
    setState(() {
      getItemsData = res['user_details'];
      print(getItemsData);
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
                SizedBox(height:5.0),
                Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Select your address",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),),
                      OutlinedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(10))),
                          backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                          overlayColor: MaterialStateProperty.all(Colors.black12),
                          side: MaterialStateProperty.all(BorderSide(
                            color: Colors.deepOrangeAccent,
                            width: 1.0,
                            style: BorderStyle.solid,)),
                        ),
                        onPressed:(){
                          Navigator.pop(context);
                          Navigator.of(context).push(addNewAddress());
                        },
                        child:Text("+ Add new",style: GoogleFonts.openSans(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 15.0),),
                      ),
                    ],
                  ),
                ),
                Divider(thickness: 2, color: Colors.deepOrangeAccent),
                Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Fullname",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.black),),
                      Text("Address",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.black),),
                      Text("Mobile Number",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.black),),
                    ],
                  ),
                ),
                Divider(thickness: 2, color: Colors.deepOrangeAccent),
                Scrollbar(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: getItemsData == null ? 0 : getItemsData.length,
                    itemBuilder: (BuildContext context, int index) {
                      var f= index;
                      f++;
                      return InkWell(
                        onTap: (){
                          placeOrderTown      = getItemsData[index]['d_townName'];
                          placeOrderBrg       = getItemsData[index]['d_brgName'];
                          placeContactNo      = getItemsData[index]['d_contact'];
                          placeRemarks        = getItemsData[index]['land_mark'];
                          street              = getItemsData[index]['street_purok'];
                          userName            = getItemsData[index]['firstname']+" "+getItemsData[index]['lastname'];
                          barrioId            = getItemsData[index]['d_townId'];
                          townId              = getItemsData[index]['d_brgId'];
                          updateDefaultShipping(getItemsData[index]['id'],getItemsData[index]['d_customerId']);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
                          child:Column(
                            children:[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  Text('${getItemsData[index]['firstname']} ${getItemsData[index]['lastname']}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.normal)),
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(20, 0, 5, 0),
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        // strutStyle: StrutStyle(fontSize: 16.0),
                                        text: TextSpan(
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 16),
                                            text: '${getItemsData[index]['street_purok']}, ${getItemsData[index]['d_brgName']}, ${getItemsData[index]['d_townName']}, ${getItemsData[index]['zipcode']}, ${getItemsData[index]['d_province']}'),
                                      ),
                                    ),
                                  ),
                                  // Text('${getItemsData[index]['street_purok']}, ${getItemsData[index]['d_brgName']}, ${getItemsData[index]['d_townName']}, ${getItemsData[index]['zipcode']}, ${getItemsData[index]['d_province']}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.normal)),
                                  Text('${getItemsData[index]['d_contact']}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ],
                          ),
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

  updateDefaultShipping(id,customerId) async{
    await db.updateDefaultShipping(id,customerId);
  }

  void displayOrder(tenantId) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          content: Container(
            height: 50.0, // Change as per your requirement
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
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
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
                    title: Text(
                        '$f. ${getItemsData[index]['d_prodName']} ₱${getItemsData[index]['d_price']} x ${getItemsData[index]['d_quantity']}',
                        style: TextStyle(fontSize: 15.0)),
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

  Future getTenantSegregate() async {
    var res = await db.getTenantSegregate();
    if (!mounted) return;
    setState(() {
      getTenant = res['user_details'];
      isLoading = false;
      print(getTenant);
    });
  }

  void removeDiscountId(discountID) async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Row(
            children: <Widget>[
              Text(
                'Hello!',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                  child: Center(
                      child:
                      Text(("Are you sure you want to remove this ID?"))),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.deepOrange,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: Text(
                  'Proceed',
                  style: TextStyle(
                    color: Colors.deepOrange,
                  ),
                ),
                onPressed: () async {
                  print(discountID);
                  Navigator.of(context).pop();
                  await db.deleteDiscountID(discountID);
                  loadId();
                }),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getLastOrder();
    getTenantSegregate();
    getBuSegregate();
    loadCart();
    loadId();
    checkIfHasId();
    amountTender.text = oCcy.format(widget.grandTotal).toString();
    print(widget.paymentMethod);
    print(widget.grandTotal);
    print(widget.deliveryDateData);
    print(widget.deliveryTimeData);
    print(widget.getTenantData);
    print(widget.getTenantNameData);
    print(widget.getBuNameData);
    print(widget.subtotal);
    print(widget.specialInstruction);
    print(widget.specialInstruction);

    getPlaceOrderData();
//    print(widget.deliveryDate);
//    print(widget.changeFor+"hello");
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    changeFor.dispose();
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
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.1,
          leading: IconButton(
              icon: Icon(Icons.close, color: Colors.black54),
              onPressed: () {
                Navigator.pop(context);
//              Navigator.pop(context);
//              Navigator.pop(context);
              }),
          title: Text(
            "Summary (Delivery)",
            style: GoogleFonts.openSans(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 18.0),
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
              )
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Expanded(
            child: Form(
              key: _formKey,
              child: Scrollbar(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Divider(thickness: 2, color: Colors.deepOrangeAccent,),

                    SizedBox(height: 35,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                            child: new Text(
                              "Customer Address",
                              style: GoogleFonts.openSans(
                                  color: Colors.deepOrangeAccent,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(5, 0, 15, 0),
                            child: SizedBox(width: 175,
                              child: OutlinedButton.icon(
                                onPressed: () async{
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  String username = prefs.getString('s_customerId');
                                  if(username == null){
                                    Navigator.of(context).push(_signIn());
                                  }else{
                                    displayAddresses(context);
                                  }
                                },
                                label: Text('MANAGE ADDRESS',  style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 13.0, color: Colors.white)),
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                                  backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                                  overlayColor: MaterialStateProperty.all(Colors.black12),
                                  side: MaterialStateProperty.all(BorderSide(
                                    color: Colors.deepOrangeAccent,
                                    width: 1.0,
                                    style: BorderStyle.solid,)),
                                ),
                                icon: Wrap(
                                  children: [
                                    Icon(Icons.settings_outlined, color: Colors.white, size: 18,)
                                  ],
                                ),
                              )
                            )
                          ),
                        ],
                      )
                    ),


                    Divider(thickness: 2, color: Colors.deepOrangeAccent,),

                    Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                      child: Row(
                        children: <Widget>[
                          Text("Customer", style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 14.0)),
                          Text(": ${userName.toString()}", style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14.0)),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                      child: Row(
                        children: <Widget>[
                          Text("Contact Number", style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 14.0)),
                          Text(": ${placeContactNo.toString()}", style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14.0)),
                        ],
                      ),
                    ),

                    Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                        child: Row(
                          children: <Widget>[
                            Text("Address", style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 14.0),),
                            Text(": ${street.toString()}, ${placeOrderBrg.toString()}, ${placeOrderTown.toString()}",
                                style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14.0))
                          ],
                        )
                    ),

                    Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Landmark",
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                fontSize: 14.0,),
                            ),

                            Flexible(
                                child: Text(
                                  ": ${placeRemarks.toString()}",
                                  style: GoogleFonts.openSans(fontSize: 14.0),
                                  // maxLines: 2,
                                  overflow: TextOverflow.ellipsis,)

                            ),
                          ],
                        )
                    ),

                    Divider(thickness: 2, color: Colors.deepOrangeAccent,),

                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 25, 0),
                      child: Text("TOTAL SUMMARY", style: TextStyle(fontStyle: FontStyle.normal,fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent ),),
                    ),
                    SizedBox(height: 10),

                    Divider(thickness: 2, color: Colors.deepOrangeAccent,),

                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('No. of Store(s)',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                          Text('$stores',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),

                    Divider(),

                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('No. of Item(s)',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                          Text('$items',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),

                    Divider(),

                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount Order',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                          Text('₱ ${oCcy.format(widget.subtotal)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),

                    Divider(),

                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery Fee',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                          Text('₱ ${oCcy.format(widget.deliveryCharge)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),

                    Divider(),

                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL AMOUNT TO PAY',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                          Text('₱ ${oCcy.format(widget.grandTotal)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),

                    Divider(),

                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('PAYMENT METHOD',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                          Text('Pay via CASH ON DELIVERY (COD)',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),

                    Divider(),

                    SizedBox(height: 35,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('AMOUNT TENDER  ',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                            SizedBox(width: 175,
                              child: Flexible(
                                child: new TextFormField(
                                  textAlign: TextAlign.end,
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Colors.deepOrange,
                                  controller: amountTender,
                                  onChanged: (value)  => change(value),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter some value';
                                    }if(int.parse(value) < widget.grandTotal){
                                      return 'Amount tender is lesser than your total payable';
                                    }
                                      return null;
                                    },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    // prefixIcon: Icon(Icons.insert_chart,color: Colors.grey,),
                                    contentPadding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                    focusedBorder:OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                  ),
                                ),
                              )
                            )
                          ],
                        ),
                      ),
                    ),

                    Divider(),

                    SizedBox(height: 35,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('CHANGE  ',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                            SizedBox(width: 175,
                              child: Flexible(
                                child: TextFormField(
                                  textAlign: TextAlign.end,
                                  enabled: false,
                                  cursorColor: Colors.deepOrange,
                                  controller: changeFor,
                                  decoration: InputDecoration(
                                    // prefixIcon: Icon(Icons.insert_chart,color: Colors.grey,),
                                    contentPadding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                    focusedBorder:OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                  ),
                                ),
                              )
                            ),
                          ],
                        ),
                      )
                    ),

                    Divider(),
                    Divider(thickness: 2, color: Colors.deepOrangeAccent),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                          child: new Text(
                            "APPLY DISCOUNT",
                            style: GoogleFonts.openSans(
                                color: Colors.deepOrangeAccent,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0),
                          ),
                        ),

                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                            child: SizedBox(width: 175,
                              child: OutlinedButton.icon(
                                onPressed: () async{
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  String username = prefs.getString('s_customerId');
                                  if(username == null){
                                    Navigator.of(context).push(_signIn());
                                  }else{
                                    // applyDiscount();
                                    showApplyDiscountDialog(context);
                                    loadId();
                                    // await Navigator.of(context).push(_showDiscountPerson());
                                  }
                                },
                                label: Text('MANAGE DISCOUNT',  style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 12.0, color: Colors.white)),
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                                  backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                                  overlayColor: MaterialStateProperty.all(Colors.black12),
                                  side: MaterialStateProperty.all(BorderSide(
                                    color: Colors.deepOrangeAccent,
                                    width: 1.0,
                                    style: BorderStyle.solid,)),
                                ),
                                icon: Wrap(
                                  children: [
                                    Icon(Icons.settings_outlined, color: Colors.white, size: 16,)
                                  ],
                                ),
                              ),),

                          ),


                      ],
                    ),
                    Divider(thickness: 2, color: Colors.deepOrangeAccent),

                    Scrollbar(
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            exist == false ? Padding(
                              padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
                              child: Text('No Discount Details', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 16, color: Colors.black54),),
                            ):ListView.builder(
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemCount: loadIdList == null ? 0 : loadIdList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var q = index;
                                  q++;
                                  if (selectedDiscountType.isEmpty){

                                    side.insert(index, false);
                                  }
                                  // side.add(false);
                                  return Padding(
                                    padding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                    child: Container(
                                      height: 85.0,
                                      child: Column(
                                        children: <Widget>[
                                         ListTile(
                                            title: Column(
                                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // SizedBox(height: 5,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 50.0,
                                                          height: 50.0,
                                                          decoration: new BoxDecoration(
                                                            image: new DecorationImage(
                                                              image: new NetworkImage(loadIdList[index]['d_photo']),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                                            border: new Border.all(
                                                              color: Colors.black54,
                                                              width: 0.5,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 30),
                                                            child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('${loadIdList[index]['name']} ',style: TextStyle(fontSize: 15, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black),),
                                                              Text('(${loadIdList[index]['discount_name']})',style: TextStyle(fontSize: 17,),),
                                                              Text('${loadIdList[index]['discount_no']}',style: TextStyle(fontSize: 15, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black),),
                                                            ],
                                                          )
                                                        )
                                                      ],
                                                    ),

                                                    RawMaterialButton(
                                                      onPressed:
                                                          () async {
                                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                                        String username = prefs.getString('s_customerId');
                                                        if (username == null) {
                                                          await Navigator.of(context).push(_signIn());
                                                        } else {
// sdfsdfs
                                                          removeDiscountId(loadIdList[index]['id']);
                                                          // print(loadIdList[index]['id']);
                                                        }
                                                      },
                                                      elevation: 1.0,
                                                      child:
                                                      Icon(
                                                        Icons.delete_outline, size: 30.0,
                                                        color: Colors.deepOrangeAccent,
                                                      ),
                                                      shape:
                                                      CircleBorder(),
                                                    )
                                                  ],
                                                ),
                                                Divider(),
                                              ],
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
                      ),

                    // Padding(
                    //   padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                    //   child: Text(
                    //     "Delivery Date & Time",
                    //     style: GoogleFonts.openSans(
                    //         fontWeight: FontWeight.bold,
                    //         fontStyle: FontStyle.normal,
                    //         fontSize: 17.0),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: EdgeInsets.fromLTRB(20.0, 5.0, 10.0, 5.0),
                    //   child: Text(
                    //     "${widget.deliveryDate.toString()}${separator.toString()}${widget.deliveryTime.toString()}",
                    //     style: GoogleFonts.openSans(
                    //         fontStyle: FontStyle.normal, fontSize: 17.0),
                    //   ),
                    // ),


//                        Padding(
//                          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
//                            child: Text("Ticket #: ${list[0]['d_ticket_id']}",style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 17.0),),
//                        ),

//                     Padding(
//                       padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//
// //                             Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: <Widget>[
// //                                 Text("Item(s)",style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
// // //                                Text("Amount",style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
// //                               ],
// //                             ),
// //                             Row(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: <Widget>[
// //                                 Padding(
// //                                   padding: EdgeInsets.fromLTRB(17.0,10.0, 0.0,10.0),
// //                                   child: new Text("*click tenant to view your item(s)*", style: GoogleFonts.openSans(color: Colors.deepOrange, fontStyle: FontStyle.normal,fontSize: 14.0),),
// //                                 ),
// //
// //                               ],
// //                             ),
//                           ListView.builder(
//                               physics: BouncingScrollPhysics(),
//                               shrinkWrap: true,
//                               itemCount: getBu == null ? 0 : getBu.length,
//                               itemBuilder:
//                                   (BuildContext context, int index0) {
//                                 int num = index0;
//                                 num++;
//                                 return Container(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: <Widget>[
//                                       Padding(
//                                         padding: EdgeInsets.fromLTRB(
//                                             10.0, 10.0, 0.0, 10.0),
//                                         child: Text(
//                                             '$num. ${getBu[index0]['d_bu_name'].toString()}',
//                                             style: TextStyle(
//                                                 color: Colors.deepOrange,
//                                                 fontWeight:
//                                                 FontWeight.bold,
//                                                 fontSize: 18.0)),
//                                       ),
// //                                              Padding(
// //                                                padding: EdgeInsets.fromLTRB(17.0,0.0, 0.0,10.0),
// //                                                child: Text('${getBu[index0]['d_tenant'].toString()}',style: TextStyle(fontSize: 15.0)),
// //                                              ),
//                                       ListView.builder(
//                                           physics:
//                                           BouncingScrollPhysics(),
//                                           shrinkWrap: true,
//                                           itemCount: getTenant == null ? 0 : getTenant.length,
//                                           itemBuilder:
//                                               (BuildContext context,
//                                               int index) {
//                                             return Visibility(
//                                               visible: getTenant[index]['bu_id'] != getBu[index0]['d_bu_id'] ? false : true,
//                                               child: Container(
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                   CrossAxisAlignment
//                                                       .start,
//                                                   children: <Widget>[
//                                                     Padding(
//                                                       padding: EdgeInsets.symmetric(horizontal: 15),
//                                                       child: OutlinedButton(
//                                                         onPressed: (){
//                                                           print('${widget.specialInstruction[index]}');
//                                                           print('pindota kay ...');
//                                                           // print('${widget.deliveryDate[index]}');
//                                                           // print('${widget.deliveryTime[index]}');
//                                                           print('${getTenant[index]['bu_name']}');
//                                                           print('${getTenant[index]['tenant_id']}');
//                                                           print('${getTenant[index]['tenant_name']}');
//                                                           displayBottomSheet(
//                                                               context,
//                                                               getTenant[index]['tenant_id'],
//                                                               getTenant[index]['bu_name'],
//                                                               getTenant[index]['tenant_name']);
//
//                                                         },
//                                                         style: ButtonStyle(
//                                                           overlayColor: MaterialStateProperty.all(Colors.black12),
//                                                           side: MaterialStateProperty.all(BorderSide(
//                                                               color: Colors.black54,
//                                                               width: 1.0,
//                                                               style: BorderStyle.solid)),
//                                                         ),
//                                                         child: Row(
//                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                           children: [
//                                                             Padding(
//                                                               padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
//                                                               child:
//                                                               Text('${getTenant[index]['tenant_name']}', style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 15.0, color: Colors.black54)),
//                                                             ),
//                                                             Padding(
//                                                                 padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
//                                                                 child:
//                                                                 Text('₱ ${oCcy.format(int.parse(getTenant[index]['total'].toString()))}', style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 15.0, color: Colors.black54)),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             );
//                                           }
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }),
//
//                           Divider(),
//                           SizedBox(height: 10),
//                           Padding(
//                               padding:EdgeInsets.fromLTRB(10.0, 0.0, 15.0, 5.0),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text("RIDER'S FEE ", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
//                                   Text("₱${oCcy.format(widget.deliveryCharge).toString()}", style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0))
//                                 ],
//                               )
//                           ),
//
//                           Divider(),
//                           SizedBox(height: 10),
//                           Padding(
//                               padding:EdgeInsets.fromLTRB(10.0, 0.0, 15.0, 5.0),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text("TOTAL AMOUNT TO PAY ", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
//                                   Text("₱${oCcy.format(widget.grandTotal).toString()}", style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0))
//                                 ],
//                               )
//                           ),
//                           Divider(),
//                           SizedBox(height: 10),
//                           Padding(
//                             padding: EdgeInsets.fromLTRB(10, 0, 20, 0),
//                             child: GestureDetector(
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       "Paymaya/GCash/Card",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontStyle: FontStyle.normal,
//                                           fontSize: 16.0),
//                                     ),
//                                   ),
//                                   Icon(CupertinoIcons.right_chevron),
//                                 ],
//                               ),
//                               onTap: () {
//                                 // Navigator.push(
//                                 //   context,
//                                 //   MaterialPageRoute(
//                                 //       builder: (context) =>
//                                 //           // SubmitPaymaya(
//                                 //           //     cart: widget.cartItems)
//                                 //   ),
//                                 // );
//                               },
//                             ),
//                           ),
//                           SizedBox(height: 10),
//                           Divider(),
//                           Padding(
//                             padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     "CASH",
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontStyle: FontStyle.normal,
//                                         fontSize: 16.0),
//                                   ),
//                                 ),
//                                 Radio(
//                                     activeColor: Colors.deepOrange,
//                                     value: 1,
//                                     groupValue: 1,
//                                     onChanged: (index) {}),
//                               ],
//                             ),
//                           ),
//                           Divider(),
//                           Padding(
//                             padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
//                             child: new Text("AMOUNT TENDER", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 16.0, fontWeight: FontWeight.bold),),
//                           ),
//                           Padding(
//                             padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
//                             child: new TextFormField(
//                               textInputAction: TextInputAction.done,
//                               cursorColor: Colors.deepOrange,
//                               controller: changeFor,
//                               validator: (value) {
//                                 if (value.isEmpty) {
//                                   return 'Please enter some value';
//                                 }if(int.parse(value) < widget.grandTotal){
//                                   return 'Amount tender is lesser than your total payable';
//                                 }
//                                 return null;
//                               },
//                               keyboardType: TextInputType.number,
//                               decoration: InputDecoration(
//                                 prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.grey,),
//                                 contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                                 focusedBorder:OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                                 ),
//                                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                               ),
//                             ),
//                           ),
//
//                           Divider(),
//
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: <Widget>[
//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
//                                 child: new Text(
//                                   "APPLY DISCOUNT",
//                                   style: GoogleFonts.openSans(
//                                       color: Colors.black,
//                                       fontStyle: FontStyle.normal,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16.0),
//                                 ),
//                               ),
//
//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
//                                 child: OutlinedButton.icon(
//                                   onPressed: () async{
//                                     FocusScope.of(context).requestFocus(FocusNode());
//                                     SharedPreferences prefs = await SharedPreferences.getInstance();
//                                     String username = prefs.getString('s_customerId');
//                                     if(username == null){
//                                       Navigator.of(context).push(_signIn());
//                                     }else{
//                                       // applyDiscount();
//                                       showApplyDiscountDialog(context);
//                                       // await Navigator.of(context).push(_showDiscountPerson());
//                                     }
//                                   },
//                                   label: Text('MANAGE DISCOUNT',  style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 12.0, color: Colors.black54)),
//                                   style: ButtonStyle(
//                                     overlayColor: MaterialStateProperty.all(Colors.black12),
//                                     side: MaterialStateProperty.all(BorderSide(
//                                       color: Colors.black,
//                                       width: 1.0,
//                                       style: BorderStyle.solid,)),
//                                   ),
//                                   icon: Wrap(
//                                     children: [
//                                       Icon(Icons.settings_outlined, color: Colors.black54, size: 18,)
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Divider(),
//                         ],
//                       ),
//                     ),
                  ],
                ),
              ),
            ),
          ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: SleekButton(
                      onTap: () async {
                        if (_formKey.currentState.validate()) {
                          placeOrderNow();
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
                          "CHECKOUT",
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

  showApplyDiscountDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ApplyDiscountDialog();
      },
    );
  }
}//end of class

class ApplyDiscountDialog extends StatefulWidget {
  @override
  _ApplyDiscountDialogState createState() => _ApplyDiscountDialogState();
}

class _ApplyDiscountDialogState extends State<ApplyDiscountDialog> {
  bool exist = false;
  final db = RapidA();
  bool canUpload = false;
  var isLoading = true;


  Future checkIfHasId() async{
    var res = await db.checkIfHasId();
    if (!mounted) return;
    setState(() {
      if(res == 'true'){
        exist = true;
      }else{
        exist = false;
      }
    });
  }

  Future loadId() async{
    var res = await db.displayId();
    if (!mounted) return;
    setState(() {
      loadIdList = res['user_details'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadId();
    checkIfHasId();
    print(selectedDiscountType);
//    print(widget.deliveryDate);
//    print(widget.changeFor+"hello");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))
      ),
      contentPadding: EdgeInsets.only(top: 10),
      content: Container(
        height: 450.0,
        width: 400.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.wallet_giftcard, color: Colors.black),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Text("Apply Discount ", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 18.0),),
                ),
              ],
            ),
            Divider(thickness: 2, color: Colors.deepOrangeAccent),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Text("Discount Applied List ", style: TextStyle(color: Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child:OutlinedButton(
                    onPressed: () async{
                      FocusScope.of(context).requestFocus(FocusNode());
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String username = prefs.getString('s_customerId');
                      if(username == null){
                        Navigator.of(context).push(_signIn());
                      }else{
                        showAddDiscountDialog(context);
                        checkIfHasId();
                        loadId();
                      }
                    },
                    child: Text('+ ADD',  style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 13.0, color: Colors.white)),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(25))),
                      overlayColor: MaterialStateProperty.all(Colors.black12),
                      backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                      side: MaterialStateProperty.all(BorderSide(
                        color: Colors.deepOrangeAccent,
                        width: 1.0,
                        style: BorderStyle.solid,)),
                    ),
                  ),
                ),
              ],
            ),
            Divider(thickness: 2, color: Colors.deepOrangeAccent),
            Expanded(
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    exist == false ? Padding(
                      padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
                      child: Text('No Discount Details', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 16, color: Colors.black54),),
                    ):ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: loadIdList == null ? 0 : loadIdList.length,
                      itemBuilder: (BuildContext context, int index) {
                        var q = index;
                        q++;
                        if (selectedDiscountType.isEmpty){

                          side.insert(index, false);
                        }
                        // side.add(false);
                        return Padding(
                          padding:EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                          child: Container(
                            height: 60.0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                CheckboxListTile(
                                  title: Column(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(height: 10,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('$q. ${loadIdList[index]['name']} (${loadIdList[index]['discount_name']})',style: TextStyle(fontSize: 15, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black),),
                                          // Text(' ${loadIdList[index]['discount_name']}',style: TextStyle(fontSize: 17,),),
                                          Text('${loadIdList[index]['discount_no']}',style: TextStyle(fontSize: 15, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black),),
                                        ],
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                  checkColor: Colors.deepOrange,
                                  value: side[index],
                                  onChanged: (bool value){
                                    setState(() {
                                      side[index] = value;
                                      if (value) {
                                        selectedDiscountType.add(loadIdList[index]['dicount_id']);
                                      } else{
                                        selectedDiscountType.remove(loadIdList[index]['dicount_id']);
                                      }
                                      print(value);
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ),
            )
          ],
        )
      ),
      actions: <Widget>[
        OutlinedButton(
          style: TextButton.styleFrom(
            primary: Colors.black,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          ),
          onPressed:(){
            for (int i=0;i<selectedDiscountType.length;i++){
              side[i] = false;
            }
            selectedDiscountType.clear();

            Navigator.pop(context);
          },
          child:Text("CLOSE",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 12.0),),
        ),
        OutlinedButton(
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.deepOrangeAccent,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          ),
          onPressed:(){
            if (selectedDiscountType.isEmpty){
              print('pili pd discount');
              Fluttertoast.showToast(
                  msg: "No discount applied!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.black.withOpacity(0.7),
                  textColor: Colors.white,
                  fontSize: 16.0
              );
            } else {
              print('very gud');
              Navigator.of(context).pop();
            }
          },
          child:Text("APPLY",style: GoogleFonts.openSans(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 12.0),),
        ),
      ],
    );
  }

  showAddDiscountDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AddDiscountDialog();
      },
    );
  }
}

class AddDiscountDialog extends StatefulWidget {
  @override
  _AddDiscountDialogState createState() => _AddDiscountDialogState();
}

class _AddDiscountDialogState extends State<AddDiscountDialog> {
  bool exist = false;
  final db = RapidA();
  File _image;
  bool canUpload = false;
  var isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _imageTxt = TextEditingController();
  final _idNumber = TextEditingController();
  final _name = TextEditingController();
  List loadDiscount;
  List loadDiscountID;
  List<String> _loadDiscount = [];
  List<String> _loadDiscountID = [];
  var id;
  var discountID;
  final List<String> genderItems = [
    'Male',
    'Female',
  ];
  String newFileName;
  String selectedValue;
  String discount;
  final picker = ImagePicker();

  Future checkIfHasId() async{
    var res = await db.checkIfHasId();
    if (!mounted) return;
    setState(() {
      if(res == 'true'){
        exist = true;
      }else{
        exist = false;
      }
    });
  }

  Future loadId() async{
    var res = await db.displayId();
    if (!mounted) return;
    setState(() {
      loadIdList = res['user_details'];
      isLoading = false;
    });
  }

  Future showDiscount() async{
    var res = await db.showDiscount();
    if (!mounted) return;
    setState(() {
      loadDiscount = res['user_details'];
      for (int i=0;i<loadDiscount.length;i++){
        _loadDiscount.add(loadDiscount[i]['discount_name']);
        _loadDiscountID.add(loadDiscount[i]['id']);
      }
    });
    print(loadDiscount);
    print(_loadDiscount);
    print(_loadDiscountID);
  }

  Future getDiscountID(name) async{
    var res = await db.getDiscountID(name);
    if (!mounted) return;
    setState(() {
      loadDiscountID = res['user_details'];
      print(loadDiscountID[0]['discount_id']);
      discountID = loadDiscountID[0]['discount_id'];
      print(discountID);
    });
  }


  camera() async{
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
        newFileName = _image.toString();
        _imageTxt.text = _image.toString().split('/').last;
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
      await db.uploadId(discountID,_name.text,_idNumber.text,base64Image);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      successMessage();
    }
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
                  child:Text(("Discounted ID successfully added")),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadId();
    checkIfHasId();
    showDiscount();
//    print(widget.deliveryDate);
//    print(widget.changeFor+"hello");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))
      ),
      contentPadding: EdgeInsets.only(top: 10),
      content: Container(
        height: 450.0,
        width: 400.0,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.wallet_giftcard, color: Colors.black),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Text("Apply Discount ", style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 18.0),),
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: Scrollbar(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
                          child: Text('Discount Type',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),)
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            //Add isDense true and zero Padding.
                            //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            //Add more decoration as you want here
                            //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                          ),
                          isExpanded: true,
                          hint: const Text(
                            'Select Discount Type', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 30,
                          items: _loadDiscount
                              .map((item) =>
                              DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                ),
                              ))
                              .toList(),
                          // ignore: missing_return
                          validator: (value) {
                            if (value == null) {
                              return 'Please select discount type!';
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value;
                              id = _loadDiscount.indexOf(value);
                              print(id + 1);

                              getDiscountID(selectedValue);
                            });
                            //Do something when changing the item if you want.
                          },
                          onSaved: (value) {
                            selectedValue = value.toString();
                            print(selectedValue);
                          },
                        ),
                      ),

                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                          child: Text('Full Name',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),)
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: _name,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.deepOrange.withOpacity(0.7),
                                width: 2.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            hintText: 'Full Name ex. (Lastname, Firstname)',
                            hintStyle: const TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some value!';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                          child: Text('ID. Picture',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),)
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        child:InkWell(
                          onTap: (){
                            FocusScope.of(context).requestFocus(FocusNode());
                            camera();
                          },
                          child: IgnorePointer(
                            child: TextFormField(
                              textInputAction: TextInputAction.done,
                              cursorColor: Colors.deepOrange.withOpacity(0.5),
                              controller: _imageTxt,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please capture an image!';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'No File Choosen',
                                hintStyle: const TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                                contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 25.0),
                                prefixIcon: Icon(Icons.camera_alt_outlined,color: Colors.grey,),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.deepOrange.withOpacity(0.5),
                                      width: 2.0),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                          child: Text('ID. Number',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),)
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        child:TextFormField(
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: _idNumber,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some value!';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'ID. Number',
                            hintStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                            contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 25.0),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.7),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              )
            ],
          )
        )
      ),
      actions: <Widget>[
        OutlinedButton(
          style: TextButton.styleFrom(
            primary: Colors.black,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          ),
          onPressed:(){
            Navigator.pop(context);
          },
          child:Text("CLOSE",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 12.0),),
        ),
        OutlinedButton(
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.deepOrangeAccent,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          ),
          onPressed:(){
            if (_formKey.currentState.validate()) {
              uploadId();
            }
            print(selectedValue);
            print(_name);
            print(_imageTxt);
            print(_idNumber);
          },
          child:Text("APPLY",style: GoogleFonts.openSans(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 12.0),),
        ),
      ],
    );
  }

  showAddDiscountDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ApplyDiscountDialog();
      },
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
    pageBuilder: (context, animation, secondaryAnimation) =>
        CreateAccountSignIn(),
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

Route _showDiscountPerson() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => DiscountManager(),
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

