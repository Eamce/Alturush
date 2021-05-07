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
  List loadCartData;
  List loadEdit;
  List getTenantLimit;
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

  var boolFlavorId = false;
  var boolDrinkId = false;
  var boolFriesId = false;
  var boolSideId = false;
  var grandTotal = 0.0;

  Future loadCart() async {

    var res = await db.loadCartData();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadCartData = res['user_details'];
      grandTotal = 0;
      loadCartData.forEach((element) {
        grandTotal = grandTotal + (double.parse(element['cart_qty'].toString()) * double.parse(element['total'].toString()));
      });
    });
  }

  // Future loadSubTotal() async{
  //   var res = await db.loadSubTotal();
  //   if (!mounted) return;
  //   setState(() {
  //     isLoading1 = false;
  //     loadSubtotal = res['user_details'];
  //
  //     if(loadSubtotal[0]['d_subtotal']==null){
  //       subTotal = 0;
  //     }else{
  //       subTotal = double.parse(loadSubtotal[0]['d_subtotal'].toString());
  //     }
  //   });
  // }

//  Future trapTenantLimit() async{
//    var res = await db.trapTenantLimit();
//    if (!mounted) return;
//    setState(() {
////      isLoading = false;
//      getTenantLimit = res['user_details'];
//    });
//  }

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
                               Text('$f. ${lGetAmountPerTenant[index]['loc_bu_name']} - ${lGetAmountPerTenant[index]['loc_tenant_name']} ',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
                               Text('₱${oCcy.format(int.parse(lGetAmountPerTenant[index]['total_price'].toString()))}',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
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



  List loadItemData;
  Future loadItem(productId,prodUom) async{
    var res = await db.getItemDataCi(productId,prodUom);
    if (!mounted) return;
    setState(() {
      loadItemData = res['user_details'];
    });
  }

  List loadFlavorData;
  Future loadFlavor(prodId) async{
    var res = await db.loadFlavor(prodId);
    if (!mounted) return;
    setState(() {
      loadFlavorData = res['user_details'];
    });
  }

  List loadDrinksData;
  Future loadDrinks(prodId) async{
    var res = await db.loadDrinks(prodId);
    if (!mounted) return;
    setState(() {
      loadDrinksData = res['user_details'];
    });
  }

  List loadFriesData;
  Future loadFries(prodId) async{
    var res = await db.loadFries(prodId);
    if (!mounted) return;
    setState((){
      loadFriesData = res['user_details'];
    });
  }

  List loadSideData;
  Future  loadSide(prodId) async{
    var res = await db.loadSide(prodId);
    if (!mounted) return;
    setState((){
      loadSideData = res['user_details'];
    });
  }

  Future displayAddon(BuildContext context,productName,productId,prodUom) async{
    loadItem(productId,prodUom);

//    loadFlavor(productId);
//    loadDrinks(productId);
//    loadFries(productId);
//    loadSide(productId);

//     if(boolFlavorId == true){
//       loadFlavor(productId);
//     }
//     if(boolDrinkId == true){
//       loadDrinks(productId);
//     }
//     if(boolFriesId == true){
//       loadFries(productId);
//     }
//     if(boolSideId == true){
//       loadSide(productId);
//     }

    var res = await db.getAmountPerTenant();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      lGetAmountPerTenant = res['user_details'];
    });
    setState(() {
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
        ),
        builder: (BuildContext  context,) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.0),
                        Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                          child: Text(productName, style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),),
                        ),
                        Expanded(
                          child: Scrollbar(
                            child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: lGetAmountPerTenant == null ? 0 : lGetAmountPerTenant.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      25.0, 15.0, 25.0, 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
//                               Text('Total:₱${oCcy.format(int.parse(lGetAmountPerTenant[index]['total_price'].toString()))}',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
                                      Expanded(
                                        child: ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: 1,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              if (loadItemData[index]['no_flavor'] !=
                                                  null) {
                                                boolFlavorId = true;
                                                labelFlavor = "Flavor";
                                                loadFlavor(productId);
                                              }
                                              if (loadItemData[index]['no_drinks'] !=
                                                  null) {
                                                boolDrinkId = true;
                                                labelDrinks = "Select drinks";
                                                loadDrinks(productId);
                                              }
                                              if (loadItemData[index]['no_fries'] !=
                                                  null) {
                                                boolFriesId = true;
                                                labelFries = "Fries";
                                                loadFries(productId);
                                              }
                                              if (loadItemData[index]['no_sides'] !=
                                                  null) {
                                                boolSideId = true;
                                                labelSides = "Sides";
                                                loadSide(productId);
                                              }
                                              if (loadItemData[index]['variation'] !=
                                                  null) {
//                                                checkAddon();
                                              }
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(
                                                        1.0, 0.0, 5.0, 5.0),
                                                    child: new Text(labelFlavor,
                                                      style: GoogleFonts.openSans(
                                                          fontWeight: FontWeight
                                                              .bold,
                                                          fontStyle: FontStyle
                                                              .normal,
                                                          fontSize: 18.0),),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(
                                                        0.0, 0.0, 5.0, 5.0),
                                                    child: ListView.builder(
                                                        physics: NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount: loadFlavorData ==null? 0: loadFlavorData.length,
                                                        itemBuilder: (
                                                            BuildContext context,
                                                            int index1) {
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment
                                                                    .spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                    fit: FlexFit
                                                                        .loose,
                                                                    child: RadioListTile(
                                                                      title: Text(loadFlavorData[index1]['add_on_flavors'], style: TextStyle(fontSize: 17,),),
                                                                      value: index1,
                                                                      groupValue: flavorGroupValue,
                                                                      onChanged: (
                                                                          newValue) {
                                                                        setState(() {
                                                                          flavorGroupValue =
                                                                              newValue;
                                                                          flavorId = int.parse(loadFlavorData[index1]['flavor_id']);
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                  //   Padding(
                                                                  //     padding: EdgeInsets.fromLTRB(10.0, 0.0, 15.0, 5.0),
                                                                  //     child: Text(loadFlavorData[index]['add_on_flavors'],style: TextStyle(fontSize: 17,color: Colors.black54),),
                                                                  //   ),
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                        1.0, 0.0,
                                                                        5.0, 5.0),
                                                                    child: Text('+ ₱ ${loadFlavorData[index1]['addon_price']}', style: TextStyle(fontSize: 17,),),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          );
                                                        }
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(1.0, 0.0, 5.0, 5.0),
                                                    child: new Text(labelDrinks,
                                                      style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 5.0),
                                                    child: ListView.builder(
                                                        physics: NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount: loadDrinksData == null ? 0 : loadDrinksData.length,
                                                        itemBuilder: (BuildContext context,int index2) {
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                    fit: FlexFit
                                                                        .loose,
                                                                    child: RadioListTile(
                                                                      title: Text(
                                                                        "${loadDrinksData[index2]['product_name']} (${loadDrinksData[index2]['unit_measure']})",
                                                                        style: TextStyle(
                                                                          fontSize: 17,),),
                                                                      value: index2,
                                                                      groupValue: drinksGroupValue,
                                                                      onChanged: (
                                                                          newValue) {
                                                                        setState(() {
                                                                          drinksGroupValue =
                                                                              newValue;
                                                                          drinkId = int.parse(loadDrinksData[index2]['drink_id']);
                                                                          drinkUom = int.parse(loadDrinksData[index2]['uom_id']);
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                        1.0, 0.0,
                                                                        5.0, 5.0),
                                                                    child: Text(
                                                                      '+ ₱ ${loadDrinksData[index2]['addon_price']}',
                                                                      style: TextStyle(
                                                                        fontSize: 17,),),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          );
                                                        }
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(
                                                        1.0, 0.0, 5.0, 5.0),
                                                    child: new Text(labelFries,
                                                      style: GoogleFonts.openSans(
                                                          fontWeight: FontWeight
                                                              .bold,
                                                          fontStyle: FontStyle
                                                              .normal,
                                                          fontSize: 18.0),),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(
                                                        0.0, 0.0, 5.0, 5.0),
                                                    child: ListView.builder(
                                                        physics: NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount: loadFriesData ==
                                                            null ? 0 : loadFriesData
                                                            .length,
                                                        itemBuilder: (
                                                            BuildContext context,
                                                            int index3) {
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment
                                                                    .spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                    fit: FlexFit
                                                                        .loose,
                                                                    child: RadioListTile(
                                                                      title: Text(
                                                                        '${loadFriesData[index3]['product_name']} ${loadFriesData[index3]['unit_measure']}',
                                                                        style: TextStyle(
                                                                          fontSize: 17,),),
                                                                      value: index3,
                                                                      groupValue: friesGroupValue,
                                                                      onChanged: (
                                                                          newValue) {
                                                                        setState(() {
                                                                          friesGroupValue =
                                                                              newValue;
                                                                          friesId =
                                                                              int
                                                                                  .parse(
                                                                                  loadFriesData[index3]['fries_id']);
                                                                          friesUom =
                                                                              int
                                                                                  .parse(
                                                                                  loadFriesData[index3]['uom_id']);
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                        1.0, 0.0,
                                                                        5.0, 5.0),
                                                                    child: Text(
                                                                      '+ ₱ ${loadFriesData[index3]['addon_price']}',
                                                                      style: TextStyle(
                                                                        fontSize: 17,),),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          );
                                                        }
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(
                                                        1.0, 0.0, 5.0, 5.0),
                                                    child: new Text(labelSides,
                                                      style: GoogleFonts.openSans(
                                                          fontWeight: FontWeight
                                                              .bold,
                                                          fontStyle: FontStyle
                                                              .normal,
                                                          fontSize: 18.0),),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(
                                                        0.0, 0.0, 5.0, 5.0),
                                                    child: ListView.builder(
                                                        physics: NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount: loadSideData ==
                                                            null ? 0 : loadSideData
                                                            .length,
                                                        itemBuilder: (
                                                            BuildContext context,
                                                            int index4) {
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment
                                                                    .spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                    fit: FlexFit
                                                                        .loose,
                                                                    child: RadioListTile(
                                                                      title: Text(
                                                                        '${loadSideData[index4]['product_name']} ${loadSideData[index4]['unit_measure']}',
                                                                        style: TextStyle(
                                                                          fontSize: 17,),),
                                                                      value: index4,
                                                                      groupValue: sidesGroupValue,
                                                                      onChanged: (
                                                                          newValue) {
                                                                        setState(() {
                                                                          friesGroupValue =
                                                                              newValue;
                                                                          sideId =
                                                                              int
                                                                                  .parse(
                                                                                  loadSideData[index4]['side_id']);
                                                                          sideUom =
                                                                              int
                                                                                  .parse(
                                                                                  loadSideData[index4]['uom_id']);
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),

                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                        1.0, 0.0,
                                                                        5.0, 5.0),
                                                                    child: Text(
                                                                      '+ ₱ ${loadSideData[index4]['addon_price']}',
                                                                      style: TextStyle(
                                                                        fontSize: 17,),),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          );
                                                        }
                                                    ),
                                                  ),

                                                ],
                                              );
                                            }
                                        ),
                                      ),

                                    ],
                                  ),
//                          child: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),

                                );
                              },
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 20.0),
                          child: SleekButton(
                            onTap: () {

                            },
                            style: SleekButtonStyle.flat(
                              color: Colors.deepOrange,
                              inverted: false,
                              rounded: false,
                              size: SleekButtonSize.big,
                              context: context,
                            ),
                            child: Center(
                              child: Text("Update", style: TextStyle(
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            );
          }
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



//  StreamController _event =StreamController<int>.broadcast();
  updateCartQty(id,qty) async{
    await db.updateCartQty(id,qty);
    loadCart();
  }

  @override
  void initState() {
    super.initState();
    loadCart();
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
//                            shrinkWrap: true,
                            itemCount:loadCartData == null ? 0 : loadCartData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
//                                  displayAddon(context,loadCartData[index]['prod_name'],loadCartData[index]['prod_id'],loadCartData[index]['prod_uom']);
                                },
                                child: Container(
                                  height: 150.0,
                                  width: 30.0,
                                  child: Card(
                                    color: Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
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
                                                      image: new NetworkImage(loadCartData[index]['prod_image']),
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  )),
                                            ),
                                            Container(
                                              child:Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                      padding: EdgeInsets.fromLTRB(15, 10, 5, 5),
                                                      child:Text('${loadCartData[index]['prod_name']}', overflow: TextOverflow.clip,
                                                        style: GoogleFonts.openSans(
                                                            fontStyle:
                                                            FontStyle.normal,
                                                            fontSize: 13.0),
                                                      ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(15, 0, 5, 5),
                                                    child: new Text('${loadCartData[index]['bu_name']} - ${loadCartData[index]['tenant_name']}', overflow: TextOverflow.clip,
                                                      style: GoogleFonts.openSans(
                                                          fontStyle:
                                                          FontStyle.normal,
                                                          fontSize: 13.0),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                                                        child: new Text(
                                                          "₱ ${loadCartData[index]['total'].toString()}",
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
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                          child:RawMaterialButton(
                                                            onPressed: () {
                                                              removeFromCart(loadCartData[index]['d_id']);
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
                                                            onPressed: (){
                                                              setState(() {
                                                                var x = loadCartData[index]['cart_qty'];
                                                                int d = int.parse(x.toString());
                                                                loadCartData[index]['cart_qty'] = d-=1;  //code ni boss rene
                                                                if(d<1){
                                                                  loadCartData[index]['cart_qty']=1;
                                                                }
                                                                updateCartQty(loadCartData[index]['d_id'].toString(),loadCartData[index]['cart_qty'].toString());
                                                              });
//                                                              qtyGlobal1 = int.parse(loadCartData[index]['d_quantity']);
//                                                                decrement(loadCartData[index]['d_id'], loadCartData[index]['d_quantity'],index);
//                                                              removeFromCart(loadCartData[index]['d_id']);
                                                            },
                                                          ),
                                                        ),
                                                      ),

                                                      Padding(
                                                        padding:EdgeInsets.fromLTRB(1, 5, 5, 5),
                                                        child:Text(loadCartData[index]['cart_qty'].toString()),
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
//                                                          color: Colors.deepOrange,
                                                            onPressed: (){
                                                              setState(() {
                                                                var x = loadCartData[index]['cart_qty'];
                                                                int d = int.parse(x.toString());
                                                                loadCartData[index]['cart_qty'] = d+=1;   //code ni boss rene
                                                                updateCartQty(loadCartData[index]['d_id'].toString(),loadCartData[index]['cart_qty'].toString());
                                                              });
//                                                              removeFromCart(loadCartData[index]['d_id']);
                                                            },
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
                      ),
                    ),
                  ),
                  Visibility(
                     visible: loadCartData.isEmpty ? false : true,
//                      visible:true,
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
                                width:  MediaQuery.of(context).size.width / 5.5,
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
                                child: SleekButton(
                                  onTap: () async {
                                    selectType(context);
                                  },
                                  style: SleekButtonStyle.flat(
                                    color: Colors.deepOrange,
                                    inverted: false,
                                    rounded: false,
                                    size: SleekButtonSize.big,
                                    context: context,
                                  ),
                                  child: Center(
                                    child: Text("₱ ${oCcy.format(grandTotal)} Next", style:TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 13.0),
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