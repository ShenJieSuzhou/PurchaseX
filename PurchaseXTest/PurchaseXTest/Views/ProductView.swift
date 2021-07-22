//
//  ProductView.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/21.
//

import SwiftUI

struct ProductView: View {
    
    var product: Product
    
    
    var body: some View {
        HStack {
            Image(product.image)
                .resizable()
                .frame(width: 75, height: 75)
                .aspectRatio(contentMode: .fit)
            
            Text(product.productName)
                .font(.title2)
                .padding()
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            
            Text(product.price)
                .font(.title3)
                .padding()
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            
            
        }
    }
}

//struct ProductView_Previews: PreviewProvider {
//    static var previews: some View {
//
//         ProductView(product: Product(pid: "1", displayName: "60钻石", thumb: "golden", price: "6 rmb"))
//    }
//}
