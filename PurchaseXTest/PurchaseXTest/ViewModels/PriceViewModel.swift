//
//  PriceViewModel.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/30.
//

import Foundation
import SwiftUI
import PurchaseX


struct PriceViewModel {
    
    @ObservedObject var purchaseXManager = PurchaseXManager()
    
    @State var purchasing: Bool = false
    @State var cancelled: Bool = false
    @State var pending: Bool = false
    @State var failed: Bool = false
    @State var purchased: Bool = false
    
    func purchase(product: Product) {
        
        purchaseXManager.purchase(product: purchaseXManager.product(from: product.productID)!) { notification in
            if notification == .purchaseRestoreSuccess(productId: product.productID) {
                updatePurchaseState(state: .complete)
            } else {
                
            }
        }
    }
    
    private func updatePurchaseState(state: PurchaseXState) {
        purchasing = false
        cancelled = state == .cancelld
        pending = state == .pending
        failed = state == .failed
        purchased = state == .complete
    }
}
