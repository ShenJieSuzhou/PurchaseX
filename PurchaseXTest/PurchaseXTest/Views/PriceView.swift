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
        
        HStack {
            
            if purchasing {
                ProgressView()
            }
            
            Spacer()
            
            Button {
                purchasing = true
                // purchase 
            } label: {
                Text(product.price)
            }

        }
    }
}

struct PriceView_Previews: PreviewProvider {
    static var previews: some View {
        PriceView(product: Product(pid: "", displayName: "", thumb: "", price: "", type: .Consumable))
    }
}
