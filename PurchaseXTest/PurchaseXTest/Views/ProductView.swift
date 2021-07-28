//
//  ProductView.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/21.
//

import SwiftUI

struct ProductView: View {
    
    var productId: String
    var displayName: String
    var price: String
    
    
    var body: some View {
        HStack {
            Image(productId)
                .resizable()
                .frame(width: 75, height: 75)
                .aspectRatio(contentMode: .fit)
            
            Text(displayName)
                .font(.title2)
                .padding()
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            
            Text(price)
                .font(.title3)
                .padding()
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            
            Spacer()
            
            PurchaseButton(price: price, productId: productId)
        }
    }
}

//struct ProductView_Previews: PreviewProvider {
//    static var previews: some View {
//
//         ProductView(product: Product(pid: "1", displayName: "60钻石", thumb: "golden", price: "6 rmb"))
//    }
//}
