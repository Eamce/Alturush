import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'place_order_delivery.dart';
import 'pickupMethod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'track_order.dart';
import 'create_account_signin.dart';
import 'package:intl/intl.dart';

class LoadCart extends StatefulWidget {
  @override
  _LoadCart createState() => _LoadCart();
}

class _LoadCart extends State<LoadCart> {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  List loadCartData = [];
  List lGetAmountPerTenant;
  List loadSubtotal;
  var isLoading = true;
  var checkOutLoading = true;
  var subTotal;

  var labelFlavor = "";
  var labelDrinks = "";
  var labelFries = "";
  var labelSides = "";

  int flavorGroupValue;
  int drinksGroupValue;
  int friesGroupValue;
  int sidesGroupValue;

  int flavorId;
  int drinkId,drinkUom;
  int friesId,friesUom;
  int sideId,sideUom;
  int grandTotal = 0;

  var boolFlavorId = false;
  var boolDrinkId = false;
  var boolFriesId = false;
  var boolSideId = false;


  List loadIMainItems;
  List loadChoices;
  List loadFlavors;
  List loadAddons;
  List loadTotalData;
  List getBu;

  Future loadCart() async {
    var res = await db.loadCartData();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadCartData = res['user_details'];
      loadIMainItems = loadCartData;
    });
  }

  Future getBuSegregate() async{
    var res = await db.getBuSegregate();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
    });
  }
  Future loadTotal() async{
    var res = await db.loadSubTotal();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadTotalData = res['user_details'];
      grandTotal = int.parse(loadTotalData[0]['grand_total'].toString());
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
                      itemCount: loadIMainItems == null ? 0 : loadIMainItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        var f = index;
                        if(f  == mainItemIndex){
                         if(loadIMainItems[mainItemIndex]['choices'].length > 0){
                           return Padding(
                             padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 5.0),
                             child:Container(
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children:[
                                   Expanded(child: Text(' + ${loadIMainItems[mainItemIndex]['choices'][0]['product_name']} - Php ${loadIMainItems[mainItemIndex]['choices'][0]['addon_price']}',style: TextStyle(fontSize: 18.0,),maxLines: 6, overflow: TextOverflow.ellipsis,)),
                                ],
                               ),
                             ),
//                          child: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                           );
                         }
                         return SizedBox(

                         );
                        }
                        return SizedBox();
                      },
                    ),
                    //addon
                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: loadCartData[mainItemIndex]['flavors'] == null ? 0 : loadCartData[mainItemIndex]['addons'].length,
                      itemBuilder: (BuildContext context, int index) {
                          if(loadCartData[mainItemIndex]['addons'].length > 0){
                            return Padding(
                              padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 5.0),
                              child:Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    Expanded(child: Text(' + ${loadIMainItems[mainItemIndex]['addons'][index]['product_name']} - Php ${loadIMainItems[mainItemIndex]['addons'][index]['addon_price']}',style: TextStyle(fontSize: 18.0,),maxLines: 6, overflow: TextOverflow.ellipsis,)),
                                  ],
                                ),
                              ),
//                          child: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                            );
                          }
                          return SizedBox(
                        );
                      },
                    ),


                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: loadCartData[mainItemIndex]['flavors'] == null ? 0 : loadCartData[mainItemIndex]['flavors'].length,
                      itemBuilder: (BuildContext context, int index) {
                        if(loadCartData[mainItemIndex]['flavors'].length > 0){
                          return Padding(
                            padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 5.0),
                            child:Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children:[
                                  Expanded(child: Text(' + ${loadIMainItems[mainItemIndex]['flavors'][0]['flavor']} - Php ${loadIMainItems[mainItemIndex]['flavors'][0]['addon_price']}',style: TextStyle(fontSize: 18.0,),maxLines: 6, overflow: TextOverflow.ellipsis,)),
                                ],
                              ),
                            ),
