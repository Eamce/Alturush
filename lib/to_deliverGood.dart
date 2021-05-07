import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:intl/intl.dart';
import 'load_bu.dart';
import 'live_map.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToDeliverGood extends StatefulWidget {
  final ticketNo;
  final customerId;
  ToDeliverGood({Key key, @required this.ticketNo,this.customerId}) : super(key: key);//
  @override
  _ToDeliver createState() => _ToDeliver();
}

class _ToDeliver extends State<ToDeliverGood> {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;
  List loadItems;
  List loadTotal;

  Future cancelOrder(tomsId) async{
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
                color: Colors.green,
              ),),
              onPressed: () async{
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Proceed',style: TextStyle(
                color: Colors.green,
              ),),
              onPressed: () async{
                cancelOrderSingle(tomsId);
                Navigator.of(context).pop();
                cancelSuccess();
              },
            ),
          ],
        );
      },
    );
  }
  var delCharge;
  var grandTotal;
  // Future getTotal() async{
  //   var res = await db.getTotal(widget.ticketNo);
  //   if (!mounted) return;
  //   setState(() {
  //     loadTotal = res['user_details'];
  //     if(loadTotal[0]['charge'] == null && loadTotal[0]['grand_total'] ){
  //       delCharge = 0;
  //       grandTotal = 0;
  //       print("opps");
  //     }else{
  //       delCharge = loadTotal[0]['charge'];
  //       grandTotal = loadTotal[0]['grand_total'];
  //       print("naa");
  //     }
  //   });
  // }

  Future cancelOrderSingle(tomsId) async{
    // await db.cancelOrderSingleGood(tomsId);
    lookItemsGood();
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

  Future lookItemsGood() async{
    //var res = await db.lookItems(widget.ticketNo);
    var res = await db.lookItemsGood(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadItems = res['user_details'];
//      tPrice = loadItems[0]['d_tot_price'];
//      deliveryCharge = loadItems[0]['d_delivery_charge'];
//      granTotal = double.parse(deliveryCharge)+tPrice;
//      tPrice = int.parse(loadItems[1]['d_tot_price']).toString();
//      deliveryCharge =  int.parse(loadItems[0]['d_delivery_charge']).toString();
//      print(int.parse(loadItems[1]['d_tot_price']).toString());
    });
  }

  var checkIfExists;
  Future checkIfOnGoing() async{
    var res = await db.checkIfOnGoing(widget.ticketNo);
    if(res == 'true'){
      checkIfExists = res;
    }if(res == 'false'){
      checkIfExists = res;
    }

  }

  @override
  void initState() {
    super.initState();
    lookItemsGood();
    // getTotal();
    checkIfOnGoing();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
          actions: [
            checkIfExists == 'true' ?
            IconButton(tooltip: "View on map",icon:Icon(Icons.map), color: Colors.green,
              onPressed: (){
                Navigator.of(context).push(_viewOrderStatus(widget.ticketNo));
              },
            ):
            IconButton(tooltip: "View on map",icon:Icon(Icons.map), color: Colors.green,
              onPressed: (){
                Fluttertoast.showToast(
                    msg: "This item must be serve before showing the rider in the map",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                    backgroundColor: Colors.black.withOpacity(0.7),
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              },
            )
          ],
          title: Text(widget.ticketNo,style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: lookItemsGood,
                child: Scrollbar(
                  child: ListView.builder(
                      itemCount:loadItems == null ? 0 : loadItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {

                          },
                          child: Container(
                            height: 130.0,
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
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                                        child: Container(
                                            width: 80.0,
                                            height: 100.0,
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
                                                child:Text(loadItems[index]['prod_name'],textAlign: TextAlign.justify, maxLines: 2, overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.openSans(
                                                      fontStyle:
                                                      FontStyle.normal,
                                                      fontSize: 15.0),
                                                ),
                                              ),
                                              // Padding(
                                              //   padding: EdgeInsets.fromLTRB(15, 0, 5, 5),
                                              //   child: new Text('From: ${loadItems[index]['bu_name']}', overflow: TextOverflow.clip,
                                              //     style: GoogleFonts.openSans(
                                              //         fontStyle:
                                              //         FontStyle.normal,
                                              //         fontSize: 15.0),
                                              //   ),
                                              // ),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                                                    child: new Text(
                                                      "Price: ₱ ${oCcy.format(double.parse(loadItems[index]['total_price']))} ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 15.0,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                                                    child: new Text('Quantity: ${loadItems[index]['d_qty']}',
                                                      style: TextStyle(
                                                        //                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15.0,
                                                        //                                                        color: Colors.deepOrange,
                                                      ),
                                                    ),
                                                  ),
                                                  loadItems[index]['canceled_status'] == '1'?
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                                                    child: OutlineButton(
                                                      borderSide: BorderSide(color: Colors.green),
                                                      highlightedBorderColor: Colors.green,
                                                      highlightColor: Colors.transparent,
                                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                      onPressed: null,
                                                      child: Text("Cancelled"),
                                                    ),
                                                  ):
                                                  loadItems[index]['ifexists'] == 'true'?
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                                                    child: OutlineButton(
                                                      borderSide: BorderSide(color: Colors.green),
                                                      highlightedBorderColor: Colors.green,
                                                      highlightColor: Colors.transparent,
                                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                      onPressed: null,
                                                      child: Text("Rider is tagged"),
                                                    ),
                                                  ):Padding(
                                                    padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                                                    child: OutlineButton(
                                                      borderSide: BorderSide(color: Colors.green),
                                                      highlightedBorderColor: Colors.green,
                                                      highlightColor: Colors.transparent,
                                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                      onPressed: (){
                                                        // cancelOrder(loadItems[index]['gc_final_id']);
                                                      },
                                                      child:Text("Cancel this item"),
                                                    ),
                                                  )
                                                ],
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
                ),
              ),
            ),
            Divider(
              color: Colors.black,
            ),
