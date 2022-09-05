import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_signin.dart';
import 'db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'uploadSrId.dart';

class DiscountManager extends StatefulWidget {
  @override
  _DiscountManager createState() => _DiscountManager();
}


class _DiscountManager extends State<DiscountManager> {
  final db = RapidA();
  bool exist = false;
  bool isLoading = true;

  Future loadId() async{
    var res = await db.displayId();
    if (!mounted) return;
    setState(() {
      loadIdList = res['user_details'];
      isLoading = false;
    });
  }

  Future checkIfHasId() async{
    var res = await db.checkIfHasId();
    if (!mounted) return;
    setState(() {
      if(res == 'true'){
        exist = true;
      }else{
        exist = false;
      }
    });
  }
  @override
  void initState() {
    loadId();
    checkIfHasId();
    super.initState();
  }
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  void removeDiscountId(discountID) async {
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
                      Text(("Are you sure you want to remove this ID?"))),
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
                  print(discountID);
                  Navigator.of(context).pop();
                  await db.deleteDiscountID(discountID);
                  loadId();
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(Icons.wallet_giftcard, color: Colors.black,size: 23,),
          onPressed: () {

          }
        ),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.clear, color: Colors.black, size: 23,),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        title: Text("Apply Discount",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),

      ),
      body:isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ): Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(thickness: 2, color: Colors.deepOrangeAccent,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Text("Discount Applied List ", style: TextStyle(color: Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child:OutlinedButton(
                  onPressed: () async{
                    FocusScope.of(context).requestFocus(FocusNode());
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String username = prefs.getString('s_customerId');
                    if(username == null){
                      Navigator.of(context).push(_signIn());
                    }else{
                      showAddDiscountDialog(context);
                      checkIfHasId();
                      loadId();
                    }
                  },
                  child: Text('+ ADD',  style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 13.0, color: Colors.white)),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(25))),
                    overlayColor: MaterialStateProperty.all(Colors.black12),
                    backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                    side: MaterialStateProperty.all(BorderSide(
                      color: Colors.deepOrangeAccent,
                      width: 1.0,
                      style: BorderStyle.solid,)),
                  ),
                ),
              ),
            ],
          ),

          Divider(thickness: 2, color: Colors.deepOrangeAccent),

          Expanded(
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    exist == false ? Padding(
                      padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
                      child: Text('No Discount Details', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 16, color: Colors.black54),),
                    ):ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: loadIdList == null ? 0 : loadIdList.length,
                        itemBuilder: (BuildContext context, int index) {
                          var q = index;
                          q++;
                          if (selectedDiscountType.isEmpty){

                            side.insert(index, false);
                          }
                          // side.add(false);
                          return Padding(
                            padding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                            child: Container(
                              height: 85.0,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Column(
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // SizedBox(height: 5,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 50.0,
                                                  height: 50.0,
                                                  decoration: new BoxDecoration(
                                                    image: new DecorationImage(
                                                      image: new NetworkImage(loadIdList[index]['d_photo']),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                                    border: new Border.all(
                                                      color: Colors.black54,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(left: 30),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('${loadIdList[index]['name']} ',style: TextStyle(fontSize: 15, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black),),
                                                        Text('(${loadIdList[index]['discount_name']})',style: TextStyle(fontSize: 17,),),
                                                        Text('${loadIdList[index]['discount_no']}',style: TextStyle(fontSize: 15, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black),),
                                                      ],
                                                    )
                                                )
                                              ],
                                            ),

                                            RawMaterialButton(
                                              onPressed:
                                                  () async {
                                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                                String username = prefs.getString('s_customerId');
                                                if (username == null) {
                                                  await Navigator.of(context).push(_signIn());
                                                } else {
// sdfsdfs
                                                  removeDiscountId(loadIdList[index]['id']);
                                                  // print(loadIdList[index]['id']);
                                                }
                                              },
                                              elevation: 1.0,
                                              child:
                                              Icon(
                                                Icons.delete_outline, size: 30.0,
                                                color: Colors.deepOrangeAccent,
                                              ),
                                              shape:
                                              CircleBorder(),
                                            )
                                          ],
                                        ),
                                        Divider(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                    ),
                  ],
                ),
              ),),

          // Expanded(
          //   child:Scrollbar(
          //     child: ListView(
          //       shrinkWrap: true,
          //       children: [
          //         exist == false ? Padding(
          //         padding: EdgeInsets.symmetric(
          //             vertical: screenHeight / 3.0),
          //         child: Center(
          //           child:Column(
          //             children: <Widget>[
          //               Container(
          //                 height: 100,
          //                 width: 100,
          //                 child: SvgPicture.asset("assets/svg/inbox.svg"),
          //               ),
          //               SizedBox(
          //                 height: 20.0,
          //               ),
          //               Text("You have no discounted ID's yet",style: TextStyle(fontSize: 19,),),
          //               TextButton(
          //                 child: Text(
          //                   'Tap here to upload',
          //                   style: TextStyle(
          //                     color: Colors.deepOrange,
          //                   ),
          //                 ),
          //                 onPressed: () async{
          //                   showAddDiscountDialog(context);
          //                   // await Navigator.of(context).push(addIds());
          //                   checkIfHasId();
          //                   loadId();
          //                 },
          //               ),
          //             ],
          //           ),
          //         ),
          //       ) : ListView.builder(
          //             shrinkWrap: true,
          //             physics: BouncingScrollPhysics(),
          //             itemCount: loadIdList == null ? 0 : loadIdList.length,
          //             itemBuilder: (BuildContext context, int index) {
          //               var q = index;
          //               q++;
          //               side.add(false);
          //               return Padding(
          //                 padding:EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
          //                 child: Container(
          //                   height: 75.0,
          //                   child: Column(
          //                     mainAxisSize: MainAxisSize.min,
          //                     children: <Widget>[
          //                       CheckboxListTile(
          //                         title: Row(
          //                           // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                           children: [
          //                             Column(
          //                               crossAxisAlignment: CrossAxisAlignment.start,
          //                               children: [
          //                                 Text('$q. ${loadIdList[index]['name']}',style: TextStyle(fontSize: 17,),),
          //                                 Text('    ${loadIdList[index]['discount_name']} # ${loadIdList[index]['discount_no']}',style: TextStyle(color:Colors.black,fontSize: 17  ,),),
          //                               ],
          //                             ),
          //                             // Text('${loadIdList[index]['discount_name']} # ${loadIdList[index]['id_number']}',style: TextStyle(color:Colors.black,fontSize: 20  ,),),
          //                           ],
          //                         ),
          //                         checkColor: Colors.deepOrange,
          //                         value: side[index],
          //                         onChanged: (bool value){
          //                           setState(() {
          //                            side[index] = value;
          //                             if (value) {
          //                               selectedDiscountType.add(loadIdList[index]['dicount_id']);
          //                             }
          //                             else{
          //                               selectedDiscountType.remove(loadIdList[index]['dicount_id']);
          //                             }
          //                           });
          //                         },
          //                         controlAffinity: ListTileControlAffinity.leading,
          //                       ),
          //                       // ListTile(
          //                       //   // title: Text(loadIdList[index]['discount_name'],style: TextStyle(fontSize: 24,),),
          //                       //   // subtitle: Text('${loadIdList[index]['name']}' ,style: TextStyle(fontSize: 18  ,),),
          //                       //   title: Text('$q. ${loadIdList[index]['name']}',style: TextStyle(fontSize: 24,),),
          //                       //   subtitle: Text('     ${loadIdList[index]['discount_name']} # ${loadIdList[index]['id_number']}',style: TextStyle(color:Colors.black,fontSize: 20  ,),),
          //                       // ),
          //                     ],
          //                   ),
          //                 ),
          //               );
          //             }
          //         ),
          //         TextButton(
          //           child: Text(
          //             'Tap here to upload new ID',
          //             style: TextStyle(
          //               color: Colors.deepOrange,
          //             ),
          //           ),
          //           onPressed: () async{
          //             await Navigator.of(context).push(addIds());
          //             checkIfHasId();
          //             loadId();
          //           },
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
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
                      Navigator.of(context).pop();
                    },
                    style: SleekButtonStyle.flat(
                      color: Colors.deepOrange,
                      inverted: false,
                      rounded: true,
                      size: SleekButtonSize.big,
                      context: context,
                    ),
                    child: Center(
                      child: Text("Back", style:TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 13.0),
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

  showAddDiscountDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AddDiscountDialog();
      },
    );
  }
}

