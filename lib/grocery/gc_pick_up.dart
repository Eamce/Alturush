import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import '../db_helper.dart';
import 'package:intl/intl.dart';
import 'package:sleek_button/sleek_button.dart';
import 'gc_pick_up_final.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:arush/create_account_signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GcPickUp extends StatefulWidget {
  @override
  _GcPickUp createState() => _GcPickUp();
}

class _GcPickUp extends State<GcPickUp> {
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  List<TextEditingController> _deliveryDate = new List();
  List<TextEditingController> _deliveryTime = new List();
  List<TextEditingController> placeRemarks = new List();

  List<String> billPerBu = [];
  List<String> deliveryTimeData = [];
  List<String> deliveryDateData = [];
  List<String> totalData = [];
  List<String> convenienceData = [];
  List<String> placeRemarksData = [];

  List<String> buData = [];
  List<String> buNameData = [];
  final _modeOfPayment = TextEditingController();
  // final placeRemarks = TextEditingController();
  final discount = TextEditingController();
  var isLoading = true;
  var totalLoading = true;
  var timeCount;
  var _globalTime,_globalTime2;
  var bill = 0.0;
  var conFee = 0.0;
  var grandTotal = 0.0;
  var minimumAmount = 0.0;
  var lt = 0;
  List getGcItemsList,getBillList,getConFeeList,getBuName;
  List trueTime;
  List<String> cont = List();
  getTrueTime() async{
    var res = await db.getTrueTime();
    if (!mounted) return;
    setState(() {
      trueTime = res['user_details'];

    });
  }

  getBill() async{
    var res = await db.getConFee();
    isLoading = false;
    if (!mounted) return;
    setState(() {
      getConFeeList = res['user_details'];
      conFee = double.parse(getConFeeList[0]['pickup_charge']);
      minimumAmount = double.parse(getConFeeList[0]['minimum_order_amount']);
      // print(getConFeeList[0]['pickup_charge']);
    });

    var res1 = await db.getBill();
    if (!mounted) return;
    setState((){
      totalLoading = false;
      getBillList = res1['user_details'];
      bill = double.parse(getBillList[0]['d_subtotal']);
      grandTotal = bill+(conFee*lt);
    });
  }


