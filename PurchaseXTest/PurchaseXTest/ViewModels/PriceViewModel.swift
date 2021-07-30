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
    
    @Binding var purchasing: Bool
    @Binding var cancelled: Bool
    @Binding var pending: Bool
    @Binding var failed: Bool
    @Binding var purchased: Bool
    
    func purchase(product: Product) {
        
        purchaseXManager.purchase(product: purchaseXManager.product(from: product.productID)!) { notification in
            if notification == .purchaseRestoreSuccess {
                updatePurchaseState(state: .complete)
            } else if notification == .purchaseRestoreFailure {
                
            } else if notification == .purchaseSuccess{
                updatePurchaseState(state: .complete)
            } else if notification == .purchaseCancelled {
                updatePurchaseState(state: .cancelled)
            } else if notification == .purchaseFailure {
                updatePurchaseState(state: .failed)
            } else if notification == .purchaseAbort {
                updatePurchaseState(state: .failed)
            } else if notification == .purchasePending {
                updatePurchaseState(state: .pending)
            } else if notification == .purchaseInProgress {
                updatePurchaseState(state: .inProgress)
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
