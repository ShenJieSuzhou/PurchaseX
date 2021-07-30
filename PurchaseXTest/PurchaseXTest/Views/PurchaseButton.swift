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
                // complete state
                BadgeView(purchaseState: .complete)
            } else {
                if cancelled {
                    BadgeView(purchaseState: .cancelled)
                }
                
                if pending {
                    BadgeView(purchaseState: .pending)
                }
                
                PriceView(purchasing: $purchasing,
                          cancelled: $cancelled,
                          pending: $pending,
                          failed: $failed,
                          purchased: $purchased,
                          product: product)
            }
        }
        .onAppear {
            
        }
        .onChange(of: purchaseXManager.products) { newValue in
            
        }
        .alert(isPresented: $failed) {
            Alert(title: Text("Purchase Error"),
                  message: Text("Sorry, your purchase of \(product.productName) failed."),
                  dismissButton: .default(Text("OK")))
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
