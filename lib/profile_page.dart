import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final db = RapidA();
  var isLoading = false;

  Future loadProfile() async {

  }

  Widget yourOrder(){
    return Text("ad");
  }

  @override
  void initState() {
//    loadProfile();

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, () {
          setState(() {});
        });
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "Profile",
            style: GoogleFonts.openSans(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
                fontStyle: FontStyle.normal,
                fontSize: 20.0),
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
              )
            : ListView.builder(
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Card(
                          elevation: 0.1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: new Stack(
                                    fit: StackFit.loose,
                                    children: <Widget>[
                                      new Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Container(
                                              width: 120.0,
                                              height: 120.0,
                                              decoration: new BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: new DecorationImage(
                                                  image: new ExactAssetImage(
                                                      'assets/png/as.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                        ],
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              top: 90.0, right: 90.0),
                                          child: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              GestureDetector(
                                                  onTap: () {

                                                  },
                                                  child: new CircleAvatar(
                                                    backgroundColor: Colors
                                                        .deepOrange,
                                                    radius: 20.0,
                                                    child: new Icon(
                                                      Icons.camera_alt,
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                            ],
                                          )),
                                    ]),
                              ),
                              Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 0.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Paul jearic Niones",
                                        style: GoogleFonts.openSans(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 20.0),
                                      ),

                                    ],
                                  )),
                                  Center(
                                  child:TextButton(
                                      onPressed: (){

                                      },
                                      child: Text("Log out"),
                                    ),
                                  ),
                                SizedBox(
                                  height: 20.0,
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: (){

                                    },
                                    child: Column( // Replace with a Row for horizontal icon + text
                                      children: <Widget>[
                                        Icon(Icons.record_voice_over),
                                        Text("your order")
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: (){

                                    },
                                    child: Column( // Replace with a Row for horizontal icon + text
                                      children: <Widget>[
                                        Icon(Icons.motorcycle),
                                        Text("In transit")
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: (){

                                    },
                                    child: Column( // Replace with a Row for horizontal icon + text
                                      children: <Widget>[
                                        Icon(Icons.history),
                                        Text("History")
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                     Column(
//                       crossAxisAlignment: ,
                        children: [
                            yourOrder(),
                        ],
                     ),


                    ],
                  );
                },
              ),
      ),
    );
  }
}
