import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Chat extends StatefulWidget {
  @override
  _Chat createState() => _Chat();
}

class _Chat extends State<Chat> {

  var isLoading = true;

  Future loadChat() async{
    isLoading = false;
  }

  @override
  void initState() {
    super.initState();

    loadChat();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text("Kevin john",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ): Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: RefreshIndicator(
                  onRefresh: loadChat,
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: 4,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(

                              );
                            }
                      ),
                    ),
                ),
            ),
          ],
      ),
    );
  }


}