import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'live_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_signin.dart';

import 'dart:async';

import 'order_timeframe.dart';
class ToDeliverFood extends StatefulWidget {
  final pend;
  final ticketNo;
  final dmop;
  final type;
  ToDeliverFood({Key key, @required this.pend, this.ticketNo,this.dmop,this.type}) : super(key: key);//
  @override
  _ToDeliver createState() => _ToDeliver();
}

class _ToDeliver extends State<ToDeliverFood> {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;
  List loadItems, lookItemsSegregateList, loadItems1;
  List loadTotal,lGetAmountPerTenant, loadSTotal;


  cancelOrder(tomsId,ticketId) async{
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return  AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal:0.0, vertical: 20.0),
          title:Row(
            children: <Widget>[
              Text('Hello',style:TextStyle(fontSize: 18.0),),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child:Center(child:Text("Do you want to cancel this item?")),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close',style: TextStyle(
                color: Colors.deepOrange,
              ),),
              onPressed: () async{
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Proceed',style: TextStyle(
                color: Colors.deepOrange,
              ),),
              onPressed: () async{
                cancelOrderSingle(tomsId,ticketId);
                Navigator.of(context).pop();
                cancelSuccess();
              },
            ),
          ],
        );
      },
    );
  }
  // var delCharge;
  var grandTotal = 0;
  var subTotal = 0;
  var deliveryCharge = 0;
  var index = 0;
  Future getTotal() async{
    var res = await db.getTotal(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      // grandTotal = 0.0;
      loadTotal = res['user_details'];
      grandTotal = loadTotal[index]['total_price'];
      subTotal = loadTotal[index]['sub_total'];
      deliveryCharge = loadTotal[index]['delivery_charge'];
    });
  }

  // var subTotal = 0;
  // Future getSubTotal() async{
  //   var res = await db.getSTotal(widget.ticketNo);
  //   if (!mounted) return;
  //   setState(() {
  //     // grandTotal = 0.0;
  //     loadSTotal = res['user_details'];
  //     subTotal = loadSTotal[0]['sub_total'];
  //   });
  // }

  Future cancelOrderSingle(tomsId,ticketId) async{
    if(widget.type == '0'){
      await db.cancelOrderSingleFood(tomsId,ticketId);
    }
    if(widget.type == '1'){
      await db.cancelOrderSingleGood(tomsId,ticketId);
    }

    lookItemsFood();
    lookItemsGood();
    getTotal();
    // getSubTotal();
  }

  Future refresh() async{
    setState(() {
      if(widget.type == '0') {
        lookItemsFood();
      }if(widget.type == '1'){
        lookItemsGood();
      }
    });
  }

  void displayBottomSheet(BuildContext context) async{
    var res = await db.getAmountPerTenantmod(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      lGetAmountPerTenant = res['user_details'];
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
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                SizedBox(height:10.0),
                Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                  child:Text("Your stores",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                ),
                Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: lGetAmountPerTenant == null ? 0 : lGetAmountPerTenant.length,
                    itemBuilder: (BuildContext context, int index) {
                      var f = index;
                      f++;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 5.0),
                        child:Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$f. ${lGetAmountPerTenant[index]['tenant_name']} ${lGetAmountPerTenant[index]['tenant_name']} ',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                              Text('₱${oCcy.format(int.parse(lGetAmountPerTenant[index]['sumpertenats'].toString()))}',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                            ],
                          ),
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

  viewAddon(BuildContext context,mainItemIndex) {
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
            child:Container(
              child: Scrollbar(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    // loadFlavors
                    // loadAddons
                    SizedBox(height:15.0),
                    Padding(
                      padding: EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                      child: Text("Add ons",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                    ),
                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: loadItems[mainItemIndex]['add_ons'].length == null ? 0 : loadItems[mainItemIndex]['add_ons'].length,
                      itemBuilder: (BuildContext context, int index) {
                        if(loadItems[mainItemIndex]['add_ons'][index]['unit_measure'] == null){
                          return Padding(
                            padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 5.0),
                            child:Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  Expanded(
                                      child: Text(
                                        ' + ${loadItems[mainItemIndex]['add_ons'][index]['product_name'].toString()} - ₱ ${loadItems[mainItemIndex]['add_ons'][index]['addon_price'].toString()}',
                                        style: TextStyle(fontSize: 18.0,),maxLines: 6, overflow: TextOverflow.ellipsis,
                                      )
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                            return Padding(
                              padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 5.0),
                              child:Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    Expanded(
                                        child: Text(
                                          ' + ${loadItems[mainItemIndex]['add_ons'][index]['product_name'].toString()} ${loadItems[mainItemIndex]['add_ons'][index]['unit_measure'].toString()} - ₱ ${loadItems[mainItemIndex]['add_ons'][index]['addon_price'].toString()}',
                                          style: TextStyle(fontSize: 18.0,),maxLines: 6, overflow: TextOverflow.ellipsis,
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            );
                      },
                    ),

                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: loadItems[mainItemIndex]['choices'] == null ? 0 : loadItems[mainItemIndex]['choices'].length,
                      itemBuilder: (BuildContext context, int index) {
                        if(loadItems[mainItemIndex]['choices'][index]['unit_measure'] == null){
                          return Padding(
                            padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 5.0),
                            child:Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  Expanded(
                                      child: Text(' + ${loadItems[mainItemIndex]['choices'][index]['product_name'].toString()} - ₱ ${loadItems[mainItemIndex]['choices'][index]['addon_price'].toString()}',style: TextStyle(fontSize: 18.0,),maxLines: 6, overflow: TextOverflow.ellipsis,)
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                          return Padding(
                            padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 5.0),
                            child:Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  Expanded(
                                      child: Text(' + ${loadItems[mainItemIndex]['choices'][index]['product_name'].toString()} ${loadItems[mainItemIndex]['choices'][index]['unit_measure'].toString()} - ₱ ${loadItems[mainItemIndex]['choices'][index]['addon_price'].toString()}',style: TextStyle(fontSize: 18.0,),maxLines: 6, overflow: TextOverflow.ellipsis,)
                                  ),
                                ],
                              ),
                            ),
                          );
                      },
                    ),

                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: loadItems[mainItemIndex]['flavors'] == null ? 0 : loadItems[mainItemIndex]['flavors'].length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 5.0),
                          child:Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                Expanded(
                                    child: Text(' + ${loadItems[mainItemIndex]['flavors'][index]['flavor'].toString()} - ₱ ${loadItems[mainItemIndex]['flavors'][index]['addon_price'].toString()}',style: TextStyle(fontSize: 18.0,),maxLines: 6, overflow: TextOverflow.ellipsis,)
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
//                     ListView.builder(
//                       physics: BouncingScrollPhysics(),
//                       shrinkWrap: true,
//                       itemCount: loadCartData[mainItemIndex]['flavors'] == null ? 0 : loadCartData[mainItemIndex]['flavors'].length,
//                       itemBuilder: (BuildContext context, int index) {
//                         if(loadCartData[mainItemIndex]['flavors'].length > 0){
//                           return Padding(
//                             padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 5.0),
//                             child:Container(
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                 children:[
//                                   Expanded(child: Text(' + ${loadIMainItems[mainItemIndex]['flavors'][0]['flavor']} - Php ${loadIMainItems[mainItemIndex]['flavors'][0]['addon_price']}',style: TextStyle(fontSize: 18.0,),maxLines: 6, overflow: TextOverflow.ellipsis,)),
//                                 ],
//                               ),
//                             ),
// //                          child: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
//                           );
//                         }
//                         return SizedBox(
//                         );
//                       },
//                     ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  cancelSuccess(){
    Fluttertoast.showToast(
        msg: "Your order successfully cancelled",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  selectType(){
    setState(() {
      if(widget.type == '0') {
        lookItemsFood();
        lookItemsSegregate();
      }if(widget.type == '1'){
        lookItemsGood();
      }

    });
  }

  Future lookItemsFood() async{
    var res = await db.lookItems(widget.ticketNo);
      if (!mounted) return;
      setState(() {
      isLoading = false;
      loadItems = res['user_details'];
    });
      print(loadItems);
  }

  Future lookItemsSegregate() async{
    var res = await db.lookItemsSegregate(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      lookItemsSegregateList = res['user_details'];
    });
  }

  Future lookItemsGood() async{
    var res = await db.lookItemsGood(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadItems1 = res['user_details'];
    });
  }

  var checkIfExists;
  Future checkIfOnGoing() async{
    var res = await db.checkIfOnGoing(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      if(res == 'true'){
        Navigator.of(context).push(_viewOrderStatus(widget.ticketNo));
      }if(res == 'false'){
        itemNotYetReady();
      }
    });
  }

  itemNotYetReady(){
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return  AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal:0.0, vertical: 20.0),
          title: Center(
            child: Container(
              height: 100,
              width: 100,
              child: SvgPicture.asset("assets/svg/fried.svg"),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child:Center(
                     child:Text("Can't show the rider details unless all the food are ready to deliver.",textAlign: TextAlign.justify, maxLines: 3,style:TextStyle(fontSize: 18.0),),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close',style: TextStyle(
                color: Colors.deepOrange,
              ),),
              onPressed: () async{
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  bool visible = true;
  @override
  void initState(){

    print("order: " + widget.dmop);
    print(widget.pend);
    super.initState();
    selectType();
    getTotal();
    // getSubTotal();
    if(widget.dmop=='Pick-up' || widget.pend == 1){
      visible = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
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
          title: Text("For "+widget.dmop+": " +widget.ticketNo,style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
          actions: [
            IconButton(
                icon: Icon(Icons.info_outline, color: Colors.black),
                onPressed: () async {

                  Navigator.of(context).push(_orderTimeFrame(widget.ticketNo));


                }
            ),
          ],
        ),

        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Visibility(
                    visible: visible,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                      child: OutlinedButton(
                        style: TextButton.styleFrom(
                          primary: Colors.black, // foreground
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                        ),
                        onPressed: () {
                          checkIfOnGoing();
                        },
                        child: Text("View rider"),
                      ),
                    ),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: refresh,
                      child: Scrollbar(
                        child:ListView.builder(
                          itemCount: lookItemsSegregateList == null ? 0 : lookItemsSegregateList.length,
                          itemBuilder: (BuildContext context, int index0) {
                            return Container(
                                child:Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(17.0,25.0, 0.0,0.0),
                                        child: Text('${lookItemsSegregateList[index0]['bu_name'].toString()} ${lookItemsSegregateList[index0]['tenant_name'].toString()}',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold ,fontSize: 17.0)),
                                      ),
                                      ListView.builder(
                                          physics:  NeverScrollableScrollPhysics (),
                                          shrinkWrap: true,
                                          itemCount:loadItems == null ? 0 : loadItems.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Visibility(
                                              visible: loadItems[index]['tenant_id'] != lookItemsSegregateList[index0]['tenant_id'] ? false : true,
                                              child: Container(
                                                height: 180.0,
                                                width: 50.0,
                                                child: Card(
                                                  color: Colors.transparent,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: [
                                                      Divider(),
                                                      Row(
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                                                            child: Container(
                                                                width: 80.0,
                                                                height: 60.0,
                                                                decoration: new BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  image: new DecorationImage(
                                                                    image: new NetworkImage(loadItems[index]['prod_image']),
                                                                    fit: BoxFit.scaleDown,
                                                                  ),
                                                                )),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              child:Column(
                                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Padding(
                                                                    padding: EdgeInsets.fromLTRB(15, 0, 5, 5),
                                                                    child:Text(loadItems[index]['prod_name'],maxLines: 6, overflow: TextOverflow.ellipsis,
                                                                      style: GoogleFonts.openSans(
                                                                          fontStyle:
                                                                          FontStyle.normal,
                                                                          fontSize: 15.0),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                                                                        child: new Text(
                                                                          "₱ ${oCcy.format(double.parse(loadItems[index]['total_price']))} ",
                                                                          style: TextStyle(
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                            fontSize: 15.0,
                                                                            color: Colors.deepOrange,
                                                                          ),
                                                                        ),
                                                                      ),

                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(15, 0, 20, 0),
                                                                        child: new Text('Quantity: ${loadItems[index]['d_qty']}',
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 15.0,
                                                                            //                                                        color: Colors.deepOrange,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      loadItems[index]['canceled_status'] == '1'?
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                                                                        child: OutlinedButton(
                                                                          style: TextButton.styleFrom(
                                                                            primary: Colors.black, // foreground
                                                                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                                          ),
                                                                          onPressed: null,
                                                                          child: Text("Cancelled"),
                                                                        ),
                                                                      ):
                                                                      loadItems[index]['ifexists'] == 'true'?
                                                                      // Padding(
                                                                      //   padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                                                                      //   child: OutlinedButton(
                                                                      //     style: TextButton.styleFrom(
                                                                      //       primary: Colors.black, // foreground
                                                                      //       shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                                      //     ),
                                                                      //     onPressed: null,
                                                                      //     child: Text("Rider is tagged"),
                                                                      //   ),
                                                                      // )
                                                                      Container()
                                                                       :Padding(
                                                                        padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                                                                        child: OutlinedButton(
                                                                          style: TextButton.styleFrom(
                                                                            primary: Colors.black, // foreground
                                                                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                                          ),
                                                                          onPressed: (){
                                                                            cancelOrder(loadItems[index]['toms_id'],loadItems[index]['ticketId']);
                                                                          },
                                                                          child:Text("Cancel this item"),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Visibility(
                                                                    // visible: loadItems[index]['addon_length'] == 0 ? false : true,
                                                                    visible: loadItems[index]['addon_length'] > 0 ? true : false,
                                                                    child: Padding(
                                                                      padding:EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                      child:Container(
                                                                        width: 70.0,
                                                                        child: OutlinedButton(
                                                                          style: TextButton.styleFrom(
                                                                            primary: Colors.red,
                                                                            onSurface: Colors.red,
                                                                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                                          ),
                                                                          child:Text('${loadItems[index]['addon_length'].toString()}  more',style: TextStyle(fontSize: 10.0),),
                                                                          onPressed: ()async {
                                                                            viewAddon(context, index);
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  elevation: 0,
                                                  margin: EdgeInsets.all(3),
                                                ),
                                              ),
                                            );
                                          }),
                                    ],
                                ),
                            );
                          }
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0,5.0, 25.0,5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0,color: Colors.black45),),
                        Text("₱ ${oCcy.format(int.parse(subTotal.toString()))}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0,color: Colors.black45),),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0,5.0, 25.0,5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Fee: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0,color: Colors.black45),),
                        Text("₱ ${oCcy.format(int.parse(deliveryCharge.toString()))}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0,color: Colors.black45),),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 5.5,
                          child: SleekButton(
                            onTap: () async{
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String status = prefs.getString('s_status');
                              status != null
                                  ?  displayBottomSheet(context)
                                  : Navigator.of(context).push(_signIn());
                            },
                            style: SleekButtonStyle.flat(
                              color: Colors.deepOrange,
                              inverted: false,
                              rounded: true,
                              size: SleekButtonSize.big,
                              context: context,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.remove_red_eye,
                                size: 17.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 2.0,
                        ),
                        Flexible(
                          child: SleekButton(
                            onTap: () async {
                            },

                            style: SleekButtonStyle.flat(
                              color: Colors.deepOrange,
                              inverted: true,
                              rounded: true,
                              size: SleekButtonSize.big,
                              context: context,
                            ),
                            child: Center(
                                // ₱${oCcy.format(int.parse(lGetAmountPerTenant[index]['sumpertenats'].toString()))}
                                child: Text("Grand Total ₱ ${oCcy.format(int.parse(grandTotal.toString()))}", style:TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 18.0),
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

Route _viewOrderStatus(ticketNo) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ViewOrderStatus(ticketNo:ticketNo),
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

Route _orderTimeFrame(ticketNo) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => OrderTimeFrame(ticketNo:ticketNo),
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
