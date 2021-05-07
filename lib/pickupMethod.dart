import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'submit_order.dart';
import 'package:intl/intl.dart';
import 'submit_pickup.dart';
import 'discountManager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_signin.dart';

class PlaceOrderPickUp extends StatefulWidget {
  @override
  _PlaceOrderPickUp createState() => _PlaceOrderPickUp();
}

class _PlaceOrderPickUp extends State<PlaceOrderPickUp>    with SingleTickerProviderStateMixin {
  final db = RapidA();
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  List<TextEditingController> _deliveryDate = new List();
  List<TextEditingController>  _deliveryTime = new List();


  List<String> getTenantData = [];
  List<String> deliveryDateData = [];
  List<String> deliveryTimeData = [];

  final oCcy = new NumberFormat("#,##0.00", "en_US");


  final discount = TextEditingController();
  var subtotal = 0.0;
  List getBu;
  List getTenant;
  List getItemsData;
  List getOrder;
  List getSubtotal;
  var isLoading = true;
  var lt = 0;
  var timeCount;
  var _globalTime,_globalTime2;

  submitPickUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }else{
      Navigator.of(context).push(submitPickUpRoute(groupValue,deliveryDateData,deliveryTimeData,getTenantData,subtotal));
    }
  }

  Future getOrderData() async{
    var res = await db.getOrderData();
    if (!mounted) return;
    setState(() {
      getOrder = res['user_details'];
    });
  }


  List loadCartData;
  Future getSubTotal() async{
    var res = await db.loadCartData();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadCartData = res['user_details'];
      subtotal = 0;
      loadCartData.forEach((element) {
        subtotal = subtotal + (double.parse(element['cart_qty'].toString()) * double.parse(element['total'].toString()));
      });
      // print(subtotal.toString());
    });
  }

  Future getBuSegregate() async{
    var res = await db.getBuSegregate();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
    });
  }


  Future getTenantSegregate() async{
    var res = await db.getTenantSegregate();
    if (!mounted) return;
    setState(() {
      getTenant = res['user_details'];
      isLoading = false;
      lt=getTenant.length;
      for(int q=0;q<lt;q++){
        getTenantData.add(getTenant[q]['tenant_id']);
      }
    });
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

  void  displayOrder(tenantId) async{
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

  Future toRefresh() async{
    getOrderData();
    getSubTotal();
    getTenantSegregate();
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
    selectedDiscountType.clear();
    super.initState();
    selectedDiscountType.clear();
    getOrderData();
    getSubTotal();
    getBuSegregate();
    getTrueTime();
    getTenantSegregate();
  }


  @override
  void dispose() {
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
//          Navigator.pop(context);
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
          title: Text("Pick up",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child:Scrollbar(
                        child: RefreshIndicator(
                            onRefresh: toRefresh,
                            child: Form(
                              key: _key,
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(15, 15, 5, 5),
                                    child: new Text("*Please enter desired date & time for pick up*", style: GoogleFonts.openSans(color: Colors.deepOrange, fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),

                                  ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:  getBu == null ? 0 : getBu.length,
                                      itemBuilder: (BuildContext context, int index0) {
//                                  test = getBu[index0]['d_bu_name'];

                                        var num = index0;
                                        num++;
                                        return Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child:  Padding(
                                                      padding: EdgeInsets.fromLTRB(17.0,10.0, 0.0,10.0),
                                                      child: Text('$num. ${getBu[index0]['d_bu_name'].toString()}',style: GoogleFonts.openSans(color:Colors.deepOrange, fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 22.0),),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ListView.builder(
                                                  physics: BouncingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:  getTenant == null ? 0 : getTenant.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    _deliveryDate.add(new TextEditingController());
                                                    _deliveryTime.add(new TextEditingController());
                                                    return Visibility(
                                                      visible: getTenant[index]['bu_id'] != getBu[index0]['d_bu_id'] ? false : true,
                                                      child: Container(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: EdgeInsets.fromLTRB(20.0,0.0, 20.0,0.0),
                                                              child: OutlineButton(
                                                                borderSide: BorderSide(color: Colors.transparent),
                                                                highlightedBorderColor: Colors.deepOrange,
                                                                highlightColor: Colors.transparent,
                                                                child:Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${getTenant[index]['tenant_name']}', style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 18.0),),
                                                                    Text('₱${oCcy.format(int.parse(getTenant[index]['total'].toString()))}', style: TextStyle(fontStyle: FontStyle.normal,fontSize: 18.0),),
                                                                  ],
                                                                ),
                                                                color: Colors.transparent,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                                                onPressed: (){
                                                                  displayBottomSheet(context,getTenant[index]['tenant_id'],getBu[index0]['d_bu_name'],getTenant[index]['tenant_name']);
//                                                                displayOrder(getTenant[index]['d_tenantId']);
                                                                },
                                                              ),
//                                                                    child: Text(getTenant[index]['d_tenantId'] , style: TextStyle(fontStyle: FontStyle.normal,fontSize: 16.0),),

                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.fromLTRB(35, 0, 5, 5),
                                                              child: new Text("Pick-up date*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                                            ),
                                                            Padding(
                                                              padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                                              child: InkWell(
                                                                onTap: (){
                                                                  FocusScope.of(context).requestFocus(FocusNode());
                                                                  showDialog<void>(
                                                                    context: context,
                                                                    builder: (BuildContext context) {
                                                                      return AlertDialog(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.all(Radius.circular(8.0))
                                                                        ),
                                                                        title: Text("Set date for this delivery",style: TextStyle(fontSize: 20.0),),
                                                                        contentPadding:EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                                                                        content: Container(
                                                                          height:290.0, // Change as per your requirement
                                                                          width: 360.0, // Change as per your requirement
                                                                          child: Scrollbar(
                                                                            child:ListView.builder(
                                                                              physics: BouncingScrollPhysics(),
                                                                              itemCount: 5,
                                                                              itemBuilder: (BuildContext context, int index1) {
                                                                                int n = 0;
                                                                                n = index1;
                                                                                var d1 = DateTime.parse(trueTime[0]['date_today']);
                                                                                var d2 = new DateTime(d1.year, d1.month, d1.day + n);
                                                                                final DateFormat formatter = DateFormat('yyyy-MM-dd');
                                                                                final String formatted = formatter.format(d2);
                                                                                return InkWell(
                                                                                  onTap: (){
                                                                                    _deliveryDate[index].text = formatted;
                                                                                    deliveryDateData.add(_deliveryDate[index].text);

                                                                                    Navigator.of(context).pop();
                                                                                    if(index1 == 0){
                                                                                      setState(() {
                                                                                        timeCount = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']).difference(DateTime.parse(trueTime[0]['date_today']+" "+"19:30")).inHours;
                                                                                        timeCount = timeCount.abs();
                                                                                        _globalTime = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']);
                                                                                        _globalTime2 = _globalTime.hour;
                                                                                      });
                                                                                    }
                                                                                    else{
                                                                                      setState(() {
                                                                                        timeCount = 12;
                                                                                        _globalTime = new DateTime.now();
                                                                                        _globalTime2 = 07;
                                                                                      });
                                                                                    }
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
                                                                                                child: Text('${formatted.toString()}',style: TextStyle(fontSize: 16.0),),
                                                                                              ),
                                                                                            ]
                                                                                        ),
                                                                                      ],
                                                                                    ),
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
                                                                              _deliveryDate[index].clear();
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
                                                                    controller: _deliveryDate[index],
                                                                    validator: (value) {
                                                                      if (value.isEmpty) {
                                                                        return 'Please select delivery date';
                                                                      }
                                                                      return null;
                                                                    },
                                                                    decoration: InputDecoration(
                                                                      prefixIcon: Icon(Icons.date_range,color: Colors.grey,),
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
                                                              padding: EdgeInsets.fromLTRB(35, 10, 5, 5),
                                                              child: new Text("Delivery time", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                                            ),
                                                            Padding(
                                                              padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                                              child: InkWell(
                                                                onTap: (){
                                                                  getTrueTime();
                                                                  if(_deliveryDate[index].text.isEmpty){
                                                                    Fluttertoast.showToast(
                                                                        msg: "Please select a delivery date",
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
                                                                      builder: (BuildContext context) {
                                                                        return AlertDialog(
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.all(Radius.circular(8.0))
                                                                          ),
                                                                          title: Text("Set time for this delivery",style: TextStyle(fontSize: 20.0),),
                                                                          contentPadding:
                                                                          EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                                                                          content: Container(
                                                                            height:290.0, // Change as per your requirement
                                                                            width: 360.0, // Change as per your requirement
                                                                            child: Scrollbar(
                                                                              child:  ListView.builder(
                                                                                  physics: BouncingScrollPhysics(),
                                                                                  shrinkWrap: true,
                                                                                  itemCount:  timeCount,
                                                                                  itemBuilder: (BuildContext context, int index1) {
                                                                                    int t = index1;
                                                                                    t++;
                                                                                    final now =  _globalTime;
                                                                                    final dtFrom = DateTime(now.year, now.month, now.day, _globalTime2+t, 0+30, now.minute, now.second);
                                                                                    // final dtTo = DateTime(now.year, now.month, now.day, 8+t, 0+30);
                                                                                    final format = DateFormat.jm();  //"6:00 AM"
                                                                                    String from = format.format(dtFrom);

                                                                                    return InkWell(
                                                                                      onTap: (){
                                                                                        _deliveryTime[index].text = from;
                                                                                        deliveryTimeData.add(_deliveryTime[index].text);
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
                                                                                _deliveryTime[index].clear();
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
                                                                    controller: _deliveryTime[index],
                                                                    validator: (value) {
                                                                      if (value.isEmpty) {
                                                                        return 'Please select delivery time';
                                                                      }
                                                                      return null;
                                                                    },
                                                                    decoration: InputDecoration(
                                                                      prefixIcon: Icon(Icons.timelapse,color: Colors.grey,),
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

                                  // Padding(
                                  //   padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                                  //   child: new Text("Customer tender(ie.4,000.00)", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  // ),
                                  // Padding(
                                  //   padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                  //   child: new TextFormField(
                                  //     textInputAction: TextInputAction.done,
                                  //     cursorColor: Colors.deepOrange,
                                  //     controller: changeForPickup,
                                  //     validator: (value){
                                  //       if (value.isEmpty) {
                                  //         return 'Please enter some value';
                                  //       }
                                  //       return null;
                                  //     },
                                  //     keyboardType: TextInputType.number,
                                  //     decoration: InputDecoration(
                                  //       prefixIcon: Icon(Icons.insert_chart,color: Colors.grey,),
                                  //       contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                  //       focusedBorder:OutlineInputBorder(
                                  //         borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                  //       ),
                                  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                  //     ),
                                  //   ),
                                  // ),

                                  Padding(
                                    padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
                                    child: new Text("Avail Discount(Optional)", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),

                                  Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                    child: InkWell(
                                      onTap: () async{
                                        FocusScope.of(context).requestFocus(FocusNode());
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
                                    child: new Text("GRAND TOTAL: ₱ ${oCcy.format(subtotal).toString()}", style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
                                  ),
                                ],
                              ),
                            )
                        )
                    )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: SleekButton(
                          onTap: () {
                            if (_key.currentState.validate()) {
                              // Navigator.of(context).push(_gcPickUpFinal(groupValue,_deliveryTime.text,_deliveryDate.text,_modeOfPayment.text));
                              submitPickUp();
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


// Route _submitOrder(changeForText,townId,barrioId,contactNo,placeOrderTown,placeOrderBrg,street,houseNo,placeRemark,changeFor,deliveryCharge,grandTotal,deliveryDate,deliveryTime,groupValue) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => SubmitOrder(changeForText:changeForText,townId:townId,barrioId:barrioId,contactNo:contactNo,placeOrderTown:placeOrderTown,placeOrderBrg:placeOrderBrg,street:street,houseNo:houseNo,placeRemark:placeRemark,changeFor:changeFor,deliveryCharge:deliveryCharge,grandTotal:grandTotal,deliveryDate:deliveryDate,deliveryTime:deliveryTime,groupValue:groupValue),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       var begin = Offset(0.0, 1.0);
//       var end = Offset.zero;
//       var curve = Curves.decelerate;
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//       return SlideTransition(
//         position: animation.drive(tween),
//         child: child,
//       );
//     },
//   );
// }


Route submitPickUpRoute(groupValue,deliveryDateData,deliveryTimeData,getTenantData,subtotal) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SubmitPickUp(groupValue:groupValue,deliveryDateData:deliveryDateData,deliveryTimeData:deliveryTimeData,getTenantData:getTenantData,subtotal:subtotal),
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