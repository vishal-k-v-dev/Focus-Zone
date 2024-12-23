// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class SubscriptionManager{
  bool isProUser = false;
  bool isEligibleForFreeTrial = true;
  String monthlySubscriptionLocalizedPrice = "";
  String yearlySubscriptionLocalizedPrice = "";
  double monthlySubscriptionPrice = 0.0;
  double yearlySubscriptionPrice = 0.0;
  bool error = false;
  SubscriptionType? activeSubscriptionType;

  static const String monthlyProductId = "com_lock_focus_premium_monthly";
  static const String yearlyProductId = "com_lock_focus_premium_yearly";

  Future<void> initalize() async{
    try{
      await FlutterInappPurchase.instance.initialize();
      await acknowledgeAllPurchases();
      isProUser = await getProStatus();
      isEligibleForFreeTrial = await getEligiblityForFreeTrial();
      monthlySubscriptionLocalizedPrice = await getLocalizedPrice(SubscriptionType.monthly);
      yearlySubscriptionLocalizedPrice = await getLocalizedPrice(SubscriptionType.yearly); 
      monthlySubscriptionPrice = await getPrice(SubscriptionType.monthly);
      yearlySubscriptionPrice = await getPrice(SubscriptionType.yearly);
    }
    catch(e){
      error = true;
    } 
    finally{
      if(
        monthlySubscriptionLocalizedPrice == "" 
        || 
        yearlySubscriptionLocalizedPrice == "" 
        || 
        monthlySubscriptionPrice == 0.0 
        || 
        yearlySubscriptionPrice == 0.0
      ){
        error = true;
      }
    } 
  }

  Future<void> refresh() async{
    await acknowledgeAllPurchases();
    try{
      isProUser = await getProStatus();
      isEligibleForFreeTrial = await getEligiblityForFreeTrial();
      monthlySubscriptionLocalizedPrice = await getLocalizedPrice(SubscriptionType.monthly);
      yearlySubscriptionLocalizedPrice = await getLocalizedPrice(SubscriptionType.yearly); 
      monthlySubscriptionPrice = await getPrice(SubscriptionType.monthly);
      yearlySubscriptionPrice = await getPrice(SubscriptionType.yearly);
    }
    catch(e){
      error = true;
    } 
    finally{
      if(
        monthlySubscriptionLocalizedPrice == "" 
        || 
        yearlySubscriptionLocalizedPrice == "" 
        || 
        monthlySubscriptionPrice == 0.0 
        || 
        yearlySubscriptionPrice == 0.0
      ){
        error = true;
      }
    }
  }

  Future<void> purchaseSubscription(SubscriptionType type) async{
    if(type == SubscriptionType.monthly){
      await FlutterInappPurchase.instance.requestSubscription(monthlyProductId);
    }
    else{
      await FlutterInappPurchase.instance.requestSubscription(yearlyProductId);
    }
  }

  Future<bool> getEligiblityForFreeTrial() async{
    bool isUserEligible = true;

    List<PurchasedItem>? purchaseHistory = [];

    purchaseHistory = await FlutterInappPurchase.instance.getPurchaseHistory();
    
    if(purchaseHistory == null){
      isUserEligible = true;
    }
    else {
      purchaseHistory.forEach((purchase) {
        if(purchase.productId == monthlyProductId || purchase.productId == yearlyProductId){
          isUserEligible = false;
        }
      });
    }
    
    return isUserEligible;
  }

  Future<bool> getProStatus() async{
    if(await FlutterInappPurchase.instance.checkSubscribed(sku: monthlyProductId)){
     activeSubscriptionType = SubscriptionType.monthly;
     return true;
    }
    if(await FlutterInappPurchase.instance.checkSubscribed(sku: yearlyProductId)){
     activeSubscriptionType = SubscriptionType.yearly;
     return true;
    }
    return false;
    // bool isProo = false;
    // List<PurchasedItem>? purchases = await FlutterInappPurchase.instance.getAvailablePurchases();
    // if(purchases == null){isProo = false;}
    // else{
    //   purchases.forEach((element) async{
    //     await FlutterInappPurchase.instance.acknowledgePurchaseAndroid(element.purchaseToken!);
    //     if(isProo == false){
    //       isProo = (element.productId == monthlyProductId);
    //     }
    //   });
    // }
    
    // return isProo;
  }

  Future<double> getPrice(SubscriptionType type) async{
    ProductDetailsResponse productDetailsResponse = await InAppPurchase.instance.queryProductDetails({monthlyProductId, yearlyProductId});
    List<ProductDetails> productDetails = productDetailsResponse.productDetails;

    if(type == SubscriptionType.monthly){
      return productDetails.firstWhere((element) => element.id == monthlyProductId).rawPrice;
    }
    else{
      return productDetails.firstWhere((element) => element.id == yearlyProductId).rawPrice;
    }
  }

  Future<String> getLocalizedPrice(SubscriptionType type) async{
    List<IAPItem> products = await FlutterInappPurchase.instance.getSubscriptions([monthlyProductId, yearlyProductId]);
    IAPItem monthlySubscription = products.firstWhere((product) => product.productId == monthlyProductId);
    IAPItem yearlySubscription = products.firstWhere((product) => product.productId == yearlyProductId);
    if(type == SubscriptionType.monthly){
      return monthlySubscription.localizedPrice ?? "";
    }
    else{
      return yearlySubscription.localizedPrice ?? "";
    }
  }

  void openPlayStoreSubscriptions() async{
    if(activeSubscriptionType != null){
      if(activeSubscriptionType == SubscriptionType.monthly){
        FlutterInappPurchase.instance.manageSubscription(monthlyProductId, "com.lock.focus");
      }
      else{
        FlutterInappPurchase.instance.manageSubscription(yearlyProductId, "com.lock.focus");
      }
    }
    else{
      FlutterInappPurchase.instance.openPlayStoreSubscriptions();
    }
  }

  Future<void> acknowledgeAllPurchases() async{
    List<PurchasedItem>? purchases = await FlutterInappPurchase.instance.getAvailablePurchases();

    if(purchases != null){
      purchases.forEach((element) async{
        await FlutterInappPurchase.instance.acknowledgePurchaseAndroid(element.purchaseToken!);
      });
    }
  }
}

enum SubscriptionType{
  monthly,
  yearly
}