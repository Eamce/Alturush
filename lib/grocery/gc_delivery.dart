import '../db_helper.dart';
import 'package:flutter/material.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class GcDelivery extends StatefulWidget {
  @override
  _GcDelivery createState() => _GcDelivery();
}

class _GcDelivery extends State<GcDelivery> {
  final db = RapidA();
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  final _modeOfPayment = TextEditingController();
  final deliveryDate = TextEditingController();
  final deliveryTime = TextEditingController();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;
  var totalLoading = true;
  List getGcItemsList,getBillList,getConFeeList,getBuName,trueTime;
  List<String> billPerBu = [];
  List<String> buData = [];
  List<String> buNameData = [];
  List<String> totalData = [];
  List<String> convenienceData = [];
  var _today;
  var timeCount;
  var _globalTime, _globalTime2;
  var conFee = 0.0;
  var bill = 0.0;
  var lt = 0;
  var minimumAmount = 0.0;
  var grandTotal = 0.0;


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

  getTrueTime() async{
    var res = await db.getTrueTime();
    if (!mounted) return;
    setState(() {
      trueTime = res['user_details'];
    });
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
                      _modeOfPayment.text = "CASH ON DELIVERY";
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage("assets/mop/cod.png"),
                        ),
                        title: Text("CASH ON DELIVERY"),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _modeOfPayment.text = "GCASH";
                      Navigator.of(context).pop();
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
                      _modeOfPayment.text = "PAYMAYA";
                      Navigator.of(context).pop();
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
    getBill();
    gcGroupByBu();
    getTrueTime();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async{
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
        title: Text("Delivery",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ): Column(
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
                  ): Form(
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
                                          child: new Text("Picking Fee:", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
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
                                      modeOfPayment(_modeOfPayment);
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
                                  child: new Text("Delivery Date*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                ),
                                Padding(
                                  padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                  child: InkWell(
                                    onTap: (){
                                      deliveryTime.clear();
                                      getTrueTime();
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      showDialog<void>(
                                        context: context,
//                                        barrierDismissible: false, // user must tap button!
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(8.0))
                                            ),
                                            title: Text("Set date for this delivery",style: TextStyle(fontSize: 20.0),),
                                            contentPadding:EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                                            content: Container(
                                              height:230.0, // Change as per your requirement
                                              width: 360.0, // Change as per your requirement
                                              child: Scrollbar(
                                                child:ListView.builder(
                                                  physics: BouncingScrollPhysics(),
//                                                  shrinkWrap: true,
                                                  itemCount: 4,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    String tom = "";
                                                    int n = 0;
                                                    n = index;
                                                    if(n==0){
                                                      tom = "(Today)";
                                                    }
                                                    var d1 = DateTime.parse(trueTime[0]['date_today']);
                                                    var d2 = new DateTime(d1.year, d1.month, d1.day + n);
                                                    final DateFormat formatter = DateFormat('yyyy-MM-dd');
                                                    final String formatted = formatter.format(d2);
                                                    return InkWell(
                                                      onTap: (){

                                                        deliveryDate.text = formatted;
                                                        Navigator.of(context).pop();
                                                        if(index == 0){
                                                          setState((){
                                                            _today = true;
                                                            timeCount = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']).difference(DateTime.parse(trueTime[0]['date_today']+" "+"19:30")).inHours;
                                                            timeCount = timeCount.abs();
                                                            _globalTime = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']);
                                                            _globalTime2 = _globalTime.hour;
                                                          });
                                                        }
                                                        else{
                                                          setState((){
                                                            _today = false;
                                                            timeCount = 12;
                                                            _globalTime = new DateTime.now();
                                                            _globalTime2 = 07;
                                                          });
                                                        }
                                                      },
                                                      child: Column(
                                                        children:[
                                                          Row(
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
                                                  deliveryDate.clear();
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
                                        controller: deliveryDate,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter some value';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
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

                              ],
                        ),
                      ),
                  ),
                ),
              ),
            ]
        ),
    ),
   );
  }
}