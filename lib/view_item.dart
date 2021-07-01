import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_signin.dart';
import 'package:intl/intl.dart';

class ViewItem extends StatefulWidget {
  final buCode;
  final tenantCode;
  final prodId;
  final productUom;
  final unitOfMeasure;
  final price;

  ViewItem({Key key, @required this.buCode, this.tenantCode,this.prodId,this.productUom, this.unitOfMeasure, this.price}) : super(key: key);
  @override
  _ViewItem createState() => _ViewItem();
}

class _ViewItem extends State<ViewItem>{
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final itemCount = TextEditingController();

  List loadItemData;
  var isLoading = true;
  int _counter = 1;

  String uomId,uomPrice;
  String choiceUomId,choiceId,choicePrice;
  String flavorId,flavorPrice,uniOfMeasure;

  List<String> selectedSideOnPrice = List();
  List<String> selectedSideItems = List();
  List<String> selectedSideItemsUom = List();

  int choiceDataGroupValue;
  int uomDataGroupValue ;
  int flavorDataGroupValue;

  List addonData;
  List choicesData;
  List uomData;
  List flavorData;

  bool addonDataVisible;
  bool choicesDataVisible;
  bool uomDataVisible;
  bool flavorDataVisible;

  Future loadStore() async{
    addonDataVisible = true;
    choicesDataVisible = true;
    uomDataVisible = true;
    flavorDataVisible = true;

    uomId = widget.productUom;
    uomPrice = widget.price;
    setState(() {
      isLoading = true;
    });
    var res = await db.getItemDataCi(widget.prodId, widget.productUom);
    if (!mounted) return;
    setState(() {
      loadItemData = res['user_details'];
      isLoading = false;
      itemCount.text = "1";
      addonData = loadItemData[1]['addon_data'];
      choicesData = loadItemData[2]['choices_data'];
      uomData = loadItemData[3]['uom_data'];
      flavorData = loadItemData[4]['flavor_data'];

      if(addonData.toString() == '[[]]'){
        addonDataVisible = false;
      }
      if(choicesData.toString() == '[[]]'){
        choicesDataVisible = false;
      }
      else{
        for(int q = 0;q<choicesData.length;q++) {
            if (choicesData[q]['default'] == '1') {
                choiceDataGroupValue = q;
                choiceUomId = choicesData[q]['uom_id'];
                choiceId = choicesData[q]['sub_productid'];
                choicePrice = choicesData[q]['addon_price'];
                print(choiceId);
                break;
            }
        }
      }

      if(uomData.toString() == '[[]]' || uomData.length == 1){
        uomDataVisible = false;
      }
      else{
        for(int q = 0;q<uomData.length;q++) {
            if (uomData[q]['default'] == '1') {
              uomDataGroupValue = q;
              uomId = uomData[q]['uom_id'];
              break;
            }
        }
      }


      if(flavorData.toString() == '[[]]'){
        flavorDataVisible = false;
      }
      else{
        for(int q = 0;q<flavorData.length;q++) {
            if (flavorData[q]['default'] == '1') {
              flavorDataGroupValue = q;
              flavorId = flavorData[q]['flavor_id'];
              flavorPrice = flavorData[q]['price'];
              print(flavorPrice);
              break;
            }
          // print(q);
        }
      }

    });
  }

