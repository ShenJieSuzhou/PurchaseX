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
        
//        purchaseXManager.requestProductsFromAppstore { notification in
//            if notification == .requestProductsStarted {
//
//            } else if notification == .receiptValidationSuccess {
//
//            } else if notification == .requestProductsFailure {
//
//            } else if notification == .requestProductsDidFinish {
//
//            } else if notification == .requestProductsNoProduct {
//
//            } else if notification == .requestProductsInvalidProducts {
//
//            }
//        }
        
//        purchaseXManager.purchase(product: purchaseXManager.product(from: product.productID)!) { notification in
//            if notification == .purchaseSuccess{
//                updatePurchaseState(state: .complete)
//            } else if notification == .purchaseCancelled {
//                updatePurchaseState(state: .cancelled)
//            } else if notification == .purchaseFailure {
//                updatePurchaseState(state: .failed)
//            } else if notification == .purchaseAbort {
//                updatePurchaseState(state: .failed)
//            } else if notification == .purchasePending {
//                updatePurchaseState(state: .pending)
//            }
//        }
        
//        purchaseXManager.rece
        purchaseXManager.purchase(product: purchaseXManager.product(from: product.productID)!) { notification in
            if notification == .purchaseSuccess{
                /// validate locally
//                purchaseXManager.validateReceiptLocally { validateResult in
//                    switch validateResult {
//                    case .success(let receipt):
//                        updatePurchaseState(state: .complete)
//                    case .error(let error):
//                        updatePurchaseState(state: .failed)
//                    }
//                }
                /// validate remotelly
                purchaseXManager.validateReceiptRemotely(shareSecret: "", isSandBox: true) { validateResult in
                    switch validateResult {
                    case .success(let receipt):
                        updatePurchaseState(state: .complete)
                    case .error(let error):
                        updatePurchaseState(state: .failed)
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
