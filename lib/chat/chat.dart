import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:arush/db_helper.dart';
import 'dart:async';


class Chat extends StatefulWidget {
  final firstName;
  final lastName;
  final riderId;

  Chat({Key key, @required this.firstName,this.lastName, this.riderId}) : super(key: key);
  @override
  _Chat createState() => _Chat();
}

class _Chat extends State<Chat> {
  final db = RapidA();
  var isLoading = true;
  List loadChatData;
  Timer timer;
  final chat = TextEditingController();

  Future loadChat() async{
    var res = await db.loadChat(widget.riderId);
    if (!mounted) return;
    setState(() {
      loadChatData = res['user_details'];
      print(loadChatData);
      isLoading = false;
    });
  }
  sendMessage() async{
    await db.sendMessage(chat.text,widget.riderId);
    chat.clear();
    loadChat();
  }

  @override
  void initState(){
    loadChat();
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => loadChat());

  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
        title: Text("${widget.firstName}  ${widget.lastName}" ,style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
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
                      child: Container(
                        child:  ListView.builder(
                          reverse: true,
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: loadChatData == null ? 0 : loadChatData.length,
                          itemBuilder: (BuildContext context, int index) {
                            bool isSender = false;
                            Color chatColor = Colors.black12;
                            if(loadChatData[index]['isSender'] == 'true'){
                               isSender = true;
                               chatColor = Colors.lightBlueAccent;
                              }
                              return Column(
                                children: [
                                  BubbleSpecialTwo(
                                    text: loadChatData[index]['body'],
                                    isSender: isSender,
                                    color: chatColor,
                                    textStyle: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                    sent: true,
                                  ),
                                  SizedBox(
                                      height: 10.0,
                                  ),
                                ],
                              );
                          }
                        ),
                      ),
                    ),
                ),
            ),
            Container(
              height: 60.0,
              width: screenWidth,
              child: Padding(
                padding: EdgeInsets.only(left: 10,right: 10.0,bottom: 10.0),
                child: CupertinoTextField(
                  // autofocus: true,
                  style: TextStyle(fontSize: 15.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black12,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  keyboardType: TextInputType.text,
                  controller: chat,
                  // maxLines: 12,
                  suffix: Container(
                    width: 60.0,
                    child: Padding(
                      padding: EdgeInsets.all(1.0),
                      child: GestureDetector(
                          onTap: (){
                              sendMessage();
                          },
                          child: Icon(Icons.send,color: Colors.blue,size: 32.0,)),
                    ),
                  ),
                  cursorColor: Colors.black54,
                  placeholder: "Enter message",
                ),
              ),
            ),
          ],
      ),
    );
  }
}