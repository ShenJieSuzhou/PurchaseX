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
    
    @State var purchasing: Bool = false
    @State var cancelled: Bool = false
    @State var pending: Bool = false
    @State var failed: Bool = false
    @State var purchased: Bool = false
    
    var product: Product
    
    var body: some View {
        HStack {
            if purchased, product.type != .Consumable {
                
            } else {
                if cancelled {
                    
                }
                
                if pending {
                    
                }
                
                
            }
            
            Spacer()
            Button(action: {
                
            }) {
                Text(product.price)
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
