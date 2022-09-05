import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../db_helper.dart';

class EditAddress extends StatefulWidget {
  final idd;
  final cusId;

  const EditAddress({this.idd, this.cusId});

  @override
  _EditAddress createState() => _EditAddress();
}

class _EditAddress extends State<EditAddress> {
  final db = RapidA();
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final firstName =  TextEditingController();
  final lastName =  TextEditingController();
  final mobileNum =  TextEditingController();
  final province = TextEditingController();
  final town = TextEditingController();
  final barangay = TextEditingController();
  final buildingType = TextEditingController();
  final houseUnit =  TextEditingController();
  final streetPurok=  TextEditingController();
  final landMark =  TextEditingController();
  List getProvinceData;
  List getTownData;
  List getBarangayData;
  List getBuildingData;
  int provinceId;
  int townID;
  int barangayID;
  int buildingID;
  List addresses;


  selectBuildingType() async{
    var res = await db.selectBuildingType();
    if (!mounted) return;
    setState(() {
      getBuildingData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Building type',),
          content: Container(
            height: 90.0,
            width: 300.0,
            child: Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: getBuildingData == null ? 0 : getBuildingData.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap:(){
                      buildingType.text = getBuildingData[index]['buildingName'];
                      buildingID = int.parse(getBuildingData[index]['buildingID']);
                      print(getBuildingData[index]['buildingID']);

                      Navigator.of(context).pop();
                    },
                    child: ListTile(
                      title: Text(getBuildingData[index]['buildingName']),
                    ),
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
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Clear',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                buildingType.clear();
              },
            ),
          ],
        );
      },
    );

  }


  selectProvince() async{
    var res = await db.getProvince();
    if (!mounted) return;
    setState(() {
      getProvinceData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Select Province',),
          content: Container(
            height: 90.0,
            width: 300.0,
            child: Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: getProvinceData == null ? 0 : getProvinceData.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap:(){
                      province.text = getProvinceData[index]['prov_name'];
                      provinceId = int.parse(getProvinceData[index]['prov_id']);
                      town.clear();
                      barangay.clear();
                      Navigator.of(context).pop();
                    },
                    child: ListTile(
                      title: Text(getProvinceData[index]['prov_name']),
                    ),
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
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Clear',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                province.clear();
                town.clear();
                barangay.clear();
              },
            ),
          ],
        );
      },
    );
  }

  selectTown() async{
    var res = await db.selectTown(provinceId.toString());
    if (!mounted) return;
    setState(() {

      getTownData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Select Town',),
          content: Container(
            height: 300.0,
            width: 300.0,
            child: Scrollbar(
              child:ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: getTownData == null ? 0 : getTownData.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap:(){
                      town.text = getTownData[index]['town_name'];
                      townID = int.parse(getTownData[index]['town_id']);
                      barangay.clear();
                      Navigator.of(context).pop();
                    },
                    child: ListTile(
                      title: Text(getTownData[index]['town_name']),
                    ),
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
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Clear',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                town.clear();
                barangay.clear();
              },
            ),
          ],
        );
      },
    );
  }

  selectBarangay() async{
    var res = await db.selectBarangay(townID.toString());
    if (!mounted) return;
    setState(() {

      getBarangayData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Select Barangay',),
          content: Container(
            height: 300.0,
            width: 300.0,
            child: Scrollbar(
              child:ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: getBarangayData == null ? 0 : getBarangayData.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap:(){
                      barangay.text = getBarangayData[index]['brgy_name'];
                      barangayID = int.parse(getBarangayData[index]['brgy_id']);

                      Navigator.of(context).pop();
                    },
                    child: ListTile(
                      title: Text(getBarangayData[index]['brgy_name']),
                    ),
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
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Clear',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                barangay.clear();

              },
            ),
          ],
        );
      },
    );
  }


  Future updateNewAddress() async{
    await db.updateNewAddress(widget.idd, firstName.text, lastName.text, mobileNum.text, houseUnit.text, streetPurok.text, landMark.text, barangayID, buildingID);
    successMessage();
  }

  String towns;
  var index = 0;
  Future loadAddress() async{
    var res = await db.loadAddresses(widget.idd, widget.cusId);
    if (!mounted) return;
    setState(() {
      addresses = res['user_details'];

      firstName.text = addresses[index]['firstname'];
      lastName.text = addresses[index]['lastname'];
      mobileNum.text = addresses[index]['d_contact'];
      province.text = addresses[index]['d_province'];
      provinceId = int.parse(addresses[index]['d_province_id']);
      town.text = addresses[index]['d_townName'];
      townID = int.parse(addresses[index]['d_townId']);
      barangay.text = addresses[index]['d_brgName'];
      barangayID = int.parse(addresses[index]['d_brgId']);
      buildingType.text = addresses[index]['add_type'];
      buildingID = int.parse(addresses[index]['add_type_id']);
      streetPurok.text = addresses[index]['street_purok'];
      houseUnit.text = addresses[index]['complete_add'];
      landMark.text = addresses[index]['land_mark'];
      print(addresses);
      isLoading = false;
    });

  }

  successMessage(){
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text(
            "Success!",
            style: TextStyle(fontSize: 18.0),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.fromLTRB(23.0, 0.0, 20.0, 0.0),
                  child:Text(("Your billing address was updated")),
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
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  @override
  void initState() {
    loadAddress();

    super.initState();
  }
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Update delivery address",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      ),
      body: isLoading
      ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ):Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Form(
              key: _formKey,
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                        child: new Text(
                          "First Name",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child:TextFormField(
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: firstName,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some value';
                            }
                            return null;
                          },
                          decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.8),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                        child: new Text(
                          "Last Name",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric( horizontal: 30.0, vertical: 5.0),
                        child:TextFormField(
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: lastName,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some value';
                            }
                            return null;
                          },
                          decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: Colors.deepOrange
                                      .withOpacity(0.8),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                        child: new Text(
                          "Mobile number",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child:TextFormField(
                          maxLength: 11,
                          keyboardType: TextInputType.number,
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: mobileNum,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some value';
                            }
                            if (value.length != 11 || mobileNum.text[0]!='0' ||  mobileNum.text[1]!='9') {
                              return 'Please enter valid phone number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                            hintText: "09123456789",
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.8),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                        child: new Text(
                          "Province",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child: GestureDetector(
                          onTap: (){
                            FocusScope.of(context).requestFocus(FocusNode());
                            selectProvince();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: IgnorePointer(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.deepOrange.withOpacity(0.8),
                                controller: province,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some value';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange.withOpacity(0.8),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                        child: new Text(
                          "Town",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child: GestureDetector(
                          onTap: (){
                            FocusScope.of(context).requestFocus(FocusNode());
                            if(province.text.isEmpty){
                              Fluttertoast.showToast(
                                  msg: "Please select a province",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.black.withOpacity(0.7),
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            }else{
                              selectTown();
                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: IgnorePointer(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.deepOrange.withOpacity(0.8),
                                controller: town,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some value';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange.withOpacity(0.8),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(250),),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                        child: new Text(
                          "Barangay",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child:GestureDetector(
                          onTap: (){
                            FocusScope.of(context).requestFocus(FocusNode());
                            if(town.text.isEmpty){
                              Fluttertoast.showToast(
                                  msg: "Please select a town",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.black.withOpacity(0.7),
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            }else{
                              selectBarangay();
                            }

                          },
                          child: Container(
                            color: Colors.transparent,
                            child: IgnorePointer(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.deepOrange.withOpacity(0.8),
                                controller: barangay,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some value';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange.withOpacity(0.8),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                        child: new Text(
                          "Building type",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child:GestureDetector(
                          onTap: (){
                            FocusScope.of(context).requestFocus(FocusNode());
                            selectBuildingType();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: IgnorePointer(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.deepOrange.withOpacity(0.8),
                                controller: buildingType,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some value';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange.withOpacity(0.8),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                        child: new Text(
                          "Complete Address",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child:TextFormField(
                          textCapitalization: TextCapitalization.words,
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: houseUnit,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some value';
                            }
                            return null;
                          },
                          decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.8),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                        child: new Text(
                          "Street/Purok/Sitio",
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal, fontSize: 15.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child:TextFormField(
                          textCapitalization: TextCapitalization.words,
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: streetPurok,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some value';
                            }
                            return null;
                          },
                          decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.8),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0)),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                        child: new Text("Nearest Landmark or Special instructions*", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                      ),
                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child: new TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          cursorColor: Colors.deepOrange,
                          controller: landMark,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some value';
                            }
                            return null;
                          },
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:"E.g Near at plaza/Be ware of dogs",
                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                            focusedBorder:OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
                          ),
                        ),
                      ),


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
                SizedBox(
                  width: 2.0,
                ),
                Flexible(
                  child: SleekButton(
                    onTap: () async {
                      if(_formKey.currentState.validate()) {
                        updateNewAddress();
                      }
                    },
                    style: SleekButtonStyle.flat(
                      color: Colors.deepOrange,
                      inverted: false,
                      rounded: true,
                      size: SleekButtonSize.big,
                      context: context,
                    ),
                    child: Center(
                      child: Text("Update", style:TextStyle(fontStyle: FontStyle.normal,fontSize: 18.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
