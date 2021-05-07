import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../create_account_signin.dart';
import 'package:intl/intl.dart';

class ViewItem extends StatefulWidget {
  final prodId;
  final prodName;
  final image;
  final itemCode;
  final price;
  final uom;
  final uomId;
  final buCode;

  ViewItem({Key key, @required this.prodId, this.prodName,this.image,this.itemCode,this.price,this.uom,this.uomId,this.buCode}) : super(key: key);
  @override
  _ViewItem createState() => _ViewItem();
}

class _ViewItem extends State<ViewItem>  {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final itemCount = TextEditingController();
  int _counter = 1;
  List getUomList;
  var imageLoading = true;
//  bool _isLogged = false;

  Future getUom() async{
    var res = await db.getUom(widget.itemCode);
    if (!mounted) return;
    setState(() {
      getUomList = res['user_details'];
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
      await db.addToCartGc(widget.buCode,widget.prodId,widget.itemCode,uomTemp,widget.uomId,_counter);
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
  var priceTemp;
  var uomTemp;
  var isLoading = true;
  @override
  void initState(){
    isLoading = false;
    imageLoading = false;
    getUom();
    super.initState();
    uomTemp =  widget.uom;
    priceTemp = widget.price;
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
              child: Scrollbar(
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
                              imageLoading
                                  ? Padding(
                                    padding:EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 60.0),
                                    child: Center(
                                child: CircularProgressIndicator(
                                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                                   ),
                                  ),
                                ) : Center(
                                child: Image.network(widget.image,height: 250.0,scale:1.8),
                              ),
                              Padding(
                                padding:EdgeInsets.fromLTRB(20.0, 10.0, 5.0, 5.0),
                                child: Row(
                                  children:[
                                    Text("Price:",style: TextStyle(fontSize: 17,color: Colors.black,),),
                                    SizedBox(width: 10.0),
                                    Text('₱ ${priceTemp.toString()}', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.deepOrange,),),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                child: Row(
                                  children:[
                                    Text("UOM:",style: TextStyle(fontSize: 17,color: Colors.black,),),
                                    SizedBox(width: 10.0),
                                    Text(uomTemp, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                                child: new Text(widget.prodName.toString(), style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 17.0),),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(20.0, 10.0, 5.0, 5.0),
                                child: new Text("Select UOM", style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 17.0),),
                              ),

                            Padding(
                              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                              child: GridView.builder(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: getUomList == null ? 0 : getUomList.length,
                              gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height / 2),
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                 return InkWell(
                                   onTap: (){
                                        setState(() {
                                          priceTemp = getUomList[index]['price_with_vat'];
                                          uomTemp = getUomList[index]['UOM'];
                                        });
                                   },
                                   child: Card(
                                     elevation: 0.10,
                                     clipBehavior: Clip.antiAlias,
                                     child: Center(child: Text(getUomList[index]['UOM'])),
                                   ),
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
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: _counter == 1 ? null : _decrementCounter,
                      child: new Text('-',style: TextStyle(fontSize: 20,color: Colors.green,),),
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
                      child: new Text('+',style: TextStyle(fontSize: 20,color: Colors.green,),),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 20, 5, 5),
                    ),
                    Flexible(
                      child: SleekButton(
                        onTap: () async{
                         await addToCart();

                        },
                        style: SleekButtonStyle.flat(
                          color: Colors.green,
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