  billNotAbove() async{
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
              child: SvgPicture.asset("assets/svg/groceries.svg"),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child:Center(
                    child:Text("Minimum order must exceed ₱${oCcy.format(minimumAmount)} on each store.",textAlign: TextAlign.center, maxLines: 3,style:TextStyle(fontSize: 18.0),),
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

  gcGroupByBu() async{
    var res = await db.gcGroupByBu();
    if (!mounted) return;
    setState((){
      getBuName = res['user_details'];
      lt=getBuName.length;
      for(int q=0;q<lt;q++){
        billPerBu.add(getBuName[q]['total']);
        buData.add(getBuName[q]['buId']);
        buNameData.add(getBuName[q]['buName']);
        totalData.add(getBuName[q]['total']);
        convenienceData.add(conFee.toString());
      }
    });
  }
  //
  // getConFee() async{
  //   var res = await db.getConFee();
  //   isLoading = false;
  //   if (!mounted) return;
  //   setState(() {
  //     getConFeeList = res['user_details'];
  //     conFee = double.parse(getConFeeList[0]['pickup_charge']);
  //     minimumAmount = double.parse(getConFeeList[0]['minimum_order_amount']);
  //     // print(getConFeeList[0]['pickup_charge']);
  //   });
  // }

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

  modeOfPayment(_modeOfPayment){
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
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                    child:Text("Payment method",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                  ),
                  InkWell(
                    onTap: () {
                      _modeOfPayment.text = "CASH ON PICK UP";
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage("assets/mop/cod.png"),
                        ),
                        title: Text("CASH ON PICK UP"),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // _modeOfPayment.text = "GCASH";
                      // Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage("assets/mop/gcash.jpg"),
                        ),
                        title: Text("GCASH"),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      // _modeOfPayment.text = "PAYMAYA";
                      // Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage("assets/mop/paymaya.jpg"),
                        ),
                        title: Text("PAYMAYA"),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          );
        });
  }

  @override
  void initState(){
    super.initState();
    // getConFee();
    getTrueTime();
    gcGroupByBu();
    getBill();
    _modeOfPayment.text = "Cash on pick-up";
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.1,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed:() {
                Navigator.pop(context);
              }
          ),
          title: Text("Pick up",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
          ) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child:Scrollbar(
                  child:totalLoading
                    ? Padding(
                    padding:EdgeInsets.fromLTRB(20.0,20.0, 5.0, 20.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                      ),
                    ),
                   ):Form(
                    key: _key,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            direction: Axis.horizontal,
                            children:[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  Padding(
                                    padding:EdgeInsets.fromLTRB(20.0, 7.0, 5.0, 5.0),
                                    child: new Text("Convenience Fee:", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.fromLTRB(20.0, 7.0, 20.0, 5.0),
                                    child: new Text("₱ ${oCcy.format(conFee*lt)}", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
                                  ),
                                ],
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding:EdgeInsets.fromLTRB(20.0, 7.0, 5.0, 5.0),
                                    child: new Text("Total:", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.fromLTRB(20.0, 7.0, 20.0, 5.0),
                                    child: new Text("₱ ${oCcy.format(bill)}", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
                                  ),
                                ],
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding:EdgeInsets.fromLTRB(20.0, 7.0, 5.0, 5.0),
                                    child: new Text("Grand Total:", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
                                  ),

                                  Padding(
                                    padding:EdgeInsets.fromLTRB(20.0, 7.0, 20.0, 5.0),
                                    child: new Text("₱ ${oCcy.format(grandTotal)}", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
                                  ),
                                ],
                              ),

                            ],
                          ),

                          Divider(
                            color: Colors.black87.withOpacity(0.8),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(35, 10, 5, 5),
                            child: new Text("Mode of payment*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                          ),
                          Padding(
                            padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                            child: InkWell(
                              onTap: (){
                                // modeOfPayment(_modeOfPayment);
                              },
                              child: IgnorePointer(
                                child: new TextFormField(
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Colors.deepOrange,
                                  controller: _modeOfPayment,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please select mode of payment';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.date_range,color: Colors.grey,),
                                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
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
                            padding: EdgeInsets.fromLTRB(35, 10, 5, 5),
                            child: new Text("In case the product is out of stock", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 18.0),),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: _myRadioButton(
                              title: "Remove it from my order",
                              value: 0,
                              onChanged: (newValue) => setState((){
                                groupValue = newValue;
                              }),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: _myRadioButton(
                              title: "Cancel the entire order",
                              value: 1,
                              onChanged: (newValue) => setState((){
                                groupValue = newValue;
                              }),
                            ),
                          ),

                          ListView.builder(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: getBuName == null ? 0: getBuName.length,
                              itemBuilder: (BuildContext context, int index) {
                                _deliveryDate.add(new TextEditingController());
                                _deliveryTime.add(new TextEditingController());
                                placeRemarks.add(new TextEditingController());
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                      color: Colors.black87.withOpacity(0.8),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(30, 0, 5, 5),
                                      child: new Text(getBuName[index]['buName'], style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 22.0),),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(30, 0, 5, 5),
                                      child: new Text("Total: ₱ ${oCcy.format(double.parse(getBuName[index]['total']))}", style: TextStyle(fontStyle: FontStyle.normal,fontSize: 20.0),),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(30, 0, 5, 5),
                                      child: new Text("Convenience fee: "+conFee.toString(), style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 20.0),),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(35, 10, 5, 5),
                                      child: new Text("Pick-up date*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                    ),
                                    Padding(
                                      padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                      child: InkWell(
                                        onTap: (){
                                          _deliveryTime[index].clear();
                                          FocusScope.of(context).requestFocus(FocusNode());
                                          showDialog<void>(
                                            context: context,
//                                        barrierDismissible: false, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(8.0))
                                                ),
                                                title: Text("Set date for delivery",style: TextStyle(fontSize: 15.0),),
                                                contentPadding:EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                                                content: Container(
                                                  height:290.0, // Change as per your requirement
                                                  width: 360.0, // Change as per your requirement
                                                  child: Scrollbar(
                                                    child:ListView.builder(
                                                      physics: BouncingScrollPhysics(),
                                                      itemCount: 5,
                                                      itemBuilder: (BuildContext context, int index1) {
                                                        int n = 0;
                                                        n = index1;
                                                        var d1 = DateTime.parse(trueTime[0]['date_today']);
                                                        var d2 = new DateTime(d1.year, d1.month, d1.day + n);
                                                        final DateFormat formatter = DateFormat('yyyy-MM-dd');
                                                        final String formatted = formatter.format(d2);
                                                        return InkWell(
                                                          onTap: (){
                                                            _deliveryDate[index].text = formatted;
                                                            deliveryDateData.add(formatted);

                                                            Navigator.of(context).pop();
                                                            if(index1 == 0){
                                                              setState(() {

                                                                timeCount = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']).difference(DateTime.parse(trueTime[0]['date_today']+" "+"19:30")).inHours;
                                                                timeCount = timeCount.abs();
                                                                _globalTime = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']);
                                                                _globalTime2 = _globalTime.hour;
                                                              });
                                                            }
                                                            else{
                                                              setState(() {

                                                                timeCount = 12;
                                                                _globalTime = new DateTime.now();
                                                                _globalTime2 = 07;
                                                              });
                                                            }
                                                          },
                                                          child: Container(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Row (
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(30.0,20.0, 0.0,20.0),
                                                                        child: Text('${formatted.toString()}',style: TextStyle(fontSize: 16.0),),
                                                                      ),
                                                                    ]
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
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
                                                      _deliveryDate[index].clear();
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
                                            cursorColor: Colors.deepOrange,
                                            controller: _deliveryDate[index],
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please select delivery date';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.date_range,color: Colors.grey,),
                                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
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
                                      padding: EdgeInsets.fromLTRB(35, 10, 5, 5),
                                      child: new Text("Delivery time", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                    ),
                                    Padding(
                                      padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                      child: InkWell(
                                        onTap: (){
                                          getTrueTime();
                                          if(_deliveryDate[index].text.isEmpty){
                                            Fluttertoast.showToast(
                                                msg: "Please select a delivery date",
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
//                                          barrierDismissible: false, // user must tap button!
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(8.0))
                                                  ),
                                                  title: Text("Set time for delivery",style: TextStyle(fontSize: 15.0),),
                                                  contentPadding:
                                                  EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                                                  content: Container(
                                                    height:290.0, // Change as per your requirement
                                                    width: 360.0, // Change as per your requirement
                                                    child: Scrollbar(
                                                      child:  ListView.builder(
                                                          physics: BouncingScrollPhysics(),
                                                          shrinkWrap: true,
                                                          itemCount:  timeCount,
                                                          itemBuilder: (BuildContext context, int index1) {
                                                            int t = index1;
                                                            t++;
//                                                              var d1 = DateTime.parse(trueTime[0]['date_today']);
                                                            final now =  _globalTime;
                                                            final dtFrom = DateTime(now.year, now.month, now.day, _globalTime2+t, 0+30, now.minute, now.second);
                                                            // final dtTo = DateTime(now.year, now.month, now.day, 8+t, 0+30);
                                                            final format = DateFormat.jm();  //"6:00 AM"
                                                            String from = format.format(dtFrom);
                                                            return InkWell(
                                                              onTap: (){
                                                                _deliveryTime[index].text = from;
                                                                deliveryTimeData.add(from);
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Container(
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: <Widget>[
                                                                    Row (
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: <Widget>[
                                                                          Padding(
                                                                            padding: EdgeInsets.fromLTRB(30.0,20.0, 0.0,20.0),
                                                                            child: Text('${from.toString()}',style: TextStyle(fontSize: 16.0),),
                                                                          ),
                                                                        ]
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                      ),
                                                    ),
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
                                                        _deliveryTime[index].clear();
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
                                            textInputAction: TextInputAction.done,
                                            cursorColor: Colors.deepOrange,
                                            controller: _deliveryTime[index],
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please select delivery time';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.timelapse,color: Colors.grey,),
                                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
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
                                      padding: EdgeInsets.fromLTRB(35, 10, 5, 5),
                                      child: new Text("Remarks*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                    ),
                                    Padding(
                                      padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                      child: new TextFormField(
                                        keyboardType: TextInputType.multiline,
                                        textInputAction: TextInputAction.done,
                                        cursorColor: Colors.deepOrange,
                                        controller: placeRemarks[index],
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter some value';
                                          }
                                          return null;
                                        },
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                          hintText:"E.g Please handle with care",
                                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                          focusedBorder:OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                          ),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: SleekButton(
                      onTap: () async{
                          FocusScope.of(context).requestFocus(FocusNode());
                          List<String> w = [];
                          placeRemarksData.clear();
                          for(int q=0;q<billPerBu.length;q++){
                            if(double.parse(billPerBu[q])<minimumAmount){
                              w.add('true');
                            }else{
                              w.add('false');
                            }
                            placeRemarksData.add(placeRemarks[q].text);
                          }
                          if(w.contains('true')){
                              billNotAbove();
                          }else{
                            if (_key.currentState.validate()) {
                              // print(groupValue);
                              // print(deliveryDateData);
                              // print(deliveryTimeData);
                              // print(buData);
                              // print(totalData);
                              // print(convenienceData);
                              // print(placeRemarksData);
                              // Navigator.of(context).push(_gcPickUpFinal(groupValue,_deliveryTime,_deliveryDate,_modeOfPayment,placeRemarks));
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String username = prefs.getString('s_customerId');
                              if(username == null){
                                Navigator.of(context).push(_signIn());
                              }else{
                                Navigator.of(context).push(_gcPickUpFinal(groupValue,deliveryDateData,deliveryTimeData,buNameData,buData,totalData,convenienceData,placeRemarksData,_modeOfPayment.text));
                              }
                            }
                          }
                             },
                              style: SleekButtonStyle.flat(
                                color: Colors.green,
                                inverted: false,
                                rounded: false,
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
            ),
          );
      }
    }

int groupValue = 0;
Widget _myRadioButton({String title, int value, Function onChanged}) {
  return Theme(
    data: ThemeData.light(),
    child: RadioListTile(
      activeColor: Colors.green,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(title),
    ),
  );
}

Route _gcPickUpFinal(groupValue,deliveryDateData,deliveryTimeData,buNameData,buData,totalData,convenienceData,placeRemarksData,_modeOfPayment){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcPickUpFinal(groupValue:groupValue,deliveryDateData:deliveryDateData,deliveryTimeData:deliveryTimeData,buNameData:buNameData,buData:buData,totalData:totalData,convenienceData:convenienceData,placeRemarksData:placeRemarksData,modeOfPayment:_modeOfPayment),
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
