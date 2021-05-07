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

  ViewItem({Key key, @required this.buCode, this.tenantCode,this.prodId,this.productUom, this.unitOfMeasure}) : super(key: key);
  @override
  _ViewItem createState() => _ViewItem();
}

class _ViewItem extends State<ViewItem>{
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final itemCount = TextEditingController();
//  bool _isLogged = false;
  List loadItemData;
  List loadFlavorData;
  List loadDrinksData;
  List loadFriesData;
  List loadSideData;
  List loadAddonsData;
  List checkLoadAddonsSideData;
  List checkLoadAddonDessertData;
  List addonSideData,loadAddonDessertSideData;

  var isLoading = true;
  var labelFlavor = "";
  var labelDrinks = "";
  var labelFries = "";
  var labelSides = "" ,checkLoadAddonsSideDataInt,checkLoadAddonDessertDataInt;
  var labelAddonSide = "";
  var labelAddonDessert = "";
  int flavorGroupValue ;
  int drinksGroupValue ;
  int friesGroupValue ;
  int sidesGroupValue ;
  int _counter = 1;
  int flavorId;
  int drinkId,drinkUom;
  int friesId,friesUom;
  int sideId,sideUom;

  var boolFlavorId = false;
  var boolDrinkId = false;
  var boolFriesId = false;
  var boolSideId = false;

  List<bool> side = new List<bool>();
  List<bool> dessert = new List<bool>();
  List<String> selectedSideItems = List();
  List<String> selectedSideItemsUom = List();
  List<String> selectedDessertItemsUom = List();
  List<String> selectedDessertItems = List();

  Future loadStore() async{
    setState(() {
      isLoading = true;
    });
    var res = await db.getItemDataCi(widget.prodId, widget.productUom);
    if (!mounted) return;
    setState(() {
      loadItemData = res['user_details'];
      isLoading = false;
      itemCount.text = "1";
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
      await db.addToCartCiTest(widget.buCode,widget.tenantCode,widget.prodId,widget.productUom,flavorId,drinkId,drinkUom,friesId,friesUom,sideId,sideUom,selectedSideItems,selectedSideItemsUom,selectedDessertItems,selectedDessertItemsUom,boolFlavorId,boolDrinkId,boolFriesId,boolSideId,_counter);
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

  Future loadFlavor() async{
    var res = await db.loadFlavor(widget.prodId);
    if (!mounted) return;
    setState(() {
      loadFlavorData = res['user_details'];

    });
  }

  Future loadDrinks() async{
    var res = await db.loadDrinks(widget.prodId);
    if (!mounted) return;
    setState(() {
      loadDrinksData = res['user_details'];
    });
  }

  Future loadFries() async{
    var res = await db.loadFries(widget.prodId);
    if (!mounted) return;
    setState((){
      loadFriesData = res['user_details'];
    });
  }

  Future  loadSide() async{
    var res = await db.loadSide(widget.prodId);
    if (!mounted) return;
    setState((){
      loadSideData = res['user_details'];
    });
  }

  Future checkAddon()async{
    var res = await db.checkAddon(widget.prodId);
    if (!mounted) return;
    setState((){
      checkLoadAddonsSideData = res['user_details'];
    });
  }

  Future addonSide() async{
    var res = await db.loadAddonSide(widget.prodId);
    if (!mounted) return;
    setState((){
      addonSideData = res['user_details'];

    });
  }

  Future addonDessert() async{
    var res = await db.loadAddonDessertSide(widget.prodId);
    if (!mounted) return;
    setState((){
      loadAddonDessertSideData = res['user_details'];

    });
  }

  @override
  void initState(){

    super.initState();
    loadStore();
    checkAddon();
    addonSide();
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
                            if(loadItemData[index]['no_flavor']!=null){
                              boolFlavorId = true;
                              labelFlavor = "Flavor";
                              loadFlavor();
                            }
                            if(loadItemData[index]['no_drinks']!=null){
                              boolDrinkId = true;
                              labelDrinks = "Select drinks";
                              loadDrinks();
                            }
                            if(loadItemData[index]['no_fries']!=null){
                              boolFriesId = true;
                              labelFries = "Fries";
                              loadFries();
                            }
                            if(loadItemData[index]['no_sides']!=null){
                              boolSideId = true;
                              labelSides = "Sides";
                              loadSide();
                            }
                            if(loadItemData[index]['variation']!=null){
                              checkAddon();
                            }
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
                                      Text("From",style: TextStyle(fontSize: 17,color: Colors.black,),),
                                      SizedBox(width: 10.0),
                                      Text('₱ ${loadItemData[index]['price'].toString()}', style: TextStyle(fontSize: 17,color: Colors.deepOrange,),),
                                    ],
                                  ),
                                ),
                                widget.unitOfMeasure != null ? Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                  child: new Text('Size : ${widget.unitOfMeasure}', style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 17.0),),
                                ):Container(),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                  child: new Text(loadItemData[index]['product_name'].toString(), style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 17.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                  child: new Text(loadItemData[index]['description'].toString(), style: GoogleFonts.openSans( fontStyle: FontStyle.normal,fontSize: 15.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                  child: new Text(labelFlavor, style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal,fontSize: 18.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:loadFlavorData == null ? 0 : loadFlavorData.length,
                                      itemBuilder: (BuildContext context, int index1) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  child: RadioListTile(
                                                    title: Text(loadFlavorData[index1]['add_on_flavors'],style: TextStyle(fontSize: 17,),),
                                                    value: index1,
                                                    groupValue: flavorGroupValue,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        flavorGroupValue = newValue;
                                                        flavorId = int.parse(loadFlavorData[index1]['flavor_id']);

                                                      });
                                                    },
                                                  ),
                                                ),
