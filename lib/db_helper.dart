import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart';

List loadIdList;
List<bool> side = [];
List<String> selectedDiscountType = [];

class RapidA {
  static final RapidA _instance = RapidA._();
  RapidA._();

  factory RapidA() {
    return _instance;
  }

  // String server = "https://app1.alturush.com";
  String server = "http://172.16.46.130/rapida";
  // String server = "http://203.177.223.59:8006/";

  final key = Key.fromUtf8('SoAxVBnw8PYHzHHTFBQdG0MFCLNdmGFf'); //32 chars
  final iv = IV.fromUtf8('T1g994xo2UAqG81M'); //16 chars

  //mysql query code

  Future loadCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/loadCartDataNew_r"),body:{
      'cusId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  //new
  Future createAccountSample(townId,barrioId,username,firstName,lastName,suffix,password,birthday,contactNumber) async{
    var client = http.Client();
    if(suffix.toString().isEmpty){
      suffix = suffix;
    }else{
      suffix = encrypt(suffix);
    }
    await client.post(Uri.parse("$server/createUser_r"),body:{
      'townId':encrypt(townId),
      'barrioId':encrypt(barrioId),
      'username':encrypt(username),
      'firstName':encrypt(firstName),
      'lastName':encrypt(lastName),
      'suffix':suffix,
      'password':encrypt(password),
      'birthday':encrypt(birthday),
      'contactNumber':encrypt("0"+contactNumber)
    });
    client.close();
  }
  String encrypt(String string) {
    final encrypt = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypt.encrypt(string, iv: iv);
    return encrypted.base64;
  }