class AddDiscountDialog extends StatefulWidget {
  @override
  _AddDiscountDialogState createState() => _AddDiscountDialogState();
}

class _AddDiscountDialogState extends State<AddDiscountDialog> {
  final db = RapidA();
  final _formKey = GlobalKey<FormState>();
  final _imageTxt = TextEditingController();
  final _idNumber = TextEditingController();
  final _name = TextEditingController();
  final picker = ImagePicker();

  File _image;

  bool exist = false;
  bool canUpload = false;

  List loadDiscount;
  List loadDiscountID;
  List<String> _loadDiscount = [];
  List<String> _loadDiscountID = [];

  String newFileName;
  String selectedValue;
  String discount;

  var isLoading = true;
  var id;
  var discountID;



  Future checkIfHasId() async{
    var res = await db.checkIfHasId();
    if (!mounted) return;
    setState(() {
      if(res == 'true'){
        exist = true;
      }else{
        exist = false;
      }
    });
  }

  Future loadId() async{
    var res = await db.displayId();
    if (!mounted) return;
    setState(() {
      loadIdList = res['user_details'];
      isLoading = false;
    });
  }

  Future showDiscount() async{
    var res = await db.showDiscount();
    if (!mounted) return;
    setState(() {
      loadDiscount = res['user_details'];
      for (int i=0;i<loadDiscount.length;i++){
        _loadDiscount.add(loadDiscount[i]['discount_name']);
        _loadDiscountID.add(loadDiscount[i]['id']);
      }
    });
    print(loadDiscount);
    print(_loadDiscount);
    print(_loadDiscountID);
  }

