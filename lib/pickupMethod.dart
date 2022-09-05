import 'package:arush/profile/addNewAddress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
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
  final paymentMethod;

  const PlaceOrderPickUp({Key key, this.paymentMethod}) : super(key: key);
  @override
  _PlaceOrderPickUp createState() => _PlaceOrderPickUp();
}

class _PlaceOrderPickUp extends State<PlaceOrderPickUp>    with SingleTickerProviderStateMixin {
  final db = RapidA();
  GlobalKey<FormState> _key = GlobalKey<FormState>();

  List<TextEditingController> _deliveryDate =  [];
  List<TextEditingController>  _deliveryTime = [];
  List<TextEditingController> _specialInstruction =  [];

  List<String> _option = ['Cancel Item','Cancel Order'];
  List<String> getTenantData = [];
  List<String> getBuNameData = [];
  List<String> getAcroNameData = [];
  List<String> getTenantNameData =[];
  List<String> deliveryDateData = [];
  List<String> deliveryTimeData = [];
  List<String> specialInstruction = [];
  List<String> productName = [];
  List<String> price = [];
  List<String> quantity = [];
  List<String> totalPrice = [];
  List<String> tenantID = [];
  List loadCartData = [];
  List loadIMainItems;
  List getBu;
  List getTenant;
  List getItemsData;
  List getOrder;
  List getSubtotal;
  List loadTotalData;
  List placeOrder;
  List getItemsData2;


  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final discount = TextEditingController();
  var subtotal = 0.0;
  var isLoading = true;
  var lt = 0;
  var timeCount;
  var items;
  var stores;
  var _globalTime,_globalTime2;
  var stock;
  String date;
  String time;
  String selectedValue;

  submitPickUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }else{
        Navigator.of(context).push(submitPickUpRoute(
            widget.paymentMethod,
            deliveryDateData,
            deliveryTimeData,
            getTenantData,
            getTenantNameData,
            getBuNameData,
            subtotal,
            specialInstruction));
    }
  }

  updateCartStock(id, stk) async {
    await db.updateCartStk(id, stk);
  }

  void loadTotal() async{
    subtotal = 0;
    var res = await db.loadSubTotal();
    if (!mounted) return;
    setState((){
      isLoading = false;
      loadTotalData = res['user_details'];
      subtotal = double.parse(loadTotalData[0]['grand_total'].toString());

    });
  }

  Future loadCart() async {
    var res = await db.loadCartData();
    if (!mounted) return;
    setState(() {

      loadCartData = res['user_details'];
      loadIMainItems = loadCartData;
      items = loadCartData.length;
      isLoading = false;
      // print(loadCartData.length);
    });
  }

  Future getOrderData() async{
    var res = await db.getOrderData();
    if (!mounted) return;
    setState(() {
      getOrder = res['user_details'];
    });
  }

  Future getBuSegregate() async {
    var res = await db.getBuSegregate1();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
      stores = getBu.length;
      // print(getBu.length);
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
        getTenantNameData.add(getTenant[q]['tenant_name']);
        getBuNameData.add(getTenant[q]['bu_name']);
        getAcroNameData.add(getTenant[q]['acroname']);
      }
      print(getTenant.length);
      // print(getTenantData);
      // print(getTenantNameData);
      // print(getBuNameData);
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

  Future toRefresh() async{
    getOrderData();
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

  viewAddon(BuildContext context, mainItemIndex) {
    showModalBottomSheet(
    isScrollControlled: true,
    isDismissible: true,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(10), topLeft: Radius.circular(10)),
    ),
    builder: (ctx) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // loadFlavors
            // loadAddons
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
              child: Text(
                "Add ons",
                style: TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
              ),
            ),

            Divider(thickness: 2, color: Colors.deepOrangeAccent,),

            Expanded(
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: loadIMainItems == null ? 0 : loadIMainItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        String flavorPrice;
                        var f = index;
                        if (f == mainItemIndex) {
                          if (loadIMainItems[mainItemIndex]['flavors'].length > 0) {
                            if (loadIMainItems[mainItemIndex]['flavors'][0]['addon_price'] == '0.00'){
                              flavorPrice = "";
                            }else{
                              flavorPrice = (' ₱ ${loadIMainItems[mainItemIndex]['flavors'][0]['addon_price']}');
                            }
                            return Padding(
                              padding:
                              EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        ' + ${loadIMainItems[mainItemIndex]['flavors'][0]['flavor']} ${flavorPrice}',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                        ),
                                        maxLines: 6,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }
                        return SizedBox();
                      },
                    ),

                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: loadIMainItems[mainItemIndex]['choices'].length == null ? 0 : loadIMainItems[mainItemIndex]['choices'].length,
                      itemBuilder: (BuildContext context, int index) {
                        String choicesPrice;
                        if (loadIMainItems[mainItemIndex]['choices'][index]['addon_price'] == '0.00') {
                          choicesPrice = "";
                        } else {
                          choicesPrice = ('- ₱ ${loadIMainItems[mainItemIndex]['choices'][index]['addon_price']}');
                        }
                        if(loadIMainItems[mainItemIndex]['choices'][index]['unit_measure'] == null) {
                          return Padding(
                            padding:
                            EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                    ' ${loadIMainItems[mainItemIndex]['choices'][index]['product_name']} ${choicesPrice}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                    maxLines: 6,
                                    overflow: TextOverflow.ellipsis,)
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding:
                          EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          child: Container(
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    ' + ${loadIMainItems[mainItemIndex]['choices'][index]['product_name']} - ${loadIMainItems[mainItemIndex]['choices'][index]['unit_measure']} ${choicesPrice}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                    maxLines: 6,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    //addon
                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: loadIMainItems[mainItemIndex]['addons'].length == null ? 0 : loadIMainItems[mainItemIndex]['addons'].length,
                      itemBuilder: (BuildContext context, int index) {
                        if(loadIMainItems[mainItemIndex]['addons'][index]['unit_measure'] == null){
                          return Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      ' + ${loadIMainItems[mainItemIndex]['addons'][index]['product_name']} - ₱ ${loadIMainItems[mainItemIndex]['addons'][index]['addon_price']}',
                                      style: TextStyle(fontSize: 14.0,), maxLines: 6, overflow: TextOverflow.ellipsis,
                                    )
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    ' + ${loadIMainItems[mainItemIndex]['addons'][index]['product_name']} ${loadIMainItems[mainItemIndex]['addons'][index]['unit_measure']} - ₱ ${loadIMainItems[mainItemIndex]['addons'][index]['addon_price']}',
                                    style: TextStyle(fontSize: 14.0,), maxLines: 6, overflow: TextOverflow.ellipsis,
                                  )
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            )
          ],
        ),
      );
    });
  }

  void displayBottomSheet(BuildContext context,tenantId,buName,tenantName) async{
    var res = await db.displayOrder(tenantId);
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
                        child:Text(tenantName+" - "+buName,style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),),
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
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 18.0, 10.0),
                            child:Text("If out of stock",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.black54),),
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

  @override
  void initState(){
    selectedDiscountType.clear();
    super.initState();
    selectedDiscountType.clear();
    getOrderData();
    getBuSegregate();
    getTrueTime();
    getTenantSegregate();
    loadTotal();
    loadCart();
    print(widget.paymentMethod);
    // _deliveryDate.clear();
    _deliveryTime.clear();
    // print(getBu.length);
  }


  @override
  void dispose() {
    var index = 0;
    _deliveryTime[index].dispose();
    _deliveryDate[index].dispose();
    _specialInstruction[index].dispose();
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
          titleSpacing: 0,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black54,size: 23,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Review Checkout Form (Pick-up)",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 16.0),),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange)),
        ) :
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Form(
                  key: _key,
                  child: RefreshIndicator(
                    onRefresh: loadCart,
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: getTenant == null ? 0 : getTenant.length,
                        itemBuilder: (BuildContext context, int index0) {
                          _deliveryDate.add(new TextEditingController());
                          _deliveryTime.add(new TextEditingController());
                          _specialInstruction.add(new TextEditingController());
                          return Container(
                            child: Column(
                              crossAxisAlignment : CrossAxisAlignment.start,
                              children: <Widget>[
                                Divider(thickness: 2, color: Colors.deepOrangeAccent,),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text('${getTenant[index0]['tenant_name'].toString()} - ${getTenant[index0]['acroname'].toString()}',
                                    style: TextStyle(
                                      color: Colors.deepOrangeAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                                ),
                                Divider(thickness: 2, color: Colors.deepOrangeAccent,),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Product Details',
                                        style: GoogleFonts.openSans(fontStyle: FontStyle.normal ,fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                      Text('Total Price',
                                        style: GoogleFonts.openSans(fontStyle: FontStyle.normal ,fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: loadCartData == null ? 0 : loadCartData.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Visibility(
                                      visible: loadCartData[index]['main_item']['tenant_id'] != getTenant[index0]['tenant_id'] ? false : true,
                                      child: Container(
                                        height: 120.0,
                                        child: Card(
                                          color: Colors.transparent,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                            width: 90.0, height: 75.0,
                                                            decoration: new BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              image: new DecorationImage(
                                                                image: new NetworkImage(
                                                                    loadCartData[index]['main_item']['image']),
                                                                fit: BoxFit.scaleDown,
                                                              ),
                                                            )),

                                                        Padding(
                                                          padding: EdgeInsets.fromLTRB(0, 5, 10, 0),
                                                          child: Text("₱ ${loadCartData[index]['main_item']['price'].toString()}",
                                                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14,
                                                              color: Colors.black54,),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: <Widget>[
                                                            Flexible(child:
                                                            Padding(
                                                              padding: EdgeInsets.fromLTRB(20, 0, 5, 0),
                                                              child: RichText(
                                                                overflow: TextOverflow.ellipsis,
                                                                text: TextSpan(
                                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 14),
                                                                  text: '${loadCartData[index]['main_item']['product_name']}'),
                                                              ),
                                                            ),
                                                            ),

                                                            Padding(
                                                              padding: EdgeInsets.fromLTRB(0, 2, 20, 0),
                                                              child: Text("₱ ${loadCartData[index]['main_item']['total_price'].toString()}",
                                                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14,
                                                                  color: Colors.black,),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: <Widget>[
                                                            Row(
                                                              children: <Widget>[
                                                                Padding(
                                                                  padding: EdgeInsets.fromLTRB(20, 5, 15, 5),
                                                                  child: Text('Quantity: ${loadCartData[index]['main_item']['quantity'].toString()}',
                                                                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 10),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Visibility(
                                                                visible: loadCartData[index]['main_item']['addon_length'] > 0 ? true : false,
                                                                // visible: loadCartData[index]['addon_length'] == 0 ? false : true,
                                                                child:
                                                                Padding(
                                                                  padding: EdgeInsets.fromLTRB(5, 0, 15, 0),
                                                                  child:
                                                                  Container(
                                                                    width: 70.0,
                                                                    child: OutlinedButton(
                                                                      style: OutlinedButton.styleFrom(
                                                                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                                                        side: BorderSide(width: 1.0, color: Colors.deepOrangeAccent),
                                                                        primary: Colors.deepOrangeAccent
                                                                      ),
                                                                      child: Text('${loadCartData[index]['main_item']['addon_length'].toString()}  more',
                                                                        style:TextStyle(fontSize: 10.0),
                                                                      ),
                                                                      onPressed:
                                                                          () async {
                                                                        viewAddon(context, index);
                                                                        // debugPrint('${loadIMainItems[index]['choices'][index]['product_name']}');
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Flexible(
                                                                child: Container(
                                                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                  width: 130,
                                                                  child: DropdownButtonFormField(
                                                                    decoration: InputDecoration(
                                                                      //Add isDense true and zero Padding.
                                                                      //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                                      isDense: true,
                                                                      contentPadding: const EdgeInsets.only(
                                                                          left: 5, right: 0
                                                                      ),
                                                                      border: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.circular(5),
                                                                      ),
                                                                      //Add more decoration as you want here
                                                                      //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                                    ),
                                                                    isExpanded: false,
                                                                    hint: const Text(
                                                                      'Cancel Item', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black54)),
                                                                    icon: const Icon(
                                                                      Icons.arrow_drop_down,
                                                                      color: Colors.black45,
                                                                    ),
                                                                    iconSize: 20,
                                                                    items: _option
                                                                        .map((item) =>
                                                                        DropdownMenuItem<String>(
                                                                          value: item,
                                                                          child: Container(
                                                                            width: 85,
                                                                            child:Text(item, style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black54)),
                                                                          )
                                                                        ))
                                                                        .toList(),
                                                                    // ignore: missing_return
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        selectedValue = value;
                                                                        stock  = _option.indexOf(value);
                                                                        print(stock);
                                                                        print(loadCartData[index]['main_item']['product_id']);
                                                                        updateCartStock(loadCartData[index]['main_item']['product_id'], stock);
                                                                      });
                                                                      //Do something when changing the item if you want.
                                                                    },
                                                                    onTap: (){
                                                                    },
                                                                    onSaved: (value) {
                                                                      selectedValue = value.toString();
                                                                      print(selectedValue);
                                                                    },
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Divider(thickness: 2),
                                            ],
                                          ),
                                          elevation: 0,
                                          margin: EdgeInsets.all(3),
                                        ),
                                      ),
                                    );
                                  }
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 5, 5),
                                  child: new Text("Setup Date & Time for Pick-up", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 5, 5),
                                  child: new Text("Pick-up date*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0),),
                                ),
                                Padding(
                                  padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                  child: InkWell(
                                    onTap: (){

                                      _deliveryTime[index0].clear();

                                      FocusScope.of(context).requestFocus(FocusNode());
                                      showDialog<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            contentPadding: EdgeInsets.all(0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(8.0))
                                            ),
                                              titlePadding: const EdgeInsets.only(left: 10, top: 10, bottom: 0),
                                              title: Text("Set date for this pick-up",style: TextStyle(fontSize: 16.0, color: Colors.deepOrangeAccent),
                                            ),
                                            content: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Divider(color: Colors.deepOrangeAccent),
                                                Container(
                                                  padding: EdgeInsets.all(0),
                                                  height:150.0, // Change as per your requirement
                                                  width: 300.0, // Change as per your requirement
                                                  child: Scrollbar(
                                                    child:ListView.builder(
                                                      physics: BouncingScrollPhysics(),
                                                      itemCount: 4,
                                                      itemBuilder: (BuildContext context, int index1) {
                                                        int n = 0;
                                                        n = index1;
                                                        var d1 = DateTime.parse(trueTime[0]['date_today']);
                                                        var d2 = new DateTime(d1.year, d1.month, d1.day + n);
                                                        final DateFormat formatter = DateFormat('yyyy-MM-dd');
                                                        final String formatted = formatter.format(d2);
                                                        return InkWell(
                                                          onTap: (){
                                                            while(deliveryDateData.length > getTenant.length-1){
                                                              deliveryDateData.removeAt(index0);
                                                            }
                                                            _deliveryDate[index0].text = formatted;
                                                            deliveryDateData.insert(index0, _deliveryDate[index0].text);

                                                            Navigator.of(context).pop();
                                                            if(index1 == 0){
                                                              setState(() {
                                                                timeCount = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']).difference(DateTime.parse(trueTime[0]['date_today']+" "+"19:30")).inHours;
                                                                timeCount = timeCount.abs();
                                                                _globalTime = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']);
                                                                _globalTime2 = _globalTime.hour;
                                                              });
                                                            }else{
                                                              setState(() {
                                                                timeCount = 12;
                                                                _globalTime = new DateTime.now();
                                                                _globalTime2 = 07;
                                                                // _deliveryDate.clear();
                                                              });
                                                            }
                                                          },
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Row (
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: <Widget>[
                                                                  Padding(
                                                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                                    child: Text('${formatted.toString()}',style: TextStyle(fontSize: 15.0),),
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
                                              ],
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
                                                  _deliveryDate[index0].clear();
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
                                        style: TextStyle(fontSize: 14),
                                        cursorColor: Colors.deepOrange,
                                        controller: _deliveryDate[index0],
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please select pick-up date';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.date_range,color: Colors.grey,),
                                          contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
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
                                  padding: EdgeInsets.fromLTRB(20, 10, 5, 5),
                                  child: new Text("Pick-up time*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0),),
                                ),
                                Padding(
                                  padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                  child: InkWell(
                                    onTap: (){

                                      getTrueTime();
                                      if(_deliveryDate[index0].text.isEmpty){
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
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              contentPadding: EdgeInsets.all(0),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                                              ),
                                              titlePadding: const EdgeInsets.only(left: 10, top: 10, bottom: 0),
                                              title: Text("Set time for this pick-up",style: TextStyle(fontSize: 16.0, color: Colors.deepOrangeAccent)),
                                              content: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Divider(color: Colors.deepOrangeAccent),
                                                  Container(
                                                    height:200.0, // Change as per your requirement
                                                    width: 300.0, // Change as per your requirement
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
                                                              while(deliveryTimeData.length > getTenant.length-1){
                                                                deliveryTimeData.removeAt(index0);
                                                              }
                                                              _deliveryTime[index0].text = from;
                                                              deliveryTimeData.insert(index0, _deliveryTime[index0].text);

                                                              Navigator.of(context).pop();
                                                            },
                                                            child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Row (
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: <Widget>[
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                                          child: Text('${from.toString()}',style: TextStyle(fontSize: 14.0),),
                                                                        ),
                                                                      ]
                                                                  ),
                                                                ],
                                                              ),
                                                          );
                                                        }
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                                                    _deliveryTime[index0].clear();
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
                                        style: TextStyle(fontSize: 14),
                                        textInputAction: TextInputAction.done,
                                        cursorColor: Colors.deepOrange,
                                        controller: _deliveryTime[index0],
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please select pick-up time';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.timelapse,color: Colors.grey,),
                                          contentPadding: EdgeInsets.all(0),
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
                                  padding: EdgeInsets.fromLTRB(10, 0, 5, 5),
                                  child: new Text("Special Instruction", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),),
                                ),
                                Padding(
                                  padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                  child: new TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.done,
                                    cursorColor: Colors.deepOrange,
                                    controller: _specialInstruction[index0],
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter some value';
                                      }
                                      return null;
                                    },
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(fontSize: 14),
                                      hintText:"Special instruction",
                                      contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                                      focusedBorder:OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                      ),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                    ),
                  ),
                )
              ),
                Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: SleekButton(
                        onTap: () {
                          if (_key.currentState.validate()) {
                            // Navigator.of(context).push(_gcPickUpFinal(groupValue,_deliveryTime.text,_deliveryDate.text,_modeOfPayment.text));
                            submitPickUp();
                          }
                          for (int i=0; i<getTenant.length; i++){
                            // print(_specialInstruction[i].text);
                            // special.add(_specialInstruction[i].text);
                            while(specialInstruction.length > getTenant.length-1){
                              specialInstruction.removeAt(i);
                            }
                            specialInstruction.insert(i, _specialInstruction[i].text);
                          }
                          // print(specialInstruction);
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
//         Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                     child:Scrollbar(
//                         child: RefreshIndicator(
//                             onRefresh: toRefresh,
//                             child: Form(
//                               key: _key,
//                               child: ListView(
//                                 padding: EdgeInsets.zero,
//                                 children:<Widget> [
//                                   ListView.builder(
//                                       physics: BouncingScrollPhysics(),
//                                       shrinkWrap: true,
//                                       itemCount:  getBu == null ? 0 : getBu.length,
//                                       itemBuilder: (BuildContext context, int index0) {
// //                                  test = getBu[index0]['d_bu_name'];
//                                         var num = index0;
//                                         num++;
//                                         return Container(
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: <Widget>[
//                                               Row(
//                                                 children: [
//                                                   Expanded(
//                                                     child:  Padding(
//                                                       padding: EdgeInsets.fromLTRB(17.0,10.0, 0.0,10.0),
//                                                       child: Text('$num. ${getBu[index0]['d_bu_name'].toString()}',style: GoogleFonts.openSans(color:Colors.deepOrange, fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 18.0),),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               ListView.builder(
//                                                   physics: BouncingScrollPhysics(),
//                                                   shrinkWrap: true,
//                                                   itemCount:  getTenant == null ? 0 : getTenant.length,
//                                                   itemBuilder: (BuildContext context, int index) {
//                                                     _deliveryDate.add(new TextEditingController());
//                                                     _deliveryTime.add(new TextEditingController());
//                                                     return Visibility(
//                                                       visible: getTenant[index]['bu_id'] != getBu[index0]['d_bu_id'] ? false : true,
//                                                       child: Container(
//                                                         child: Column(
//                                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                                           children: <Widget>[
//                                                             Padding(
//                                                               padding: EdgeInsets.fromLTRB(20.0,0.0, 20.0,0.0),
//                                                               child: OutlinedButton(
//                                                                 onPressed: (){
//                                                                   print(getTenant);
//                                                                   // print(getTenantData[index]);
//                                                                   // print(getTenantNameData[index]);
//                                                                   // print(getBuNameData[index]);
//                                                                   print(getAcroNameData[index]);
//                                                                   displayBottomSheet(
//                                                                       context,
//                                                                       getTenantData[index],
//                                                                       getAcroNameData[index],
//                                                                       getTenantNameData[index]);
//
//
//                                                                 },
//                                                                 style: ButtonStyle(
//                                                                   overlayColor: MaterialStateProperty.all(Colors.black12),
//                                                                   side: MaterialStateProperty.all(BorderSide(
//                                                                       color: Colors.black54,
//                                                                       width: 1.0,
//                                                                       style: BorderStyle.solid)),
//                                                                 ),
//                                                                 child:Row(
//                                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                   children: [
//                                                                     Text('${getTenant[index]['tenant_name']}', style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 15.0, color: Colors.black54),),
//                                                                     Text('₱${oCcy.format(int.parse(getTenant[index]['total'].toString()))}', style: TextStyle(fontStyle: FontStyle.normal,fontSize: 15.0, color: Colors.black54),),
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             Padding(
//                                                               padding: EdgeInsets.fromLTRB(35, 0, 5, 5),
//                                                               child: new Text("Pick-up date*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                                                             ),
//                                                             Padding(
//                                                               padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
//                                                               child: InkWell(
//                                                                 onTap: (){
//
//                                                                   _deliveryTime[index].clear();
//
//                                                                   FocusScope.of(context).requestFocus(FocusNode());
//                                                                   showDialog<void>(
//                                                                     context: context,
//                                                                     builder: (BuildContext context) {
//                                                                       return AlertDialog(
//                                                                         shape: RoundedRectangleBorder(
//                                                                             borderRadius: BorderRadius.all(Radius.circular(8.0))
//                                                                         ),
//                                                                         title: Text("Set date for this pick-up",style: TextStyle(fontSize: 20.0),),
//                                                                         contentPadding:EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
//                                                                         content: Container(
//                                                                           height:230.0, // Change as per your requirement
//                                                                           width: 360.0, // Change as per your requirement
//                                                                           child: Scrollbar(
//                                                                             child:ListView.builder(
//                                                                               physics: BouncingScrollPhysics(),
//                                                                               itemCount: 4,
//                                                                               itemBuilder: (BuildContext context, int index1) {
//                                                                                 int n = 0;
//                                                                                 n = index1;
//                                                                                 var d1 = DateTime.parse(trueTime[0]['date_today']);
//                                                                                 var d2 = new DateTime(d1.year, d1.month, d1.day + n);
//                                                                                 final DateFormat formatter = DateFormat('yyyy-MM-dd');
//                                                                                 final String formatted = formatter.format(d2);
//                                                                                 return InkWell(
//                                                                                   onTap: (){
//                                                                                     while(deliveryDateData.length > getTenant.length-1){
//                                                                                       deliveryDateData.removeAt(index);
//                                                                                     }
//                                                                                     _deliveryDate[index].text = formatted;
//                                                                                     deliveryDateData.insert(index, _deliveryDate[index].text);
//
//                                                                                     Navigator.of(context).pop();
//                                                                                     if(index1 == 0){
//                                                                                       setState(() {
//                                                                                         timeCount = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']).difference(DateTime.parse(trueTime[0]['date_today']+" "+"19:30")).inHours;
//                                                                                         timeCount = timeCount.abs();
//                                                                                         _globalTime = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']);
//                                                                                         _globalTime2 = _globalTime.hour;
//                                                                                       });
//                                                                                     }else{
//                                                                                       setState(() {
//                                                                                         timeCount = 12;
//                                                                                         _globalTime = new DateTime.now();
//                                                                                         _globalTime2 = 07;
//                                                                                         // _deliveryDate.clear();
//                                                                                       });
//                                                                                     }
//                                                                                   },
//                                                                                   child: Container(
//                                                                                     child: Column(
//                                                                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                                                                       children: <Widget>[
//                                                                                         Row (
//                                                                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                             children: <Widget>[
//                                                                                               Padding(
//                                                                                                 padding: EdgeInsets.fromLTRB(30.0,20.0, 0.0,20.0),
//                                                                                                 child: Text('${formatted.toString()}',style: TextStyle(fontSize: 16.0),),
//                                                                                               ),
//                                                                                             ]
//                                                                                         ),
//                                                                                       ],
//                                                                                     ),
//                                                                                   ),
//                                                                                 );
//                                                                               },
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                         actions: <Widget>[
//                                                                           TextButton(
//                                                                             child: Text(
//                                                                               'Clear',
//                                                                               style: TextStyle(
//                                                                                 color: Colors.deepOrange,
//                                                                               ),
//                                                                             ),
//                                                                             onPressed: () {
//                                                                               _deliveryDate[index].clear();
//                                                                               Navigator.of(context).pop();
//                                                                             },
//                                                                           ),
//                                                                         ],
//                                                                       );
//                                                                     },
//                                                                   );
//                                                                 },
//                                                                 child: IgnorePointer(
//                                                                   child: new TextFormField(
//                                                                     textInputAction: TextInputAction.done,
//                                                                     cursorColor: Colors.deepOrange,
//                                                                     controller: _deliveryDate[index],
//                                                                     validator: (value) {
//                                                                       if (value.isEmpty) {
//                                                                         return 'Please select pick-up date';
//                                                                       }
//                                                                       return null;
//                                                                     },
//                                                                     decoration: InputDecoration(
//                                                                       prefixIcon: Icon(Icons.date_range,color: Colors.grey,),
//                                                                       contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                                                                       focusedBorder:OutlineInputBorder(
//                                                                         borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                                                                       ),
//                                                                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             Padding(
//                                                               padding: EdgeInsets.fromLTRB(35, 10, 5, 5),
//                                                               child: new Text("Pick-up time", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                                                             ),
//                                                             Padding(
//                                                               padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
//                                                               child: InkWell(
//                                                                 onTap: (){
//
//                                                                   getTrueTime();
//                                                                   if(_deliveryDate[index].text.isEmpty){
//                                                                     Fluttertoast.showToast(
//                                                                         msg: "Please select a pick-up date",
//                                                                         toastLength: Toast.LENGTH_SHORT,
//                                                                         gravity: ToastGravity.BOTTOM,
//                                                                         timeInSecForIosWeb: 2,
//                                                                         backgroundColor: Colors.black.withOpacity(0.7),
//                                                                         textColor: Colors.white,
//                                                                         fontSize: 16.0
//                                                                     );
//                                                                   }
//                                                                   else{
//                                                                     FocusScope.of(context).requestFocus(FocusNode());
//                                                                     showDialog<void>(
//                                                                       context: context,
//                                                                       builder: (BuildContext context) {
//                                                                         return AlertDialog(
//                                                                           shape: RoundedRectangleBorder(
//                                                                               borderRadius: BorderRadius.all(Radius.circular(8.0))
//                                                                           ),
//                                                                           title: Text("Set time for this pick-up",style: TextStyle(fontSize: 20.0),),
//                                                                           contentPadding:
//                                                                           EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
//                                                                           content: Container(
//                                                                             height:230.0, // Change as per your requirement
//                                                                             width: 360.0, // Change as per your requirement
//                                                                             child: Scrollbar(
//                                                                               child:  ListView.builder(
//                                                                                   physics: BouncingScrollPhysics(),
//                                                                                   shrinkWrap: true,
//                                                                                   itemCount:  timeCount,
//                                                                                   itemBuilder: (BuildContext context, int index1) {
//                                                                                     int t = index1;
//                                                                                     t++;
//                                                                                     final now =  _globalTime;
//                                                                                     final dtFrom = DateTime(now.year, now.month, now.day, _globalTime2+t, 0+30, now.minute, now.second);
//                                                                                     // final dtTo = DateTime(now.year, now.month, now.day, 8+t, 0+30);
//                                                                                     final format = DateFormat.jm();  //"6:00 AM"
//                                                                                     String from = format.format(dtFrom);
//
//                                                                                     return InkWell(
//                                                                                       onTap: (){
//                                                                                         while(deliveryTimeData.length > getTenant.length-1){
//                                                                                           deliveryTimeData.removeAt(index);
//                                                                                         }
//                                                                                         _deliveryTime[index].text = from;
//                                                                                         deliveryTimeData.insert(index, _deliveryTime[index].text);
//
//                                                                                         Navigator.of(context).pop();
//                                                                                       },
//                                                                                       child: Container(
//                                                                                         child: Column(
//                                                                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                                                                           children: <Widget>[
//                                                                                             Row (
//                                                                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                                 children: <Widget>[
//                                                                                                   Padding(
//                                                                                                     padding: EdgeInsets.fromLTRB(30.0,20.0, 0.0,20.0),
//                                                                                                     child: Text('${from.toString()}',style: TextStyle(fontSize: 16.0),),
//                                                                                                   ),
//                                                                                                 ]
//                                                                                             ),
//                                                                                           ],
//                                                                                         ),
//                                                                                       ),
//                                                                                     );
//                                                                                   }
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                           actions: <Widget>[
//                                                                             TextButton(
//                                                                               child: Text(
//                                                                                 'Clear',
//                                                                                 style: TextStyle(
//                                                                                   color: Colors.deepOrange,
//                                                                                 ),
//                                                                               ),
//                                                                               onPressed: () {
//                                                                                 _deliveryTime[index].clear();
//                                                                                 Navigator.of(context).pop();
//                                                                               },
//                                                                             ),
//                                                                           ],
//                                                                         );
//                                                                       },
//                                                                     );
//                                                                   }
//
//                                                                 },
//                                                                 child: IgnorePointer(
//                                                                   child: new TextFormField(
//                                                                     textInputAction: TextInputAction.done,
//                                                                     cursorColor: Colors.deepOrange,
//                                                                     controller: _deliveryTime[index],
//                                                                     validator: (value) {
//                                                                       if (value.isEmpty) {
//                                                                         return 'Please select pick-up time';
//                                                                       }
//                                                                       return null;
//                                                                     },
//                                                                     decoration: InputDecoration(
//                                                                       prefixIcon: Icon(Icons.timelapse,color: Colors.grey,),
//                                                                       contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                                                                       focusedBorder:OutlineInputBorder(
//                                                                         borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                                                                       ),
//                                                                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             Divider(),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     );
//                                                   }
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       }
//                                   ),
//                                   // Padding(
//                                   //   padding: EdgeInsets.fromLTRB(35, 20, 5, 5),
//                                   //   child: new Text("Customer tender(ie.4,000.00)", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                                   // ),
//                                   // Padding(
//                                   //   padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
//                                   //   child: new TextFormField(
//                                   //     textInputAction: TextInputAction.done,
//                                   //     cursorColor: Colors.deepOrange,
//                                   //     controller: changeForPickup,
//                                   //     validator: (value){
//                                   //       if (value.isEmpty) {
//                                   //         return 'Please enter some value';
//                                   //       }
//                                   //       return null;
//                                   //     },
//                                   //     keyboardType: TextInputType.number,
//                                   //     decoration: InputDecoration(
//                                   //       prefixIcon: Icon(Icons.insert_chart,color: Colors.grey,),
//                                   //       contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                                   //       focusedBorder:OutlineInputBorder(
//                                   //         borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                                   //       ),
//                                   //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                                   //     ),
//                                   //   ),
//                                   // ),
//
//
//                                   // Padding(
//                                   //   padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
//                                   //   child: new Text("In case the product is out of stock", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                                   // ),
//                                   //
//                                   // _myRadioButton(
//                                   //   title: "Cancel the entire order",
//                                   //   value: 0,
//                                   //   onChanged: (newValue) => setState((){
//                                   //     groupValue = newValue;
//                                   //   }),
//                                   // ),
//                                   //
//                                   // _myRadioButton(
//                                   //   title: "Remove it from my order",
//                                   //   value: 1,
//                                   //   onChanged: (newValue) => setState((){
//                                   //     groupValue = newValue;
//                                   //   }),
//                                   // ),
//
//
//                                 ],
//                               ),
//                             )
//                         )
//                     )
//                 ),
//                 Divider(),
//                 Padding(
//                   padding:EdgeInsets.fromLTRB(30.0, 7.0, 30.0, 5.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text("Total Amount: ", style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
//                       Text("₱${oCcy.format(subtotal).toString()}", style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0))
//                     ],
//                   )
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
//                   child: Row(
//                     children: <Widget>[
//                       Flexible(
//                         child: SleekButton(
//                           onTap: () {
//                             if (_key.currentState.validate()) {
//                               // Navigator.of(context).push(_gcPickUpFinal(groupValue,_deliveryTime.text,_deliveryDate.text,_modeOfPayment.text));
//                               submitPickUp();
//
//                             }
//                           },
//                           style: SleekButtonStyle.flat(
//                             color: Colors.deepOrange,
//                             inverted: false,
//                             rounded: true,
//                             size: SleekButtonSize.big,
//                             context: context,
//                           ),
//                           child: Center(
//                             child: Text(
//                               "Next",
//                               style: GoogleFonts.openSans(
//                                   fontStyle: FontStyle.normal,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13.0),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
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


Route submitPickUpRoute(
    groupValue,
    deliveryDateData,
    deliveryTimeData,
    getTenantData,
    getTenantNameData,
    getBuNameData,
    subtotal,
    specialInstruction) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SubmitPickUp(
        groupValue:groupValue,
        deliveryDateData:deliveryDateData,
        deliveryTimeData:deliveryTimeData,
        getTenantData:getTenantData,
        getTenantNameData:getTenantNameData,
        getBuNameData:getBuNameData,
        subtotal:subtotal,
        specialInstruction:specialInstruction),
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