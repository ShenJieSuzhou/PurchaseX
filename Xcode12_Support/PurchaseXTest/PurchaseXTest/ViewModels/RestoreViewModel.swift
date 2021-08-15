//
//  RestoreViewModel.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/8/12.
//

import Foundation
import PurchaseX
import SwiftUI

struct RestoreViewModel {
    
    @ObservedObject var purchaseXManager: PurchaseXManager
//    @Binding var restored: Bool
//    @Binding var failed: Bool
    
    func restorePurchase() {
        purchaseXManager.restorePurchase { notification in
            
            switch notification{
            case .purchaseRestoreSuccess:
                updatePurchaseState(state: .complete)
                // validate receipt
                // reload data
                fallthrough
            case .purchaseRestoreFailure:
                updatePurchaseState(state: .failed)
            default:
                break
            }
        }
    }
        
    private func updatePurchaseState(state: PurchaseXState) {
//        failed = state == .failed
//        restored = state == .complete
    }
}