  Future getDiscountID(name) async{
    var res = await db.getDiscountID(name);
    if (!mounted) return;
    setState(() {
      loadDiscountID = res['user_details'];
      print(loadDiscountID[0]['discount_id']);
      discountID = loadDiscountID[0]['discount_id'];
      print(discountID);
    });
  }


  camera() async{
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
        newFileName = _image.toString();
        _imageTxt.text = _image.toString().split('/').last;
      }
    });
  }

  Future uploadId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      await Navigator.of(context).push(_signIn());
    }else{
      loading();
      String base64Image = base64Encode(_image.readAsBytesSync());
      await db.uploadId(discountID,_name.text,_idNumber.text,base64Image);
      Navigator.of(context).pop();
      successMessage();
    }
  }

  loading(){
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
                  child:Text(("Discounted ID successfully added")),
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
    super.initState();
    loadId();
    checkIfHasId();
    showDiscount();
//    print(widget.deliveryDate);
//    print(widget.changeFor+"hello");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))
      ),
      contentPadding: EdgeInsets.only(top: 10),
      content: Container(
          height: 450.0,
          width: 400.0,
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.wallet_giftcard, color: Colors.black),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Text("Apply Discount ", style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 18.0),),
                      ),
                    ],
                  ),
                  Divider(),
                  Expanded(
                      child: Scrollbar(
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
                                child: Text('Discount Type',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),)
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                  //Add isDense true and zero Padding.
                                  //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  //Add more decoration as you want here
                                  //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                ),
                                isExpanded: true,
                                hint: const Text(
                                  'Select Discount Type', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black45,
                                ),
                                iconSize: 30,
                                items: _loadDiscount
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
                                    return 'Please select discount type!';
                                  }
                                },
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value;
                                    id = _loadDiscount.indexOf(value);
                                    print(id + 1);

                                    getDiscountID(selectedValue);
                                  });
                                  //Do something when changing the item if you want.
                                },
                                onSaved: (value) {
                                  selectedValue = value.toString();
                                  print(selectedValue);
                                },
                              ),
                            ),

                            Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                                child: Text('Full Name',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),)
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.done,
                                cursorColor: Colors.deepOrange.withOpacity(0.8),
                                controller: _name,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange.withOpacity(0.7),
                                        width: 2.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  hintText: 'Full Name ex. (Lastname, Firstname)',
                                  hintStyle: const TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some value!';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                                child: Text('ID. Picture',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),)
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child:InkWell(
                                onTap: (){
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  camera();
                                },
                                child: IgnorePointer(
                                  child: TextFormField(
                                    textInputAction: TextInputAction.done,
                                    cursorColor: Colors.deepOrange.withOpacity(0.5),
                                    controller: _imageTxt,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please capture an image!';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'No File Choosen',
                                      hintStyle: const TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                                      contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 25.0),
                                      prefixIcon: Icon(Icons.camera_alt_outlined,color: Colors.grey,),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.deepOrange.withOpacity(0.5),
                                            width: 2.0),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                                child: Text('ID. Number',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),)
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child:TextFormField(
                                cursorColor: Colors.deepOrange.withOpacity(0.8),
                                controller: _idNumber,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some value!';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'ID. Number',
                                  hintStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 25.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange.withOpacity(0.7),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  )
                ],
              )
          )
      ),
      actions: <Widget>[
        OutlinedButton(
          style: TextButton.styleFrom(
            primary: Colors.black,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          ),
          onPressed:(){
            Navigator.pop(context);
          },
          child:Text("CLOSE",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 12.0),),
        ),
        OutlinedButton(
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.deepOrangeAccent,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          ),
          onPressed:(){
            if (_formKey.currentState.validate()) {
              uploadId();
            }
            print(selectedValue);
            print(_name);
            print(_imageTxt);
            print(_idNumber);
          },
          child:Text("APPLY",style: GoogleFonts.openSans(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 12.0),),
        ),
      ],
    );
  }

  // showAddDiscountDialog(BuildContext context) {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return ApplyDiscountDialog();
  //     },
  //   );
  // }
}


Route addIds(){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => UploadSrImage(),
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

