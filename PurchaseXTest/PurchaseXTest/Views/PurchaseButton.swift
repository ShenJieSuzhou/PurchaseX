//
//  PurchaseButton.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/22.
//

import SwiftUI

struct PurchaseButton: View {
    
    var price: String
    var product: Product?
    
    var body: some View {
        if product == nil {
            PurchaseErrorView()
        } else {
            HStack {
                
            }
        }
    }
}

struct PurchaseButton_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseButton(price: "0.99", product: Product(pid: "", displayName: "", thumb: "", price: "", type: .Non_Consumable))
    }
}
