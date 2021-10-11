//
//  PriceView.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/30.
//

import SwiftUI
import PurchaseX
import StoreKit

struct PriceView: View {
    @EnvironmentObject var purchaseXManager: PurchaseXManager
    @Binding var purchasing: Bool
    @Binding var cancelled: Bool
    @Binding var pending: Bool
    @Binding var failed: Bool
    @Binding var purchased: Bool

    
    var productID: String
    var price: String
    var product: Product
    
    var body: some View {
        
        let priceViewModel = PriceViewModel(purchaseXManager: purchaseXManager,
                                            purchasing: $purchasing,
                                            cancelled: $cancelled,
                                            pending: $pending,
                                            failed: $failed,
                                            purchased: $purchased)
        
        HStack {
//            if restore && purchaseXManager.isPurchased(productId: product.productID) && product.type == .Non_Consumable{
//                Text("Free")
//                    .font(.title2)
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(height: 40)
//                    .background(Color.gray)
//                    .cornerRadius(25)
//            } else {
}
//            }
        
            Button {
                purchasing = true
                purchased = false
                // start a purchase
                Task.init{
                    await priceViewModel.purchase(product: product)
                }
            } label: {
                Text(price)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(height: 40)
                    .background(Color.blue)
                    .cornerRadius(25)
        
        }
    }
}

struct PriceView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ProgressView()
            Spacer()
            Button(action: {}) {
                Text("£1.99")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(height: 40)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
        .padding()
    }
}
