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
    
    @ObservedObject var purchaseXManager: PurchaseXManager
    
    @Binding var purchasing: Bool
    @Binding var cancelled: Bool
    @Binding var pending: Bool
    @Binding var failed: Bool
    @Binding var purchased: Bool
    
    
    func purchase(product: Product) {
        
        purchaseXManager.purchase(product: purchaseXManager.product(from: product.productID)!) { notification in
            if notification == .purchaseSuccess{
                if purchaseXManager.processReceipt() {
                    updatePurchaseState(state: .complete)
                    print("验证完毕，给账户增加道具")
                } else {
                    print("验证失败")
                }
            } else if notification == .purchaseCancelled {
                updatePurchaseState(state: .cancelled)
            } else if notification == .purchaseFailure {
                updatePurchaseState(state: .failed)
            } else if notification == .purchaseAbort {
                updatePurchaseState(state: .failed)
            } else if notification == .purchasePending {
                updatePurchaseState(state: .pending)
            }
        }
    }
    
    private func updatePurchaseState(state: PurchaseXState) {
        purchasing = false
        cancelled = state == .cancelled
        pending = state == .pending
        failed = state == .failed
        purchased = state == .complete
    }
}
