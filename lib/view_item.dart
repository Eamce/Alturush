import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_signin.dart';
import 'package:intl/intl.dart';
import 'search.dart';

class ViewItem extends StatefulWidget {
  final buCode;
  final tenantCode;
  final prodId;
  final productUom;
  final unitOfMeasure;
  final price;
  final globalID;

  ViewItem({Key key, @required this.buCode, this.tenantCode,this.prodId,this.productUom, this.unitOfMeasure, this.price, this.globalID}) : super(key: key);
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
  String choiceUomIdDrinks,choiceIdDrinks,choicePriceDrinks;
  String choiceUomIdFries,choiceIdFries,choicePriceFries;
  String choiceUomIdSides,choiceIdSides,choicePriceSides;
  String flavorId,flavorPrice,uniOfMeasure;
  String variation;

  // ignore: deprecated_member_use
  List<String> selectedSideOnPrice = List();
  // ignore: deprecated_member_use
  List<String> selectedSideItems = List();
  // ignore: deprecated_member_use
  List<String> selectedSideItemsUom = List();

  int choiceDrinksGroupValue;
  int choiceFriesGroupValue;
  int choiceSidesGroupValue;
  int uomDataGroupValue ;
  int flavorDataGroupValue;

  List addonSidesData;
  List addonDessertData;
  List addonDrinksData;
  List choicesDrinksData;
  List choicesFriesData;
  List choicesSidesData;
  List uomData;
  List flavorData;

  bool addonSidesDataVisible;
  bool addonDessertDataVisible;
  bool addonDrinksDataVisible;
  bool choicesDrinksVisible;
  bool choicesFriesVisible;
  bool choicesSidesVisible;
  bool uomDataVisible;
  bool flavorDataVisible;

  var index = 0;
  String sides;