//                  Padding(
//                    padding:EdgeInsets.fromLTRB(15.0, 7.0, 15.0, 5.0),
//                    child: Row(
//                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                      children: [
//                        new Text("Status", style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 18.0),),
//                        new Text("Pending", style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 18.0),),
//                      ],
//                    ),
//                  ),


            // Padding(
            //   padding:EdgeInsets.fromLTRB(15.0, 7.0, 15.0, 5.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       new Text("Rider's charge", style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 18.0),),
            //       delCharge == null ?
            //       new Text('₱ 0.0', style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 18.0),)
            //           :new Text('₱ $delCharge', style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 18.0),)
            //     ],
            //   ),
            // ),
            // Padding(
            //   padding:EdgeInsets.fromLTRB(15.0, 7.0, 15.0, 5.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       new Text("GRAND TOTAL", style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
            //       grandTotal == null ?
            //       new Text('₱${ oCcy.format(0)}', style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),)
            //           :new Text('₱${ oCcy.format(grandTotal)}', style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
            //     ],
            //   ),
            // ),
            Center(
              child:Column(
                children: [
//                        Padding(
//                          padding: EdgeInsets.fromLTRB(10.0,0.0, 10.0,0.0),
//                          child: SizedBox(
//                            width: 400.0,
//                            height: 50.0,
//                            child:  OutlineButton(
//                              highlightedBorderColor: Colors.deepOrange,
//                              highlightColor: Colors.transparent,
//                              shape: RoundedRectangleBorder(
//                                  borderRadius: BorderRadius.circular(5.0),
//                                  side: BorderSide(color: Colors.red)
//                              ),
//                              color: Colors.deepOrange,
//                              onPressed: (){
//                                cancelEntireOrder(widget.ticketNo);
//                              },
//                              child: Text("Cancel entire order", style: GoogleFonts.openSans(
//                                  fontWeight: FontWeight.bold,
//                                  fontStyle: FontStyle.normal,
//                                  color: Colors.black,
//                                  fontSize: 18.0),),
//                            ),
//                          ),
//                        ),
//                        SizedBox(
//                          height: 5.0,
//                        ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.0,0.0, 10.0,0.0),
                    child: SizedBox(
                      width: width-50,
                      height: 50.0,
                      child:  OutlineButton(
                        highlightedBorderColor: Colors.deepOrange,
                        highlightColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: Colors.red)
                        ),
                        color: Colors.deepOrange,
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyHomePage()),
                          );
                        },
                        child: Text("Shop more", style: GoogleFonts.openSans(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 18.0),),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 10.0,
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
