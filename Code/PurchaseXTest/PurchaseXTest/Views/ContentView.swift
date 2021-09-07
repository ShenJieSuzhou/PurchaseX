//
//  ContentView.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/20.
//

import SwiftUI
import PurchaseX

/// The main app View
struct ContentView: View {
    
    @EnvironmentObject var purchaseXManager: PurchaseXManager
    @State var restore: Bool = false
    @State var isLoading: Bool = false
        
    let configProducts:[Product] = [
        Product(pid: "com.purchasex.60", displayName: "60 金币", thumb: "com.purchasex.60", price: "0.99", type: .Consumable),
        Product(pid: "com.purchasex.120", displayName: "120 金币", thumb: "com.purchasex.120", price: "1.99", type: .Consumable),
        Product(pid: "com.purchasex.stylefilter", displayName: "风格滤镜", thumb: "com.purchasex.stylefilter", price: "0.99", type: .Non_Consumable),
        Product(pid: "com.purchase.monthcard", displayName: "月卡", thumb: "com.purchase.monthcard", price: "2.99", type: .Non_Renewing_Subscriptions),
        Product(pid: "com.purchasex.vip1", displayName: "VIP1", thumb: "com.purchasex.vip1", price: "2.99", type: .Auto_Renewable_Subscriptions),
        Product(pid: "com.purchasex.vip2", displayName: "VIP2", thumb: "com.purchasex.vip2", price: "6.99", type: .Auto_Renewable_Subscriptions)
    ]
    
    ///  Display product info, due to SKProduct object cannot get subscription product title, so I get the title via the local config product array.
    var nonConsumableProducts: [Product]? {
        let products = purchaseXManager.products
        var targets = [Product]()
        for product in products! {
            if product.productIdentifier == "com.purchasex.stylefilter" {
                let result = configProducts.filter { p in
                    return p.productID == product.productIdentifier
                }
                targets.append(result.first!)
            }
        }
        return targets
    }
    
    var consumableProducts: [Product]? {
        let products = purchaseXManager.products
        var targets = [Product]()
        for product in products! {
            if product.productIdentifier == "com.purchasex.60" || product.productIdentifier == "com.purchasex.120" {
                let result = configProducts.filter { p in
                    return p.productID == product.productIdentifier
                }
                targets.append(result.first!)
            }
        }
        return targets
    }
    
    var noRenewSubscriptionProducts: [Product]? {
        let products = purchaseXManager.products
        var targets = [Product]()
        for product in products! {
            if product.productIdentifier == "com.purchase.monthcard" {
                let result = configProducts.filter { p in
                    return p.productID == product.productIdentifier
                }
                targets.append(result.first!)
            }
        }
        return targets
    }
    
    var autoSubscriptionProducts: [Product]? {
        let products = purchaseXManager.products
        var targets = [Product]()
        for product in products! {
            if product.productIdentifier == "com.purchasex.vip1" || product.productIdentifier == "com.purchasex.vip2" {
                let result = configProducts.filter { p in
                    return p.productID == product.productIdentifier
                }
                targets.append(result.first!)
            }
        }
        return targets
    }
    
    var body: some View {
        NavigationView {
            if purchaseXManager.hasProducts {
                    List {
                        HStack {
                            Spacer()
                            Button {
                                let restoreViewModel = RestoreViewModel(purchaseXManager: purchaseXManager, restored: $restore, isLoading: $isLoading)
                                restoreViewModel.restorePurchase()
                                isLoading.toggle()
                            } label: {
                                Text("Restore")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(height: 40)
                                    .background(Color.blue)
                                    .cornerRadius(25)
                            }
                        }.frame(height: 60)

                        if let consumables = consumableProducts {
                            Section(header: Text("ConsumableProducts")) {
                                ForEach(0..<consumables.count) {
                                    let product = consumables[$0]
                                    ProductView(restore: $restore, product: product)
                                }
                            }
                        }
                        
                        if let nonConsumables = nonConsumableProducts {
                            Section(header: Text("NonConsumableProducts")) {
                                ForEach(0..<nonConsumables.count) {
                                    let product = nonConsumables[$0]
                                    ProductView(restore: $restore, product: product)
                                }
                            }
                        }
                        
                        if let noRenewSubscriptions = noRenewSubscriptionProducts {
                            Section(header: Text("NoRenewSubscriptionProducts")) {
                                ForEach(0..<noRenewSubscriptions.count) {
                                    let product = noRenewSubscriptions[$0]
                                    ProductView(restore: $restore, product: product)
                                }
                            }
                        }
                        
                        if let subscriptions = autoSubscriptionProducts {
                            Section(header: Text("Subscriptions")) {
                                ForEach(0..<subscriptions.count) {
                                    let product = subscriptions[$0]
                                    ProductView(restore: $restore, product: product)
                                }
                            }
                        }
                    }
                    .overlay(LoadingView(isLoading: $isLoading), alignment: .center)
                    .navigationTitle("PurchaseX")
            } else {
                Text("No products available")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
                                                               
struct ContentView_Previews: PreviewProvider {
    
    // Mock data
//    let products:[Product] = [
//        Product(pid: "1", displayName: "60 金币", thumb: "com.purchasex.60", price: "0.99", type: .Consumable),
//        Product(pid: "2", displayName: "120 金币", thumb: "com.purchasex.120", price: "1.99", type: .Consumable),
//        Product(pid: "3", displayName: "风格滤镜", thumb: "com.purchasex.stylefilter", price: "0.99", type: .Non_Consumable),
//        Product(pid: "4", displayName: "月卡", thumb: "com.purchase.monthcard", price: "2.99", type: .Non_Renewing_Subscriptions),
//        Product(pid: "5", displayName: "VIP1", thumb: "com.purchasex.vip1", price: "2.99", type: .Auto_Renewable_Subscriptions),
//        Product(pid: "6", displayName: "VIP2", thumb: "com.purchasex.vip2", price: "6.99", type: .Auto_Renewable_Subscriptions),
//    ]
    
    static var previews: some View {
        @StateObject var purchaseManager = PurchaseXManager()
        return NavigationView {
            List {
                Section(header: Text("Product")) {
                    
                }
            }
            .navigationTitle("PurchaseX")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
