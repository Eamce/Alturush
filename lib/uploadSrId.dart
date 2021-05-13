import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sleek_button/sleek_button.dart';
import 'dart:io';
import 'dart:convert';
import 'db_helper.dart';
import 'create_account_signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadSrImage extends StatefulWidget {
  @override
  _UploadSrImage createState() => _UploadSrImage();
}

class _UploadSrImage extends State<UploadSrImage> {
  final db = RapidA();
  File _image;
  File _imageBooklet;
  String newFileName;
  final _idType = TextEditingController();
  final _name = TextEditingController();
  final _idNumber = TextEditingController();
  final _imageTxt = TextEditingController();

  final picker = ImagePicker();
  List<String> selectedImages = List();
  final _formKey = GlobalKey<FormState>();
  List loadDiscount;
  var discountId;

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


  bookletCamera() async{
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null){
        _imageBooklet = File(pickedFile.path);
        newFileName = _imageBooklet.toString();
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
      await db.uploadId(discountId,_name.text,_idNumber.text,base64Image);
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

   showDiscount() async{
    var res = await db.showDiscount();
    if (!mounted) return;
    setState(() {
      loadDiscount = res['user_details'];
    });
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          title: Text("Select Type"),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          content: Container(
            height:200.0, // Change as per your requirement
            width: 100.0, // Change as per your requirement
            child: Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: loadDiscount == null ? 0 : loadDiscount.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: (){
                      discountId = loadDiscount[index]['id'];
                      _idType.text = loadDiscount[index]['discount_name'];
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loadDiscount[index]['discount_name'],style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                         ],
                      ),
                      //                       child: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
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
        title: Text("Upload new ID",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                    child: new Text(
                      "ID type",
                      style: GoogleFonts.openSans(
                          fontStyle: FontStyle.normal, fontSize: 15.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    child:InkWell(
                      onTap: (){
                        FocusScope.of(context).requestFocus(FocusNode());
                        showDiscount();
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: _idType,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some value';
                            }
                            return null;
                          },
                          decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.deepOrange
                                      .withOpacity(0.8),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                    child: new Text(
                      "Full Name",
                      style: GoogleFonts.openSans(
                          fontStyle: FontStyle.normal, fontSize: 15.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric( horizontal: 30.0, vertical: 5.0),
                    child:TextFormField(
                      textInputAction: TextInputAction.done,
                      cursorColor: Colors.deepOrange.withOpacity(0.8),
                      controller: _name,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some value';
                        }
                        return null;
                      },
                      decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.deepOrange
                                  .withOpacity(0.8),
                              width: 2.0),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                    child: new Text(
                      "ID number",
                      style: GoogleFonts.openSans(
                          fontStyle: FontStyle.normal, fontSize: 15.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    child:TextFormField(
                      cursorColor: Colors.deepOrange.withOpacity(0.8),
                      controller: _idNumber,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some value';
                        }
                        return null;
                      },
                      decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.deepOrange.withOpacity(0.8),
                              width: 2.0),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(35, 15, 5, 0),
                    child: new Text(
                      "Upload id image",
                      style: GoogleFonts.openSans(
                          fontStyle: FontStyle.normal, fontSize: 15.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    child:InkWell(
                      onTap: (){
                        FocusScope.of(context).requestFocus(FocusNode());
                        camera();
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: _imageTxt,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please capture an image';
                            }
                            return null;
                          },
                          decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                            prefixIcon: Icon(Icons.camera_alt_outlined,color: Colors.grey,),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.8),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                      if (_formKey.currentState.validate()) {
                        uploadId();
                      }
                    },
                    style: SleekButtonStyle.flat(
                      color: Colors.deepOrange,
                      inverted: false,
                      rounded: false,
                      size: SleekButtonSize.big,
                      context: context,
                    ),
                    child: Center(
                      child: Text("Save", style:TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 13.0),
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
