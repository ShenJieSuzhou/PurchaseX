//
//  ConsumableView.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/30.
//

import SwiftUI
import PurchaseX

struct ConsumableView: View {

    @ObservedObject var purchaseXManager: PurchaseXManager
    @State var count: Int = 0

    var product: Product

    var body: some View {
        HStack {
            if count == 0 {
                Image(product.productID)
                    .resizable()
                    .frame(width: 75, height: 80)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(25)
            } else {
                Image(product.productID)
                    .resizable()
                    .frame(width: 75, height: 80)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(25)
                    .overlay(Badge(count: $count))
            }
            
            Text(product.productName)
                .font(.title2)
                .padding()
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            
            Spacer()
            
            PurchaseButton(purchaseXManager: purchaseXManager, product: product)
        }
        .padding()
        .onAppear {
            count = purchaseXManager.count
        }
        .onChange(of: purchaseXManager.products) { _ in
            count = purchaseXManager.count
        }
    }
}

struct Badge: View {
    @Binding var count: Int
    
    var body: some View {
        
        ZStack {
            Capsule()
                .fill(Color.red)
                .frame(width: 30, height: 30, alignment: .topTrailing)
                .position(x: 70, y: 10)
            
            Text(String(count)).foregroundColor(.white)
                .font(Font.system(size: 20).bold()).position(x: 70, y: 10)
        }
    }
}

struct ConsumableView_Previews: PreviewProvider {
    static var previews: some View {
        ConsumableView(purchaseXManager: PurchaseXManager(), product: Product(pid: "", displayName: "", thumb: "", price: "", type: .Consumable))
    }
}
