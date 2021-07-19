import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'db_helper.dart';

class Search extends StatefulWidget {
  @override
  _Search createState() => _Search();
}
class _Search extends State<Search> {
  final db = RapidA();
  final search = TextEditingController();
  List searchProdData;
  bool searchLoading;

  Future searchProd() async {
    searchLoading = true;
    var res = await db.searchProd(search.text,unitGroupId);
    if (!mounted) return;
    setState(() {
      searchLoading = false;
      searchProdData = res['user_details'];
      print(searchProdData);
    });
  }

  @override
  void initState() {
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
        body: ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: searchProdData == null ? 0 : searchProdData.length,
            itemBuilder: (BuildContext context, int index){
              return InkWell(
                onTap: (){

                },
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                    child: Text(searchProdData[index]['prod_name']),
                ),
              );
            }
        )
      ),
    );
  }
}
