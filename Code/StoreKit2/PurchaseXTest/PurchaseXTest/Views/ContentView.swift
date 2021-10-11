//
//  ContentView.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/20.
//

import SwiftUI
import PurchaseX
import StoreKit

/// The main app View
struct ContentView: View {
    
    @EnvironmentObject var purchaseXManager: PurchaseXManager
    @State var restore: Bool = false
    @State var isLoading: Bool = false
        
    let configProducts:[PXProduct] = [
        PXProduct(pid: "com.purchasex.60", displayName: "60 金币", thumb: "com.purchasex.60", price: "0.99"),
        PXProduct(pid: "com.purchasex.120", displayName: "120 金币", thumb: "com.purchasex.120", price: "1.99"),
        PXProduct(pid: "com.purchasex.stylefilter", displayName: "风格滤镜", thumb: "com.purchasex.stylefilter", price: "0.99"),
        PXProduct(pid: "com.purchase.monthcard", displayName: "月卡", thumb: "com.purchase.monthcard", price: "2.99"),
        PXProduct(pid: "com.purchasex.vip1", displayName: "VIP1", thumb: "com.purchasex.vip1", price: "2.99"),
        PXProduct(pid: "com.purchasex.vip2", displayName: "VIP2", thumb: "com.purchasex.vip2", price: "6.99")
    ]
    
    var body: some View {
        NavigationView {
            if purchaseXManager.hasProducts() {
                    List {
//                        HStack {
//                            Spacer()
//                            Button {
//                                let restoreViewModel = RestoreViewModel(purchaseXManager: purchaseXManager, restored: $restore, isLoading: $isLoading)
//                                restoreViewModel.restorePurchase()
//                                isLoading.toggle()
//                            } label: {
//                                Text("Restore")
//                                    .font(.title2)
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .frame(height: 40)
//                                    .background(Color.blue)
//                                    .cornerRadius(25)
//                            }
//                        }.frame(height: 60)

                        if let consumables = purchaseXManager.consumableProducts {
                            Section(header: Text("ConsumableProducts")) {
                                ForEach(consumables, id: \.id) { product in
                                    ProductView(restore: $restore, productID: product.id, displayName: product.displayName, price: product.displayPrice)
                                }
                            }
                        }
                        
                        if let nonConsumables = purchaseXManager.nonConsumbaleProducts {
                            Section(header: Text("NonConsumableProducts")) {
                                ForEach(nonConsumables, id: \.id) { product in
                                    ProductView(restore: $restore, productID: product.id, displayName: product.displayName, price: product.displayPrice)
                                }
                            }
                        }
                        
                        if let noRenewSubscriptions = purchaseXManager.nonSubscriptionProducts {
                            Section(header: Text("NoRenewSubscriptionProducts")) {
                                ForEach(noRenewSubscriptions, id: \.id) { product in
                                    ProductView(restore: $restore, productID: product.id, displayName: product.displayName, price: product.displayPrice)
                                }
                            }
                        }
                        
                        if let subscriptions = purchaseXManager.subscriptionProducts {
                            Section(header: Text("Subscriptions")) {
                                ForEach(subscriptions, id: \.id) { product in
                                    ProductView(restore: $restore, productID: product.id, displayName: product.displayName, price: product.displayPrice)
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
        .onAppear {
            purchaseXManager.requestProductsFromAppstore(productIds: ["com.purchasex.60", "com.purchasex.120", "com.purchasex.stylefilter", "com.purchase.monthcard", "com.purchasex.vip1", "com.purchasex.vip2"])
        }
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