//                                              Padding(
//                                                padding: EdgeInsets.fromLTRB(10.0, 0.0, 15.0, 5.0),
//                                                child: Text(loadFlavorData[index]['add_on_flavors'],style: TextStyle(fontSize: 17,color: Colors.black54),),
//                                              ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 15.0, 10.0),
                                                  child:  Text('+ ₱ ${loadFlavorData[index1]['addon_price']}', style: TextStyle(fontSize: 17,),),
                                                ),

                                              ],
                                            )
                                          ],
                                        );
                                      }
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                  child: new Text(labelDrinks, style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal,fontSize: 18.0),),
                                ),

                                Padding(
                                  padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:loadDrinksData == null ? 0 : loadDrinksData.length,
                                      itemBuilder: (BuildContext context, int index2) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  child: RadioListTile(
                                                    title: Text("${loadDrinksData[index2]['product_name']} (${loadDrinksData[index2]['unit_measure']})",style: TextStyle(fontSize: 17,),),
                                                    value: index2,
                                                    groupValue: drinksGroupValue,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        drinksGroupValue = newValue;
                                                        drinkId = int.parse(loadDrinksData[index2]['drink_id']);
                                                        drinkUom = int.parse(loadDrinksData[index2]['uom_id']);
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 15.0, 10.0),
                                                  child:  Text('+ ₱ ${loadDrinksData[index2]['addon_price']}', style: TextStyle(fontSize: 17,),),
                                                ),
                                              ],
                                            )
                                          ],
                                        );
                                      }
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                  child: new Text(labelFries, style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal,fontSize: 18.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:loadFriesData == null ? 0 : loadFriesData.length,
                                      itemBuilder: (BuildContext context, int index3) {

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  child: RadioListTile(
                                                    title: Text('${loadFriesData[index3]['product_name']} ${loadFriesData[index3]['unit_measure']}',style: TextStyle(fontSize: 17,),),
                                                    value: index3,
                                                    groupValue: friesGroupValue,
                                                    onChanged: (newValue) {
                                                      setState((){
                                                        friesGroupValue = newValue;
                                                        friesId = int.parse(loadFriesData[index3]['fries_id']);
                                                        friesUom = int.parse(loadFriesData[index3]['uom_id']);
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 15.0, 10.0),
                                                  child:  Text('+ ₱ ${loadFriesData[index3]['addon_price']}', style: TextStyle(fontSize: 17,),),
                                                ),
                                              ],
                                            )
                                          ],
                                        );
                                      }
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                  child: new Text(labelSides, style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal,fontSize: 18.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:loadSideData == null ? 0 : loadSideData.length,
                                      itemBuilder: (BuildContext context, int index4) {

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  child: RadioListTile(
                                                    title: Text('${loadSideData[index4]['product_name']} ${loadSideData[index4]['unit_measure']}',style: TextStyle(fontSize: 17,),),
                                                    value: index4,
                                                    groupValue: sidesGroupValue,
                                                    onChanged: (newValue) {
                                                      setState((){
                                                        friesGroupValue = newValue;
                                                        sideId = int.parse(loadSideData[index4]['side_id']);
                                                        sideUom = int.parse(loadSideData[index4]['uom_id']);
                                                      });
                                                    },
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 15.0, 0.0),
                                                  child:  Text('+ ₱ ${loadSideData[index4]['addon_price']}', style: TextStyle(fontSize: 17,),),
                                                ),
                                              ],
                                            )
                                          ],
                                        );
                                      }
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 0.0),
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:checkLoadAddonsSideData == null ? 0 : checkLoadAddonsSideData.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        if(checkLoadAddonsSideData[index]['addon_sides']=='1'){
                                          labelAddonSide = "Side";
                                          addonSide();
                                        }if(checkLoadAddonsSideData[index]['addon_dessert']=='1'){
                                          labelAddonDessert = "Dessert";
                                          addonDessert();
                                        }
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                          ],
                                        );
                                      }
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 15.0, 5.0),
                                  child: Text(labelAddonSide,style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal,fontSize: 18.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:addonSideData == null ? 0 : addonSideData.length,
                                      itemBuilder: (BuildContext context, int index1) {
                                        side.add(false);
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CheckboxListTile(
                                              title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(addonSideData[index1]['product_name']),
                                                  Text('+ ₱ ${addonSideData[index1]['addon_price']}')
                                                ],
                                              ),
                                              value: side[index1],
                                              onChanged: (bool value){
                                                setState(() {
                                                  side[index1] = value;
//                                                   selectedItems.clear();
                                                  if (value) {
                                                    selectedSideItems.add(addonSideData[index1]['product_id']);
                                                    selectedSideItemsUom.add(addonSideData[index1]['uom_id']);
                                                  }
                                                  else{
                                                    selectedSideItems.remove(addonSideData[index1]['product_id']);
                                                    selectedSideItemsUom.remove(addonSideData[index1]['uom_id']);
                                                  }
                                                });
                                              },
                                              controlAffinity: ListTileControlAffinity.leading,
                                            ),
                                          ],
                                        );
                                      }
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 15.0, 5.0),
                                  child: Text(labelAddonDessert,style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal,fontSize: 18.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:loadAddonDessertSideData == null ? 0 : loadAddonDessertSideData.length,
                                      itemBuilder: (BuildContext context, int index1) {
                                        dessert.add(false);
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CheckboxListTile(
                                              title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(loadAddonDessertSideData[index1]['product_name']),
                                                  Text('+ ₱ ${loadAddonDessertSideData[index1]['addon_price']}')
                                                ],
                                              ),
                                              value: dessert[index1],
                                              onChanged: (bool value){
                                                dessert[index1] = value;
                                                setState(() {
                                                  if (value) {
                                                    selectedDessertItems.add(loadAddonDessertSideData[index1]['product_id']);
                                                    selectedDessertItemsUom.add(loadAddonDessertSideData[index1]['uom_id']);
                                                  }
                                                  else{
                                                    selectedDessertItems.remove(loadAddonDessertSideData[index1]['product_id']);
                                                    selectedDessertItemsUom.remove(loadAddonDessertSideData[index1]['uom_id']);
                                                  }

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