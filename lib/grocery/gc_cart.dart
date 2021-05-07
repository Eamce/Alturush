import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'gc_pick_up.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../track_order.dart';
import '../create_account_signin.dart';
import 'package:intl/intl.dart';

class GcLoadCart extends StatefulWidget {
  @override
  _GcLoadCart createState() => _GcLoadCart();
}

class _GcLoadCart extends State<GcLoadCart> {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  List loadCartData;
  List loadSubtotal;
  var isLoading = true;
  var isLoading1 = true;

  var subTotal;


  Future loadCart() async {
    var res = await db.gcLoadCartData();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadCartData = res['user_details'];
      if(loadCartData.isNotEmpty){
        loadGcSubTotal();
      }
    });
  }

  Future loadGcSubTotal() async{
    var res = await db.loadGcSubTotal();
    if (!mounted) return;
    setState(() {
      isLoading1 = false;
      loadSubtotal = res['user_details'];
      if(loadSubtotal[0]['d_subtotal']==null){
        subTotal = 0;
      }else{
        subTotal = loadSubtotal[0]['d_subtotal'].toString();
      }
    });
  }

//   void selectType(BuildContext context) async{
//     showModalBottomSheet(
//         isScrollControlled: true,
//         isDismissible: true,
//         context: context,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
//         ),
//         builder: (ctx) {
//           return Container(
//             height: MediaQuery.of(context).size.height  * 0.4,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children:[
//                 SizedBox(height:10.0),
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
//                   child:Text("Select type",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
//                 ),
//                 SizedBox(
//                   height: 30.0,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children:[
//                     Column(
//                       children: [
//                         GestureDetector(
//                           onTap: (){
//                             Navigator.pop(context);
// //                            submitPlaceOrder();
//                           },
//                           child: Container(
//                             width:130,
//                             height:130,
//                             child: Padding(
//                               padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
//                               child: SvgPicture.asset("assets/svg/food-delivery.svg"),
//                             ),
//                           ),
//                         ),
//                         Text("Delivery",style: TextStyle(fontSize: 18.0,fontWeight:FontWeight.bold),),
//                       ],
//                     ),
//
//                     Column(
//                       children: [
//                         GestureDetector(
//                           onTap: (){
//                             Navigator.pop(context);
//                             Navigator.of(context).push(_pickUp());
//                           },
//                           child: Container(
//                             width:130,
//                             height:130,
//                             child: Padding(
//                               padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
//                               child: SvgPicture.asset("assets/svg/staff-picks.svg"),
//                             ),
//                           ),
//                         ),
//                         Text("Pick up",style: TextStyle(fontSize: 18.0,fontWeight:FontWeight.bold),),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         });
//   }


//  StreamController _event =StreamController<int>.broadcast();
  updateCartQty(id,qty) async{
    await db.updateGcCartQty(id,qty);
//    loadSubTotal();
  }

  @override
  void initState() {
//    _event.add(0);
    super.initState();
    loadCart();
//    trapTenantLimit();
//    loadSubTotal();
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
            TextButton (
              child: Text('Cancel',style: TextStyle(color:Colors.green,),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: Text('Proceed',style: TextStyle(color:Colors.green,),),
                onPressed:() async{
                  Navigator.of(context).pop();
                  await db.removeGcItemFromCart(prodId);
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
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
             ),
          ): Column(
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
//                            height: 150.0,
//                            width: 30.0,
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
                                                image: new NetworkImage(loadCartData[index]['product_image']),
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
                                                padding:EdgeInsets.fromLTRB(15, 10, 30, 5),
                                                child:Text('${loadCartData[index]['product_name']}',textAlign: TextAlign.justify, maxLines: 2, overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.openSans(
                                                      fontStyle:
                                                      FontStyle.normal,
                                                      fontSize: 13.0),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(15, 0, 5, 5),
                                                child: new Text('${loadCartData[index]['bu']}', overflow: TextOverflow.clip,
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
                                                      "₱ ${loadCartData[index]['price_price'].toString()}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 15,
                                                        color: Colors.green,
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
                                                          removeFromCart(loadCartData[index]['cart_id']);
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
                                                            updateCartQty(loadCartData[index]['cart_id'].toString(),loadCartData[index]['cart_qty'].toString());
                                                            loadGcSubTotal();
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
                                                        onPressed: (){
                                                          setState(() {
                                                            var x = loadCartData[index]['cart_qty'];
                                                            int d = int.parse(x.toString());
                                                            loadCartData[index]['cart_qty'] = d+=1;   //code ni boss rene
                                                            updateCartQty(loadCartData[index]['cart_id'].toString(),loadCartData[index]['cart_qty'].toString());
                                                            loadGcSubTotal();
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
              replacement: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight / 3.0),
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
                    SizedBox(
                      width: 2.0,
                    ),
                    Flexible(
                      child: SleekButton(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String username = prefs.getString('s_customerId');
                          if(username == null){
                            Navigator.of(context).push(_signIn());
                          }else{
                            Navigator.of(context).push(_pickUp());
                          }
                          // selectType(context);
                        },
                        style: SleekButtonStyle.flat(
                          color: Colors.green,
                          inverted: false,
                          rounded: false,
                          size: SleekButtonSize.big,
                          context: context,
                        ),
                        child: Center(
                          child: isLoading1
                              ? Center(
                            child:Container(
                              height:16.0 ,
                              width: 16.0,
                              child: CircularProgressIndicator(
//                              strokeWidth: 1,
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ) : Text("₱ ${subTotal.toString()} Next", style:TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 13.0),
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

Route _pickUp() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcPickUp(),
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