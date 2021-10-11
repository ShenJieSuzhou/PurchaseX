//
//  PriceViewModel.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/30.
//

import SwiftUI
import StoreKit
import PurchaseX


struct PriceViewModel {
    
    @ObservedObject var purchaseXManager: PurchaseXManager
    
    @Binding var purchasing: Bool
    @Binding var cancelled: Bool
    @Binding var pending: Bool
    @Binding var failed: Bool
    @Binding var purchased: Bool
    
    func purchase(product: Product) async {
        do {
            let result = try await purchaseXManager.purchase(product: product)
            updatePurchaseState(state: result.purchaseState)
        } catch  {
            updatePurchaseState(state: .failed)
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
