//
//  PurchaseButton.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/22.
//

import SwiftUI
import PurchaseX
import StoreKit

struct PurchaseButton: View {
    @EnvironmentObject var purchaseXManager:PurchaseXManager
    
    @State var purchasing: Bool = false
    @State var cancelled: Bool = false
    @State var pending: Bool = false
    @State var failed: Bool = false
    @State var purchased: Bool = false
    @State var bageViewSwitch = false
    
    var productID: String
    var price: String
    
    var body: some View {
        let product = purchaseXManager.product(from: productID)
        if product == nil {
            PurchaseErrorView()
        } else {
            HStack {
                if pending && !bageViewSwitch {
                    // failed
                    BadgeView(purchaseState: .pending)
                        .onAppear{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.bageViewSwitch.toggle()
                            }
                    }
                }
                
                if cancelled && !bageViewSwitch {
                    // failed
                    BadgeView(purchaseState: .cancelled)
                        .onAppear{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.bageViewSwitch.toggle()
                            }
                    }
                }
                
                if purchased && !bageViewSwitch {
                    // complete state
                    BadgeView(purchaseState: .complete)
                        .onAppear{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.bageViewSwitch.toggle()
                            }
                    }
                }
                
                Spacer()
        
                PriceView(purchasing: $purchasing,
                          cancelled: $cancelled,
                          pending: $pending,
                          failed: $failed,
                          purchased: $purchased,
                          productID: productID,
                          price: price,
                          product: product!)
            }
            .onAppear {
                Task.init {
                    await purchaseState(product: product!)
                }
            }
            .onChange(of: purchaseXManager.products) { newValue in
                
            }
            .alert(isPresented: $failed) {
                Alert(title: Text("Purchase Error"),
                      message: Text("Sorry, your purchase of \(product!.displayName) failed."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func purchaseState(product: Product) async {
        purchased = (try? await purchaseXManager.isPurchased(productId: productID)) ?? false
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
