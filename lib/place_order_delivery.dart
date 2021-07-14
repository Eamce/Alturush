import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'submit_order.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'discountManager.dart';
import 'profile/addNewAddress.dart';
import 'create_account_signin.dart';

class PlaceOrderDelivery extends StatefulWidget {
  @override
  _PlaceOrderDelivery createState() => _PlaceOrderDelivery();
}

class _PlaceOrderDelivery extends State<PlaceOrderDelivery> with SingleTickerProviderStateMixin {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final changeFor = TextEditingController();
  final placeOrderTown = TextEditingController();
  final userName = TextEditingController();
  final placeOrderBrg = TextEditingController();
  final placeContactNo = TextEditingController();
  final placeRemarks = TextEditingController();
  final specialInstruction = TextEditingController();
  final street = TextEditingController();
  final houseNo = TextEditingController();
  final deliveryDate = TextEditingController();
  final deliveryTime = TextEditingController();
  final discount = TextEditingController();
  var subtotal = 0.0;
  List getTenant;
  List getItemsData;
  List displayAddOnsData;
  List placeOrder;
  List getBu;
  // List barrioData;
  // List getAllowLoc;
  // List getTenantLimit;
  List checkFee;
  List loadDiscountedPerson;
  var isLoading = true;
  var townId,townName,barrioId,brgName,contact;

  double deliveryCharge = 0;
  double grandTotal = 0.0;
  double minimumAmount = 0.0;

  var timeCount;
  var _globalTime,_globalTime2;
  var _today;
  // String changeForFinal;
  final _formKey = GlobalKey<FormState>();

  Future getPlaceOrderData() async{
    getTrueTime();
    // loadTotal();
    var res = await db.loadSubTotal();
    if (!mounted) return;
    setState(() {
      loadTotalData = res['user_details'];
      subtotal = double.parse(loadTotalData[0]['grand_total'].toString());
    });

    var res1 = await db.getPlaceOrderData();
    if (!mounted) return;
    setState(() {
      placeOrder = res1['user_details'];
      // print(placeOrder);
      deliveryCharge = double.parse(placeOrder[0]['d_charge_amt']);
      townId = placeOrder[0]['d_townId'];
      barrioId = placeOrder[0]['d_brgId'];
      placeOrderTown.text = placeOrder[0]['d_townName'];
      placeOrderBrg.text = placeOrder[0]['d_brgName'];
      placeContactNo.text = placeOrder[0]['d_contact'];
      placeRemarks.text = placeOrder[0]['land_mark'];
      street.text = placeOrder[0]['street_purok'];
      // houseNo.text = placeOrder[0]['complete_address'];
      deliveryCharge = double.parse(placeOrder[0]['d_charge_amt']);
      grandTotal = deliveryCharge + subtotal;
      userName.text = placeOrder[0]['firstname']+" "+placeOrder[0]['lastname'];
      minimumAmount = double.parse(placeOrder[0]['minimum_order_amount']);
      getTenantSegregate();
      isLoading = false;

    });
  }

  updateDefaultShipping(id,customerId) async{
    await db.updateDefaultShipping(id,customerId);
  }

  Future countDiscount() async{
    if(selectedDiscountType.length == 0){
      discount.text = "";
    }else{
      if(selectedDiscountType.length == 1){
        discount.text = selectedDiscountType.length.toString() +" person";
      }
      else{
        discount.text = selectedDiscountType.length.toString() +" persons";
      }
    }
  }

  List loadTotalData;
  Future loadTotal() async{
    var res = await db.loadSubTotal();
    if (!mounted) return;
    setState(() {
      loadTotalData = res['user_details'];
      subtotal = double.parse(loadTotalData[0]['grand_total'].toString());
    });
  }