  Future addToCart() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }
    else{
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return  AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))
            ),
            contentPadding: EdgeInsets.symmetric(horizontal:1.0, vertical: 20.0),
            title:Row(
              children: <Widget>[
                Text('Hooray!',style:TextStyle(fontSize: 18.0),),
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Padding(
                    padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child:Center(child:Text("Successfully added to cart")),
                  ),

                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Done',style: TextStyle(
                  color: Colors.deepOrange,
                ),),
                onPressed: () async{
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      // print(widget.buCode);
      // print(widget.prodId);
      // print(widget.productUom);
      //
      // print(choiceUomId);
      // print(choiceId);
      // print(uomId);
      // print(flavorId);
      // print(selectedSideItems);
      // print(selectedSideItemsUom);
      // print(_counter);
      // await db.addToCartCiTest(widget.buCode,widget.tenantCode,widget.prodId,widget.productUom,flavorId,drinkId,drinkUom,friesId,friesUom,sideId,sideUom,selectedSideItems,selectedSideItemsUom,selectedDessertItems,selectedDessertItemsUom,boolFlavorId,boolDrinkId,boolFriesId,boolSideId,_counter);
      await db.addToCartNew(widget.prodId,uomId,_counter,uomPrice,choiceUomId,choiceId,choicePrice,flavorId,flavorPrice,selectedSideOnPrice,selectedSideItems,selectedSideItemsUom);
    }
  }


  void _decrementCounter() {
    setState(() {
      _counter--;
      itemCount.text = _counter.toString();
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _incrementCounter(){
    setState((){
      _counter++;
      itemCount.text = _counter.toString();
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void initState(){
    super.initState();
    uniOfMeasure = widget.unitOfMeasure;
    side.clear();
    loadStore();
  }

  @override
  void dispose(){
    super.dispose();
    itemCount.dispose();
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
          iconTheme: new IconThemeData(color: Colors.black),
          title: Text("Customize",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) : Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadStore,
                child:Scrollbar(
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children:[
                      ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index){
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                                Center(
                                  child: Image.network(loadItemData[index]['image'],height: 250.0,scale:1.8),
                                ),
                                Padding(
                                  padding:EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                  child: Row(
                                    children:[

                                      Text('₱ $uomPrice', style: TextStyle(fontSize: 20,color: Colors.deepOrange,),),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                  child: new Text(loadItemData[index]['product_name'].toString(), style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 17.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                  child: new Text(loadItemData[index]['description'].toString(), style: GoogleFonts.openSans( fontStyle: FontStyle.normal,fontSize: 15.0),),
                                ),
                                Divider(

                                ),
                                Visibility(
                                  visible:addonDataVisible,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
                                        child: Text("Select add-ons",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:addonData == null ? 0 : addonData.length,
                                            itemBuilder: (BuildContext context, int index1) {
                                              String uomName = "";
                                              if(addonData[index1]['unit']!=null){
                                                uomName = addonData[index1]['unit'];
                                              }
                                              side.add(false);
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CheckboxListTile(
                                                    activeColor: Colors.deepOrange,
                                                    title: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text('${addonData[index1]['sub_productname']}  $uomName'),
                                                        Text('+ ₱ ${addonData[index1]['addon_price']}')
                                                      ],
                                                    ),
                                                    value: side[index1],
                                                    onChanged: (bool value){
                                                      setState(() {
                                                        side[index1] = value;
                                                         // selectedSideItems.clear();
                                                        // selectedSideItemsUom.clear();
                                                        if (value) {
                                                          selectedSideOnPrice.add(addonData[index1]['addon_price']);
                                                          selectedSideItems.add(addonData[index1]['sub_productid']);
                                                          selectedSideItemsUom.add(addonData[index1]['uom_id']);
                                                        }
                                                        else{
                                                          selectedSideOnPrice.remove(addonData[index1]['addon_price']);
                                                          selectedSideItems.remove(addonData[index1]['sub_productid']);
                                                          selectedSideItemsUom.remove(addonData[index1]['uom_id']);
                                                        }
                                                        print(selectedSideItems);
                                                      });
                                                    },
                                                    controlAffinity: ListTileControlAffinity.leading,
                                                  ),
                                                ],
                                              );
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Visibility(
                                  visible:choicesDataVisible,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
                                        child: Text("Select side",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:choicesData == null ? 0 : choicesData.length,
                                            itemBuilder: (BuildContext context, int index2) {
                                              String uomName = "";
                                              if(choicesData[index2]['unit']!=null){
                                                uomName = choicesData[index2]['unit'].toString();
                                              }
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        fit: FlexFit.loose,
                                                        child: RadioListTile(
                                                          activeColor: Colors.deepOrange,
                                                          // title: Text('${choicesData[index2]['sub_productname']} $uomName + ₱ ${choicesData[index2]['addon_price']}',style: TextStyle(fontSize: 17,),),
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text('${choicesData[index2]['sub_productname']}  $uomName'),
                                                              Text('+ ₱ ${choicesData[index2]['addon_price']}'),
                                                            ],
                                                          ),
                                                          value: index2,
                                                          groupValue: choiceDataGroupValue,
                                                          onChanged: (newValue) {
                                                            setState((){
                                                              choiceDataGroupValue = newValue;
                                                              choiceUomId = choicesData[index2]['uom_id'];
                                                              choiceId = choicesData[index2]['sub_productid'];
                                                              choicePrice = choicesData[index2]['addon_price'];
                                                              print(choiceId);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      // Padding(
                                                      //   padding: EdgeInsets.fromLTRB(20.0, 0.0, 15.0, 0.0),
                                                      //   child:  Text('+ ₱ ${choicesData[index2]['addon_price']}', style: TextStyle(fontSize: 17,),),
                                                      // ),
                                                    ],
                                                  )
                                                ],
                                              );
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:uomDataVisible,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
                                        child: Text("Change size",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:uomData == null ? 0 : uomData.length,
                                            itemBuilder: (BuildContext context, int index3) {
                                              String uomName = "";
                                              if(uomData[index3]['unit']!=null){
                                                uomName = uomData[index3]['unit'].toString();
                                              }
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        fit: FlexFit.loose,
                                                        child: RadioListTile(
                                                          activeColor: Colors.deepOrange,
                                                          // title: Text('${uomData[index3]['price_productname']} $uomName  ₱ ${uomData[index3]['price']}',style: TextStyle(fontSize: 17,),),
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text('${uomData[index3]['price_productname']}  $uomName'),
                                                              Text('₱ ${uomData[index3]['price']}'),
                                                            ],
                                                          ),
                                                          value: index3,
                                                          groupValue: uomDataGroupValue,
                                                          onChanged: (newValue) {
                                                            setState((){
                                                              uomDataGroupValue = newValue;
                                                              uomPrice = uomData[index3]['price'];
                                                              uomId = uomData[index3]['uom_id'];
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      // Padding(
                                                      //   padding: EdgeInsets.fromLTRB(20.0, 0.0, 15.0, 0.0),
                                                      //   child:  Text('+ ₱ ${choicesData[index2]['addon_price']}', style: TextStyle(fontSize: 17,),),
                                                      // ),
                                                    ],
                                                  )
                                                ],
                                              );
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Visibility(
                                  visible:flavorDataVisible,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
                                        child: Text("Add flavor",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:flavorData == null ? 0 : flavorData.length,
                                            itemBuilder: (BuildContext context, int index4) {
                                              String uomName = "";
                                              if(flavorData[index4]['unit']!=null){
                                                uomName = flavorData[index4]['unit'].toString();
                                              }
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        fit: FlexFit.loose,
                                                        child: RadioListTile(
                                                          activeColor: Colors.deepOrange,
                                                          // title: Text('${uomData[index3]['price_productname']} $uomName  ₱ ${uomData[index3]['price']}',style: TextStyle(fontSize: 17,),),
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text('${flavorData[index4]['flavor_name']}  $uomName'),
                                                              Text('₱ ${flavorData[index4]['price']}'),
                                                            ],
                                                          ),
                                                          value: index4,
                                                          groupValue: flavorDataGroupValue,
                                                          onChanged: (newValue) {
                                                            setState((){
                                                              flavorDataGroupValue = newValue;
                                                              flavorId = flavorData[index4]['flavor_id'];
                                                              flavorPrice = flavorData[index4]['price'];
                                                              print(flavorPrice);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      // Padding(
                                                      //   padding: EdgeInsets.fromLTRB(20.0, 0.0, 15.0, 0.0),
                                                      //   child:  Text('+ ₱ ${choicesData[index2]['addon_price']}', style: TextStyle(fontSize: 17,),),
                                                      // ),
                                                    ],
                                                  )
                                                ],
                                              );
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            );
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: _counter == 1 ? null : _decrementCounter,
                      child: new Text('-',style: TextStyle(fontSize: 20,color: Colors.deepOrange,),),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    ),
                    Text(_counter.toString()),
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    ),
                    TextButton(
                      onPressed: _counter == 999 ? null : _incrementCounter,
                      child: new Text('+',style: TextStyle(fontSize: 20,color: Colors.deepOrange,),),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 20, 5, 5),
                    ),
                    Flexible(
                      child: SleekButton(
                        onTap: () async{
                          addToCart();
                        },
                        style: SleekButtonStyle.flat(
                          color: Colors.deepOrange,
                          inverted: false,
                          rounded: false,
                          size: SleekButtonSize.big,
                          context: context,
                        ),
                        child: Center(
                          child:Text("Add to cart", style: TextStyle(
                              shadows: [
                                Shadow(
                                  blurRadius: 1.0,
                                  color: Colors.black54,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0),),
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ],
        ),
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