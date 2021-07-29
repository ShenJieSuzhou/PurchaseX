//
//  PurchaseButton.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/22.
//

import SwiftUI
import PurchaseX

struct PurchaseButton: View {
    @ObservedObject var purchaseXManager = PurchaseXManager()
    
    var purchasing: Bool = false
    var cancelled: Bool = false
    var pending: Bool = false
    var failed: Bool = false
    var purchased: Bool = false
    
    var price: String
    var productId: String
    
    var body: some View {
        let product = purchaseXManager.product(from: productId)
        if product == nil {
            PurchaseErrorView()
        } else {
            HStack {
                Spacer()
                Button(action: {
                    
                }) {
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
    }
}

struct PurchaseButton_Previews: PreviewProvider {
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
