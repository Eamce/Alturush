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
  final List cartItems;
  final paymentMethod;

  const PlaceOrderDelivery({Key key, this.cartItems, this.paymentMethod}) : super(key: key);
  @override
  _PlaceOrderDelivery createState() => _PlaceOrderDelivery();
}

class _PlaceOrderDelivery extends State<PlaceOrderDelivery> with SingleTickerProviderStateMixin {
  final db = RapidA();
  final oCcy                = new NumberFormat("#,##0.00", "en_US");
  final changeFor           = TextEditingController();
  final placeOrderTown      = TextEditingController();
  final userName            = TextEditingController();
  final placeOrderBrg       = TextEditingController();
  final placeContactNo      = TextEditingController();
  final placeRemarks        = TextEditingController();
  // final specialInstruction  = TextEditingController();
  final street              = TextEditingController();
  final houseNo             = TextEditingController();
  final deliveryDate        = TextEditingController();
  final deliveryTime        = TextEditingController();
  final discount            = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  List<String> _option            = ['Cancel Item','Cancel Order'];
  List<String> specialInstruction = [];
  List<String> getAcroNameData    = [];
  List<String> deliveryDateData   = [];
  List<String> deliveryTimeData   = [];
  List<String> special            = [];
  List<String> getTenantData      = [];
  List<String> getBuNameData      = [];
  List<String> getTenantNameData  = [];

  List<TextEditingController> _specialInstruction = [];
  List<TextEditingController>  _deliveryTime      = [];
  List<TextEditingController> _deliveryDate       = [];

  List getTenant;
  List getItemsData;
  List displayAddOnsData;
  List placeOrder;
  List getBu;
  List checkFee;
  List loadDiscountedPerson;
  List loadCartData = [];
  List loadIMainItems;

  String selectedValue;

  double deliveryCharge = 0;
  double grandTotal     = 0.0;
  double minimumAmount  = 0.0;

