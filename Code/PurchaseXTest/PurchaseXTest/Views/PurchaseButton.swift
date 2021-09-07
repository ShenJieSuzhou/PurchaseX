//
//  PurchaseButton.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/22.
//

import SwiftUI
import PurchaseX

struct PurchaseButton: View {
    @EnvironmentObject var purchaseXManager:PurchaseXManager
    @Binding var restore: Bool
    
    @State var purchasing: Bool = false
    @State var cancelled: Bool = false
    @State var pending: Bool = false
    @State var failed: Bool = false
    @State var purchased: Bool = false
    @State var bageViewSwitch = false
    
    var product: Product
    
    var body: some View {
        HStack {
            if purchasing {
                ProgressView()
            }
            
            if failed && !bageViewSwitch {
                // failed
                BadgeView(purchaseState: .failed)
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
                      bageViewSwitch: $bageViewSwitch,
                      restore: $restore, product: product)
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