  Future loadStore() async{
    addonSidesDataVisible = true;
    addonDessertDataVisible = true;
    addonDrinksDataVisible = true;
    choicesDrinksVisible = true;
    choicesFriesVisible = true;
    choicesSidesVisible = true;
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
      addonSidesData = loadItemData[1]['addon_sides_data'];
      addonDessertData = loadItemData[2]['addon_dessert_data'];
      addonDrinksData = loadItemData[3]['addon_drinks_data'];
      choicesDrinksData = loadItemData[4]['choices_drinks_data'];
      choicesFriesData = loadItemData[5]['choices_fries_data'];
      choicesSidesData = loadItemData[6]['choices_sides_data'];
      uomData = loadItemData[7]['uom_data'];
      flavorData = loadItemData[8]['flavor_data'];

      print(loadItemData);

      // sides = loadItemData[index1]['addon_sides'];

      if(addonSidesData.toString() == '[[]]'){
        addonSidesDataVisible = false;
      }
      if(addonDessertData.toString() == '[[]]'){
        addonDessertDataVisible = false;
      }
      if(addonDrinksData.toString() == '[[]]'){
        addonDrinksDataVisible = false;
      }

      if(choicesDrinksData.toString() == '[[]]'){
        choicesDrinksVisible = false;
      } else{
        for(int q = 0;q<choicesDrinksData.length;q++) {
            if (choicesDrinksData[q]['default'] == '1') {
                choiceDrinksGroupValue = q;
                choiceUomIdDrinks = choicesDrinksData[q]['uom_id'];
                choiceIdDrinks = choicesDrinksData[q]['sub_productid'];
                choicePriceDrinks = choicesDrinksData[q]['addon_price'];
                break;
            }
        }
      }

      if(choicesFriesData.toString() == '[[]]'){
        choicesFriesVisible = false;
      } else{
        for(int q = 0;q<choicesFriesData.length;q++) {
          if (choicesFriesData[q]['default'] == '1') {
            choiceFriesGroupValue = q;
            choiceUomIdFries = choicesFriesData[q]['uom_id'];
            choiceIdFries = choicesFriesData[q]['sub_productid'];
            choicePriceFries = choicesFriesData[q]['addon_price'];
            break;
          }
        }
      }

      if(choicesSidesData.toString() == '[[]]'){
        choicesSidesVisible = false;
      } else{
        for(int i = 0;i<choicesSidesData.length;i++) {
          if (choicesSidesData[i]['default'] == '1') {
            choiceSidesGroupValue = i;
            choiceUomIdSides = choicesSidesData[i]['uom_id'];
            choiceIdSides = choicesSidesData[i]['sub_productid'];
            choicePriceSides = choicesSidesData[i]['addon_price'];
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
      await db.addToCartNew(
          widget.prodId,
          uomId,_counter,
          uomPrice,
          choiceUomIdDrinks,
          choiceIdDrinks,
          choicePriceDrinks,
          choiceUomIdFries,
          choiceIdFries,
          choicePriceFries,
          choiceUomIdSides,
          choiceIdSides,
          choicePriceSides,
          flavorId,
          flavorPrice,
          selectedSideOnPrice,
          selectedSideItems,
          selectedSideItemsUom);
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
    side1.clear();
    side2.clear();
    side3.clear();
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
          title: Text("Details",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.search_outlined, color: Colors.black),
                onPressed: () async {
                  Navigator.of(context).push(_search());
                }
            ),
            // IconButton(
            //     icon: Icon(Icons.info_outline, color: Colors.black),
            //     onPressed: () async {
            //
            //     }
            // ),
          ],
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
                          if (loadItemData[index]['variation'] == null){
                            variation = '';
                          } else {
                            variation = loadItemData[index]['variation'];
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:[
                              Center(
                                child: Image.network(loadItemData[index]['image'],height: 190.0,scale:1.2),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 5.0),
                                child: new Text(loadItemData[index]['product_name'].toString(), style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
                              ),
                              Padding(
                                padding:EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 5.0),
                                child: Text('₱ $uomPrice', style: TextStyle(fontSize: 15,color: Colors.deepOrange,),)
                              ),
                              Padding(
                                  padding:EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 5.0),
                                  child: Text(variation, style: TextStyle(fontSize: 15),)
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 5.0),
                                child: new Text(loadItemData[index]['description'].toString(), style: GoogleFonts.openSans( fontStyle: FontStyle.normal,fontSize: 14.0),),
                              ),

                              Divider(color: Colors.deepOrangeAccent,),

                              Visibility(
                                visible:uomDataVisible,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                      child: Text("Change size",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                                      child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:uomData == null ? 0 : uomData.length,
                                        itemBuilder: (BuildContext context, int index2) {
                                          String uomName = "";

                                          if(uomData[index2]['unit']!=null){
                                            uomName = uomData[index2]['unit'].toString();
                                          }
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    child: SizedBox(height: 35,
                                                      child: RadioListTile(
                                                        contentPadding: EdgeInsets.all(0),
                                                        activeColor: Colors.deepOrange,
                                                        // title: Text('${uomData[index3]['price_productname']} $uomName  ₱ ${uomData[index3]['price']}',style: TextStyle(fontSize: 17,),),
                                                        title: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text('${uomData[index2]['price_productname']}  $uomName', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                            Text('₱ ${uomData[index2]['price']}', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                          ],
                                                        ),
                                                        value: index2,
                                                        groupValue: uomDataGroupValue,
                                                        onChanged: (newValue) {
                                                          setState((){
                                                            uomDataGroupValue = newValue;
                                                            uomPrice = uomData[index2]['price'];
                                                            uomId = uomData[index2]['uom_id'];
                                                          });
                                                        },
                                                      )
                                                    )
                                                  ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                      child: Text("Add flavor",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                                      child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:flavorData == null ? 0 : flavorData.length,
                                        itemBuilder: (BuildContext context, int index3) {
                                          String uomName = "";

                                          String flavorPriceD;
                                          if(flavorData[index3]['price'] == '0.00'){
                                            flavorPriceD = "";
                                          }else{
                                            flavorPriceD ='+ ₱ ${flavorData[index3]['price']}';
                                          }
                                          if(flavorData[index3]['unit']!=null){
                                            uomName = flavorData[index3]['unit'].toString();
                                          }
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    child: SizedBox(height: 35,
                                                      child: RadioListTile(
                                                        contentPadding: EdgeInsets.all(0),
                                                        activeColor: Colors.deepOrange,
                                                        // title: Text('${uomData[index3]['price_productname']} $uomName  ₱ ${uomData[index3]['price']}',style: TextStyle(fontSize: 17,),),
                                                        title: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text('${flavorData[index3]['flavor_name']}  $uomName', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                            Text('$flavorPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                          ],
                                                        ),
                                                        value: index3,
                                                        groupValue: flavorDataGroupValue,
                                                        onChanged: (newValue) {
                                                          setState((){
                                                            flavorDataGroupValue = newValue;
                                                            flavorId = flavorData[index3]['flavor_id'];
                                                            flavorPrice = flavorData[index3]['price'];
                                                          });
                                                        },
                                                      )
                                                    )
                                                  ),
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
                                visible:choicesDrinksVisible,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                      child: Column(
                                        children: [
                                          Text("1-pc Choice of Drinks",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
                                          Text("Select 1",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                        ],
                                      )

                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                                      child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:choicesDrinksData == null ? 0 : choicesDrinksData.length,
                                          itemBuilder: (BuildContext context, int index4) {
                                            String uomName = "";
                                            String sidePrice;
                                            if(choicesDrinksData[index4]['addon_price'] == '0.00'){
                                              sidePrice = "";
                                            }else{
                                              sidePrice ='+ ₱ ${choicesDrinksData[index4]['addon_price']}';
                                            }
                                            if(choicesDrinksData[index4]['unit']!=null){
                                              uomName = choicesDrinksData[index4]['unit'].toString();
                                            }
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      fit: FlexFit.loose,
                                                      child: SizedBox(height: 35,
                                                        child: RadioListTile(
                                                          contentPadding: EdgeInsets.all(0),
                                                          activeColor: Colors.deepOrange,
                                                          // title: Text('${choicesData[index2]['sub_productname']} $uomName + ₱ ${choicesData[index2]['addon_price']}',style: TextStyle(fontSize: 17,),),
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text('${choicesDrinksData[index4]['sub_productname']}  $uomName', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                              Text('$sidePrice', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                            ],
                                                          ),
                                                          value: index4,
                                                          groupValue: choiceDrinksGroupValue,
                                                          onChanged: (newValue) {
                                                            setState((){
                                                              choiceDrinksGroupValue = newValue;
                                                              choiceUomIdDrinks = choicesDrinksData[index4]['uom_id'];
                                                              choiceIdDrinks = choicesDrinksData[index4]['sub_productid'];
                                                              choicePriceDrinks = choicesDrinksData[index4]['addon_price'];
                                                              // print('${choicesDrinksData[index4]['sud_producname'].toString()}');
                                                            });
                                                          },
                                                        ))
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
                                visible:choicesFriesVisible,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                        child: Column(
                                          children: [
                                            Text("1-pc Choice of Fries",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
                                            Text("Select 1",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                          ],
                                        )

                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                                      child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:choicesFriesData == null ? 0 : choicesFriesData.length,
                                          itemBuilder: (BuildContext context, int index5) {
                                            String uomName = "";
                                            String sidePrice;
                                            if(choicesFriesData[index5]['addon_price'] == '0.00'){
                                              sidePrice = "";
                                            }else{
                                              sidePrice ='+ ₱ ${choicesFriesData[index5]['addon_price']}';
                                            }
                                            if(choicesFriesData[index5]['unit']!=null){
                                              uomName = choicesFriesData[index5]['unit'].toString();
                                            }
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      fit: FlexFit.loose,
                                                      child: SizedBox(height: 35,
                                                        child: RadioListTile(
                                                          contentPadding: EdgeInsets.all(0),
                                                          activeColor: Colors.deepOrange,
                                                          // title: Text('${choicesData[index2]['sub_productname']} $uomName + ₱ ${choicesData[index2]['addon_price']}',style: TextStyle(fontSize: 17,),),
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text('${choicesFriesData[index5]['sub_productname']}  $uomName', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                              Text('$sidePrice', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                            ],
                                                          ),
                                                          value: index5,
                                                          groupValue: choiceFriesGroupValue,
                                                          onChanged: (newValue) {
                                                            setState((){
                                                              choiceFriesGroupValue = newValue;
                                                              choiceUomIdFries = choicesFriesData[index5]['uom_id'];
                                                              choiceIdFries = choicesFriesData[index5]['sub_productid'];
                                                              choicePriceFries = choicesFriesData[index5]['addon_price'];
                                                              // print('${choicesFriesData[index5]['sud_producname'].toString()}');
                                                            });
                                                          },
                                                        )
                                                      )
                                                    ),
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
                                visible:choicesSidesVisible,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                      child: Column(
                                        children: [
                                          Text("1-pc Choice of Sides",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
                                          Text("Select 1",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                        ],
                                      )
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                                      child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:choicesSidesData == null ? 0 : choicesSidesData.length,
                                          itemBuilder: (BuildContext context, int index6) {
                                            String uomName = "";
                                            String sidePrice;
                                            if(choicesSidesData[index6]['addon_price'] == '0.00'){
                                              sidePrice = "";
                                            }else{
                                              sidePrice ='+ ₱ ${choicesSidesData[index6]['addon_price']}';
                                            }
                                            if(choicesSidesData[index6]['unit']!=null){
                                              uomName = choicesSidesData[index6]['unit'].toString();
                                            }
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      fit: FlexFit.loose,
                                                      child: SizedBox(height: 35,
                                                        child: RadioListTile(
                                                          contentPadding: EdgeInsets.all(0),
                                                          activeColor: Colors.deepOrange,
                                                          // title: Text('${choicesData[index2]['sub_productname']} $uomName + ₱ ${choicesData[index2]['addon_price']}',style: TextStyle(fontSize: 17,),),
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text('${choicesSidesData[index6]['sub_productname']}  $uomName', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                              Text('$sidePrice', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                            ],
                                                          ),
                                                          value: index6,
                                                          groupValue: choiceSidesGroupValue,
                                                          onChanged: (newValue1) {
                                                            setState((){
                                                              choiceSidesGroupValue = newValue1;
                                                              choiceUomIdSides = choicesSidesData[index6]['uom_id'];
                                                              choiceIdSides = choicesSidesData[index6]['sub_productid'];
                                                              choicePriceSides = choicesSidesData[index6]['addon_price'];
                                                              // print('${choicesSidesData[index6]['sud_producname'].toString()}');
                                                            });
                                                          },
                                                        ),
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
                                visible:addonDrinksDataVisible,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 0.0),
                                      child: Text("Add-on Drink(s)",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                                      child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:addonDrinksData == null ? 0 : addonDrinksData.length,
                                          itemBuilder: (BuildContext context, int index7) {
                                            String uomName = "";
                                            String addonPrice = addonDrinksData[index7]['addon_price'];
                                            if(addonPrice == '0.00'){
                                              addonPrice = "";
                                            }
                                            if(addonDrinksData[index7]['unit']!=null){
                                              uomName = addonDrinksData[index7]['unit'];
                                            }
                                            side1.add(false);
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 35,
                                                  child: CheckboxListTile(
                                                    contentPadding: EdgeInsets.all(0),
                                                    activeColor: Colors.deepOrange,
                                                    title: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text('${addonDrinksData[index7]['sub_productname']}  $uomName', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                        Text('+ ₱ $addonPrice', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14))
                                                      ],
                                                    ),
                                                    value: side1[index7],
                                                    onChanged: (bool value1){
                                                      setState(() {
                                                        side1[index7] = value1;
                                                        // selectedSideItems.clear();
                                                        // selectedSideItemsUom.clear();
                                                        if (value1) {
                                                          selectedSideOnPrice.add(addonDrinksData[index7]['addon_price']);
                                                          selectedSideItems.add(addonDrinksData[index7]['sub_productid']);
                                                          selectedSideItemsUom.add(addonDrinksData[index7]['uom_id']);

                                                        }else{
                                                          selectedSideOnPrice.remove(addonDrinksData[index7]['addon_price']);
                                                          selectedSideItems.remove(addonDrinksData[index7]['sub_productid']);
                                                          selectedSideItemsUom.remove(addonDrinksData[index7]['uom_id']);

                                                        }
                                                      });
                                                    },
                                                    controlAffinity: ListTileControlAffinity.leading,
                                                  ),
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
                                visible:addonDessertDataVisible,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                      child: Text("Add-on Dessert(s)",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                                      child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:addonDessertData == null ? 0 : addonDessertData.length,
                                          itemBuilder: (BuildContext context, int index8) {
                                            String uomName = "";
                                            String addonPrice = addonDessertData[index8]['addon_price'];
                                            if(addonPrice == '0.00'){
                                              addonPrice = "";
                                            }
                                            if(addonDessertData[index8]['unit']!=null){
                                              uomName = addonDessertData[index8]['unit'];
                                            }
                                            side2.add(false);
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 35,
                                                  child: CheckboxListTile(
                                                    contentPadding: EdgeInsets.all(0),
                                                    activeColor: Colors.deepOrange,
                                                    title: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text('${addonDessertData[index8]['sub_productname']}  $uomName', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                        Text('+ ₱ $addonPrice', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14))
                                                      ],
                                                    ),
                                                    value: side2[index8],
                                                    onChanged: (bool value2){
                                                      setState(() {
                                                        side2[index8] = value2;
                                                        // selectedSideItems.clear();
                                                        // selectedSideItemsUom.clear();
                                                        if (value2) {
                                                          selectedSideOnPrice.add(addonDessertData[index8]['addon_price']);
                                                          selectedSideItems.add(addonDessertData[index8]['sub_productid']);
                                                          selectedSideItemsUom.add(addonDessertData[index8]['uom_id']);

                                                        }else{
                                                          selectedSideOnPrice.remove(addonDessertData[index8]['addon_price']);
                                                          selectedSideItems.remove(addonDessertData[index8]['sub_productid']);
                                                          selectedSideItemsUom.remove(addonDessertData[index8]['uom_id']);

                                                        }
                                                      });
                                                    },
                                                    controlAffinity: ListTileControlAffinity.leading,
                                                  ),
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
                                visible:addonSidesDataVisible,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                      child: Text("Add-on Side(s)",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                                      child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:addonSidesData == null ? 0 : addonSidesData.length,
                                        itemBuilder: (BuildContext context, int index9) {
                                          String uomName = "";
                                          String addonPrice = addonSidesData[index9]['addon_price'];
                                          if(addonPrice == '0.00'){
                                            addonPrice = "";
                                          }
                                          if(addonSidesData[index9]['unit']!=null){
                                            uomName = addonSidesData[index9]['unit'];
                                          }
                                          side3.add(false);
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 35,
                                                child: CheckboxListTile(
                                                  contentPadding: EdgeInsets.all(0),
                                                  activeColor: Colors.deepOrange,
                                                  title: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('${addonSidesData[index9]['sub_productname']}  $uomName', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
                                                      Text('+ ₱ $addonPrice', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14))
                                                    ],
                                                  ),
                                                  value: side3[index9],
                                                  onChanged: (bool value3){
                                                    setState(() {
                                                      side3[index9] = value3;
                                                      // selectedSideItems.clear();
                                                      // selectedSideItemsUom.clear();
                                                      if (value3) {
                                                        selectedSideOnPrice.add(addonSidesData[index9]['addon_price']);
                                                        selectedSideItems.add(addonSidesData[index9]['sub_productid']);
                                                        selectedSideItemsUom.add(addonSidesData[index9]['uom_id']);

                                                      }else{
                                                        selectedSideOnPrice.remove(addonSidesData[index9]['addon_price']);
                                                        selectedSideItems.remove(addonSidesData[index9]['sub_productid']);
                                                        selectedSideItemsUom.remove(addonSidesData[index9]['uom_id']);

                                                      }
                                                    });
                                                  },
                                                  controlAffinity: ListTileControlAffinity.leading,
                                                )
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
                          // print(selectedSideOnPrice);
                        },
                        style: SleekButtonStyle.flat(
                          color: Colors.deepOrange,
                          inverted: false,
                          rounded: true,
                          size: SleekButtonSize.big,
                          context: context,
                        ),
                        child: Center(
                          child:Text("ADD TO CART", style: TextStyle(
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

Route _search() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Search(),
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