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
                /// validate locally
//                if purchaseXManager.processReceiptLocally() {
//                    updatePurchaseState(state: .complete)
//                    print("验证完毕，给账户增加道具")
//                } else {
//                    updatePurchaseState(state: .failed)
//                    print("验证失败")
//                }
                
                /// validate remotelly                
                purchaseXManager.processReceiptRemotely(shareSecret: "fd4748dc46cc4d75ac86d0d68926ebe9", isSandBox: true) { notification, error in
                    if notification == .receiptValidationSuccess {

                    } else {

                    }
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