  var subtotal  = 0.0;
  var isLoading = true;
  var townId,townName,barrioId,brgName,contact;
  var timeCount;
  var _globalTime,_globalTime2;
  var _today;
  var items;
  var stores;
  var stock;
  // String changeForFinal;


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
      deliveryCharge = double.parse(placeOrder[0]['d_charge_amt']);
      townId = placeOrder[0]['d_townId'];
      barrioId = placeOrder[0]['d_brgId'];
      placeOrderTown.text = placeOrder[0]['d_townName'];
      placeOrderBrg.text = placeOrder[0]['d_brgName'];
      placeContactNo.text = placeOrder[0]['d_contact'];
      placeRemarks.text = placeOrder[0]['land_mark'];
      street.text = placeOrder[0]['street_purok'];
      houseNo.text = placeOrder[0]['complete_address'];
      deliveryCharge = double.parse(placeOrder[0]['d_charge_amt']);
      grandTotal = deliveryCharge + subtotal;
      userName.text = ('${placeOrder[0]['firstname']} ${placeOrder[0]['lastname']}');
      minimumAmount = double.parse(placeOrder[0]['minimum_order_amount']);
      getTenantSegregate();
      print(userName.text);
      isLoading = false;
    });
  }

  updateCartStock(id, stk) async {
    await db.updateCartStk(id, stk);
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
                      OutlinedButton(
                        style: TextButton.styleFrom(
                          primary: Colors.black,
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        ),
                        onPressed:(){
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
                          placeOrderBrg.text  = getItemsData[index]['d_brgName'];
                          placeContactNo.text = getItemsData[index]['d_contact'];
                          placeRemarks.text   = getItemsData[index]['land_mark'];
                          street.text         = getItemsData[index]['street_purok'];
                          userName.text       = getItemsData[index]['firstname']+" "+getItemsData[index]['lastname'];
                          barrioId            = getItemsData[index]['d_townId'];
                          townId              = getItemsData[index]['d_brgId'];
                          deliveryCharge      = double.parse(getItemsData[index]['d_charge_amt']);
                          grandTotal          = deliveryCharge + subtotal;
                          minimumAmount       = double.parse(getItemsData[index]['minimum_order_amount']);
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
                        fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
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
                                    EdgeInsets.fromLTRB(15.0, 5.0, 25.0, 5.0),
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                              child: Text(
                                                '+ ${loadIMainItems[mainItemIndex]['flavors'][0]['flavor']} ${flavorPrice}',
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
                                  EdgeInsets.fromLTRB(15.0, 5.0, 25.0, 5.0),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                            child: Text(
                                              '+ ${loadIMainItems[mainItemIndex]['choices'][index]['product_name']} ${choicesPrice}',
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
                                EdgeInsets.fromLTRB(15.0, 5.0, 25.0, 5.0),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                            '+ ${loadIMainItems[mainItemIndex]['choices'][index]['product_name']} - ${loadIMainItems[mainItemIndex]['choices'][index]['unit_measure']} ${choicesPrice}',
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
                                  padding: EdgeInsets.fromLTRB(15.0, 5.0, 25.0, 5.0),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                            child: Text(
                                              '+ ${loadIMainItems[mainItemIndex]['addons'][index]['product_name']} - ₱ ${loadIMainItems[mainItemIndex]['addons'][index]['addon_price']}',
                                              style: TextStyle(fontSize: 14.0,), maxLines: 6, overflow: TextOverflow.ellipsis,
                                            )
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding: EdgeInsets.fromLTRB(15.0, 5.0, 25.0, 5.0),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                            '+ ${loadIMainItems[mainItemIndex]['addons'][index]['product_name']} ${loadIMainItems[mainItemIndex]['addons'][index]['unit_measure']} - ₱ ${loadIMainItems[mainItemIndex]['addons'][index]['addon_price']}',
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

  List<bool> subTotalTenant = [];

  Future getTenantSegregate() async{
    subTotalTenant.clear();
    var res = await db.getTenantSegregate();
    if (!mounted) return;
    setState(() {
      getTenant = res['user_details'];
     for(int q=0;q<getTenant.length;q++){
       bool result = getTenant[q]['total'] < minimumAmount;
       subTotalTenant.add(result);
       getTenantData.add(getTenant[q]['tenant_id']);
       getTenantNameData.add(getTenant[q]['tenant_name']);
       getBuNameData.add(getTenant[q]['bu_name']);
     }
     print(getTenantData);
     print(getTenantNameData);
     print(getBuNameData);
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

      if(subTotalTenant.contains(true)){
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))
            ),
            contentPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.only(left: 10, top: 10),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello!",
                  style: TextStyle(fontSize: 18.0, color: Colors.black54, fontWeight: FontWeight.bold)),

              ],
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(color: Colors.deepOrangeAccent,),
                SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Padding(
                        padding:EdgeInsets.fromLTRB(15.0, 0.0, 20.0, 0.0),
                        child:Center(
                            child:Text("Must reach a minimum order of ₱${oCcy.format(minimumAmount)} per tenant.", style: TextStyle(color: Colors.red, fontStyle: FontStyle.normal, fontSize: 14))),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.deepOrangeAccent,
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
     } else {
       SharedPreferences prefs = await SharedPreferences.getInstance();
       String username = prefs.getString('s_customerId');
       if(username == null){
         Navigator.of(context).push(_signIn());
       }else{
         Navigator.of(context).push(_submitOrder(
           widget.paymentMethod,
           deliveryDateData,
           deliveryTimeData,
           getTenantData,
           getTenantNameData,
           getBuNameData,
           subtotal,
           grandTotal,
           specialInstruction,
           deliveryCharge,
             ));
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
    loadCart();
    getPlaceOrderData();
    getBuSegregate();
    print(widget.paymentMethod);
    // print(userName.text);
    // loadTotal();
    // getTenantSegregate();
    // trapTenantLimit();
  }

  var index = 0;
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
    _specialInstruction[index].dispose();
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
        titleSpacing: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        leading: IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(Icons.arrow_back, color: Colors.black54,size: 23,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Padding(
          padding: EdgeInsets.all(0),
          child: Text("Review Checkout Form (Delivery)",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 16.0)),
        )
     ),
      body: isLoading
          ? Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
           ):
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Form(
                key: _formKey,
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
                                  child: Text(
                                      '${getTenant[index0]['tenant_name'].toString()} - ${getTenant[index0]['acroname'].toString()}',
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

                                                                  // Padding(
                                                                  //   padding: EdgeInsets.fromLTRB(260, 0, 0, 0),
                                                                  // ),
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
                                                                            'Cancel Item', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black)),
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
                                                                                  child:Text(item, style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54)),
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
                      if (_formKey.currentState.validate()) {
                        // Navigator.of(context).push(_gcPickUpFinal(groupValue,_deliveryTime.text,_deliveryDate.text,_modeOfPayment.text));
                        submitPlaceOrder();
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
//       Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Expanded(
//                 child:Form(
//                   key: _formKey,
//                   child: Scrollbar(
//                     child: ListView(
//                       padding: EdgeInsets.zero,
//                       children: <Widget>[
//                         Visibility(
//                           visible: true,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               // Padding(
//                               //   padding: EdgeInsets.fromLTRB(15, 2, 10, 2),
//                               //   // child: new Text("Name", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               //   child: Row(
//                               //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               //     children: [
//                               //       Padding(
//                               //         padding: EdgeInsets.fromLTRB(5, 2, 5, 5),
//                               //         child: new Text("Customer Address", style: GoogleFonts.openSans(fontWeight:FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 18.0),),
//                               //       ),
//                               //       Padding(
//                               //         padding: EdgeInsets.fromLTRB(5, 2, 5, 5),
//                               //         child: OutlinedButton.icon(
//                               //           onPressed: () async{
//                               //             FocusScope.of(context).requestFocus(FocusNode());
//                               //             SharedPreferences prefs = await SharedPreferences.getInstance();
//                               //             String username = prefs.getString('s_customerId');
//                               //             if(username == null){
//                               //               Navigator.of(context).push(_signIn());
//                               //             }else{
//                               //               displayAddresses(context);
//                               //             }
//                               //           },
//                               //
//                               //           label: Text('MANAGE ADDRESS',  style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 12.0, color: Colors.black54)),
//                               //           style: ButtonStyle(
//                               //             overlayColor: MaterialStateProperty.all(Colors.black12),
//                               //             side: MaterialStateProperty.all(BorderSide(
//                               //               color: Colors.black,
//                               //               width: 1.0,
//                               //               style: BorderStyle.solid,)),
//                               //           ),
//                               //           icon: Wrap(
//                               //             children: [
//                               //               Icon(Icons.settings_outlined, color: Colors.black54, size: 18,)
//                               //             ],
//                               //           ),
//                               //         ),
//                               //       ),
//                               //     ],
//                               //   ),
//                               // ),
//
//                               // Padding(
//                               //   padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
//                               //   child: new Text("Customer*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               // ),
//                               // Padding(
//                               //   padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//                               //   child: InkWell(
//                               //     onTap: (){
//                               //       FocusScope.of(context).requestFocus(FocusNode());
//                               //     },
//                               //     child: IgnorePointer(
//                               //       child: new TextFormField(
//                               //         textInputAction: TextInputAction.done,
//                               //         cursorColor: Colors.deepOrange,
//                               //         controller: userName,
//                               //         validator: (value) {
//                               //           if (value.isEmpty) {
//                               //             return 'Please enter some value';
//                               //           }
//                               //           return null;
//                               //         },
//                               //         decoration: InputDecoration(
//                               //           contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                               //           focusedBorder:OutlineInputBorder(
//                               //             borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                               //           ),
//                               //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                               //         ),
//                               //       ),
//                               //     ),
//                               //   ),
//                               // ),
//                               // Padding(
//                               //   padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
//                               //   child: new Text("Town*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               // ),
// //                               Padding(
// //                                 padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
// //                                 child: InkWell(
// //                                   onTap: (){
// //                                     FocusScope.of(context).requestFocus(FocusNode());
// // // //                                    placeOrderBrg.clear();
// // //                                       selectTown();
// //                                   },
// //                                   child: IgnorePointer(
// //                                     child: new TextFormField(
// //                                       textInputAction: TextInputAction.done,
// //                                       cursorColor: Colors.deepOrange,
// //                                       controller: placeOrderTown,
// //                                       validator: (value) {
// //                                         if (value.isEmpty) {
// //                                           return 'Please enter some value';
// //                                         }
// //                                         return null;
// //                                       },
// //                                       decoration: InputDecoration(
// //                                         contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
// //                                         focusedBorder:OutlineInputBorder(
// //                                           borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
// //                                         ),
// //                                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
//
//                               // Padding(
//                               //   padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
//                               //   child: new Text("Barangay*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               // ),
//
//
//                               // Padding(
//                               //   padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//                               //   child: InkWell(
//                               //     onTap: (){
//                               //       FocusScope.of(context).requestFocus(FocusNode());
//                               //
//                               //     },
//                               //     child: IgnorePointer(
//                               //       child: new TextFormField(
//                               //         textInputAction: TextInputAction.done,
//                               //         cursorColor: Colors.deepOrange,
//                               //         controller: placeOrderBrg,
//                               //         validator: (value) {
//                               //           if (value.isEmpty) {
//                               //             return 'Please enter some value';
//                               //           }
//                               //           return null;
//                               //         },
//                               //         decoration: InputDecoration(
//                               //           contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                               //           focusedBorder:OutlineInputBorder(
//                               //             borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                               //           ),
//                               //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                               //         ),
//                               //       ),
//                               //     ),
//                               //   ),
//                               // ),
//                               // Padding(
//                               //   padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
//                               //   child: new Text("Phone Number*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               // ),
// //                               Padding(
// //                                 padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
// //                                 child: Row(
// //                                   children: <Widget>[
// //                                     SizedBox(
// //                                       width: 2.0,
// //                                     ),
// //                                     Flexible(
// //                                       child: new TextFormField(
// //                                         maxLength: 11,
// //                                         keyboardType: TextInputType.number,
// //                                         inputFormatters: [FilteringTextInputFormatter.deny(new RegExp('[.-]'))],
// //                                         cursorColor: Colors.deepOrange,
// //                                         controller: placeContactNo,
// //                                         validator: (value) {
// //                                           if (value.isEmpty) {
// //                                             return 'Please enter some value';
// //                                           }
// //                                           return null;
// //                                         },
// //                                         decoration: InputDecoration(
// //                                           counterText: "",
// //                                           contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
// //                                           focusedBorder:OutlineInputBorder(
// //                                             borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
// //                                           ),
// //                                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
// //                                         ),
// // //                                        focusNode: textSecondFocusNode,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
//                               // Padding(
//                               //   padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
//                               //   child: new Text("Street*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               // ),
//                               // Padding(
//                               //   padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//                               //   child: new TextFormField(
//                               //     textInputAction: TextInputAction.done,
//                               //     cursorColor: Colors.deepOrange,
//                               //     controller: street,
//                               //     validator: (value) {
//                               //       if (value.isEmpty) {
//                               //         return 'Please enter some value';
//                               //       }
//                               //       return null;
//                               //     },
//                               //     decoration: InputDecoration(
//                               //       contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                               //       focusedBorder:OutlineInputBorder(
//                               //         borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                               //       ),
//                               //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                               //     ),
//                               //   ),
//                               // ),
//                               // Padding(
//                               //   padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
//                               //   child: new Text("House number(optional)", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               // ),
//                               // Padding(
//                               //   padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//                               //   child: new TextFormField(
//                               //     textInputAction: TextInputAction.done,
//                               //     cursorColor: Colors.deepOrange.withOpacity(0.8),
//                               //     controller: houseNo,
//                               //     keyboardType: TextInputType.number,
//                               //     decoration: InputDecoration(
//                               //       contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                               //       focusedBorder:OutlineInputBorder(
//                               //         borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                               //       ),
//                               //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                               //     ),
//                               //   ),
//                               // ),
//
//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(15, 15, 5, 5),
//                                 child: new Text("Delivery Date*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               ),
//                               Padding(
//                                 padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
//                                 child: InkWell(
//                                   onTap: (){
//                                     deliveryTime.clear();
//                                     getTrueTime();
//                                     FocusScope.of(context).requestFocus(FocusNode());
//                                     showDialog<void>(
//                                       context: context,
// //                                        barrierDismissible: false, // user must tap button!
//                                       builder: (BuildContext context) {
//                                         return AlertDialog(
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.all(Radius.circular(8.0))
//                                           ),
//                                           title: Text("Set date for this delivery",style: TextStyle(fontSize: 20.0),),
//                                           contentPadding:EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
//                                           content: Container(
//                                             height:230.0, // Change as per your requirement
//                                             width: 360.0, // Change as per your requirement
//                                             child: Scrollbar(
//                                               child:ListView.builder(
//                                                 physics: BouncingScrollPhysics(),
// //                                                  shrinkWrap: true,
//                                                 itemCount: 4,
//                                                 itemBuilder: (BuildContext context, int index) {
//                                                   String tom = "";
//                                                   int n = 0;
//                                                   n = index;
//                                                   if(n==0){
//                                                     tom = "(Today)";
//                                                   }
//                                                   var d1 = DateTime.parse(trueTime[0]['date_today']);
//                                                   var d2 = new DateTime(d1.year, d1.month, d1.day + n);
//                                                   final DateFormat formatter = DateFormat('yyyy-MM-dd');
//                                                   final String formatted = formatter.format(d2);
//                                                   return InkWell(
//                                                     onTap: (){
//
//                                                       deliveryDate.text =formatted;
//                                                       Navigator.of(context).pop();
//                                                       if(index == 0){
//                                                         setState(() {
//                                                           _today = true;
//                                                           timeCount = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']).difference(DateTime.parse(trueTime[0]['date_today']+" "+"19:30")).inHours;
//                                                           timeCount = timeCount.abs();
//                                                           _globalTime = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']);
//                                                           _globalTime2 = _globalTime.hour;
//                                                         });
//                                                      }
//                                                      else{
//                                                        setState((){
//                                                          _today = false;
//                                                          timeCount = 12;
//                                                          _globalTime = new DateTime.now();
//                                                          _globalTime2 = 07;
//                                                        });
//                                                       }
//                                                     },
//                                                       child: Column(
//                                                         children:[
//                                                           Row(
//                                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                               children: <Widget>[
//                                                                 Padding(
//                                                                   padding: EdgeInsets.fromLTRB(30.0,20.0, 0.0,20.0),
//                                                                   child: Text('${formatted.toString()}',style: TextStyle(fontSize: 16.0),),
//                                                                 ),
//                                                               ]
//                                                           ),
//                                                         ],
//                                                       ),
//                                                   );
//                                                 },
//                                               ),
//                                             ),
//                                           ),
//                                           actions: <Widget>[
//                                             TextButton(
//                                               child: Text(
//                                                 'Clear',
//                                                 style: TextStyle(
//                                                   color: Colors.deepOrange,
//                                                 ),
//                                               ),
//                                               onPressed: () {
//                                                 deliveryDate.clear();
//                                                 Navigator.of(context).pop();
//                                               },
//                                             ),
//                                           ],
//                                         );
//                                       },
//                                     );
//                                     },
//                                       child: IgnorePointer(
//                                         child: new TextFormField(
//                                           textInputAction: TextInputAction.done,
//                                           cursorColor: Colors.deepOrange,
//                                           controller: deliveryDate,
//                                           validator: (value) {
//                                             if (value.isEmpty) {
//                                               return 'Please enter some value';
//                                             }
//                                             return null;
//                                           },
//                                           decoration: InputDecoration(
//                                             prefixIcon: Icon(Icons.date_range,color: Colors.grey,),
//                                             contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                                             focusedBorder:OutlineInputBorder(
//                                               borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                                             ),
//                                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(15, 15, 5, 5),
//                                 child: new Text("Delivery Time*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               ),
//                               Padding(
//                                 padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
//                                 child: InkWell(
//                                   onTap: (){
//                                       getTrueTime();
//                                       if(deliveryDate.text.isEmpty){
//                                         Fluttertoast.showToast(
//                                             msg: "Please select a delivery date",
//                                             toastLength: Toast.LENGTH_SHORT,
//                                             gravity: ToastGravity.BOTTOM,
//                                             timeInSecForIosWeb: 2,
//                                             backgroundColor: Colors.black.withOpacity(0.7),
//                                             textColor: Colors.white,
//                                             fontSize: 16.0);
//                                       }
//                                       else{
//                                         FocusScope.of(context).requestFocus(FocusNode());
//                                         showDialog<void>(
//                                           context: context,
// //                                          barrierDismissible: false, // user must tap button!
//                                           builder: (BuildContext context) {
//                                             return AlertDialog(
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius: BorderRadius.all(Radius.circular(8.0))
//                                               ),
//                                               title: Text("Set time for this delivery",style: TextStyle(fontSize: 20.0),),
//                                               contentPadding:
//                                               EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
//                                               content: Container(
//                                                 height:230.0, // Change as per your requirement
//                                                 width: 360.0, // Change as per your requirement
//                                                 child: Scrollbar(
//                                                   child:  ListView.builder(
//                                                       physics: BouncingScrollPhysics(),
//                                                       shrinkWrap: true,
//                                                       itemCount:  timeCount,
//                                                       itemBuilder: (BuildContext context, int index1) {
//                                                         int t = index1;
//                                                         t++;
// //                                                              var d1 = DateTime.parse(trueTime[0]['date_today']);
//                                                         final now =  _globalTime;
//                                                         final dtFrom = DateTime(now.year, now.month, now.day, _globalTime2+t, 0+30, now.minute, now.second);
//                                                         // final dtTo = DateTime(now.year, now.month, now.day, 8+t, 0+30);
//                                                         final format = DateFormat.jm();  //"6:00 AM"
//                                                         String from = format.format(dtFrom);
//                                                         // String to = format.format(dtTo);
//                                                         return InkWell(
//                                                           onTap: (){
//                                                             deliveryTime.text = from;
//                                                             Navigator.of(context).pop();
//                                                           },
//                                                           child: Container(
//                                                             child: Column(
//                                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                                               children: <Widget>[
//                                                                 Row (
//                                                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                     children: <Widget>[
//                                                                       Padding(
//                                                                         padding: EdgeInsets.fromLTRB(30.0,20.0, 0.0,20.0),
//                                                                         child: Text('${from.toString()}',style: TextStyle(fontSize: 16.0),),
//                                                                       ),
//                                                                     ]
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         );
//                                                       }
//                                                   ),
//                                                 ),
//                                               ),
//                                               actions: <Widget>[
//                                                 TextButton(
//                                                   child: Text(
//                                                     'Clear',
//                                                     style: TextStyle(
//                                                       color: Colors.deepOrange,
//                                                     ),
//                                                   ),
//                                                   onPressed: () {
//                                                     deliveryTime.clear();
//                                                     Navigator.of(context).pop();
//                                                   },
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                         );
//                                       }
//
//                                   },
//                                   child: IgnorePointer(
//                                       child: new TextFormField(
//                                         textInputAction: TextInputAction.done,
//                                         cursorColor: Colors.deepOrange,
//                                         controller: deliveryTime,
//                                         validator: (value) {
//                                           if (value.isEmpty) {
//                                             return 'Please enter some value';
//                                           }
//                                           return null;
//                                         },
//                                         decoration: InputDecoration(
//                                           prefixIcon: Icon(Icons.timelapse,color: Colors.grey,),
//                                           contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                                           focusedBorder:OutlineInputBorder(
//                                             borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                                           ),
//                                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                                         ),
//                                       ),
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
//                               ),
//
//                               // Padding(
//                               //   padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
//                               //   child: new Text("Avail Discount(Optional)", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               // ),
//
//                               // Padding(
//                               //   padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//                               //   child: InkWell(
//                               //     onTap: () async{
//                               //       FocusScope.of(context).requestFocus(FocusNode());
//                               //       SharedPreferences prefs = await SharedPreferences.getInstance();
//                               //       String username = prefs.getString('s_customerId');
//                               //       if(username == null){
//                               //         Navigator.of(context).push(_signIn());
//                               //       }else{
//                               //         await Navigator.of(context).push(_showDiscountPerson());
//                               //         countDiscount();
//                               //       }
//                               //     },
//                               //     child: IgnorePointer(
//                               //       child: new TextFormField(
//                               //         textInputAction: TextInputAction.done,
//                               //         cursorColor: Colors.deepOrange,
//                               //         controller: discount,
//                               //         decoration: InputDecoration(
//                               //           contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                               //           focusedBorder:OutlineInputBorder(
//                               //             borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                               //           ),
//                               //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                               //         ),
//                               //       ),
//                               //     ),
//                               //   ),
//                               // ),
//                               // Padding(
//                               //   padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
//                               //   child: new Text("Landmark*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               // ),
//                               // Padding(
//                               //   padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//                               //   child: new TextFormField(
//                               //     keyboardType: TextInputType.multiline,
//                               //     textInputAction: TextInputAction.done,
//                               //     cursorColor: Colors.deepOrange,
//                               //     controller: placeRemarks,
//                               //     validator: (value) {
//                               //       if (value.isEmpty) {
//                               //         return 'Please enter some value';
//                               //       }
//                               //       return null;
//                               //     },
//                               //     maxLines: 4,
//                               //     decoration: InputDecoration(
//                               //       hintText:"E.g Near at plaza/Be ware of dogs",
//                               //       contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                               //       focusedBorder:OutlineInputBorder(
//                               //         borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                               //       ),
//                               //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                               //     ),
//                               //   ),
//                               // ),
//                               Divider(),
//                               ListView.builder(
//                                   physics: BouncingScrollPhysics(),
//                                   shrinkWrap: true,
//                                   itemCount:  getBu == null ? 0 : getBu.length,
//                                   itemBuilder: (BuildContext context, int index0) {
//                                     int num = index0;
//                                     num++;
//                                     return Container(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: <Widget>[
//                                           Padding(
//                                             padding: EdgeInsets.fromLTRB(15.0,10.0, 0.0,10.0),
//                                             child: Text('$num. ${getBu[index0]['d_bu_name'].toString()}',style: GoogleFonts.openSans(color:Colors.deepOrange, fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 18.0)),
//                                           ),
//
//                                           ListView.builder(
//                                               physics: BouncingScrollPhysics(),
//                                               shrinkWrap: true,
//                                               itemCount:  getTenant == null ? 0 : getTenant.length,
//                                               itemBuilder: (BuildContext context, int index) {
//                                                 _specialInstruction.add(new TextEditingController());
//                                                 return Visibility(
//                                                   visible: getTenant[index]['bu_id'] != getBu[index0]['d_bu_id'] ? false : true,
//                                                   child: Container(
//                                                     child: Column(
//                                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                                       children: <Widget>[
//                                                         Divider(),
//                                                         Padding(
//                                                           padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
//                                                           child: OutlinedButton(
//                                                             onPressed: (){
//                                                               print('${getTenant[index]['tenant_name']}');
//                                                             },
//                                                             style: ButtonStyle(
//                                                               overlayColor: MaterialStateProperty.all(Colors.white30),
//                                                               side: MaterialStateProperty.all(BorderSide(
//                                                                   color: Colors.black54,
//                                                                   width: 1.0,
//                                                                   style: BorderStyle.solid)),
//                                                             ),
//                                                             child:Row(
//                                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                               children: [
//                                                                 Text('${getTenant[index]['tenant_name']}', style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 15.0, color: Colors.black54),),
//                                                                 Text('₱${oCcy.format(int.parse(getTenant[index]['total'].toString()))}', style: TextStyle(fontStyle: FontStyle.normal,fontSize: 15.0, color: Colors.black54),),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//
//                                                         Padding(
//                                                           padding:EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
//                                                           child: new TextFormField(
//                                                             keyboardType: TextInputType.multiline,
//                                                             textInputAction: TextInputAction.done,
//                                                             cursorColor: Colors.deepOrange,
//                                                             controller: _specialInstruction[index],
//                                                             validator: (value) {
//                                                               if (value.isEmpty) {
//                                                                 return 'Please enter some value';
//                                                               }
//                                                               return null;
//                                                             },
//                                                             maxLines: 4,
//                                                             decoration: InputDecoration(
//                                                               hintText:"Special instruction",
//                                                               contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
//                                                               focusedBorder:OutlineInputBorder(
//                                                                 borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
//                                                               ),
//                                                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 );
//                                               }
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   }
//                               ),
//
//                               // Padding(
//                               //   padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
//                               //   child: new Text("In case the product is out of stock", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               // ),
//                               // _myRadioButton(
//                               //   title: "Cancel the entire order",
//                               //   value: 0,
//                               //   onChanged: (newValue) => setState((){
//                               //     groupValue = newValue;
//                               //
//                               //   }),
//                               // ),
//                               //
//                               // _myRadioButton(
//                               //   title: "Remove it from my order",
//                               //   value: 1,
//                               //   onChanged: (newValue) => setState((){
//                               //     groupValue = newValue;
//                               //   }),
//                               // ),
//                               // Padding(
//                               //   padding:EdgeInsets.fromLTRB(15.0, 7.0, 5.0, 5.0),
//                               //   child: new Text("Rider's fee: ₱ ${ oCcy.format(deliveryCharge)}", style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 15.0),),
//                               // ),
//
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Divider(),
//               Padding(
//                   padding:EdgeInsets.fromLTRB(30.0, 7.0, 30.0, 5.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text("Total Amount: ", style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
//                       Text("₱${oCcy.format(grandTotal).toString()}", style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0))
//                     ],
//                   )
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//                 child: Row(
//                   children: <Widget>[
//                     Flexible(
//                       child: SleekButton(
//                         onTap: () async {
//                           if (_formKey.currentState.validate()) {
//                             submitPlaceOrder();
//                           }
//                           for (int i=0; i<getTenant.length; i++){
//                             // print(_specialInstruction[i].text);
//                             // special.add(_specialInstruction[i].text);
//                             while(special.length > getTenant.length-1){
//                               special.removeAt(i);
//                             }
//                             special.insert(i, _specialInstruction[i].text);
//                           }
//                         },
//                         style: SleekButtonStyle.flat(
//                           color: Colors.deepOrange,
//                           inverted: false,
//                           rounded: true,
//                           size: SleekButtonSize.big,
//                           context: context,
//                         ),
//                         child: Center(
//                           child: Text(
//                             "Next",
//                             style: GoogleFonts.openSans(
//                                 fontStyle: FontStyle.normal,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13.0),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
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

Route _submitOrder(
    paymentMethod,
    deliveryDateData,
    deliveryTimeData,
    getTenantData,
    getTenantNameData,
    getBuNameData,
    subtotal,
    grandTotal,
    specialInstruction,
    deliveryCharge,) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SubmitOrder(
      paymentMethod: paymentMethod,
      deliveryDateData:deliveryDateData,
      deliveryTimeData:deliveryTimeData,
      getTenantData:getTenantData,
      getTenantNameData:getTenantNameData,
      getBuNameData:getBuNameData,
      subtotal:subtotal,
      grandTotal:grandTotal,
      specialInstruction:specialInstruction,
      deliveryCharge:deliveryCharge,),
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