//
//  ProductView.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/21.
//

import SwiftUI
import PurchaseX

struct ProductView: View {
    @EnvironmentObject var purchaseXManager: PurchaseXManager
    @Binding var restore: Bool
    
    var product: Product
    
    var body: some View {
        HStack {
            Image(product.productID)
                .resizable()
                .frame(width: 75, height: 75)
                .aspectRatio(contentMode: .fit)
            
            Text(product.productName)
                .font(.title2)
                .padding()
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            
            Spacer()
            
            PurchaseButton(restore: $restore, product: product)
        }
        .padding()
    }
}

//struct ProductView_Previews: PreviewProvider {
//    static var previews: some View {
//
//         ProductView(product: Product(pid: "1", displayName: "60钻石", thumb: "golden", price: "6 rmb"))
//    }
//}
