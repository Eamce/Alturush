import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paymaya_flutter/paymaya_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';

class SubmitOrderPaymaya extends StatefulWidget {
  final cart;

  const SubmitOrderPaymaya({Key key, @required this.cart}) : super(key: key);
  @override
  _SubmitOrderPaymayaState createState() => _SubmitOrderPaymayaState();
}

class _SubmitOrderPaymayaState extends State<SubmitOrderPaymaya> {
  PayMayaSDK _payMayaSdk;
  List fcart = [];

  @override
  void initState() {
    _payMayaSdk = PayMayaSDK.init('pk-eo4sL393CWU5KmveJUaW8V730TTei2zY8zE4dHJDxkF');
    print(widget.cart);
    List wcart = widget.cart;
    wcart.forEach((element) {
      print(element["main_item"]["product_id"]);
      fcart.add(element["main_item"]);
    });
    // fcart = [widget.cart[0]["main_item"]];
    readyPaymaya();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0.0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Preparing",
          style: GoogleFonts.openSans(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 18.0),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // children: [
        //   Center(
        //       child: CircularProgressIndicator(
        //     valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        //   )),
        // ],
      ),
    );
  }

  readyPaymaya() async {
    final _amount = fcart.fold(
        0,
        (previousValue, element) =>
            previousValue + double.parse(element["total_price"]));
    final _items = fcart.map((cart) {
      print(cart["quantity"]);
      return PaymayaItem(
        name: cart["product_name"],
        quantity: int.parse(cart["quantity"].toString()),
        code: cart["product_id"],
        description: cart["description"],
        amount: PaymayaAmount(
          value: double.parse(cart["price"].toString()),
          currency: 'PHP',
        ),
        totalAmount: PaymayaAmount(
          value: double.parse(cart["total_price"].toString()),
          currency: 'PHP',
        ),
      );
    }).toList();
    final totalAmount = PaymayaAmount(
      value: _amount,
      currency: 'PHP',
    );
    const _buyer = PaymayaBuyer(
      firstName: 'John',
      middleName: '',
      lastName: 'Doe',
      customerSince: '2020-01-01',
      birthday: '1998-01-01',
      contact: PaymayaContact(email: 'johndoe@x.com', phone: '0912345678'),
      billingAddress: PaymayaBillingAddress(
        city: 'Davao City',
        countryCode: 'PH',
        zipCode: '8000',
        state: 'Davao',
      ),
      shippingAddress: PaymayaShippingAddress(
        city: 'Davao City',
        countryCode: 'PH',
        zipCode: '8000',
        state: 'Davao',
        firstName: 'John',
        middleName: '',
        lastName: 'Doe',
        email: 'paymaya@flutter.com',
        // ST - Standard
        // SD - Same Day
        shippingType: ShippingType.sd,
      ),
    );
    final redirectUrls = const PaymayaRedirectUrls(
      success: 'http://google.com/?success=1&id=6319921',
      failure: 'http://google.com/?failure=1&id=6319921',
      cancel: 'http://google.com/?cancel=1&id=6319921',
    );
    final _checkout = PaymayaCheckout(
        totalAmount: totalAmount,
        buyer: _buyer,
        items: _items,
        redirectUrl: redirectUrls,
        requestReferenceNumber: '6319921');
    final result = await _payMayaSdk.createCheckOut(
      _checkout,
    );
    await _onRedirectUrl(result.redirectUrl);
  }

  Future<void> _onRedirectUrl(String url) async {
    if (!await canLaunch(url)) {
      return;
    }

    final isPaid = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const CheckoutPage('http://google.com/?success=1&id=6319921',
              'http://google.com/?failure=1&id=6319921');
        },
        settings: RouteSettings(arguments: url),
      ),
    );

    // final isPaid = await launch(url);
    print(isPaid);
    if (isPaid) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CHECKOUT PAID!')),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CANCELLED BY USER')),
      );
    }
  }
}

class CheckoutPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const CheckoutPage(this.successURL, this.failedURL);
  // ignore: public_member_api_docs
  final String successURL;
  final String failedURL;

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('successURL', successURL));
  }
}

class _CheckoutPageState extends State<CheckoutPage> {
  final Completer<WebViewController> _controller = Completer();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final url = ModalRoute.of(context)?.settings.arguments as String;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleSpacing: 0.0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          title: Text(
            "Payment",
            style: GoogleFonts.openSans(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 18.0),
          ),
        ),
        body: SafeArea(
          child: WebView(
            onWebViewCreated: _controller.complete,
            initialUrl: url,
            javascriptMode: JavascriptMode.unrestricted,
            debuggingEnabled: kDebugMode,
            navigationDelegate: (request) async {
              if (request.url == widget.successURL) {
                Navigator.pop(context, true);
                return NavigationDecision.prevent;
              } else if (request.url == widget.failedURL) {
                Navigator.pop(context, false);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onWebResourceError: (error) async {
              final dialog = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Something went wrong'),
                    content: Text('$error'),
                    actions: [
                      TextButton(
                        child: const Text('close'),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      )
                    ],
                  );
                },
              );
              if (dialog) {
                Navigator.pop(context, false);
              }
            },
          ),
        ),
      ),
    );
  }
}
