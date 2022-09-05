import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'db_helper.dart';

class OrderTimeFrame extends StatefulWidget {
  final ticketNo;

  const OrderTimeFrame({Key key, this.ticketNo}) : super(key: key);
  // const OrderTimeFrame({Key key, @required this.cart}) : super(key: key);
  @override
  _OrderTimeFrameState createState() => _OrderTimeFrameState();
}

class _OrderTimeFrameState extends State<OrderTimeFrame>{
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;
  List getTime, getStatus, timeframe;
  var submit = true;
  var taggedpickup = true;
  var taggedstatus = true;
  var cancel = true;
  var prepare = true;
  var pending = true;
  var set_up = true;
  var trans = true;
  var deliver = true;
  var complete = true;
  var remit = true;
  var canceL = true;


  @override
  void initState(){
    print(widget.ticketNo);
    timeFrame();
    // canceLstatus();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        titleSpacing: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Ticket #: "+widget.ticketNo,
          style: GoogleFonts.openSans(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 18.0),
        ),
      ),
      body:
      isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ):
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child:RefreshIndicator(
                    onRefresh: refresh,
                    child: Scrollbar(
                        child: ListView(
                            padding: EdgeInsets.zero,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[

                                        SizedBox(height: 30),
                                        Container(
                                          child: Row(
                                            children: [
                                              Text('ORDER TIME FRAME:', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 20.0, color: Colors.deepOrangeAccent),),
                                            ],
                                          ),
                                        ),
                                        Divider(),

                                        Visibility(
                                            visible: pending,
                                            child: Column(
                                              children: <Widget>[
                                                SizedBox(height: 15),
                                                Container(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('Order status: ', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                                      Text("Pending",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0,color: Colors.black45),),
                                                    ],
                                                  ),
                                                ),
                                                Divider(),
                                              ],
                                            )
                                        ),

                                        Visibility(
                                            visible: submit,
                                            child: Column(
                                              children: <Widget>[
                                                SizedBox(height: 15),
                                                Container(
                                                  child: Column(
                                                    children: [
                                                      Text('Order Submission: ', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                                      Text('(Submitted Order by Tenant)', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 16.0, color: Colors.deepOrangeAccent),),
                                                      Text(" ${submitted}",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                    ],
                                                  ),
                                                ),
                                                Divider(),
                                              ],
                                            )
                                        ),

                                        Visibility(
                                            visible: prepare,
                                            child: Column(
                                              children: <Widget> [
                                                SizedBox(height: 15),
                                                Container(
                                                  child: Column(
                                                    children: [
                                                      Text("Food Preparation: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                                      Text('(Order Submission -> For Pick-up Tagging)', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 16.0, color: Colors.deepOrangeAccent),),
                                                      Container(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(" ${prepared} /",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                            Text(" ${prepareMin} min,",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                            Text(" ${prepareSec} sec",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                          ],
                                                        )
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Divider(),
                                              ],
                                            )
                                        ),

                                        Visibility(
                                          visible: taggedstatus,
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(height: 15),
                                              Container(
                                                child: Column(
                                                  children: [
                                                    Text("Picking Assignment: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                                    Text('(For Pick-up Tagging -> Rider Set-up)', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 16.0, color: Colors.deepOrangeAccent),),
                                                    Container(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(" ${taggedStatus} /",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                            Text(" ${tagMin} min,",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                            Text(" ${tagSec} sec",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                          ],
                                                        )
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Divider(),
                                            ],
                                          ),
                                        ),

                                        Visibility(
                                          visible: taggedpickup,
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(height: 15),
                                              Container(
                                                child: Column(
                                                  children: [
                                                    Text("Order Claim: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                                    Text('(For Pick-up Tagging -> Order Pick-up)', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 16.0, color: Colors.deepOrangeAccent),),
                                                    Container(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(" ${taggedPickup} /",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                            Text(" ${tagPickupMin} min,",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                            Text(" ${tagPickupSec} sec",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                          ],
                                                        )
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Divider(),
                                            ],
                                          ),
                                        ),

                                        Visibility(
                                          visible: set_up,
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(height: 15),
                                              Container(
                                                child: Column(
                                                  children: [
                                                    Text("Order Claiming: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                                    Text('(Rider Set-up -> In Transit Tagging by Tenant)', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 16.0, color: Colors.deepOrangeAccent),),
                                                    Container(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget> [
                                                            Text(" ${setup} /",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                            Text(" ${setupMin} min,",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                            Text(" ${setupSec} sec",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                          ],
                                                        )
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Divider(),
                                            ],
                                          ),
                                        ),

                                        Visibility(
                                          visible: trans,
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(height: 15),
                                              Container(
                                                child: Column(
                                                  children: [
                                                    Text("Delivery period: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                                    Text('(In Transit Tagging by Tenant -> Customer)', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 16.0, color: Colors.deepOrangeAccent),),
                                                    Container(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(" ${transit} /",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                            Text(" ${transMin} min,",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                            Text(" ${transSec} sec",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16.0,color: Colors.black45),),
                                                          ],
                                                        )
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Divider(),
                                            ],
                                          ),
                                        ),

                                        // Visibility(
                                        //   visible: cancel,
                                        //   child: Column(
                                        //     children: <Widget>[
                                        //       SizedBox(height: 15),
                                        //       Container(
                                        //         child:
                                        //         Row(
                                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //           children: [
                                        //             Text("Cancelled at: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                        //             Text(" ${cancelled}",textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0,color: Colors.black45),),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //       Divider(),
                                        //     ],
                                        //   ),
                                        // ),

                                        // Visibility(
                                        //   visible: deliver,
                                        //   child: Column(
                                        //     children: <Widget>[
                                        //       SizedBox(height: 15),
                                        //       Container(
                                        //         child: Row(
                                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //           children: [
                                        //             Text("Delivered at: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                        //             Text(" ${delivered}",textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0,color: Colors.black45),),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //       Divider(),
                                        //     ],
                                        //   ),
                                        // ),
                                        //
                                        // Visibility(
                                        //   visible: complete,
                                        //   child: Column(
                                        //     children: <Widget>[
                                        //       SizedBox(height: 15),
                                        //       Container(
                                        //         child: Row(
                                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //           children: [
                                        //             Text("Completed at: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                        //             Text(" ${completed}",textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0,color: Colors.black45),),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //       Divider(),
                                        //     ],
                                        //   ),
                                        // ),
                                        //
                                        // Visibility(
                                        //   visible: remit,
                                        //   child: Column(
                                        //     children: <Widget>[
                                        //       SizedBox(height: 15),
                                        //       Container(
                                        //         child: Row(
                                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //           children: [
                                        //             Text("Remitted at: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                        //             Text(" ${remitted}",textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0,color: Colors.black45),),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //       Divider(),
                                        //     ],
                                        //   ),
                                        // ),

                                        Visibility(
                                          visible: canceL,
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(height: 15),
                                              Container(
                                                child: Column(
                                                  children: [
                                                    Text("Order status: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                                    Text(" Cancelled",textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0,color: Colors.black45),),
                                                  ],
                                                ),
                                              ),
                                              Divider(),
                                            ],
                                          ),
                                        ),
                                      ]
                                  )
                              )
                            ]
                        )
                    )
                )
            )
          ]
      ),
    );
  }

  Future refresh() async{
    setState(() {
      // canceLstatus();
      timeFrame();
    });
  }

  // Future canceLstatus() async{
  //   var res = await db.cancelStatus();
  //   if (!mounted) return;
  //   setState(() {
  //     getStatus = res['user_details'];
  //
  //     if (getStatus[0]['cancel_status'] == null) {
  //       canceL = false;
  //     } else {
  //       pending = false;
  //       canceL = true;
  //     }
  //     print(getStatus);
  //   });
  // }

  String submitted, submittedDate;
  String prepared, prepareDate, prepareHr, prepareMin, prepareSec;
  String taggedStatus, taggedStatusDate, tagHr, tagMin, tagSec;
  String taggedPickup, taggedPickupDate, tagPickupHr, tagPickupMin, tagPickupSec;
  String setup, setupDate, setupHr, setupMin, setupSec;
  String transit, transitDate, transHr, transMin, transSec;
  String cancelled, delivered, completed, remitted;
  var index = 0;
  Future timeFrame() async{

    var res = await db.orderTimeFrame(widget.ticketNo);
    var res1 = await db.cancelStatus(widget.ticketNo);
    if (!mounted) return;
    setState(() {

      getTime = res['user_details'];
      getStatus = res1['user_details'];

      if (getStatus[index]['cancel_status'] == '0') {
        canceL = false;
      } else {
        canceL = true;
        pending = false;
      }

      if(getTime.isEmpty){

        submit = false;
        prepare = false;
        taggedpickup = false;
        taggedstatus = false;
        set_up = false;
        trans = false;
        cancel = false;
        deliver = false;
        complete = false;
        remit = false;

      } else {
        //submitted at
        if (getTime[index]['submitted_at'] == null) {
          submit = false;
          pending = true;
        } else {
          submittedDate = getTime[index]['submitted_at'];
          DateTime startDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(submittedDate);
          submitted =  DateFormat().format(startDate);
          pending = false;
        }
        //prepared at
        if (getTime[index]['prepared_at'] == null) {
          prepare = false;
        } else {
          prepareDate = getTime[index]['prepared_at'];
          DateTime prep = DateFormat('yyyy-MM-dd hh:mm:ss').parse(prepareDate);
          prepared = DateFormat().format(prep);

          DateTime startDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(submittedDate);
          DateTime endDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(prepareDate);
          Duration dif = endDate.difference(startDate);

          prepareHr = dif.inHours.toString();
          prepareMin = (dif.inMinutes %60).toString();
          prepareSec = (dif.inSeconds %60).toString();
        }
        //tagged status at
        if (getTime[index]['tag_status_at'] == null){
          taggedstatus = false;
        } else {
          taggedStatusDate = getTime[index]['tag_status_at'];
          DateTime tag = DateFormat('yyyy-MM-dd hh:mm:ss').parse(taggedStatusDate);
          taggedStatus = DateFormat().format(tag);

          DateTime startDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(prepareDate);
          DateTime endDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(taggedStatusDate);
          Duration dif = endDate.difference(startDate);

          tagHr = dif.inHours.toString();
          tagMin = (dif.inMinutes %60).toString();
          tagSec = (dif.inSeconds %60).toString();
        }
        //tagged pickup at
        if (getTime[index]['tag_pickup_at'] == null) {
          taggedpickup = false;
        } else {
          taggedPickupDate = getTime[index]['tag_pickup_at'];
          DateTime tagP = DateFormat('yyyy-MM-dd hh:mm:ss').parse(taggedPickupDate);
          taggedPickup = DateFormat().format(tagP);

          DateTime startDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(prepareDate);
          DateTime endDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(taggedPickupDate);
          Duration dif = endDate.difference(startDate);

          tagPickupHr = dif.inHours.toString();
          tagPickupMin = (dif.inMinutes %60).toString();
          tagPickupSec = (dif.inSeconds %60).toString();

          print(dif.toString()); // 12:00:00.000000
          print(dif.inHours);
          print(dif.inMinutes %60); // 12
          print(dif.inSeconds %60);
        }
        //setup at
        if (getTime[index]['r_setup_stat_at'] == null) {
          set_up = false;
        } else {
          setupDate = getTime[index]['r_setup_stat_at'];
          DateTime set = DateFormat('yyyy-MM-dd hh:mm:ss').parse(setupDate);
          setup = DateFormat().format(set);

          DateTime startDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(taggedStatusDate);
          DateTime endDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(setupDate);
          Duration dif = endDate.difference(startDate);

          setupHr = dif.inHours.toString();
          setupMin = (dif.inMinutes %60).toString();
          setupSec = (dif.inSeconds %60).toString();

        }
        //trans at
        if (getTime[index]['trans_at'] == null) {
          trans = false;
        } else {
          transitDate = getTime[index]['trans_at'];
          DateTime trans = DateFormat('yyyy-MM-dd hh:mm:ss').parse(transitDate);
          transit = DateFormat().format(trans);

          DateTime startDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(setupDate);
          DateTime endDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(transitDate);
          Duration dif = endDate.difference(startDate);

          transHr = dif.inHours.toString();
          transMin = (dif.inMinutes %60).toString();
          transSec = (dif.inSeconds %60).toString();

          // print(dif.toString()); // 12:00:00.000000
          // print(dif.inMinutes); // 12
          // print(dif.inSeconds %60);
        }
        // if (getTime[index]['delevered_at'] == null) {
        //   deliver = false;
        // } else {
        //   delivered = getTime[index]['delevered_at'];
        // }
        // if (getTime[index]['completed_at'] == null) {
        //   complete = false;
        // } else {
        //   completed = getTime[index]['completed_at'];
        // }
        // if (getTime[index]['remitted_at'] == null) {
        //   remit = false;
        // } else {
        //   remitted = getTime[index]['remitted_at'];
        // }
      }
      print(getTime[index]['tag_pickup_at']);
      isLoading = false;
    });
    // print(getTime);
    // print(getStatus);
  }



}



