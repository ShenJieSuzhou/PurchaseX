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
    
    @ObservedObject var purchaseXManager = PurchaseXManager()
        
    let configProducts:[Product] = [
        Product(pid: "com.purchasex.60", displayName: "60 金币", thumb: "com.purchasex.60", price: "0.99", type: .Consumable),
        Product(pid: "com.purchasex.120", displayName: "120 金币", thumb: "com.purchasex.120", price: "1.99", type: .Consumable),
        Product(pid: "com.purchasex.stylefilter", displayName: "风格滤镜", thumb: "com.purchasex.stylefilter", price: "0.99", type: .Non_Consumable),
        Product(pid: "com.purchase.monthcard", displayName: "月卡", thumb: "com.purchase.monthcard", price: "2.99", type: .Non_Renewing_Subscriptions),
        Product(pid: "com.purchasex.vip1", displayName: "VIP1", thumb: "com.purchasex.vip1", price: "2.99", type: .Auto_Renewable_Subscriptions),
        Product(pid: "com.purchasex.vip2", displayName: "VIP2", thumb: "com.purchasex.vip2", price: "6.99", type: .Auto_Renewable_Subscriptions)
    ]
    
    var body: some View {
        NavigationView {
            if purchaseXManager.hasProducts {
                List {
                    if let products = purchaseXManager.products! {
                        Section(header: Text("Product")) {
                            ///  Display product info, due to SKProduct object cannot get subscription product title, so I get the title via the local config product array.
                            ForEach(0..<products.count) {
                                let product = products[$0]
                                let result = configProducts.filter { p in
                                    return p.productID == product.productIdentifier
                                }
                                ProductView(productId: result[0].productID, displayName: result[0].productName, price: result[0].price)
                            }
                        }
                    }
                }.listStyle(.grouped)
                .navigationTitle("PurchaseX")
            } else {
                Text("No products available")
                    .font(.title)
                    .foregroundColor(.black)
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
            }.listStyle(.grouped)
            .navigationTitle("PurchaseX")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
