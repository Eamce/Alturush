import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'live_map.dart';
import 'package:fluttertoast/fluttertoast.dart';


import 'dart:async';
class ToDeliverFood extends StatefulWidget {
  final ticketNo;
  final dmop;
  final type;
  ToDeliverFood({Key key, @required this.ticketNo,this.dmop,this.type}) : super(key: key);//
  @override
  _ToDeliver createState() => _ToDeliver();
}

class _ToDeliver extends State<ToDeliverFood> {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;
  List loadItems;
  List loadTotal;
  StreamController<List> _streamController = StreamController<List>();

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
  var grandTotal = '0';
  Future getTotal() async{
    var res = await db.getTotal(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      // grandTotal = 0.0;
      loadTotal = res['user_details'];
      grandTotal = loadTotal[0]['total_price'];
    });
  }

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
//  Future cancelEntireOrder(ticketId) async{
//    showDialog<void>(
//      context: context,
//      builder: (BuildContext context) {
//        return  AlertDialog(
//          contentPadding: EdgeInsets.symmetric(horizontal:0.0, vertical: 20.0),
//          title:Row(
//            children: <Widget>[
//              Text('Hello',style:TextStyle(fontSize: 18.0),),
//            ],
//          ),
//          content: SingleChildScrollView(
//            child: ListBody(
//              children: <Widget>[
//                Padding(
//                  padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
//                  child:Center(child:Text("Do you want to cancel this ticket?")),
//                ),
//              ],
//            ),
//          ),
//          actions: <Widget>[
//            FlatButton(
//              child: Text('Close',style: TextStyle(
//                color: Colors.deepOrange,
//              ),),
//              onPressed: () async{
//                Navigator.of(context).pop();
//              },
//            ),
//            FlatButton(
//              child: Text('Proceed',style: TextStyle(
//                color: Colors.deepOrange,
//              ),),
//              onPressed: () async{
//                Navigator.of(context).pop();
//                cancelSuccess();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }
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
      _streamController.add(loadItems);
    });
  }

  Future lookItemsGood() async{
    var res = await db.lookItemsGood(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadItems = res['user_details'];
      _streamController.add(loadItems);
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


    super.initState();
    selectType();
    getTotal();
    if(widget.dmop=='Pick-up'){
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
          title: Text(widget.ticketNo,style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
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
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                      child: OutlineButton(
                        borderSide: BorderSide(color: Colors.deepOrange),
                        highlightedBorderColor: Colors.deepOrange,
                        highlightColor: Colors.transparent,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                        onPressed: () {
                          checkIfOnGoing();
                        },
                        child: Text("Show more"),
                      ),
                    ),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: refresh,
                      child: Scrollbar(
                        child: StreamBuilder(
                          stream: _streamController.stream,
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData)
                              return ListView.builder(
                                    itemCount:snapshot.data.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {

                                        },
                                        child: Container(
                                          height: 150.0,
                                          width: 50.0,
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
                                                              child: new Text('${loadItems[index]['bu_name']} ${loadItems[index]['tenant_name']}', overflow: TextOverflow.clip,
                                                                style: GoogleFonts.openSans(
                                                                    fontStyle:
                                                                    FontStyle.normal,
                                                                    fontSize: 15.0),
                                                              ),
                                                            ),
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
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
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
                                                                  padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                                                                  child: OutlineButton(
                                                                    borderSide: BorderSide(color: Colors.deepOrange),
                                                                    highlightedBorderColor: Colors.deepOrange,
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
                                                                      borderSide: BorderSide(color: Colors.deepOrange),
                                                                      highlightedBorderColor: Colors.deepOrange,
                                                                      highlightColor: Colors.transparent,
                                                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                                      onPressed: null,
                                                                      child: Text("Rider is tagged"),
                                                                    ),
                                                                  ):Padding(
                                                                    padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                                                                    child: OutlineButton(
                                                                      borderSide: BorderSide(color: Colors.deepOrange),
                                                                      highlightedBorderColor: Colors.deepOrange,
                                                                      highlightColor: Colors.transparent,
                                                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                                      onPressed: (){
                                                                        cancelOrder(loadItems[index]['toms_id'],loadItems[index]['ticketId']);
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
                                    }
                                    );
                              // return ListView(
                              //   children: [
                              //     for (Map document in snapshot.data)
                              //       Container(
                              //         height: 150.0,
                              //         width: 50.0,
                              //         child: Card(
                              //           color: Colors.transparent,
                              //           child: Column(
                              //             crossAxisAlignment: CrossAxisAlignment.start,
                              //             mainAxisAlignment: MainAxisAlignment.spaceAround,
                              //             children: [
                              //               Row(
                              //                 children: <Widget>[
                              //                   Padding(
                              //                     padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                              //                     child: Container(
                              //                         width: 80.0,
                              //                         height: 100.0,
                              //                         decoration: new BoxDecoration(
                              //                           shape: BoxShape.circle,
                              //                           image: new DecorationImage(
                              //                             image: new NetworkImage(document['prod_image']),
                              //                             fit: BoxFit.scaleDown,
                              //                           ),
                              //                         )),
                              //                   ),
                              //                   Expanded(
                              //                     child: Container(
                              //                       child:Column(
                              //                         crossAxisAlignment:CrossAxisAlignment.start,
                              //                         children: <Widget>[
                              //                           Padding(
                              //                             padding: EdgeInsets.fromLTRB(15, 0, 5, 5),
                              //                             child: new Text('${document['bu_name']} ${document['tenant_name']}', overflow: TextOverflow.clip,
                              //                               style: GoogleFonts.openSans(
                              //                                   fontStyle:
                              //                                   FontStyle.normal,
                              //                                   fontSize: 15.0),
                              //                             ),
                              //                           ),
                              //                           Padding(
                              //                             padding: EdgeInsets.fromLTRB(15, 0, 5, 5),
                              //                             child:Text(document['prod_name'],maxLines: 6, overflow: TextOverflow.ellipsis,
                              //                               style: GoogleFonts.openSans(
                              //                                   fontStyle:
                              //                                   FontStyle.normal,
                              //                                   fontSize: 15.0),
                              //                             ),
                              //                           ),
                              //                           Row(
                              //                             children: <Widget>[
                              //                               Padding(
                              //                                 padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                              //                                 child: new Text(
                              //                                   "₱ ${oCcy.format(double.parse(document['total_price']))} ",
                              //                                   style: TextStyle(
                              //                                     fontWeight:
                              //                                     FontWeight.bold,
                              //                                     fontSize: 15.0,
                              //                                     color: Colors.deepOrange,
                              //                                   ),
                              //                                 ),
                              //                               ),
                              //
                              //                             ],
                              //                           ),
                              //                           Row(
                              //                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //                             children: [
                              //                               Padding(
                              //                                 padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                              //                                 child: new Text('Quantity: ${document['d_qty']}',
                              //                                   style: TextStyle(
                              //                                     //                                                        fontWeight: FontWeight.bold,
                              //                                     fontSize: 15.0,
                              //                                     //                                                        color: Colors.deepOrange,
                              //                                   ),
                              //                                 ),
                              //                               ),
                              //                               document['canceled_status'] == '1'?
                              //                               Padding(
                              //                                 padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                              //                                 child: OutlineButton(
                              //                                   borderSide: BorderSide(color: Colors.deepOrange),
                              //                                   highlightedBorderColor: Colors.deepOrange,
                              //                                   highlightColor: Colors.transparent,
                              //                                   shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                              //                                   onPressed: null,
                              //                                   child: Text("Cancelled"),
                              //                                 ),
                              //                               ):
                              //                               document['ifexists'] == 'true'?
                              //                               Padding(
                              //                                 padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                              //                                 child: OutlineButton(
                              //                                   borderSide: BorderSide(color: Colors.deepOrange),
                              //                                   highlightedBorderColor: Colors.deepOrange,
                              //                                   highlightColor: Colors.transparent,
                              //                                   shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                              //                                   onPressed: null,
                              //                                   child: Text("Rider is tagged"),
                              //                                 ),
                              //                               ):Padding(
                              //                                 padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                              //                                 child: OutlineButton(
                              //                                   borderSide: BorderSide(color: Colors.deepOrange),
                              //                                   highlightedBorderColor: Colors.deepOrange,
                              //                                   highlightColor: Colors.transparent,
                              //                                   shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                              //                                   onPressed: (){
                              //                                     cancelOrder(document['toms_id'],document['ticketId']);
                              //                                     print(document['toms_id']);
                              //                                     print(document['ticketId']);
                              //                                   },
                              //                                   child:Text("Cancel this item"),
                              //                                 ),
                              //                               )
                              //                             ],
                              //                           ),
                              //                         ],
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ],
                              //               )
                              //             ],
                              //           ),
                              //           elevation: 0,
                              //           margin: EdgeInsets.all(3),
                              //         ),
                              //       ),
                              //   ],
                              // );
                            return Text('Loading...');
                          },
                        ),
                        // child: ListView.builder(
                        //     itemCount:loadItems == null ? 0 : loadItems.length,
                        //     itemBuilder: (BuildContext context, int index) {
                        //       return GestureDetector(
                        //         onTap: () {
                        //
                        //         },
                        //         child: Container(
                        //           height: 150.0,
                        //           width: 50.0,
                        //           child: Card(
                        //             color: Colors.transparent,
                        //             child: Column(
                        //               crossAxisAlignment: CrossAxisAlignment.start,
                        //               mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //               children: [
                        //                 Row(
                        //                   children: <Widget>[
                        //                     Padding(
                        //                       padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                        //                       child: Container(
                        //                           width: 80.0,
                        //                           height: 100.0,
                        //                           decoration: new BoxDecoration(
                        //                             shape: BoxShape.circle,
                        //                             image: new DecorationImage(
                        //                               image: new NetworkImage(loadItems[index]['prod_image']),
                        //                               fit: BoxFit.scaleDown,
                        //                             ),
                        //                           )),
                        //                     ),
                        //                     Expanded(
                        //                       child: Container(
                        //                         child:Column(
                        //                           crossAxisAlignment:CrossAxisAlignment.start,
                        //                           children: <Widget>[
                        //                             Padding(
                        //                               padding: EdgeInsets.fromLTRB(15, 0, 5, 5),
                        //                               child: new Text('${loadItems[index]['bu_name']} ${loadItems[index]['tenant_name']}', overflow: TextOverflow.clip,
                        //                                 style: GoogleFonts.openSans(
                        //                                     fontStyle:
                        //                                     FontStyle.normal,
                        //                                     fontSize: 15.0),
                        //                               ),
                        //                             ),
                        //                             Padding(
                        //                               padding: EdgeInsets.fromLTRB(15, 0, 5, 5),
                        //                               child:Text(loadItems[index]['prod_name'],maxLines: 6, overflow: TextOverflow.ellipsis,
                        //                                 style: GoogleFonts.openSans(
                        //                                     fontStyle:
                        //                                     FontStyle.normal,
                        //                                     fontSize: 15.0),
                        //                               ),
                        //                             ),
                        //                             Row(
                        //                               children: <Widget>[
                        //                                 Padding(
                        //                                   padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                        //                                   child: new Text(
                        //                                     "₱ ${oCcy.format(double.parse(loadItems[index]['total_price']))} ",
                        //                                     style: TextStyle(
                        //                                       fontWeight:
                        //                                       FontWeight.bold,
                        //                                       fontSize: 15.0,
                        //                                       color: Colors.deepOrange,
                        //                                     ),
                        //                                   ),
                        //                                 ),
                        //
                        //                               ],
                        //                             ),
                        //                             Row(
                        //                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //                               children: [
                        //                                 Padding(
                        //                                   padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                        //                                   child: new Text('Quantity: ${loadItems[index]['d_qty']}',
                        //                                     style: TextStyle(
                        //                                       //                                                        fontWeight: FontWeight.bold,
                        //                                       fontSize: 15.0,
                        //                                       //                                                        color: Colors.deepOrange,
                        //                                     ),
                        //                                   ),
                        //                                 ),
                        //                                 loadItems[index]['canceled_status'] == '1'?
                        //                                 Padding(
                        //                                   padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                        //                                   child: OutlineButton(
                        //                                     borderSide: BorderSide(color: Colors.deepOrange),
                        //                                     highlightedBorderColor: Colors.deepOrange,
                        //                                     highlightColor: Colors.transparent,
                        //                                     shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                        //                                     onPressed: null,
                        //                                     child: Text("Cancelled"),
                        //                                   ),
                        //                                 ):
                        //                                 loadItems[index]['ifexists'] == 'true'?
                        //                                   Padding(
                        //                                     padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                        //                                     child: OutlineButton(
                        //                                       borderSide: BorderSide(color: Colors.deepOrange),
                        //                                       highlightedBorderColor: Colors.deepOrange,
                        //                                       highlightColor: Colors.transparent,
                        //                                       shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                        //                                       onPressed: null,
                        //                                       child: Text("Rider is tagged"),
                        //                                     ),
                        //                                   ):Padding(
                        //                                     padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                        //                                     child: OutlineButton(
                        //                                       borderSide: BorderSide(color: Colors.deepOrange),
                        //                                       highlightedBorderColor: Colors.deepOrange,
                        //                                       highlightColor: Colors.transparent,
                        //                                       shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                        //                                       onPressed: (){
                        //                                         cancelOrder(loadItems[index]['toms_id'],loadItems[index]['ticketId']);
                        //                                         print(loadItems[index]['toms_id']);
                        //                                         print(loadItems[index]['ticketId']);
                        //                                       },
                        //                                       child:Text("Cancel this item"),
                        //                                     ),
                        //                                 )
                        //                               ],
                        //                             ),
                        //                           ],
                        //                         ),
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 )
                        //               ],
                        //             ),
                        //             elevation: 0,
                        //             margin: EdgeInsets.all(3),
                        //           ),
                        //         ),
                        //       );
                        //     }),
                      ),
                    ),
                  ),
                  // Divider(
                  //   color: Colors.black,
                  // ),
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
//                   Padding(
//                     padding:EdgeInsets.fromLTRB(25.0, 7.0, 25.0, 5.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         new Text("TOTAL", style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
//                         Text('₱${oCcy.format(double.parse(grandTotal))}', style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10.0,
//                   ),
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
