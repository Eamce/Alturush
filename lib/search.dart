import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final buCode;
  final buLogo;
  final buName;
  Search({Key key, @required this.buLogo,this.buName,this.buCode}) : super(key: key);
  @override
  _Search createState() => _Search();
}
class _Search extends State<Search> {

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
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
    );
  }
}