  void displayAddresses(BuildContext context) async{
    var res = await db.displayAddresses();
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
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Select your address",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                      OutlineButton(
                        borderSide: BorderSide(color: Colors.deepOrangeAccent),
                        highlightedBorderColor: Colors.deepOrangeAccent,
                        highlightColor: Colors.transparent,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                        onPressed: (){
                          Navigator.pop(context);
                          Navigator.of(context).push(addNewAddress());
                        },
                        child:Text("+ Add new",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 15.0),),
                      ),
                    ],
                  ),
                ),
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
                          placeOrderTown.text = getItemsData[index]['d_townName'];
                          placeOrderBrg.text = getItemsData[index]['d_brgName'];
                          placeContactNo.text = getItemsData[index]['d_contact'];
                          placeRemarks.text = getItemsData[index]['land_mark'];
                          street.text = getItemsData[index]['street_purok'];
                          userName.text = getItemsData[index]['firstname']+" "+getItemsData[index]['lastname'];
                          barrioId = getItemsData[index]['d_townId'];
                          townId = getItemsData[index]['d_brgId'];
                          deliveryCharge = double.parse(getItemsData[index]['d_charge_amt']);
                          grandTotal = deliveryCharge + subtotal;
                          minimumAmount = double.parse(getItemsData[index]['minimum_order_amount']);
                          updateDefaultShipping(getItemsData[index]['id'],getItemsData[index]['d_customerId']);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                          child:Column(
                            children:[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  Text('$f. ${getItemsData[index]['d_townName']} ${getItemsData[index]['d_brgName']}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                                  Text('${getItemsData[index]['d_contact']}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
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

  Future getBuSegregate() async{
    var res = await db.getBuSegregate();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
    });
  }

  List<bool> subTotalTenant = [];
  Future getTenantSegregate() async{
    subTotalTenant.clear();
    var res = await db.getTenantSegregate();
    if (!mounted) return;
    setState(() {
      getTenant = res['user_details'];

     for(int q=0;q<getTenant.length;q++){
       print(minimumAmount);
       bool result = getTenant[q]['total'] < minimumAmount;
       print(getTenant[q]['total']);
       subTotalTenant.add(result);
     }
     print(subTotalTenant);
    });
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
                      return InkWell(
                        onTap: (){
                          // displayAddOns(getItemsData[index]['cart_id']);
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$f. ${getItemsData[index]['d_prodName']} ',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
                              Text('₱${getItemsData[index]['prod_price']}',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
                              Text(' x ${getItemsData[index]['d_quantity']}',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
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

 void displayOrder(tenantId) async{
   showDialog<void>(
     context: context,
     barrierDismissible: false, // user must tap button!
     builder: (BuildContext context) {
       return AlertDialog(
         shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.all(Radius.circular(8.0))
         ),
         contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
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
   setState((){
     getItemsData = res['user_details'];
     Navigator.of(context).pop();
   });
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context){
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

  submitPlaceOrder() async{
     FocusScope.of(context).requestFocus(FocusNode());
     print(subTotalTenant.contains(true));
      if(subTotalTenant.contains(true)){
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
              "Hello!",
              style: TextStyle(fontSize: 18.0),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Padding(
                    padding:EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                    child:Center(
                        child:Text(("This order must have a minimum amount of ₱${oCcy.format(minimumAmount)} per tenant please check the tenant's subtotal, thank you."))),
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
      }if(_today == false && deliveryTime.text.isEmpty){
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
                    Center(
//                    padding:EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                      child: Text("Please enter delivery time"),
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
    else if(deliveryDate.text.isEmpty || placeOrderTown.text.isEmpty || placeOrderBrg.text.isEmpty || placeContactNo.text.isEmpty || placeRemarks.text.isEmpty || specialInstruction.text.isEmpty || placeContactNo.text.length < 10 || changeFor.text.isEmpty)
    {
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
                    child: Text("Some fields invalid or empty"),
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
    else {
       SharedPreferences prefs = await SharedPreferences.getInstance();
       String username = prefs.getString('s_customerId');
       if(username == null){
         Navigator.of(context).push(_signIn());
       }else{
         Navigator.of(context).push(_submitOrder(changeFor.text,int.parse(townId),int.parse(barrioId),placeContactNo.text,placeOrderTown.text,placeOrderBrg.text,street.text,houseNo.text,placeRemarks.text,specialInstruction.text,deliveryCharge,grandTotal,deliveryDate.text,deliveryTime.text,groupValue));
       }
    }
  }

  List trueTime;
  getTrueTime() async{
    var res = await db.getTrueTime();
    if (!mounted) return;
    setState(() {
      trueTime = res['user_details'];
    });
  }

  @override
  void initState(){
    side.clear();
    selectedDiscountType.clear();
    super.initState();
    getPlaceOrderData();
    getBuSegregate();
    print("hello");
    print(selectedDiscountType);
    // loadTotal();
    // getTenantSegregate();
    // trapTenantLimit();
  }

  @override
  void dispose() {
    super.dispose();
    changeFor.dispose();
    placeOrderTown.dispose();
    placeOrderBrg.dispose();
    placeContactNo.dispose();
    placeRemarks.dispose();
    street.dispose();
    houseNo.dispose();
    deliveryDate.dispose();
    deliveryTime.dispose();
    discount.dispose();
//    trap.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
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
          icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Delivery",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      ),
      body: isLoading
          ? Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
           ):Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child:Form(
                  key: _formKey,
                  child: Scrollbar(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        Visibility(
                          visible: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Padding(
                              //   padding: EdgeInsets.fromLTRB(25, 20, 200, 5),
                              //   child: OutlinedButton(
                              //     style: TextButton.styleFrom(
                              //       shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                              //     ),
                              //     onPressed: () async{
                              //       FocusScope.of(context).requestFocus(FocusNode());
                              //       SharedPreferences prefs = await SharedPreferences.getInstance();
                              //       String username = prefs.getString('s_customerId');
                              //       if(username == null){
                              //         Navigator.of(context).push(_signIn());
                              //       }else{
                              //         displayAddresses(context);
                              //       }
                              //     },
                              //     child: Container(
                              //       height: 50.0,
                              //       child: Row(
                              //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //         children: [
                              //           Icon(
                              //             Icons.location_on,
                              //             color: Colors.deepOrangeAccent,
                              //           ),
                              //           Text("Select address",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 15.0),),
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(25, 20, 200, 5),
                                child: Container(
                                  height: 40.0,
                                  child: OutlinedButton(
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
                                    style: TextButton.styleFrom(

                                      primary: Colors.black,
                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                    ),
                                    child: Text("Select address"),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                                child: new Text("Name", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: InkWell(
                                  onTap: (){
                                    FocusScope.of(context).requestFocus(FocusNode());
// //                                    placeOrderBrg.clear();
//                                       selectTown();
                                  },
                                  child: IgnorePointer(
                                    child: new TextFormField(
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange,
                                      controller: userName,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter some value';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                                child: new Text("Town *", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: InkWell(
                                  onTap: (){
                                    FocusScope.of(context).requestFocus(FocusNode());
// //                                    placeOrderBrg.clear();
//                                       selectTown();
                                  },
                                  child: IgnorePointer(
                                    child: new TextFormField(
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange,
                                      controller: placeOrderTown,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter some value';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                                child: new Text("Barangay *", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: InkWell(
                                  onTap: (){
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    // placeOrderTown.text.isEmpty ? print('no town selected') : selectBarrio();
                                  },
                                  child: IgnorePointer(
                                    child: new TextFormField(
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange,
                                      controller: placeOrderBrg,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter some value';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                                child: new Text("Phone Number *", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 2.0,
                                    ),
                                    Flexible(
                                      child: new TextFormField(
                                        maxLength: 11,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.deny(new RegExp('[.-]'))],
                                        cursorColor: Colors.deepOrange,
                                        controller: placeContactNo,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter some value';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          counterText: "",
                                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                          focusedBorder:OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                          ),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                        ),
//                                        focusNode: textSecondFocusNode,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                                child: new Text("Street *", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: new TextFormField(
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Colors.deepOrange,
                                  controller: street,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter some value';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                    focusedBorder:OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                                child: new Text("House number(optional)", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: new TextFormField(
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Colors.deepOrange.withOpacity(0.8),
                                  controller: houseNo,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                    focusedBorder:OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                                child: new Text("Delivery date *", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: InkWell(
                                  onTap: (){
                                    deliveryTime.clear();
                                    getTrueTime();
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    showDialog<void>(
                                      context: context,
//                                        barrierDismissible: false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(8.0))
                                          ),
                                          title: Text("Set date for this delivery",style: TextStyle(fontSize: 20.0),),
                                          contentPadding:EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                                          content: Container(
                                            height:230.0, // Change as per your requirement
                                            width: 360.0, // Change as per your requirement
                                            child: Scrollbar(
                                              child:ListView.builder(
                                                physics: BouncingScrollPhysics(),
//                                                  shrinkWrap: true,
                                                itemCount: 4,
                                                itemBuilder: (BuildContext context, int index) {
                                                  String tom = "";
                                                  int n = 0;
                                                  n = index;
                                                  if(n==0){
                                                    tom = "(Today)";
                                                  }
                                                  var d1 = DateTime.parse(trueTime[0]['date_today']);
                                                  var d2 = new DateTime(d1.year, d1.month, d1.day + n);
                                                  final DateFormat formatter = DateFormat('yyyy-MM-dd');
                                                  final String formatted = formatter.format(d2);
                                                  return InkWell(
                                                    onTap: (){

                                                      deliveryDate.text =formatted;
                                                      Navigator.of(context).pop();
                                                      if(index == 0){
                                                        setState(() {
                                                          _today = true;
                                                          timeCount = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']).difference(DateTime.parse(trueTime[0]['date_today']+" "+"19:30")).inHours;
                                                          timeCount = timeCount.abs();
                                                          _globalTime = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']);
                                                          _globalTime2 = _globalTime.hour;
                                                        });
                                                     }
                                                     else{
                                                       setState((){
                                                         _today = false;
                                                         timeCount = 12;
                                                         _globalTime = new DateTime.now();
                                                         _globalTime2 = 07;
                                                       });
                                                      }
                                                    },
                                                      child: Column(
                                                        children:[
                                                          Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: <Widget>[
                                                                Padding(
                                                                  padding: EdgeInsets.fromLTRB(30.0,20.0, 0.0,20.0),
                                                                  child: Text('${formatted.toString()}',style: TextStyle(fontSize: 16.0),),
                                                                ),
                                                              ]
                                                          ),
                                                        ],
                                                      ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text(
                                                'Clear',
                                                style: TextStyle(
                                                  color: Colors.deepOrange,
                                                ),
                                              ),
                                              onPressed: () {
                                                deliveryDate.clear();
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    },
                                      child: IgnorePointer(
                                        child: new TextFormField(
                                          textInputAction: TextInputAction.done,
                                          cursorColor: Colors.deepOrange,
                                          controller: deliveryDate,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please enter some value';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                            focusedBorder:OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                            ),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                                child: new Text("Delivery time*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: InkWell(
                                  onTap: (){
                                      getTrueTime();
                                      if(deliveryDate.text.isEmpty){
                                        Fluttertoast.showToast(
                                            msg: "Please select a pick-up date",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 2,
                                            backgroundColor: Colors.black.withOpacity(0.7),
                                            textColor: Colors.white,
                                            fontSize: 16.0
                                        );
                                      }
                                      else{
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        showDialog<void>(
                                          context: context,
//                                          barrierDismissible: false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                                              ),
                                              title: Text("Set time for this delivery",style: TextStyle(fontSize: 20.0),),
                                              contentPadding:
                                              EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                                              content: Container(
                                                height:230.0, // Change as per your requirement
                                                width: 360.0, // Change as per your requirement
                                                child: Scrollbar(
                                                  child:  ListView.builder(
                                                      physics: BouncingScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount:  timeCount,
                                                      itemBuilder: (BuildContext context, int index1) {
                                                        int t = index1;
                                                        t++;
//                                                              var d1 = DateTime.parse(trueTime[0]['date_today']);
                                                        final now =  _globalTime;
                                                        final dtFrom = DateTime(now.year, now.month, now.day, _globalTime2+t, 0+30, now.minute, now.second);
                                                        // final dtTo = DateTime(now.year, now.month, now.day, 8+t, 0+30);
                                                        final format = DateFormat.jm();  //"6:00 AM"
                                                        String from = format.format(dtFrom);
                                                        // String to = format.format(dtTo);
                                                        return InkWell(
                                                          onTap: (){
                                                            deliveryTime.text = from;
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Container(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Row (
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(30.0,20.0, 0.0,20.0),
                                                                        child: Text('${from.toString()}',style: TextStyle(fontSize: 16.0),),
                                                                      ),
                                                                    ]
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                  ),
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                    'Clear',
                                                    style: TextStyle(
                                                      color: Colors.deepOrange,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    deliveryTime.clear();
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }

                                  },
                                  child: IgnorePointer(
                                      child: new TextFormField(
                                        textInputAction: TextInputAction.done,
                                        cursorColor: Colors.deepOrange,
                                        controller: deliveryTime,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter some value';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                          focusedBorder:OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                          ),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                        ),
                                      ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                                child: new Text("Avail Discount(Optional)", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: InkWell(
                                  onTap: () async{
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    String username = prefs.getString('s_customerId');
                                    if(username == null){
                                      Navigator.of(context).push(_signIn());
                                    }else{
                                      await Navigator.of(context).push(_showDiscountPerson());
                                      countDiscount();
                                    }
                                  },
                                  child: IgnorePointer(
                                    child: new TextFormField(
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange,
                                      controller: discount,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                                child: new Text("Landmark*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: new TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Colors.deepOrange,
                                  controller: placeRemarks,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter some value';
                                    }
                                    return null;
                                  },
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText:"E.g Near at plaza/Be ware of dogs",
                                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                    focusedBorder:OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                  ),
                                ),
                              ),

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
                                            padding: EdgeInsets.fromLTRB(17.0,20.0, 0.0,10.0),
                                            child: Text('$num. ${getBu[index0]['d_bu_name'].toString()}',style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold ,fontSize: 18.0)),
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
                                                          padding: EdgeInsets.fromLTRB(25.0,0.0, 25.0,1.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text('${getTenant[index]['tenant_name']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0,color: Colors.black),),
                                                              Text('₱${oCcy.format(int.parse(getTenant[index]['total'].toString()))}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0,color: Colors.black),),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                                          child: new TextFormField(
                                                            keyboardType: TextInputType.multiline,
                                                            textInputAction: TextInputAction.done,
                                                            cursorColor: Colors.deepOrange,
                                                            controller: specialInstruction,
                                                            validator: (value) {
                                                              if (value.isEmpty) {
                                                                return 'Please enter some value';
                                                              }
                                                              return null;
                                                            },
                                                            maxLines: 4,
                                                            decoration: InputDecoration(
                                                              hintText:"Special instruction",
                                                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                                              focusedBorder:OutlineInputBorder(
                                                                borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                                              ),
                                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
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

                              Padding(
                                padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                child: new Text("In case the product is out of stock", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),
                              _myRadioButton(
                                title: "Cancel the entire order",
                                value: 0,
                                onChanged: (newValue) => setState((){
                                  groupValue = newValue;

                                }),
                              ),

                              _myRadioButton(
                                title: "Remove it from my order",
                                value: 1,
                                onChanged: (newValue) => setState((){
                                  groupValue = newValue;
                                }),
                              ),
                              Padding(
                                padding:EdgeInsets.fromLTRB(49.0, 7.0, 5.0, 5.0),
                                child: new Text("Rider's fee: ₱ ${ oCcy.format(deliveryCharge)}", style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),
                              Divider(),
                              Padding(
                                padding:EdgeInsets.fromLTRB(49.0, 7.0, 5.0, 5.0),
                                child: new Text("GRAND TOTAL: ₱ ${ oCcy.format(grandTotal).toString()}", style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                child: new Text("Customer tender(ie.4,000.00)", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                              ),
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                  child: new TextFormField(
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Colors.deepOrange,
                                  controller: changeFor,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter some value';
                                    }if(int.parse(value) < grandTotal){
                                      return 'Amount tender is lesser than your total payable';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.insert_chart,color: Colors.grey,),
                                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                    focusedBorder:OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),


                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: SleekButton(
                        onTap: () async {
                          if (_formKey.currentState.validate()) {
                            submitPlaceOrder();
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

int groupValue = 0;
Widget _myRadioButton({String title, int value, Function onChanged}) {
  return Theme(
    data: ThemeData.light(),
    child: RadioListTile(
      activeColor: Colors.deepOrange,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(title),
    ),
  );
}

Route _submitOrder(changeForText,townId,barrioId,contactNo,placeOrderTown,placeOrderBrg,street,houseNo,placeRemark,specialInstruction,deliveryCharge,grandTotal,deliveryDate,deliveryTime,groupValue) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SubmitOrder(changeForText:changeForText,townId:townId,barrioId:barrioId,contactNo:contactNo,placeOrderTown:placeOrderTown,placeOrderBrg:placeOrderBrg,street:street,houseNo:houseNo,placeRemark:placeRemark,specialInstruction:specialInstruction,deliveryCharge:deliveryCharge,grandTotal:grandTotal,deliveryDate:deliveryDate,deliveryTime:deliveryTime,groupValue:groupValue),
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