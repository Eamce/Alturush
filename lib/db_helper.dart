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
    final response = await http.post(Uri.parse("$server/loadCartData_r"),body:{
      'cusId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  //new
  Future createAccountSample(townId,barrioId,username,firstName,lastName,suffix,password,birthday,contactNumber) async{
    if(suffix.toString().isEmpty){
      suffix = suffix;
    }else{
      suffix = encrypt(suffix);
    }
    await http.post(Uri.parse("$server/createUser_r"),body:{
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
  }
  String encrypt(String string) {
    final encrypt = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypt.encrypt(string, iv: iv);
    return encrypted.base64;
  }

  Future checkLogin(_usernameLogIn,_passwordLogIn) async{
    final response = await http.post(Uri.parse("$server/checkLogin_r"),body:{
      '_usernameLogIn':encrypt(_usernameLogIn),
      '_passwordLogIn':encrypt(_passwordLogIn)
    });
    return response.body;
  }

  Future getUserData(id) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getUserData_r"),body:{
      'id':id
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }


  Future getPlaceOrderData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getPlaceOrderData_r"),body:{
      'cusId':encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future checkAllowedPlace() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse("$server/checkAllowedPlace_r"),body:{
      'townId':prefs.getString('s_townId'),
    });

    return response.body;
  }

  Future checkFee() async{
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse("$server/checkFee_r"),body:{
      'townId':prefs.getString('s_townId'),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }


  Future getOrderData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map dataUser;
    final response = await http.post(Uri.parse("$server/getOrderData_r"),body:{
      'cusId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getSubTotal() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getSubtotal_r"),body:{
      'customerId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future placeOrder(townId,barrioId,contact,remarks,houseNo,changeFor,street,deliveryCharge,deliveryDate,deliveryTime,groupValue) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await http.post(Uri.parse("$server/placeOrder_r"),body:{
      'cusId':prefs.getString('s_customerId'),
      'townId':townId,
      'barrioId':barrioId,
      'contact':contact,
      'remarks':remarks,
      'houseNo':houseNo,
      'changeFor':changeFor,
      'street':street,
      'deliveryCharge':deliveryCharge,
      'radioVal':groupValue,
      'deliveryDate':deliveryDate,
      'deliveryTime':deliveryTime,
      'selectedDiscountType':selectedDiscountType.toString()
    });
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
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getLastItems_r"),body:{
      'orderNo':orderNo,
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getAllowedLoc() async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getAllowedLoc_r"),body:{
      'd':'d',
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getBuSegregate() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getBu_r"),body:{
      'cusId':prefs.getString('s_customerId')
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future displayOrder(tenantId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await http.post(Uri.parse("$server/displayOrder_r"),body:{
      'cusId':prefs.getString('s_customerId'),
      'tenantId':tenantId
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future displayAddOns(cartId) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/displayAddOns_r"),body:{
      'cartId':cartId
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getTenantSegregate () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getTenant_r"),body:{
      'cusId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getTicketNoFood() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getTicketNoFood_r"),body:{
      'cusId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await http.post(Uri.parse("$server/loadProfile_r"),body:{
      'cusId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future lookItems(ticketNo) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/lookItems_r"),body:{
      'ticketNo':encrypt(ticketNo)
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future lookItemsGood(ticketNo) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/lookitems_good_r"),body:{
      'ticketNo':encrypt(ticketNo),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getTotal(ticketNo) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getTotal_r"),body:{
      'ticketNo':encrypt(ticketNo),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }


  Future checkIfOnGoing(ticketNo) async{
    final response = await http.post(Uri.parse("$server/checkifongoing_r"),body:{
      'ticketNo':ticketNo
    });
    return response.body;
  }



  Future removeItemFromCart(cartId) async{
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    await http.post(Uri.parse("$server/removeItemFromCart_r"),body:{
      'cartId':cartId
    });
  }

  Future trapTenantLimit(townId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await http.post(Uri.parse("$server/trapTenantLimit_r"),body:{
      'cusId':prefs.getString('s_customerId'),
      'townId':townId.toString()
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getAmountPerTenant() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getAmountPertenant_r"),body:{
      'cusId':prefs.getString('s_customerId'),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  //node
  Future getBusinessUnitsCi() async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/display_store_r"),body:{

    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getTenantsCi(buCode) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/display_tenant_r"),body:{
      'buCode':buCode
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getStoreCi(categoryId) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/display_restaurant_r"),body:{
      'categoryId':categoryId
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getItemDataCi(prodId,productUom) async{

    if(productUom == null){
      productUom = null;
    }
//    else{
//      productUom = productUom;
//    }

    Map dataUser;
    final response = await http.post(Uri.parse("$server/display_item_data_r"),body:{
      'prodId':prodId.toString(),
      'productUom':productUom.toString()
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future addToCartCi(buCode,tenantCode,prodId,itemCount,price) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await http.post(Uri.parse("$server/add_to_cart_r"),body:{
      'customerId':prefs.getString('s_customerId'),
      'buCode':buCode,
      'tenantCode':tenantCode,
      'prodId':prodId,
      'itemCount':itemCount,
      'price':price
    });
  }


  Future addToCartCiTest(buCode,tenantCode,prodId,productUom,flavorId,drinkId,drinkUom,friesId,friesUom,sideId,sideUom,selectedSideItems,selectedSideItemsUom,selectedDessertItems,selectedDessertItemsUom,boolFlavorId,boolDrinkId,boolFriesId,boolSideId,_counter) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await http.post(Uri.parse("$server/add_to_cart_r"),body:{
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
  }

  Future selectSuffixCi() async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/selectSuffix_r"));
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getTownsCi() async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getTowns_r"));
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getBarrioCi(townId) async{
    Map dataUser;
    final response =  await http.post(Uri.parse("$server/getbarrio_r"),body:{
      'townId':townId.toString()
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future updateCartQty(id,qty) async{
    await http.post(Uri.parse("$server/updateCartQty_r"),body:{
      'id':id,
      'qty':qty
    });
  }

  Future getCounter() async{
    String userID;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String status = prefs.getString('s_status');
    if(status==null){
      userID = '0';
    }else{
      userID = prefs.getString('s_customerId');
    }
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getCounter_r"),body:{
      'customerId':userID
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future savePickup(groupValue,deliveryDateData,deliveryTimeData,getTenantData,subtotal,tender) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
     await http.post(Uri.parse("$server/savePickup_r"),body:{
      'customerId':encrypt(prefs.getString('s_customerId').toString()),
      'groupValue':encrypt(groupValue),
      'deliveryDateData':encrypt(deliveryDateData.toString()),
      'deliveryTimeData':encrypt(deliveryTimeData.toString()),
      'getTenantData':encrypt(getTenantData.toString()),
      'subtotal':encrypt(subtotal.toString()),
      'tender':encrypt(tender.toString()),
      'contactNo':encrypt(prefs.getString('s_contact').toString()),
    });
  }
  //
  // Future loadSubTotal() async{
  //   Map dataUser;
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var userID = prefs.getString('s_customerId');
  //   final response = await http.post("$server/getSubtotal_r",body:{
  //     'customerId':userID
  //   });
  //   dataUser = jsonDecode(response.body);
  //   return dataUser;
  // }

  Future loadRiderPage(ticketNo) async{
    Map dataUser;
    final response =  await http.post(Uri.parse("$server/showRiderDetails_r"),body:{
      'ticketNo':encrypt(ticketNo)
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getTrueTime() async{
    Map dataUser;
    final response =  await http.post(Uri.parse("$server/getTrueTime_r"));
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future loadFlavor(prodId) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/loadFlavor_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future loadDrinks(prodId) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/loadDrinks_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future loadFries(prodId) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/loadFries_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future loadSide(prodId) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/loadSide_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
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
    Map dataUser;
    final response = await http.post(Uri.parse("$server/checkAddon_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future loadAddonSide(prodId) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/loadAddonSide_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future loadAddonDessertSide(prodId) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/loadAddonDessert_r"),body:{
      'prodId':prodId
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future cancelOrderSingleGood(tomsId,ticketId) async{
    await http.post(Uri.parse("$server/cancelOrderSingleGood_r"),body:{
      'tomsId':tomsId,
      'ticketId':ticketId
    });
  }

  Future cancelOrderSingleFood(tomsId,ticketId) async{
    await http.post(Uri.parse("$server/cancelOrderSingleFood_r"),body:{
      'tomsId':tomsId,
      'ticketId':ticketId
    });
  }

  Future loadLocation(placeRemark) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/loadLocation_r"),body:{
      'placeRemark':placeRemark
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future checkEmptyStore(tenantCode) async{
    final response = await http.post(Uri.parse("$server/checkifemptystore_r"),body:{
      'tenantCode':tenantCode
    });
    return response.body;
  }

  Future getCategories(tenantCode) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getCategories_r"),body:{
      'tenantCode':tenantCode
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getItemsByCategories(categoryId) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getItemsByCategories_r"),body:{
      'categoryId':categoryId
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getGcStoreCi(String offset,[itemSearch = ""]) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getGcItems_r"),body:{
        'offset':offset,
        'itemSearch':itemSearch
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future addToCartGc(buCode,prodId,itemCode,uomSymbol,uomId,_counter) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await http.post(Uri.parse("$server/addToCartGc_r"),body:{
      'userID':userID.toString(),
      'buCode':buCode.toString(),
      'prodId':prodId.toString(),
      'itemCode':itemCode.toString(),
      'uomSymbol':uomSymbol.toString(),
      'uom':uomId.toString(),
      '_counter':_counter.toString(),
    });
  }

  Future gcLoadCartData() async{
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response =  await http.post(Uri.parse("$server/gc_cart_r"),body:{
      'userID':userID.toString(),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future updateGcCartQty(id,qty) async{
    await http.post(Uri.parse("$server/updateGcCartQty_r"),body:{
      'id':id,
      'qty':qty
    });
  }

  Future loadGcSubTotal() async{
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await http.post(Uri.parse("$server/loadGcSubTotal_r"),body:{
      'customerId':userID
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getGcCounter() async{
    String userID;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String status = prefs.getString('s_status');
    if(status==null){
      userID = '0';
    }else{
      userID = prefs.getString('s_customerId');
    }
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getGcCounter_r"),body:{
      'customerId':userID
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getGcCategories() async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getGcCategories_r"),body:{

    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getItemsByGcCategories(categoryId,offset) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getItemsByGcCategories_r"),body:{
      'categoryId':categoryId,
      'offset':offset.toString()
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future removeGcItemFromCart(cartId) async{
    await http.post(Uri.parse("$server/removeGcItemFromCart_r"),body:{
      'cartId':cartId
    });
  }

  Future getBill() async{
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await http.post(Uri.parse("$server/getBill_r"),body:{
      'customerId':userID
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future gcGroupByBu() async{
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await http.post(Uri.parse("$server/gcgroupbyBu_r"),body:{
      'customerId':encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future getConFee() async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getConFee_r"),body:{

    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future submitOrder(groupValue,deliveryDateData,deliveryTimeData,buData,totalData,convenienceData,placeRemarks) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await http.post(Uri.parse("$server/gc_submitOrder_r"),body:{
      'customerId':encrypt(userID),
      'groupValue':encrypt(groupValue.toString()),
      'deliveryDateData':encrypt(deliveryDateData.toString()),
      'deliveryTimeData':encrypt(deliveryTimeData.toString()),
      'buData':encrypt(buData.toString()),
      'totalData':encrypt(totalData.toString()),
      'convenienceData':encrypt(convenienceData.toString()),
      'placeRemarks':encrypt(placeRemarks.toString())
    });
  }

  Future getUom(itemCode) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/gc_select_uom_r"),body:{
      'itemCode':itemCode
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future showDiscount() async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/showDiscount_r"),body:{

    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future uploadId1(discountIdType,name,idNumber,base64Image,base64Booklet) async{
    int imageName = DateTime.now().microsecondsSinceEpoch;
    int imageBookletName = DateTime.now().microsecondsSinceEpoch;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var userID = prefs.getString('s_customerId');
    await http.post(Uri.parse("$server/uploadId1_r"),body:{
      'userID':encrypt(userID),
      'discountId':encrypt(discountIdType),
      'name':encrypt(name),
      'idNumber':encrypt(idNumber),
      'imageName':encrypt(imageName.toString()),
      'imageBookletName':encrypt(imageBookletName.toString())
    });
    uploadImage(base64Image,imageName);
    uploadBookletImage(base64Booklet,imageBookletName);
  }

  Future uploadId(discountIdType,name,idNumber,base64Image) async{
    int imageName = DateTime.now().microsecondsSinceEpoch;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var userID = prefs.getString('s_customerId');
    await http.post(Uri.parse("$server/uploadId_r"),body:{
      'userID':encrypt(userID),
      'discountId':encrypt(discountIdType),
      'name':encrypt(name),
      'idNumber':encrypt(idNumber),
      'imageName':encrypt(imageName.toString())
    });
    uploadImage(base64Image,imageName);
  }

  Future uploadImage(_image,imageName) async{
    await http.post(Uri.parse("$server/upLoadImage_r"),body:{
      '_image':_image,
      '_imageName':imageName.toString()
    });
  }

  Future uploadBookletImage(_image,imageName) async{
    await http.post(Uri.parse("$server/upLoadImage_r"),body:{
      '_image':_image,
      '_imageName':imageName.toString()
    });
  }

  Future displayId() async{
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await http.post(Uri.parse("$server/loadIdList_r"),body:{
      'userID':userID
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future futureLoadQuotes() async{
    Map dataUser;
    final response = await http.get(Uri.parse("https://api.quotable.io/random?minLength=30&maxLength=40"));
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future delete(id) async{
    await http.post(Uri.parse("$server/delete_id_r"),body:{
      'id':id
    });
  }

  Future checkIfHasId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await http.post(Uri.parse("$server/checkidcheckout_r"),body:{
      'userID':userID
    });
    return response.body;
  }

  Future changeAccountStat(usernameLogIn) async{
    await http.post(Uri.parse("$server/changeAccountStat_r"),body:{
      'usernameLogIn':usernameLogIn
    });
  }

  Future getUserDetails(usernameLogIn) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getUserDetails_r"),body:{
      'usernameLogIn':usernameLogIn
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future saveOTPNumber(realMobileNumber) async{
    await http.post(Uri.parse("$server/saveOTPNumber_r"),body:{
        'mobileNumber':realMobileNumber
    });
  }

  Future checkOtpCode(otpCode,mobileNumber) async{
    final response = await http.post(Uri.parse("$server/checkOtpCode_r"),body:{
      'otpCode':encrypt(otpCode),
      'mobileNumber':encrypt(mobileNumber)
    });
    return response.body;
  }

  Future changePassword(newPassWord,realMobileNumber) async{
    await http.post(Uri.parse("$server/changePassword_r"),body:{
      'newPassWord':encrypt(newPassWord),
      'realMobileNumber':encrypt(realMobileNumber)
    });
  }

  Future checkUsernameIfExist(username) async{
    final response = await http.post(Uri.parse("$server/checkUsernameIfExist_r"),body:{
      'username':encrypt(username)
    });
    return response.body;
  }

  Future checkPhoneIfExist(phoneNumber) async{
    final response = await http.post(Uri.parse("$server/checkPhoneIfExist_r"),body:{
      'phoneNumber':encrypt(phoneNumber)
    });
    return response.body;
  }

  Future getProvince() async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getProvince_r"),body:{
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future selectTown(provinceId) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getTown_r"),body:{
      'provinceId':encrypt(provinceId)
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future selectBarangay(townID) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/getBarangay_r"),body:{
      'townID':encrypt(townID)
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future selectBuildingType() async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/selectBuildingType"),body:{
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future submitNewAddress(firstName,lastName,mobileNum,houseUnit,streetPurok,landMark,barangayID,buildingID) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await http.post(Uri.parse("$server/submitNewAddress_r"),body:{
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
    return response.body;
  }

  Future loadAddress() async{
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await http.post(Uri.parse("$server/loadAddress_r"),body:{
      'userID':encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future deleteAddress(id) async{
    await http.post(Uri.parse("$server/deleteAddress_r"),body:{
      'id':encrypt(id)
    });
  }

  Future checkIfHasAddresses() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await http.post(Uri.parse("$server/checkIfHasAddresses_r"),body:{
      'userID':encrypt(userID)
    });
    return response.body;
  }

  Future displayAddresses() async{
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await http.post(Uri.parse("$server/loadAddress_r"),body:{
      'userID':encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future updateDefaultShipping(id,customerId) async{
    await http.post(Uri.parse("$server/updateDefaultShipping_r"),body:{
      'id':encrypt(id),
      'customerId':encrypt(customerId)
    });
  }

  Future selectCategory(tenantId) async{
    Map dataUser;
    final response = await http.post(Uri.parse("$server/viewTenantCategories_r"),body:{
      'tenantId':encrypt(tenantId)
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

}




