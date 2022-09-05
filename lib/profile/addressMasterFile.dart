import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:arush/db_helper.dart';
import 'addNewAddress.dart';
import 'editAddress.dart';

class AddressMasterFile extends StatefulWidget {
  @override
  _AddressMasterFile createState() => _AddressMasterFile();
}

class _AddressMasterFile extends State<AddressMasterFile> {
  final db = RapidA();

  List loadIdList;
  bool isLoading = true;
  bool exist = false;
  // bool exist = true;

  Future loadAddress() async{
   var res = await db.loadAddress();
    if (!mounted) return;
    setState(() {

      loadIdList = res['user_details'];
      isLoading = false;
      print(loadIdList);
    });
  }

  deleteAddress(id) async{
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text(
            'Hello',
            style: TextStyle(fontSize: 18.0),
          ),
          content: SingleChildScrollView(
            child:Padding(
                padding:EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                child: Text("Do you want to delete this address?")
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
              onPressed: (){
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
              onPressed: () async{
                Navigator.of(context).pop();
                await db.deleteAddress(id);
                loadAddress();
              },
            ),
          ],
        );
      },
    );

  }

  Future checkIfHasId() async{
    var res = await db.checkIfHasAddresses();
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
    loadAddress();
    checkIfHasId();
    super.initState();
  }
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
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
          icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Your Addresses",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      ),
      body:
      // Center(
      //   child: CircularProgressIndicator(
      //     valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
      //    ),
      //   ):
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child:RefreshIndicator(
              onRefresh: loadAddress,
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (exist == false) Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight / 3.0),
                          child: Center(
                            child:Column(
                              children: <Widget>[
                                Container(
                                  height: 100,
                                  width: 100,
                                  child: SvgPicture.asset("assets/svg/inbox.svg"),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Text("You have no secondary addresses yet",style: TextStyle(fontSize: 19,),),
                              ],
                            ),
                          ),
                        ) else ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: loadIdList == null ? 0 : loadIdList.length,
                        itemBuilder: (BuildContext context, int index) {
                          var q = index;
                          q++;
                          return InkWell(
                            onTap: () {
                              // print("Tap item index: $index");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditAddress(
                                            idd: loadIdList[index]['id'], cusId: loadIdList[index]['d_customerId'])),
                              );
                            },

                              child: Dismissible(
                                key: UniqueKey(),

                                // only allows the user swipe from right to left
                                direction: DismissDirection.endToStart,

                                // Remove this product from the list
                                // In production enviroment, you may want to send some request to delete it on server side
                                onDismissed: (_) {
                                  setState(() {
                                    deleteAddress(loadIdList[index]['id']);
                                  });
                                },


                                // Display item's title, price...
                                child: Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: ListTile(
                                    leading: const Icon(Icons.location_on),
                                    // CircleAvatar(
                                    //     backgroundColor: Colors.deepOrangeAccent,
                                    //     child: Text('$q.',style: TextStyle(fontSize: 18, color: Colors.white,  fontWeight: FontWeight.bold),)
                                    // ),
                                    title: Text('${loadIdList[index]['firstname']} ${loadIdList[index]['lastname']}',style: TextStyle(fontSize: 20,),),
                                    subtitle: Text('${loadIdList[index]['d_townName']}, ${loadIdList[index]['d_brgName']}, ${loadIdList[index]['street_purok']} \n${loadIdList[index]['d_contact']}', style: TextStyle(fontSize: 16,),),
                                    trailing: const Icon(Icons.arrow_back),

                                  ),
                                ),

                                // This will show up when the user performs dismissal action
                                // It is a red background and a trash icon
                                background: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                    ),
                                    margin: const EdgeInsets.symmetric(horizontal: 10),
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),)

                                ),
                              )
                          );

                          // return InkWell(
                          //   onTap: (){
                          //
                          //   },
                          //   child: Padding(padding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                          //     child: Padding(padding:EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                          //       child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: <Widget>[
                          //           Padding(padding:EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 0.0),
                          //             child:Column(crossAxisAlignment: CrossAxisAlignment.start,
                          //               children: [
                          //                 Text('$q. ${loadIdList[index]['firstname']} ${loadIdList[index]['lastname']}',style: TextStyle(fontSize: 20,),),
                          //                 Text('    ${loadIdList[index]['d_townName']}, ${loadIdList[index]['d_brgName']}',style: TextStyle(fontSize: 20,),),
                          //                 Text('    ${loadIdList[index]['street_purok']}',style: TextStyle(fontSize: 20,),),
                          //                 Text('    ${loadIdList[index]['d_contact']}',style: TextStyle(fontSize: 20,),),
                          //
                          //                 ButtonBar(
                          //                   children: <Widget>[
                          //                     OutlineButton(
                          //                       child: Stack(
                          //                       children: <Widget>[
                          //                           Align(alignment: Alignment.bottomRight, child: Icon(Icons.delete_outline_outlined,color: Colors.black)
                          //                           )
                          //                         ],
                          //                       ),
                          //                       highlightedBorderColor: Colors.black,
                          //                       highlightColor: Colors.transparent,
                          //                       shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                          //                       onPressed: () {
                          //                         deleteAddress(loadIdList[index]['id']);
                          //                       },
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //           // ButtonBar(
                          //           //   children: <Widget>[
                          //           //     // OutlineButton(
                          //           //     //   highlightedBorderColor: Colors.black,
                          //           //     //   highlightColor: Colors.transparent,
                          //           //     //   shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                          //           //     //   child: Icon(Icons.edit_outlined,color: Colors.black,),
                          //           //     //   onPressed: () {
                          //           //     //
                          //           //     //   },
                          //           //     // ),
                          //           //     OutlineButton(
                          //           //       child: Stack(
                          //           //         children: <Widget>[
                          //           //           Align(
                          //           //             alignment: Alignment.topRight,
                          //           //               child: Icon(Icons.delete_outline_outlined,color: Colors.black)
                          //           //           )
                          //           //         ],
                          //           //       ),
                          //           //       highlightedBorderColor: Colors.black,
                          //           //       highlightColor: Colors.transparent,
                          //           //       shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                          //           //       onPressed: () {
                          //           //          deleteAddress(loadIdList[index]['id']);
                          //           //       },
                          //           //     ),
                          //           //   ],
                          //           // ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // );
                        }
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
            child: Row(children: <Widget>[
                SizedBox(width: 2.0,
                ),
                Flexible(child: SleekButton(
                  onTap: () async {
                      await Navigator.of(context).push(addNewAddress());
                      loadAddress();
                      checkIfHasId();
                    },
                    style: SleekButtonStyle.flat(
                      color: Colors.deepOrange,
                      inverted: false,
                      rounded: true,
                      size: SleekButtonSize.big,
                      context: context,
                    ),
                    child: Center(
                      child: Text("Add new +", style:TextStyle(fontStyle: FontStyle.normal,fontSize: 18.0),
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

Route addNewAddress() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AddNewAddress(),
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

Route editAddress() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => EditAddress(),
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
