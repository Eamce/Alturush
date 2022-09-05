import 'package:arush/profile_page.dart';
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
  List listProfile;
  var isLoading = true;
  var checkOutLoading = true;
  var profileLoading = true;
  var labelFlavor = "";
  var labelDrinks = "";
  var labelFries = "";
  var labelSides = "";
  var profilePicture = "";

  int flavorGroupValue;
  int drinksGroupValue;
  int friesGroupValue;
  int sidesGroupValue;
  int flavorId;
  int drinkId, drinkUom;
  int friesId, friesUom;
  int sideId, sideUom;
  int grandTotal = 0;
  int subTotal = 0;
  int index = 0;
  int option;

  var boolFlavorId = false;
  var boolDrinkId = false;
  var boolFriesId = false;
  var boolSideId = false;

  List loadIMainItems;
  List loadChoices;
  List loadFlavors;
  List loadAddons;
  List loadTotalData;
  List loadTotalPrice;
  List getBu;
  List<String> totalPrice = [];
  String totPrice;
  final _formKey = GlobalKey<FormState>();
  var stores;
  var items;

  List<String> _options = ['Pay via Cash/COD']; // Option 2
  String _selectOption; // Option 2

  Future loadCart() async {
    var res = await db.loadCartData();
    if (!mounted) return;
    setState(() {

      loadCartData = res['user_details'];
      loadIMainItems = loadCartData;
      items = loadCartData.length;
      isLoading = false;
    });
  }


  String status;
  Future loadProfilePic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status = prefs.getString('s_status');
    if (status != null) {
      var res = await db.loadProfile();
      if (!mounted) return;
      setState(() {
        listProfile = res['user_details'];
        profilePicture = listProfile[0]['d_photo'];
        profileLoading = false;
      });
    }
  }

  Future getBuSegregate() async {
    var res = await db.getBuSegregate1();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
      stores = getBu.length;
      print(getBu);
    });
  }

  Future loadTotal() async {
    var res = await db.loadSubTotal();
    if (!mounted) return;
    setState(() {

      loadTotalData = res['user_details'];
      grandTotal = int.parse(loadTotalData[0]['grand_total'].toString());
      isLoading = false;
    });
    print(grandTotal);

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
                          padding: EdgeInsets.all(0),
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
                          padding: EdgeInsets.all(0),
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
                          padding: EdgeInsets.all(0),
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
                              padding: EdgeInsets.fromLTRB(10.0, 5.0, 25.0, 5.0),
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

  void displayBottomSheet(BuildContext context) async {
    var res = await db.getAmountPerTenant();
    if (!mounted) return;
    setState(() {

      lGetAmountPerTenant = res['user_details'];
      isLoading = false;
      print(lGetAmountPerTenant);
    });
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
            child:Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.0),
                  Padding(
                    padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                    child: Text(
                      "YOUR STORES",
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),),
                  ),
                  Divider(thickness: 2,),
                  Expanded(
                    child: Scrollbar(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: lGetAmountPerTenant == null ? 0 : lGetAmountPerTenant.length,
                            itemBuilder: (BuildContext context, int index) {
                              var f = index;
                              f++;
                              return Padding(
                                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${lGetAmountPerTenant[index]['acroname']} - ${lGetAmountPerTenant[index]['tenant_name']}',
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Divider(thickness: 2,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              'No. of Item(s):',
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              '${lGetAmountPerTenant[index]['count']}',
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.normal)),
                                        ],
                                      ),
                                      Divider(),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              'Subtotal Amount:',
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              '₱${oCcy.format(int.parse(lGetAmountPerTenant[index]['total'].toString()))}',
                                              style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.normal)),
                                        ],
                                      ),
                                      Divider(),

                                      // ListView.builder(
                                      //   shrinkWrap: true,
                                      //   itemCount: loadCartData == null ? 0 : loadCartData.length,
                                      //   itemBuilder: (BuildContext context, int index1) {
                                      //     return Padding(
                                      //       padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      //       child: Column(
                                      //         crossAxisAlignment: CrossAxisAlignment.start,
                                      //         children: [
                                      //           Row(
                                      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //             children: [
                                      //               Text(
                                      //                   'No of. Item(s)',
                                      //                   style: TextStyle(
                                      //                       fontSize: 15.0,
                                      //                       fontWeight: FontWeight.bold)),
                                      //               Text(
                                      //                   '??',
                                      //                   style: TextStyle(
                                      //                       fontSize: 15.0,
                                      //                       fontWeight: FontWeight.bold)),
                                      //             ],
                                      //           ),
                                      //         ]
                                      //       ),
                                      //     );
                                      //   },
                                      // ),
                                    ],
                                  )
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  void selectType(BuildContext context) async {
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
            height: MediaQuery.of(context).size.height / 3.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context)
                              .push(_placeOrderDelivery(loadIMainItems, _selectOption));
                        },
                        child: Container(
                          width: 130,
                          height: 200,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                                child: Image.asset(
                                  "assets/png/delivery.png",
                                ),
                              ),
                              Text(
                                "Delivery",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(_placeOrderPickUp(_selectOption));
                        },
                        child: Container(
                          width: 130,
                          height: 200,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                                child: Image.asset(
                                  "assets/png/delivery-man.png",
                                ),
                              ),
                              Text(
                                "Pick-up",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
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

  void viewCartTenants() async {
//    getAmountPerTenant();
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

    var res = await db.getAmountPerTenant();
    if (!mounted) return;
    setState(() {

      lGetAmountPerTenant = res['user_details'];
      isLoading = false;
      Navigator.of(context).pop();
    });

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
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
                      title: Text(
                          '$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',
                          style: TextStyle(
                            fontSize: 15.0,
                          )));
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

  bool ignorePointer = false;
  Future checkIfBf() async {
    var res = await db.checkIfBf();
    if (!mounted) return;
    setState(() {

      lGetAmountPerTenant = res['user_details'];
      isLoading = false;
    });
    if (lGetAmountPerTenant[0]['isavail'] == false) {
      ignorePointer = true;
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 0.0, vertical: 20.0),
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
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: Center(
                      child: Text(
                        "Some items can only be cook and deliver in specific time, please remove them to proceed.",
                        textAlign: TextAlign.justify,
                        maxLines: 3,
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
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
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ignorePointer = false;
    }
  }

//  StreamController _event =StreamController<int>.broadcast();
  updateCartQty(id, qty) async {
    await db.updateCartQty(id, qty);
  }

  @override
  void initState() {
    super.initState();
    loadCart();
    loadTotal();
    getBuSegregate();
    checkIfBf();
    loadProfilePic();
    option = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void removeFromCart(prodId) async {
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
                          Text(("Are you sure you want to remove this item?"))),
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
                  Navigator.of(context).pop();
                  await db.removeItemFromCart(prodId);
                  loadCart();
                  loadTotal();
                  getBuSegregate();
                  checkIfBf();
                }),
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
          titleSpacing: 0,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.1,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black54,
              size: 23,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "My cart",
            style: GoogleFonts.openSans(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 16.0),
          ),
          actions: <Widget>[
            InkWell(
              customBorder: CircleBorder(),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String username = prefs.getString('s_customerId');
                if (username == null) {
                  await Navigator.of(context).push(_signIn());
                  // listenCartCount();
                  // loadProfile();
                  loadProfilePic();
                } else {
                  await Navigator.of(context).push(_profilePage());
                  // listenCartCount();
                  // loadProfile();
                  loadProfilePic();
                }
              },
              child: Container(
                width: 70.0,
                height: 70.0,
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: profileLoading
                      ? CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.deepOrange),
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(profilePicture),
                        ),
                ),
              ),
            ),
          ],
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange)),
        ) :
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: loadCart,
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: getBu == null ? 0 : getBu.length,
                      itemBuilder: (BuildContext context, int index0) {
                        return Container(
                          child: Column(
                            crossAxisAlignment : CrossAxisAlignment.start,
                            children: <Widget>[
                              Divider(thickness: 2, color: Colors.deepOrangeAccent,),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                    '${getBu[index0]['d_tenant_name'].toString()} - ${getBu[index0]['d_acroname'].toString()}',
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
                                  physics: NeverScrollableScrollPhysics(), //
                                  shrinkWrap: true,
                                  itemCount: loadCartData == null ? 0 : loadCartData.length,
                                  itemBuilder: (BuildContext context, int index) {

                                  return Visibility(
                                    visible: loadCartData[index]['main_item']['tenant_id'] != getBu[index0]['d_tenant_id'] ? false : true,
                                    child: Container(
                                      height: 125.0,
                                      child: Card(color: Colors.transparent,
                                        child: Column(
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                                  )
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Flexible(
                                                            child: Padding(
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
                                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                child: Container(
                                                                  width: 30.0,
                                                                  child:
                                                                  TextButton(style: TextButton.styleFrom(backgroundColor: Colors.white12,
                                                                    primary: Colors.black, onSurface: Colors.red,
                                                                  ),
                                                                    child: Text('-', style: TextStyle(fontSize: 16.0)),
                                                                    onPressed:
                                                                        () async {
                                                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                      String username = prefs.getString('s_customerId');
                                                                      if (username == null) {
                                                                        await Navigator.of(context).push(_signIn());
                                                                      } else {
                                                                        setState(() {
                                                                          var x = loadCartData[index]['main_item']['quantity'];
                                                                          int d = int.parse(x.toString());
                                                                          loadCartData[index]['main_item']['quantity'] = d -= 1; //code ni boss rene
                                                                          if (d < 1 || d == 0) {
                                                                            loadCartData[index]['main_item']['quantity'] = 1;
                                                                            removeFromCart(loadCartData[index]['main_item']['id']);
                                                                          }
                                                                        });
                                                                        loadTotal();
                                                                        loadCart();
                                                                        updateCartQty(loadCartData[index]['main_item']['id'].toString(),
                                                                            loadCartData[index]['main_item']['quantity'].toString());
                                                                        totPrice = loadCartData[index]['main_item']['total_price'].toString();
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                child: Text(
                                                                  loadCartData[index]['main_item']['quantity'].toString(),
                                                                  style: TextStyle(fontSize: 14.0),
                                                                ),
                                                              ),

                                                              Padding(
                                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                child:
                                                                Container(
                                                                  width: 30.0,
                                                                  child:
                                                                  TextButton(
                                                                    style: TextButton.styleFrom(backgroundColor: Colors.white12,
                                                                      primary: Colors.black, onSurface: Colors.red,
                                                                    ),
                                                                    child: Text('+', style: TextStyle(fontSize: 15.0)),
                                                                    onPressed:
                                                                        () async {
                                                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                      String username = prefs.getString('s_customerId');
                                                                      if (username == null) {
                                                                        await Navigator.of(context).push(_signIn());
                                                                      } else {
                                                                        setState(() {
                                                                          var x = loadCartData[index]['main_item']['quantity'];
                                                                          int d = int.parse(x.toString());
                                                                          loadCartData[index]['main_item']['quantity'] = d += 1; //code ni boss rene
                                                                        });
                                                                        loadTotal();
                                                                        loadCart();
                                                                        updateCartQty(loadCartData[index]['main_item']['id'].toString(),
                                                                            loadCartData[index]['main_item']['quantity'].toString());
                                                                        totPrice = loadCartData[index]['main_item']['total_price'].toString();
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                            child:
                                                            OutlinedButton(
                                                            onPressed:
                                                                () async {
                                                              SharedPreferences prefs = await SharedPreferences.getInstance();
                                                              String username = prefs.getString('s_customerId');
                                                              if (username == null) {
                                                                await Navigator.of(context).push(_signIn());
                                                              } else {
                                                                removeFromCart(loadCartData[index]['main_item']['id']);
                                                              }
                                                            },
                                                            style: OutlinedButton.styleFrom(
                                                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                                              side: BorderSide(width: 1.0, color: Colors.deepOrangeAccent),
                                                              primary: Colors.deepOrangeAccent
                                                            ),
                                                            child:
                                                            Text('DELETE', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 11),)
                                                            )
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
                                                          ],
                                                        )
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Divider(),
                                          ],
                                        ),
                                        elevation: 0,
                                        margin: EdgeInsets.all(3),
                                      ),
                                    ),
                                  );
                                }
                              ),
                            ]
                          )
                        );
                      }
                    ),
                  ),
                ),
              ),

              Divider(),

              Visibility(
                  visible: loadCartData.isEmpty ? false : true,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text("TOTAL SUMMARY", style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54 )),
                        ),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('No. of Store(s)',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54)),

                              Text('$stores',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black54)),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('No. of Item(s)',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54)),

                              Text('$items',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black54)),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                                child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Amount Order',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54)),

                              Text('₱ ${oCcy.format(grandTotal)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black54)),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TOTAL AMOUNT TO PAY',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54)),

                              Text('₱ ${oCcy.format(grandTotal)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black54)),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              //Add isDense true and zero Padding.
                              //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              //Add more decoration as you want here
                              //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                            ),
                            isExpanded: true,
                            hint: const Text(
                              'PAYMENT METHOD',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black45,
                            ),
                            iconSize: 30,
                            items: _options
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
                                return 'Please select option';
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectOption = value;
                                option = _options.indexOf(value);
                                print(_selectOption);
                              });
                              //Do something when changing the item if you want.
                            },
                            onSaved: (value) {
                              _selectOption = value.toString();
                            },
                          ),
                        ),
                      ],
                    ),
                  )
              ),



              Visibility(
                visible: loadCartData.isEmpty ? false : true,
                replacement: Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: screenHeight / 3.0),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 100,
                          width: 100,
                          child:
                          SvgPicture.asset("assets/svg/empty-cart.svg"),
                        ),
                      ],
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 5.5,
                        child: SleekButton(
                          onTap: () async {
                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                            String status = prefs.getString('s_status');
                            status != null
                                ? displayBottomSheet(context)
                                : Navigator.of(context).push(_signIn());
                          },
                          style: SleekButtonStyle.flat(
                            color: Colors.deepOrange,
                            inverted: false,
                            rounded: true,
                            size: SleekButtonSize.normal,
                            context: context,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.remove_red_eye,
                              size: 18.0,
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
                              SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                              String username =
                              prefs.getString('s_customerId');
                              if (username == null) {
                                await Navigator.of(context).push(_signIn());
                              } else {
                                if (lGetAmountPerTenant[0]['isavail'] ==
                                    false) {
                                  checkIfBf();
                                } else {
                                  if (_formKey.currentState.validate()) {
                                    selectType(context);
                                  }

                                }
                              }
                            },
                            style: SleekButtonStyle.flat(
                              color: Colors.deepOrange,
                              inverted: false,
                              rounded: true,
                              size: SleekButtonSize.normal,
                              context: context,
                            ),
                            child: Center(
                              child: Text(
                                "PROCESS CHECKOUT",
                                style: TextStyle(
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0),
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
        )
//      ),
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

Route _placeOrderPickUp(paymentMethod) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => PlaceOrderPickUp(paymentMethod: paymentMethod),
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

Route _placeOrderDelivery(List loadIMainItems, paymentMethod) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => PlaceOrderDelivery(cartItems: loadIMainItems, paymentMethod: paymentMethod),
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
    pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
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
