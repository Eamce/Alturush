import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Search extends StatefulWidget {
  @override
  _Search createState() => _Search();
}
class _Search extends State<Search> {
  final db = RapidA();
  final search = TextEditingController();
  List searchProdData = [];
  bool searchLoading;
  bool load;

  Future searchProd() async {
    searchLoading = true;
    var res = await db.searchProd(search.text,unitGroupId);
    if (!mounted) return;
    setState(() {
      load = false;
      searchLoading = false;
      searchProdData = res['user_details'];
    });
  }

  @override
  void initState() {
    load = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          iconTheme: new IconThemeData(color: Colors.black),
          elevation: 0.0,
          title: Container(
            height: 40.0,
            child: CupertinoTextField(
                autofocus: true,
                style: TextStyle(fontSize: 15.0),
                keyboardType: TextInputType.text,
                controller: search,
                onChanged: (text) {
                  searchProd();
                  if(search.text.length == 0){
                    setState(() {
                      searchProdData.clear();
                    });
                  }
                },
                prefix: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.search_sharp,color: Colors.black54,),
                ),
                suffix: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: (){
                      search.clear();
                      load = true;
                      setState(() {
                        searchProdData.clear();
                      });
                      print(load);
                    },
                      child: Icon(Icons.close_rounded,color: Colors.black54,)),
                ),
                cursorColor: Colors.black54,
                placeholder: "Search food",
            ),
          ),
          actions: [
            TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                ),
                onPressed: (){
                  FocusScope.of(context).requestFocus(FocusNode());
                  searchProd();
                },
                child: Text("Search",style: TextStyle(color: Colors.black),)
            )
          ],),
        body: Scrollbar(
          child: searchProdData.length !=0 || load == true ? ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: searchProdData == null ? 0 : searchProdData.length,
              itemBuilder: (BuildContext context, int index){
                return InkWell(
                  onTap: (){

                  },
                  child:Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                      child: Row(
                        children:[
                          Container(
                            width: 30.0,
                            height: 30.0,
                            decoration: new BoxDecoration(
                              image: new DecorationImage(
                                image: new NetworkImage(searchProdData[index]['prod_image']),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                              border: new Border.all(
                                color: Colors.black54,
                                width: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(searchProdData[index]['prod_name'],style: TextStyle(fontSize: 12.0),)
                        ],
                      ),
                  ),
                );
              }
          ): Center(
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    child: SvgPicture.asset("assets/svg/file.svg"),
                  ),
                  Text("No Result Found",style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 20.0),),
                  Text("We can't find any item matching your search",style: TextStyle(color: Colors.black54,),),
                ],
              ),
          ),
        )
      ),
    );
  }
}
