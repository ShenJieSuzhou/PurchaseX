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
    
    var productID: String
    var displayName: String
    var price: String
    
    var body: some View {
        HStack {
            Image(productID)
                .resizable()
                .frame(width: 75, height: 75)
                .aspectRatio(contentMode: .fit)
            
            Text(displayName)
                .font(.title2)
                .padding()
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            
            Spacer()
            
            PurchaseButton(productID: productID, price: price)
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
