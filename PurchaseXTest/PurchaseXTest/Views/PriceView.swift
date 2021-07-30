//
//  PriceView.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/30.
//

import SwiftUI
import PurchaseX

struct PriceView: View {
    
    @ObservedObject var purchaseXManager = PurchaseXManager()
    
    @State var purchasing: Bool = false
    @State var cancelled: Bool = false
    @State var pending: Bool = false
    @State var failed: Bool = false
    @State var purchased: Bool = false
    
    var product: Product
    
    var body: some View {
        
        let priceViewModel = PriceViewModel(purchaseXManager: purchaseXManager,
                                            purchasing: $purchasing,
                                            cancelled: $cancelled,
                                            pending: $pending,
                                            failed: $failed,
                                            purchased: $purchased)
        
        HStack {
            
            if purchasing {
                ProgressView()
            }
            
            Spacer()
            
            Button {
                purchasing = true
                // start a purchase
                priceViewModel.purchase(product: product)
            } label: {
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

struct PriceView_Previews: PreviewProvider {
    static var previews: some View {
        PriceView(product: Product(pid: "", displayName: "", thumb: "", price: "", type: .Consumable))
    }
}