//                          child: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                          );
                        }
                        return SizedBox(
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
  void displayBottomSheet(BuildContext context) async{
    var res = await db.getAmountPerTenant();
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
           child:Container(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children:[
                 SizedBox(height:10.0),
                 Padding(
                   padding: EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                   child:Text("Your stores",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                 ),
                 Scrollbar(
                   child: ListView.builder(
                     physics: BouncingScrollPhysics(),
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
                               Text('$f. ${lGetAmountPerTenant[index]['bu_name']} ${lGetAmountPerTenant[index]['tenant_name']} ',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
                               Text('₱${oCcy.format(int.parse(lGetAmountPerTenant[index]['total'].toString()))}',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
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
           ),
          );
        });
  }

  void selectType(BuildContext context) async{
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
        ),
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height/3.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          Navigator.of(context).push(_placeOrderDelivery());
                        },
                        child: Container(
                          width:130,
                          height:200,
                          child: Column(
                            children:[
                              Padding(
                                padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                                child: Image.asset("assets/png/delivery.png",),
                              ),
                              Text("Delivery",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          Navigator.of(context).push(_placeOrderPickUp());
                        },
                        child: Container(
                          width:130,
                          height:200,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                                child: Image.asset("assets/png/delivery-man.png",),
                              ),
                              Text("Pick-up",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                            ],
                          ),
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

  void viewCartTenants() async{
//    getAmountPerTenant();
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

    var res = await db.getAmountPerTenant();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      lGetAmountPerTenant = res['user_details'];
      Navigator.of(context).pop();
    });

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          content: Container(
            height: 200.0, // Change as per your requirement
            width: 310, // Change as per your requirement

            child: Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: lGetAmountPerTenant == null ? 0 : lGetAmountPerTenant.length,
                itemBuilder: (BuildContext context, int index) {
                  var f = index;
                  f++;
                  return ListTile(
                    title: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 15.0,)
                    ));
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',style: TextStyle(
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


bool ignorePointer = false;
 Future checkIfBf() async{
   var res = await db.checkIfBf();
   if (!mounted) return;
   setState(() {
     isLoading = false;
     lGetAmountPerTenant = res['user_details'];
   });
   if(lGetAmountPerTenant[0]['isavail'] == false){
     ignorePointer = true;
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
                      child:Text("Some items can only be cook and deliver in specific time, please remove them to proceed.",textAlign: TextAlign.justify, maxLines: 3,style:TextStyle(fontSize: 18.0),),
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
   else{
     ignorePointer = false;
   }
 }


//  StreamController _event =StreamController<int>.broadcast();
  updateCartQty(id,qty) async{
    await db.updateCartQty(id,qty);
    loadTotal();
  }

  @override
  void initState() {
    super.initState();
    loadCart();
    loadTotal();
    getBuSegregate();
    checkIfBf();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void removeFromCart(prodId) async{
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal:1.0, vertical: 20.0),
          title: Row(
            children: <Widget>[
              Text('Hello!',style:TextStyle(fontSize: 18.0),),
            ],
          ) ,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                  child:Center(child:Text(("Are you sure you want to remove this item?"))),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',style: TextStyle(color:Colors.deepOrange,),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: Text('Proceed',style: TextStyle(color:Colors.deepOrange,),),
                onPressed:() async{
                  Navigator.of(context).pop();
                  await db.removeItemFromCart(prodId);
                  loadCart();
                  loadTotal();
                  getBuSegregate();
                  checkIfBf();
                }
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
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
          title: Text("My cart",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
          actions: <Widget>[
            // IconButton(
            //     icon: Icon(Icons.search, color: Colors.black),
            //     onPressed: () => {}
            // ),
            IconButton(
                icon: Icon(Icons.person, color: Colors.black),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String status = prefs.getString('s_status');
                  status != null
                      ? Navigator.of(context).push(_profilePage())
                      : Navigator.of(context).push(_signIn());
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
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: loadCart,
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount:  getBu == null ? 0 : getBu.length,
                          itemBuilder: (BuildContext context, int index0) {

                            return Container(
                                child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(17.0,25.0, 0.0,0.0),
                                        child: Text('${getBu[index0]['d_bu_name'].toString()} ${getBu[index0]['d_tenant_name'].toString()}',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold ,fontSize: 17.0)),
                                      ),
                                       ListView.builder(
                                           physics: BouncingScrollPhysics(),
                                           shrinkWrap: true,
                                          itemCount:loadCartData == null ? 0 : loadCartData.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Visibility(
                                              visible: loadCartData[index]['main_item']['tenant_id'] != getBu[index0]['d_tenant_id'] ? false : true,
                                              child: Container(
                                                height: 150.0,
                                                width: 30.0,
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
                                                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                                                            child: Container(
                                                                width: 80.0,
                                                                height: 60.0,
                                                                decoration: new BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  image: new DecorationImage(
                                                                    image: new NetworkImage(loadCartData[index]['main_item']['image']),
                                                                    fit: BoxFit.scaleDown,
                                                                  ),
                                                                )),
                                                          ),
                                                          Container(
                                                            child:Column(
                                                              crossAxisAlignment:CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                SingleChildScrollView(
                                                                  scrollDirection: Axis.horizontal,
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(0, 10, 5, 5),
                                                                        child: Text('${loadCartData[index]['main_item']['product_name']}',
                                                                          style: GoogleFonts.openSans(
                                                                              fontStyle:
                                                                              FontStyle.normal,
                                                                              fontSize: 11.0),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),

                                                                Row(
                                                                  children: <Widget>[
                                                                    Padding(
                                                                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                                                      child: new Text(
                                                                        "₱ ${loadCartData[index]['main_item']['price'].toString()}",
                                                                        style: TextStyle(
                                                                          fontWeight:
                                                                          FontWeight.bold,
                                                                          fontSize: 15,
                                                                          color: Colors.deepOrange,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  children: <Widget>[
                                                                    Padding(
                                                                        padding:EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                        child:RawMaterialButton(
                                                                          onPressed: () async{
                                                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                            String username = prefs.getString('s_customerId');
                                                                            if(username == null){
                                                                              await Navigator.of(context).push(_signIn());
                                                                            }else{
                                                                              removeFromCart(loadCartData[index]['main_item']['id']);
                                                                            }
                                                                          },
                                                                          elevation: 1.0,
//                                                            fillColor: Colors.transparent,
                                                                          child: Icon(
                                                                            Icons.delete_outline,
                                                                            size: 25.0,
                                                                          ),
//                                                          padding: EdgeInsets.all(15.0),
                                                                          shape: CircleBorder(),
                                                                        )
                                                                    ),
                                                                    Padding(
                                                                      padding:EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                      child:Container(
                                                                        width: 50.0,
                                                                        child: TextButton(
                                                                          style: TextButton.styleFrom(
                                                                            primary: Colors.blue,
                                                                            onSurface: Colors.red,
                                                                          ),
                                                                          child: Text('-'),
                                                                          onPressed: () async{
                                                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                            String username = prefs.getString('s_customerId');
                                                                            if(username == null){
                                                                              await Navigator.of(context).push(_signIn());
                                                                            }else{
                                                                              setState(() {
                                                                                var x = loadCartData[index]['main_item']['quantity'];
                                                                                int d = int.parse(x.toString());
                                                                                loadCartData[index]['main_item']['quantity'] = d-=1;  //code ni boss rene
                                                                                if(d<1){
                                                                                  loadCartData[index]['main_item']['quantity']=1;
                                                                                }
                                                                              });
                                                                              updateCartQty(loadCartData[index]['main_item']['id'].toString(),loadCartData[index]['main_item']['quantity'].toString());
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),

                                                                    Padding(
                                                                      padding:EdgeInsets.fromLTRB(1, 5, 5, 5),
                                                                      child:Text(loadCartData[index]['main_item']['quantity'].toString()),
                                                                    ),
                                                                    Padding(
                                                                      padding:EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                      child:Container(
                                                                        width: 50.0,
                                                                        child: TextButton(
                                                                          style: TextButton.styleFrom(
                                                                            primary: Colors.blue,
                                                                            onSurface: Colors.red,
                                                                          ),
                                                                          child: Text('+'),
                                                                          onPressed: ()async {
                                                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                            String username = prefs.getString('s_customerId');
                                                                            if(username == null){
                                                                              await Navigator.of(context).push(_signIn());
                                                                            }else{
                                                                              setState(() {
                                                                                var x = loadCartData[index]['main_item']['quantity'];
                                                                                int d = int.parse(x.toString());
                                                                                loadCartData[index]['main_item']['quantity'] = d+=1;   //code ni boss rene
                                                                              });
                                                                              updateCartQty(loadCartData[index]['main_item']['id'].toString(),loadCartData[index]['main_item']['quantity'].toString());
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Visibility(
                                                                      visible: loadCartData[index]['main_item']['addon_length'] <= 0? false : true,
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
                                                                            child:Text('${loadCartData[index]['main_item']['addon_length'].toString()} more',style: TextStyle(fontSize: 10.0),),
                                                                            onPressed: ()async {
                                                                              viewAddon(context, index);
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
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
                                    ]
                                )
                            );
                          }

                        ),
                      ),
                    ),
                  ),
                  Visibility(
                     visible: loadCartData.isEmpty ? false : true,
                      replacement: Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight / 3.0),
                      child: Center(
                            child:Column(
                              children: <Widget>[
                                  Container(
                                    height: 100,
                                    width: 100,
                                    child: SvgPicture.asset("assets/svg/empty-cart.svg"),
                                  ),
                               ],
                            ),
                          ),
                       ),
                        child: Padding(
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
                                        rounded: false,
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
                                child: IgnorePointer(
                                  ignoring: ignorePointer,
                                  child: SleekButton(
                                    onTap: () async {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String username = prefs.getString('s_customerId');
                                      if(username == null){
                                        await Navigator.of(context).push(_signIn());
                                      }else{
                                        if(lGetAmountPerTenant[0]['isavail']==false){
                                          checkIfBf();
                                        }else{
                                          selectType(context);
                                        }

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
                                      child: Text("₱ ${oCcy.format (grandTotal)} Next", style:TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 13.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),
                ],
              ),
//      ),
      ),
    );
  }
}


Route _placeOrderPickUp() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => PlaceOrderPickUp(),
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

Route _placeOrderDelivery() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => PlaceOrderDelivery(),
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

Route _profilePage() {
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