  Future checkLogin(_usernameLogIn,_passwordLogIn) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkLogin_r"),body:{
      '_usernameLogIn':encrypt(_usernameLogIn),
      '_passwordLogIn':encrypt(_passwordLogIn)
    });
    client.close();
    return response.body;
  }

  Future getUserData(id) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getUserData_r"),body:{
      'id':id
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }


  Future getPlaceOrderData() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getPlaceOrderData_r"),body:{
      'cusId':encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future checkAllowedPlace() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await client.post(Uri.parse("$server/checkAllowedPlace_r"),body:{
      'townId':prefs.getString('s_townId'),
    });
    client.close();
    return response.body;
  }

  Future checkFee() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await client.post(Uri.parse("$server/checkFee_r"),body:{
      'townId':prefs.getString('s_townId'),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }


  Future getOrderData() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getOrderData_r"),body:{
      'cusId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getSubTotal() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getSubtotal_r"),body:{
      'customerId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future placeOrder(townId,barrioId,contact,landmark,specialInstruction,houseNo,changeFor,street,deliveryCharge,deliveryDate,deliveryTime,groupValue) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var client = http.Client();
     await client.post(Uri.parse("$server/placeOrder_r"),body:{
      // 'cusId':prefs.getString('s_customerId'),
      // 'townId':townId,
      // 'barrioId':barrioId,
      // 'contact':contact,
      // 'landmark':landmark,
      // 'specialInstruction':specialInstruction,
      // 'houseNo':houseNo,
      // 'changeFor':changeFor,
      // 'street':street,
      // 'deliveryCharge':deliveryCharge,
      // 'radioVal':groupValue,
      // 'deliveryDate':deliveryDate,
      // 'deliveryTime':deliveryTime,
      // 'selectedDiscountType':selectedDiscountType.toString(),
       'cusId':prefs.getString('s_customerId'),
       'deliveryDate':deliveryDate,
       'deliveryTime':deliveryTime,
       'selectedDiscountType':selectedDiscountType.toString(),
       'deliveryCharge':deliveryCharge,
       'changeFor':changeFor
    });
    client.close();
    print(client);
  }

  // Future getLastOrder() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   Map dataUser;
  //   final response = await http.post("$server/getLastOrderId_r",body:{
  //     'cusId':prefs.getString('s_customerId'),
  //   });
  //   dataUser = jsonDecode(response.body);
  //   return dataUser;
  // }

  Future getLastItems(orderNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getLastItems_r"),body:{
      'orderNo':orderNo,
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getAllowedLoc() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getAllowedLoc_r"),body:{
      'd':'d',
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getBuSegregate() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getBu_r"),body:{
      'cusId':prefs.getString('s_customerId')
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future displayOrder(tenantId) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/displayOrder_r"),body:{
      'cusId':prefs.getString('s_customerId'),
      'tenantId':tenantId
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future displayAddOns(cartId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/displayAddOns_r"),body:{
      'cartId':cartId
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTenantSegregate () async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTenant_r"),body:{
      'cusId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTicketNoFood() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTicketNoFood_r"),body:{
      'cusId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  // Future getTicketNoGood() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   Map dataUser;
  //   final response = await http.post("$server/getTicketNoGood_r",body:{
  //     'cusId':prefs.getString('s_customerId'),
  //   });
  //   dataUser = jsonDecode(response.body);
  //   return dataUser;
  // }

  Future loadProfile() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadProfile_r"),body:{
      'cusId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future lookItems(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/lookItems_r"),body:{
      'ticketNo':encrypt(ticketNo)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future lookItemsGood(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/lookitems_good_r"),body:{
      'ticketNo':encrypt(ticketNo),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTotal(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTotal_r"),body:{
      'ticketNo':encrypt(ticketNo),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }


  Future checkIfOnGoing(ticketNo) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkifongoing_r"),body:{
      'ticketNo':ticketNo
    });
    client.close();
    return response.body;
  }



  Future removeItemFromCart(cartId) async{
    var client = http.Client();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    await client.post(Uri.parse("$server/removeItemFromCart_r"),body:{
      'cartId':cartId
    });
    client.close();
  }

  Future trapTenantLimit(townId) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/trapTenantLimit_r"),body:{
      'cusId':prefs.getString('s_customerId'),
      'townId':townId.toString()
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getAmountPerTenant() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTenant_r"),body:{
      'cusId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  //node
  Future getBusinessUnitsCi() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/display_store_r"),body:{

    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTenantsCi(buCode) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/display_tenant_r"),body:{
      'buCode':buCode
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getStoreCi(categoryId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/display_restaurant_r"),body:{
      'categoryId':categoryId
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getItemDataCi(prodId,productUom) async{
    var client = http.Client();
    if(productUom == null){
      productUom = null;
    }
//    else{
//      productUom = productUom;
//    }

    Map dataUser;
    final response = await client.post(Uri.parse("$server/display_item_data_r"),body:{
      'prodId':prodId.toString(),
      'productUom':productUom.toString()
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future addToCartCi(buCode,tenantCode,prodId,itemCount,price) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await client.post(Uri.parse("$server/add_to_cart_r"),body:{
      'customerId':prefs.getString('s_customerId'),
      'buCode':buCode,
      'tenantCode':tenantCode,
      'prodId':prodId,
      'itemCount':itemCount,
      'price':price
    });
    client.close();
  }


  Future addToCartCiTest(buCode,tenantCode,prodId,productUom,flavorId,drinkId,drinkUom,friesId,friesUom,sideId,sideUom,selectedSideItems,selectedSideItemsUom,selectedDessertItems,selectedDessertItemsUom,boolFlavorId,boolDrinkId,boolFriesId,boolSideId,_counter) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await client.post(Uri.parse("$server/add_to_cart_r"),body:{
      'customerId':prefs.getString('s_customerId'),
      'buCode':buCode.toString(),
      'tenantCode':tenantCode.toString(),
      'prodId':prodId.toString(),
      'productUom':productUom.toString(),
      'flavorId':flavorId.toString(),
      'drinkId':drinkId.toString(),
      'drinkUom':drinkUom.toString(),
      'friesId':friesId.toString(),
      'friesUom':friesUom.toString(),
      'sideId':sideId.toString(),
      'sideUom':sideUom.toString(),
      'selectedSideItems':selectedSideItems.toString(),
      'selectedSideItemsUom':selectedSideItemsUom.toString(),
      'selectedDessertItems':selectedDessertItems.toString(),
      'selectedDessertItemsUom':selectedDessertItemsUom.toString(),
      '_counter':_counter.toString()
    });
    client.close();
  }

  Future addToCartNew(prodId,uomId,_counter,uomPrice,choiceUomId,choiceId,choicePrice,flavorId ,flavorPrice,selectedSideOnPrice,selectedSideItems ,selectedSideItemsUom) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/addToCartNew_r"),body:{
      'userID':userID,
      'prodId':prodId,
      'uomId':uomId.toString(),
      'uomPrice':uomPrice,
      'choiceUomId':choiceUomId.toString(),
      'choiceId':choiceId.toString(),
      'choicePrice':choicePrice.toString(),
      'flavorId':flavorId.toString(),
      'flavorPrice':flavorPrice.toString(),
      '_counter':_counter.toString(),
      'selectedSideOnPrice':selectedSideOnPrice.toString(),
      'selectedSideItems':selectedSideItems.toString(),
      'selectedSideItemsUom':selectedSideItemsUom.toString()
    });
    client.close();
  }


  Future selectSuffixCi() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/selectSuffix_r"));
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTownsCi() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTowns_r"));
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getBarrioCi(townId) async{
    var client = http.Client();
    Map dataUser;
    final response =  await client.post(Uri.parse("$server/getbarrio_r"),body:{
      'townId':townId.toString()
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future updateCartQty(id,qty) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/updateCartQty_r"),body:{
      'id':id,
      'qty':qty
    });
    client.close();
  }

  Future getCounter() async{
    var client = http.Client();
    String userID;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String status = prefs.getString('s_status');
    if(status==null){
      userID = '0';
    }else{
      userID = prefs.getString('s_customerId');
    }
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getCounter_r"),body:{
      'customerId':userID
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future savePickup(deliveryDateData,deliveryTimeData,subtotal,tender) async{

   // print(deliveryDateData);
   // print(deliveryTimeData);
   // print(subtotal);
   // print(tender);
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await client.post(Uri.parse("$server/savePickup_r"),body:{
       'customerId':encrypt(prefs.getString('s_customerId').toString()),
       'deliveryDateData':deliveryDateData.toString(),
       'deliveryTimeData':deliveryTimeData.toString(),
       'subtotal':encrypt(subtotal.toString()),
       'tender':encrypt(tender.toString()),
       'selectedDiscountType':encrypt(selectedDiscountType.toString()),
    });
    client.close();
  }

  Future loadSubTotal() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response =  await client.post(Uri.parse("$server/loadSubTotalnew_r"),body:{
      'customerId':prefs.getString('s_customerId').toString(),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadRiderPage(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response =  await client.post(Uri.parse("$server/showRiderDetails_r"),body:{
      'ticketNo':encrypt(ticketNo)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTrueTime() async{
    var client = http.Client();
    Map dataUser;
    final response =  await client.post(Uri.parse("$server/getTrueTime_r"));
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadFlavor(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadFlavor_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadDrinks(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadDrinks_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadFries(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadFries_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadSide(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadSide_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

//  Future listenCartSubtotal() async{
//    String userID;
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String status = prefs.getString('s_status');
//    if(status==null){
//      userID = '0';
//    }else{
//      userID = prefs.getString('s_customerId');
//    }
//    Map dataUser;
//    final response = await http.post("$server/getSubtotal_r",body:{
//      'customerId':userID
//    });
//    dataUser = jsonDecode(response.body);
//    return dataUser;
//  }

  Future checkAddon(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/checkAddon_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadAddonSide(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadAddonSide_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadAddonDessertSide(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadAddonDessert_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future cancelOrderSingleGood(tomsId,ticketId) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/cancelOrderSingleGood_r"),body:{
      'tomsId':tomsId,
      'ticketId':ticketId
    });
    client.close();
  }

  Future cancelOrderSingleFood(tomsId,ticketId) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/cancelOrderSingleFood_r"),body:{
      'tomsId':tomsId,
      'ticketId':ticketId
    });
    client.close();
  }

  Future loadLocation(placeRemark) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadLocation_r"),body:{
      'placeRemark':placeRemark
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future checkEmptyStore(tenantCode) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkifemptystore_r"),body:{
      'tenantCode':tenantCode
    });
    client.close();
    return response.body;
  }

  Future getCategories(tenantCode) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getCategories_r"),body:{
      'tenantCode':tenantCode
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getItemsByCategories(categoryId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getItemsByCategories_r"),body:{
      'categoryId':categoryId
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getItemsByCategoriesAll(tenantCode) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getItemsByCategoriesAll_r"),body:{
        'tenantCode':tenantCode
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getGcStoreCi(String offset,categoryNo,[itemSearch = ""]) async{
    print(categoryNo);
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getGcItems_r"),body:{
        'offset':offset,
        'categoryNo':categoryNo,
        'itemSearch':itemSearch
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future addToCartGc(buCode,prodId,itemCode,uomSymbol,uomId,_counter) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/addToCartGc_r"),body:{
      'userID':userID.toString(),
      'buCode':buCode.toString(),
      'prodId':prodId.toString(),
      'itemCode':itemCode.toString(),
      'uomSymbol':uomSymbol.toString(),
      'uom':uomId.toString(),
      '_counter':_counter.toString(),
    });
    client.close();
  }

  Future gcLoadCartData() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response =  await client.post(Uri.parse("$server/gc_cart_r"),body:{
      'userID':userID.toString(),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future updateGcCartQty(id,qty) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/updateGcCartQty_r"),body:{
      'id':id,
      'qty':qty
    });
    client.close();
  }

  Future loadGcSubTotal() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/loadGcSubTotal_r"),body:{
      'customerId':userID
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getGcCounter() async{
    var client = http.Client();
    String userID;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String status = prefs.getString('s_status');
    if(status==null){
      userID = '0';
    }else{
      userID = prefs.getString('s_customerId');
    }
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getGcCounter_r"),body:{
      'customerId':userID
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getGcCategories() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getGcCategories_r"),body:{

    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getItemsByGcCategories(categoryId,offset) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getItemsByGcCategories_r"),body:{
      'categoryId':categoryId,
      'offset':offset.toString()
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future removeGcItemFromCart(cartId) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/removeGcItemFromCart_r"),body:{
      'cartId':cartId
    });
    client.close();
  }

  Future getBill() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/getBill_r"),body:{
      'customerId':userID
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future gcGroupByBu() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/gcgroupbyBu_r"),body:{
      'customerId':encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getConFee() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getConFee_r"),body:{

    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future submitOrder(groupValue,deliveryDateData,deliveryTimeData,buData,totalData,convenienceData,placeRemarks) async{
    // print(encrypt(groupValue.toString()));
    // print(deliveryDateData);
    // print(deliveryTimeData);
    // print(buData);
    // print(totalData);
    // print(convenienceData);
    // print(placeRemarks);
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/gc_submitOrder_r"),body:{
      'customerId':userID,
      'groupValue':groupValue.toString(),
      'deliveryDateData':deliveryDateData.toString(),
      'deliveryTimeData':deliveryTimeData.toString(),
      'buData':buData.toString(),
      'totalData':totalData.toString(),
      'convenienceData':convenienceData.toString(),
      'placeRemarks':placeRemarks.toString()
    });
    client.close();
  }

  Future getUom(itemCode) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/gc_select_uom_r"),body:{
      'itemCode':itemCode
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future showDiscount() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/showDiscount_r"),body:{

    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  // Future uploadId1(discountIdType,name,idNumber,base64Image,base64Booklet) async{
  //   var client = http.Client();
  //   int imageName = DateTime.now().microsecondsSinceEpoch;
  //   int imageBookletName = DateTime.now().microsecondsSinceEpoch;
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   var userID = prefs.getString('s_customerId');
  //   await client.post(Uri.parse("$server/uploadId1_r"),body:{
  //     'userID':encrypt(userID),
  //     'discountId':encrypt(discountIdType),
  //     'name':encrypt(name),
  //     'idNumber':encrypt(idNumber),
  //     'imageName':encrypt(imageName.toString()),
  //     'imageBookletName':encrypt(imageBookletName.toString())
  //   });
  //   uploadImage(base64Image,imageName);
  //   uploadBookletImage(base64Booklet,imageBookletName);
  //   client.close();
  // }

  Future uploadId(discountIdType,name,idNumber,base64Image) async{
    var client = http.Client();
    int imageName = DateTime.now().microsecondsSinceEpoch;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/uploadId_r"),body:{
      'userID':encrypt(userID),
      'discountId':encrypt(discountIdType),
      'name':encrypt(name),
      'idNumber':encrypt(idNumber),
      'imageName':encrypt(imageName.toString())
    });
    uploadImage(base64Image,imageName);
    client.close();
  }

  Future uploadImage(_image,imageName) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/upLoadImage_r"),body:{
      '_image':_image,
      '_imageName':imageName.toString()
    });
    client.close();
  }

  Future uploadBookletImage(_image,imageName) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/upLoadImage_r"),body:{
      '_image':_image,
      '_imageName':imageName.toString()
    });
    client.close();
  }

  Future displayId() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/loadIdList_r"),body:{
      'userID':userID
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future futureLoadQuotes() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.get(Uri.parse("https://api.quotable.io/random?minLength=30&maxLength=40"));
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future delete(id) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/delete_id_r"),body:{
      'id':id
    });
    client.close();
  }

  Future checkIfHasId() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/checkidcheckout_r"),body:{
      'userID':userID
    });
    client.close();
    return response.body;
  }

  Future changeAccountStat(usernameLogIn) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/changeAccountStat_r"),body:{
      'usernameLogIn':usernameLogIn
    });
    client.close();
  }

  Future getUserDetails(usernameLogIn) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getUserDetails_r"),body:{
      'usernameLogIn':usernameLogIn
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future saveOTPNumber(realMobileNumber) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/saveOTPNumber_r"),body:{
        'mobileNumber':realMobileNumber
    });
    client.close();
  }

  Future checkOtpCode(otpCode,mobileNumber) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkOtpCode_r"),body:{
      'otpCode':encrypt(otpCode),
      'mobileNumber':encrypt(mobileNumber)
    });
    client.close();
    return response.body;
  }

  Future changePassword(newPassWord,realMobileNumber) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/changePassword_r"),body:{
      'newPassWord':encrypt(newPassWord),
      'realMobileNumber':encrypt(realMobileNumber)
    });
    client.close();
  }

  Future checkUsernameIfExist(username) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkUsernameIfExist_r"),body:{
      'username':encrypt(username)
    });
    client.close();
    return response.body;
  }

  Future checkPhoneIfExist(phoneNumber) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkPhoneIfExist_r"),body:{
      'phoneNumber':encrypt(phoneNumber)
    });
    client.close();
    return response.body;
  }

  Future getProvince() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getProvince_r"),body:{
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future selectTown(provinceId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTown_r"),body:{
      'provinceId':encrypt(provinceId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future selectBarangay(townID) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getBarangay_r"),body:{
      'townID':encrypt(townID)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future selectBuildingType() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/selectBuildingType"),body:{
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future submitNewAddress(firstName,lastName,mobileNum,houseUnit,streetPurok,landMark,barangayID,buildingID) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/submitNewAddress_r"),body:{
      'userID':encrypt(userID),
      'firstName':encrypt(firstName),
      'lastName':encrypt(lastName),
      'mobileNum':encrypt(mobileNum),
      'houseUnit':encrypt(houseUnit),
      'streetPurok':encrypt(streetPurok),
      'landMark':encrypt(landMark),
      'barangayID':encrypt(barangayID.toString()),
      'buildingID':encrypt(buildingID.toString())
    });
    client.close();
    return response.body;
  }

  Future loadAddress() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/loadAddress_r"),body:{
      'userID':encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future deleteAddress(id) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/deleteAddress_r"),body:{
      'id':encrypt(id)
    });
    client.close();
  }

  Future checkIfHasAddresses() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/checkIfHasAddresses_r"),body:{
      'userID':encrypt(userID)
    });
    client.close();
    return response.body;
  }

  Future displayAddresses() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/loadAddress_r"),body:{
      'userID':encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future updateDefaultShipping(id,customerId) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/updateDefaultShipping_r"),body:{
      'id':encrypt(id),
      'customerId':encrypt(customerId)
    });
    client.close();
  }

  Future selectCategory(tenantId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/viewTenantCategories_r"),body:{
      'tenantId':encrypt(tenantId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future checkIfBf() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/checkIfBf_r"),body:{
      'userID':encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTotalFee(ticketID) async{
    var client = http.Client();
    Map dataUser;

    final response = await client.post(Uri.parse("$server/checkIfBf_r"),body:{

    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

}




